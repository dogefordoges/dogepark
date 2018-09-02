module DogePark exposing (..)

import Html exposing (..)
import Model exposing (Model, Flags, Msg, init)
import Update exposing (update)
import View exposing (view)
import Browser

main =
    Browser.element
        { init = init
        , subscriptions = \_-> Sub.none
        , update = update
        , view = view
        }
