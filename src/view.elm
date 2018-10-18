module View exposing (..)

import Html exposing (Html, h3, text)
import Types exposing (..)
import RemoteData exposing (WebData)
import Pages.List
import Pages.Edit

view : Model -> Html Msg
view model =
    case model.currentRoute of
        PostsRoute ->
            Views.List.view model

        PostsRoute id ->
            case findPostById id model.posts of
                Just post ->
                    Views.Edit.view model

                Nothing ->
                    notFoundView

        NotFoundRoute ->
            notFoundView

findPostById : Int -> WebData (List Post) -> Maybe Post
findPostById postId posts =
    case RemoteData.toMaybe posts of
        Just posts ->
            posts
                |> List.filter (\post -> post.id == postId)
                |> List.head
        Nothing ->
            Nothing

notFoundView : Html msg
notFoundView =
    h3 [] [ text "Oops! The page you requested was not found!" ]
