module App exposing (main)

import Browser
import State exposing (init, update)
import Pages.List exposing (view)
import Types exposing (..)

main : Program () Model Msg
main =
 Browser.element
  { init = init
  , update = update
  , view = view
  , subscriptions = \_ -> Sub.none
  }
