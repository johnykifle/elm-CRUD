module Pages.EditPost exposing (view)

import Html exposing (Html, button, div, input, text)
import Html.Attributes exposing (type_, value)
import Html.Events exposing (onClick, onInput)
import Shared exposing (Model, Msg(..), Post)


view : String -> List Post -> Html Msg
view id posts =
    let
        filteredPosts =
            findPostById id posts

        post =
            List.head filteredPosts
    in
    case post of
        Just curretPost ->
            Html.form []
                [ div []
                    [ div [] [ text curretPost.id ]
                    , input
                        [ type_ "text"
                        , value curretPost.title
                        , onInput (UpdateTitle curretPost.id)
                        ]
                        []
                    ]
                ]

        Nothing ->
            div []
                [ text "post not found" ]


findPostById : String -> List Post -> List Post
findPostById id posts =
    List.filter (\x -> x.id == id) posts
