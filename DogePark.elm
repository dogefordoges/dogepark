module Main exposing (..)

import Geolocation exposing (Location)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput, onClick)
import Task


-- MODEl


type alias Model =
    { location : Result Geolocation.Error (Maybe Location)
    , address : String
    , balance : Float
    , withdrawalAddress : String
    , withdrawalAmount : Float
    , rainAmount : Float
    , rainRadius : Float
    , bowlAmount : Float
    , bowlCode : String
    }


type alias ShibeLocation =
    { latitude : Float, longitude : Float }


init : ( Model, Cmd Msg )
init =
    ( { location = Ok Nothing
      , address = "0x123456789123456789123456789123456789"
      , balance = 420.4242424242442
      , withdrawalAddress = ""
      , withdrawalAmount = 0
      , rainAmount = 0
      , rainRadius = 0
      , bowlAmount = 0
      , bowlCode = ""
      }
    , Task.attempt UpdateLocation Geolocation.now
    )

    
defaultShibeLocation : ShibeLocation
defaultShibeLocation =
    { latitude = 0, longitude = 0 }

        
toShibeLocation : Location -> ShibeLocation
toShibeLocation loc =
    { latitude = loc.latitude, longitude = loc.longitude }

        
handleLocation : Model -> ShibeLocation
handleLocation model =
    case model.location of
        Ok loc ->
            (Maybe.withDefault defaultShibeLocation (Maybe.map toShibeLocation loc))

        Err _ ->
            defaultShibeLocation


-- UPDATE


type Msg
    = UpdateLocation (Result Geolocation.Error Location)
    | WithdrawalAddress String
    | WithdrawalAmount String
    | Withdraw
    | RainAmount String
    | RainRadius String
    | Rain
    | BowlAmount String
    | NewBowl
    | BowlCode String
    | RedeemBowl


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UpdateLocation result ->
            ( { model | location = Result.map Just result }, Cmd.none )

                
        WithdrawalAddress address ->
            ( { model | withdrawalAddress = address }, Cmd.none )

                
        WithdrawalAmount amount ->
            ( { model | withdrawalAmount = Result.withDefault 0 (String.toFloat amount) }, Cmd.none )


        Withdraw ->
            ( model, Cmd.none )
                

        RainAmount amount ->
            ( { model | rainAmount = Result.withDefault 0 (String.toFloat amount) }, Cmd.none )


        RainRadius radius ->
            ( { model | rainRadius = Result.withDefault 0 (String.toFloat radius) }, Cmd.none )


        Rain ->
            (model, Cmd.none)


        BowlAmount amount ->
            ( { model | bowlAmount = Result.withDefault 0 (String.toFloat amount) }, Cmd.none )


        NewBowl ->
            (model, Cmd.none)


        BowlCode code ->
            ( { model | bowlCode = code }, Cmd.none )


        RedeemBowl ->
            ( model, Cmd.none)


-- SUBSCRIPTION                


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ h1 [] [ text "Welcome Shibe!" ]
        , walletView model
        , rainView model
        , bowlView model
        ]


walletView : Model -> Html Msg
walletView model =
    div []
        [ h1 [] [ text "Wallet" ]
        , h2 [] [ text ("address: " ++ model.address) ]
        , h2 [] [ text ("balance: " ++ (toString model.balance) ++ " Ð") ]
        , input [ type_ "withdrawalAddress", placeholder "Withdrawal Address", onInput WithdrawalAddress ] []
        , input [ type_ "withdrawalAmount", placeholder "Withdrawal Amount", onInput WithdrawalAmount ] []
        , button [ onClick Withdraw ] [ text "Withdraw" ]
        ]
       

rainView : Model -> Html Msg
rainView model =
    let
        l = handleLocation model
    in  
        div []
            [ h1 [] [ text "Rain" ]
            , h2 [] [ text ("latitude: " ++ (toString l.latitude)) ]
            , h2 [] [ text ("longitude: " ++ (toString l.longitude)) ]
            , input [ type_ "rainAmount", placeholder "Rain Amount", onInput RainAmount ] []
            , input [ type_ "rainRadius", placeholder "Rain Radius", onInput RainRadius ] []
            , button [ onClick Rain ] [ text "Rain" ]
            ]


bowlView : Model -> Html Msg
bowlView model =
    div []
        [ h1 [] [ text "Bowl" ]
        , input [ type_ "bowlAmount", placeholder "Bowl Amount", onInput BowlAmount ] []
        , button [ onClick NewBowl ] [ text "New Bowl" ]
        , input [ type_ "bowlCode", placeholder "Bowl Code", onInput BowlCode ] []
        , button [ onClick RedeemBowl ] [ text "Redeem Bowl" ]
        ]
              
        
main : Program Never Model Msg
main =
    Html.program
        { init = init
        , subscriptions = subscriptions
        , update = update
        , view = view
        }
