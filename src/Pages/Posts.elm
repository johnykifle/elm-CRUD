module Pages.Posts exposing (view)

import Html exposing (Html, a, button, div, i, table, tbody, td, text, th, thead, tr)
import Html.Attributes exposing (class, href)
import Routes
import Shared exposing (Msg(..), Post)



view : List Post -> Html Msg
view posts =
    div []
        [ a [ href "/" ] [ text "Back-Home" ]
        , table []
            [ thead []
                [ tr []
                    [ th [] [ text "Id" ]
                    , th [] [ text "Title" ]
                    , th [] [ text "Author-Name" ]
                    , th [] [ text "Action" ]
                    ]
                ]
            , tbody [] (List.map postRow posts)
            ]
        ]


postRow : Post -> Html Msg
postRow post =
    tr []
        [ td [] [ text post.id ]
        , td [] [ text post.title ]
        , td [] [ text post.author.name ]
        , td [] [ editBtn post ]
        ]


editBtn : Post -> Html Msg
editBtn post =
    let
        path =
            Routes.postPath post.id
    in
    a
        [ class "btn regular"
        , href path
        ]
        [ i [ class "fa fa-edit " ] []
        , text "Edit"
        ]
