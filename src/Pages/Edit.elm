module Pages.Edit exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Types exposing (..)

view : Post -> Html Msg
view post =
    div []
        [ h3 [] [ text "Edit page"]
        , editForm post
        ]

editForm : Post -> Html Msg
editForm post =
    Html.Form []
        [ div []
            [ text "Title"
            , br [] []
            , input
                [ type_ "text"
                , value post.title
                ]
                []
            ]
        , br [] []
        , div []
            [ text "Author Name"
            , br [] []
            , input
                [ type_ "text"
                , value post.author.name
                ]
                []
            ]
        , br [] []
        , div []
            [ text "Author URL"
            , br [] []
            , input
                [ type_ "text"
                , value post.author.url
                ]
                []
            ]
        , br [] []
        , div []
            [ button []
                [ text "Submit" ]
            ]

        ]
