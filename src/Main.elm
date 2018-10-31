module Main exposing (init, main, subscriptions)

import Browser
import Browser.Navigation as Nav exposing (Key)
import Error exposing (createErrorMessage)
import Html exposing (Html, a, button, div, form, input, li, section, span, text, ul)
import Html.Attributes exposing (attribute, class, href, id, placeholder, type_)
import Pages.Edit
import Pages.EditPost
import Pages.List
import Pages.Posts
import Player exposing (fetchPlayers)
import Posts exposing (fetchPosts, savePostCmd)
import RemoteData exposing (WebData)
import Routes
import Shared exposing (..)
import Url exposing (Url)


type alias Flags =
    {}


init : Flags -> Url -> Key -> ( Model, Cmd Msg )
init flags url key =
    let
        currentRoute =
            Routes.parseUrl url
    in
    ( initialModel currentRoute key, Cmd.batch [ fetchPlayers, fetchPosts ] )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SendHttpRequest ->
            ( { model | posts = RemoteData.Loading }, fetchPosts )

        OnFetchPosts response ->
            ( { model | posts = response }, Cmd.none )

        OnFetchPlayers (Ok players) ->
            ( { model | players = Loaded players }, Cmd.none )

        OnFetchPlayers (Err err) ->
            ( { model | players = Failure }, Cmd.none )

        OnUrlRequest urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model
                    , Nav.pushUrl model.key (Url.toString url)
                    )

                Browser.External url ->
                    ( model
                    , Nav.load url
                    )

        OnUrlChange url ->
            let
                newRoute =
                    Routes.parseUrl url
            in
            ( { model | route = newRoute }, Cmd.none )

        ChangeLevel player howMuch ->
            let
                updatedPlayer =
                    { player | level = player.level + howMuch }
            in
            ( model, Player.savePlayerCmd updatedPlayer )

        OnPostSave (Ok post) ->
            let
                _ =
                    Debug.log "posting save " post
            in
            ( model, Cmd.none )

        OnPostSave (Err error) ->
            let
                _ =
                    Debug.log "issue" error
            in
            ( model, Cmd.none )

        OnPlayerSave (Ok player) ->
            ( updatePlayerInModel player model, Cmd.none )

        OnPlayerSave (Err error) ->
            ( model, Cmd.none )

        UpdateTitle postId newTitle ->
            let
                pick post =
                    if post.id == postId then
                        { post | title = newTitle }

                    else
                        post

                posts =
                    getPosts model.posts

                editPost =
                    posts
                        |> List.filter (\x -> x.id == postId)
                        |> List.head
                        

                updatedPosts =
                    List.map pick posts
            in
            ( { model | posts = convertToWebData updatedPosts }, savePostCmd editPost )


getPosts : WebData (List Post) -> List Post
getPosts remoteDataPosts =
    case remoteDataPosts of
        RemoteData.Success posts ->
            posts

        _ ->
            []


convertToWebData : List Post -> WebData (List Post)
convertToWebData posts =
    RemoteData.Success posts


updatePlayerInModel : Player -> Model -> Model
updatePlayerInModel player model =
    let
        updatedPlayers =
            mapRemoteData (updatePlayerInList player) model.players
    in
    { model | players = updatedPlayers }


updatePlayerInList : Player -> List Player -> List Player
updatePlayerInList player players =
    let
        pick currentPlayer =
            if currentPlayer.id == player.id then
                player

            else
                currentPlayer
    in
    List.map pick players



-- MAIN


main : Program Flags Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlRequest = OnUrlRequest
        , onUrlChange = OnUrlChange
        }



-- VIEWS


view : Model -> Browser.Document Msg
view model =
    { title = "App"
    , body = [ page model ]
    }


page : Model -> Html Msg
page model =
    let
        content =
            case model.players of
                NotAsked ->
                    text ""

                Loading ->
                    text "Loading ..."

                Loaded players ->
                    pageWithData model players

                Failure ->
                    text "Error"
    in
    section []
        [ nav model
        , div [ class "p-4" ] [ content ]
        ]


pageWithData : Model -> List Player -> Html Msg
pageWithData model players =
    case model.route of
        HomeRoute ->
            div []
                [ horizontalNav model ]

        PostsRoute ->
            postsPageWithData Nothing model

        PostRoute id ->
            postsPageWithData (Just id) model

        PlayersRoute ->
            Pages.List.view players

        PlayerRoute id ->
            Pages.Edit.view players id

        NotFoundRoute ->
            notFoundView


postsPageWithData : Maybe PostId -> Model -> Html Msg
postsPageWithData id model =
    case model.posts of
        RemoteData.NotAsked ->
            text "Not found"

        RemoteData.Loading ->
            text " Loading posts "

        RemoteData.Success posts ->
            case id of
                Just postId ->
                    Pages.EditPost.view postId posts

                Nothing ->
                    Pages.Posts.view posts

        RemoteData.Failure _ ->
            text "Error"


horizontalNav : Model -> Html Msg
horizontalNav model =
    div
        [ class "mb-2 text-white bg-black p-4" ]
        [ a [ href Routes.homePath, class "text-white" ] [ text "Home" ]
        , text "  -  "
        , a [ href Routes.playersPath, class "text-white" ] [ text "Players" ]
        , text " - "
        , a [ href Routes.postsPath, class "text-white" ] [ text "Posts" ]
        ]


nav : Model -> Html Msg
nav model =
    let
        links =
            case model.route of
                HomeRoute ->
                    [ homeToNav ]

                PostsRoute ->
                    [ postsLink ]

                PostRoute _ ->
                    [ text "post detail " ]

                PlayersRoute ->
                    [ text "Players" ]

                PlayerRoute _ ->
                    [ linkToList ]

                NotFoundRoute ->
                    [ linkToList ]

        linkToList =
            a [ href Routes.playersPath, class "text-white" ] [ text "List" ]

        homeToNav =
            a [ href Routes.homePath, class "text-white" ] [ text "Home" ]

        postsLink =
            a [ href Routes.postsPath, class "text-white" ] [ text "Posts" ]
    in
    div
        [ class "mb-2 text-white bg-black p-4" ]
        links


notFoundView : Html msg
notFoundView =
    div []
        [ text "Not found"
        ]
