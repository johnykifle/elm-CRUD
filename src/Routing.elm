module Routing exposing (..)

import Browser.Navigation exposing (..)
import Url exposing (Url)
import Types exposing (..)
import Url.Parser as Parser exposing ((</>), Parser, oneOf, s, int, top, map, string)

extractRoute : Url -> Route
extractRoute url =
    case (Parser.parse matchRoute url) of
        Just route ->
            route
        
        Nothing ->
            NotFoundRoute
        

matchRoute : Parser (Route -> a) a
matchRoute =
    oneOf
        [ map PostsRoute top
        , map PostsRoute (s "posts")
        , map PostRoute (s "posts" </> int)
        ]
