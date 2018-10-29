module Pages.Posts exposing (view)

import Html exposing (Html, div, table, tbody, td, text, th, thead, tr)
import Routes
import Shared exposing (Msg(..), Post)


view : List Post -> Html Msg
view posts =
    table []
        [ thead []
            [ tr []
                [ th [] [ text "Id" ]
                , th [] [ text "Title" ]
                , th [] [ text "Author-Name" ]
                ]
            ]
        , tbody [] (List.map postRow posts)
        ]


postRow : Post -> Html Msg
postRow post =
    tr []
        [ td [] [ text (String.fromInt post.id) ]
        , td [] [ text post.title ]
        , td [] [ text post.author.name ]
        ]
