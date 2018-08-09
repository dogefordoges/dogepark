module DogePark exposing (..)

import Html exposing (..)
import Model exposing (Model, Flags, Msg, init)
import Update exposing (update)
import View exposing (view)

subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none

main : Program Flags Model Msg
main =
    Html.programWithFlags
        { init = init
        , subscriptions = subscriptions
        , update = update
        , view = view
        }
