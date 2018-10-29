module Routes exposing (homePath, matchers, parseUrl, pathFor, playerPath, playersPath)

import Shared exposing (..)
import Url exposing (Url)
import Url.Parser exposing (..)


matchers : Parser (Route -> a) a
matchers =
    oneOf
        [ map HomeRoute top
        , map PlayerRoute (s "players" </> string)
        , map PlayersRoute (s "players")
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

        PlayersRoute ->
            "/players"

        PlayerRoute id ->
            "/players/" ++ id

        NotFoundRoute ->
            "/"


homePath =
    pathFor HomeRoute


playersPath =
    pathFor PlayersRoute


playerPath id =
    pathFor (PlayerRoute id)
