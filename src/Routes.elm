module Routes exposing (homePath, matchers, parseUrl, pathFor, playerPath, playersPath, postPath, postsPath, elmCssPath)

import Shared exposing (..)
import Url exposing (Url)
import Url.Parser exposing (..)


matchers : Parser (Route -> a) a
matchers =
    oneOf
        [ map HomeRoute top
        , map PlayerRoute (s "players" </> string)
        , map PlayersRoute (s "players")
        , map PostRoute (s "posts" </> string)
        , map PostsRoute (s "posts")
        , map ElmCssRoute (s "elm-css")
        ]


parseUrl : Url -> Route
parseUrl url =
    case parse matchers url of
        Just route ->
            route

        Nothing ->
            NotFoundRoute


pathFor : Route -> String
pathFor route =
    case route of
        HomeRoute ->
            "/"

        PostsRoute ->
            "/posts"

        PostRoute id ->
            "/posts/" ++ id

        PlayersRoute ->
            "/players"

        PlayerRoute id ->
            "/players/" ++ id

        ElmCssRoute ->
            "/elm-css"

        NotFoundRoute ->
            "/"


homePath =
    pathFor HomeRoute


playersPath =
    pathFor PlayersRoute


playerPath id =
    pathFor (PlayerRoute id)


postsPath =
    pathFor PostsRoute


postPath id =
    pathFor (PostRoute id)


elmCssPath =
    pathFor ElmCssRoute
