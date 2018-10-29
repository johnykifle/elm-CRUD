module Main exposing (init, main, subscriptions)

import Browser
import Browser.Navigation as Nav exposing (Key)
import Html exposing (Html, a, button, div, form, input, li, section, span, text, ul)
import Html.Attributes exposing (attribute, class, href, id, placeholder, type_)
import Pages.Edit
import Pages.List
import Pages.Posts
import Player exposing (fetchPlayers)
import Posts exposing (fetchPosts)
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
    case Debug.log "the msg " msg of
        OnFetchPosts (Ok posts) ->
            ( { model | posts = Loaded posts }, Cmd.none )

        OnFetchPosts (Err err) ->
            ( { model | posts = Failure }, Cmd.none )

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

        OnPlayerSave (Ok player) ->
            ( updatePlayerInModel player model, Cmd.none )

        OnPlayerSave (Err error) ->
            ( model, Cmd.none )


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
            postsPageWithData model

        PlayersRoute ->
            Pages.List.view players

        PlayerRoute id ->
            Pages.Edit.view players id

        NotFoundRoute ->
            notFoundView


postsPageWithData : Model -> Html Msg
postsPageWithData model =
    case model.posts of
        NotAsked ->
            text "Not found"

        Loading ->
            text " Loading posts "

        Loaded posts ->
            Pages.Posts.view posts

        Failure ->
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
