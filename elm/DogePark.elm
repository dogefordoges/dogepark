module DogePark exposing (..)

import Geolocation exposing (Location)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput, onClick)
import Task
import Http
import Json.Decode as Decode
import Json.Encode as Encode


-- MODEl


type alias Flags =
    { address : String
    , username : String
    , token : String
    }


type alias BowlData =
    { bowlCode : String, bowlAmount : Float }


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
    , biteAmount : Float
    , username : String
    , locationMessage : String
    , password : String
    , withdrawMessage : String
    , rainMessage : String
    , bowlMessage : String
    , redeemMessage : String
    , rainLogs : List String
    , bowls : List BowlData
    , token : String
    }


type alias ShibeLocation =
    { latitude : Float, longitude : Float }


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( { location = Ok Nothing
      , address = flags.address
      , balance = 0
      , withdrawalAddress = ""
      , withdrawalAmount = 0
      , rainAmount = 0
      , rainRadius = 0
      , bowlAmount = 0
      , bowlCode = ""
      , biteAmount = 0
      , username = flags.username
      , password = ""
      , locationMessage = "If you want to receive doge from local rain events, you have to save your current location at least once. "
      , withdrawMessage = ""
      , rainMessage = ""
      , bowlMessage = "You can create a bowl for other shibes to get bites out of. Set the total amount, and the bite size for each shibe."
      , redeemMessage = "If you know a bowl code, go ahead and try to receive some free doge!"
      , rainLogs = []
      , bowls = []
      , token = flags.token
      }
    , Cmd.batch
        [ Task.attempt UpdateLocation Geolocation.now
        , getBalance flags.address flags.token
        , getRainLogs flags.username flags.token
        , getBowls flags.address flags.token
        ]
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


getBalance : String -> String -> Cmd Msg
getBalance address token =
    Http.send UpdateBalance (Http.get ("/balance?address=" ++ address ++ "&token=" ++ token ) decodeBalance)


decodeBalance : Decode.Decoder Float
decodeBalance =
    Decode.field "balance" Decode.float


getRainLogs : String -> String -> Cmd Msg
getRainLogs username token =
    Http.send UpdateRainLogs (Http.get ("/rainlogs?username=" ++ username ++ "&token=" ++ token) decodeRainLogs)


decodeRainLogs : Decode.Decoder (List String)
decodeRainLogs =
    Decode.field "rainLogs" (Decode.list Decode.string)


getBowls : String -> String -> Cmd Msg
getBowls address token =
    Http.send UpdateBowls (Http.get ("/bowls?address=" ++ address ++ "&token=" ++ token) decodeBowls)


decodeBowls : Decode.Decoder (List BowlData)
decodeBowls =
    Decode.field "bowls" (Decode.list (Decode.map2 BowlData (Decode.field "bowlCode" Decode.string) (Decode.field "bowlAmount" Decode.float)))


withdraw : Model -> Cmd Msg
withdraw model =
    Http.send SendWithdraw (Http.post "/withdraw" (Http.jsonBody (encodeWithdrawPost model)) decodeMessage)


encodeWithdrawPost : Model -> Encode.Value
encodeWithdrawPost model =
    Encode.object
        [ ( "username", Encode.string model.username )
        , ( "password", Encode.string model.password )
        , ( "address", Encode.string model.address )
        , ( "withdrawAddress", Encode.string model.withdrawalAddress )
        , ( "amount", Encode.float model.withdrawalAmount )
        , ( "token", Encode.string model.token )
        ]


persistLocation : Model -> Cmd Msg
persistLocation model =
    Http.send PersistLocation (Http.post "/location" (Http.jsonBody (encodeLocationPost model)) decodeMessage)


encodeLocationPost : Model -> Encode.Value
encodeLocationPost model =
    let
        l =
            handleLocation model
    in
        Encode.object
            [ ( "latitude", Encode.float l.latitude )
            , ( "longitude", Encode.float l.longitude )
            , ( "username", Encode.string model.username )
            , ( "password", Encode.string model.password )
            , ( "token", Encode.string model.token )
            ]


sendRain : Model -> Cmd Msg
sendRain model =
    Http.send SendRain (Http.post "/rain" (Http.jsonBody (encodeRainPost model)) decodeMessage)


encodeRainPost : Model -> Encode.Value
encodeRainPost model =
    let
        l =
            handleLocation model
    in
        Encode.object
            [ ( "latitude", Encode.float l.latitude )
            , ( "longitude", Encode.float l.longitude )
            , ( "username", Encode.string model.username )
            , ( "password", Encode.string model.password )
            , ( "address", Encode.string model.address )
            , ( "amount", Encode.float model.rainAmount )
            , ( "radius", Encode.float model.rainRadius )
            , ( "token", Encode.string model.token )
            ]


newBowl : Model -> Cmd Msg
newBowl model =
    Http.send NewBowl (Http.post "/bowl" (Http.jsonBody (encodeBowlPost model)) decodeMessage)


encodeBowlPost : Model -> Encode.Value
encodeBowlPost model =
    Encode.object
        [ ( "username", Encode.string model.username )
        , ( "password", Encode.string model.password )
        , ( "address", Encode.string model.address )
        , ( "bowlAmount", Encode.float model.bowlAmount )
        , ( "biteAmount", Encode.float model.biteAmount )
        , ( "token", Encode.string model.token )
        ]


bite : Model -> Cmd Msg
bite model =
    Http.send Bite (Http.post "/bite" (Http.jsonBody (encodeBitePost model)) decodeMessage)


encodeBitePost : Model -> Encode.Value
encodeBitePost model =
    Encode.object
        [ ( "address", Encode.string model.address )
        , ( "bowlCode", Encode.string model.bowlCode )
        , ( "token", Encode.string model.token )
        ]


decodeMessage : Decode.Decoder String
decodeMessage =
    Decode.field "message" Decode.string


errorToString : Http.Error -> String
errorToString error =
    case error of
        Http.BadStatus e ->
            ("Error: " ++ (toString e.status.code) ++ " " ++ e.body)

        _ ->
            "Error"



-- UPDATE


type Msg
    = UpdateLocation (Result Geolocation.Error Location)
    | WithdrawalAddress String
    | WithdrawalAmount String
    | Withdraw
    | SendWithdraw (Result Http.Error String)
    | RefreshBalance
    | UpdateBalance (Result Http.Error Float)
    | RainAmount String
    | RainRadius String
    | SaveLocation
    | PersistLocation (Result Http.Error String)
    | Rain
    | SendRain (Result Http.Error String)
    | RefreshRainLogs
    | UpdateRainLogs (Result Http.Error (List String))
    | BowlAmount String
    | BiteAmount String
    | Bowl
    | NewBowl (Result Http.Error String)
    | BowlCode String
    | RedeemBowl
    | Bite (Result Http.Error String)
    | Password String
    | UpdateBowls (Result Http.Error (List BowlData))


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
            ( model, withdraw model )

        SendWithdraw (Ok message) ->
            ( { model | withdrawMessage = message }, getBalance model.address model.token )

        SendWithdraw (Err error) ->
            ( { model | withdrawMessage = (errorToString error) }, Cmd.none )

        RefreshBalance ->
            ( model, getBalance model.address model.token )

        UpdateBalance (Ok balance) ->
            ( { model | balance = balance }, Cmd.none )

        UpdateBalance (Err error) ->
            ( model, Cmd.none )

        RainAmount amount ->
            ( { model | rainAmount = Result.withDefault 0 (String.toFloat amount) }, Cmd.none )

        RainRadius radius ->
            ( { model | rainRadius = Result.withDefault 0 (String.toFloat radius) }, Cmd.none )

        Rain ->
            ( model, sendRain model )

        SendRain (Ok message) ->
            ( { model | rainMessage = message }, getBalance model.address model.token )

        SendRain (Err error) ->
            ( { model | rainMessage = (errorToString error) }, Cmd.none )

        RefreshRainLogs ->
            ( model, getRainLogs model.username model.token )

        UpdateRainLogs (Ok logs) ->
            ( { model | rainLogs = logs }, Cmd.none )

        UpdateRainLogs (Err _) ->
            ( model, Cmd.none )

        SaveLocation ->
            ( model, persistLocation model )

        PersistLocation (Ok message) ->
            ( { model | locationMessage = message }, Cmd.none )

        PersistLocation (Err error) ->
            ( { model | locationMessage = (errorToString error) }, Cmd.none )

        BowlAmount amount ->
            ( { model | bowlAmount = Result.withDefault 0 (String.toFloat amount) }, Cmd.none )

        BiteAmount amount ->
            ( { model | biteAmount = Result.withDefault 0 (String.toFloat amount) }, Cmd.none )

        Bowl ->
            ( model, newBowl model )

        NewBowl (Ok message) ->
            ( { model | bowlMessage = message }, Cmd.batch [ (getBalance model.address model.token), (getBowls model.address model.token) ] )

        NewBowl (Err error) ->
            ( { model | bowlMessage = (errorToString error) }, Cmd.none )

        BowlCode code ->
            ( { model | bowlCode = code }, Cmd.none )

        RedeemBowl ->
            ( model, bite model )

        Bite (Ok message) ->
            ( { model | redeemMessage = message }, getBalance model.address model.token )

        Bite (Err error) ->
            ( { model | redeemMessage = (errorToString error) }, Cmd.none )

        Password password ->
            ( { model | password = password }, Cmd.none )

        UpdateBowls (Ok bowls) ->
            ( { model | bowls = bowls }, Cmd.none )

        UpdateBowls (Err _) ->
            ( model, Cmd.none )


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
        , div []
            [ h2 [] [ text ("balance: " ++ (toString model.balance) ++ " Ð") ]
            , button [ onClick RefreshBalance ] [ text "Refresh Balance" ]
            ]
        , input [ type_ "withdrawalAddress", placeholder "Withdrawal Address", onInput WithdrawalAddress ] []
        , input [ type_ "withdrawalAmount", placeholder "Withdrawal Amount", onInput WithdrawalAmount ] []
        , passwordView
        , button [ onClick Withdraw ] [ text "Withdraw" ]
        , text model.withdrawMessage
        ]


rainView : Model -> Html Msg
rainView model =
    let
        l =
            handleLocation model
    in
        div []
            [ h1 [] [ text "Rain" ]
            , h2 [] [ text ("latitude: " ++ (toString l.latitude)) ]
            , h2 [] [ text ("longitude: " ++ (toString l.longitude)) ]
            , saveLocationView model
            , input [ type_ "rainAmount", placeholder "Rain Amount", onInput RainAmount ] []
            , input [ type_ "rainRadius", placeholder "Rain Radius", onInput RainRadius ] []
            , passwordView
            , button [ onClick Rain ] [ text "Rain" ]
            , text model.rainMessage
            , button [ onClick RefreshRainLogs ] [ text "Refresh Rain Logs" ]
            , div [] (List.map rainLogView model.rainLogs)
            ]


rainLogView : String -> Html Msg
rainLogView log =
    div [] [ text log ]


saveLocationView : Model -> Html Msg
saveLocationView model =
    div []
        [ button [ onClick SaveLocation ] [ text "Save Location" ]
        , text model.locationMessage
        ]


bowlView : Model -> Html Msg
bowlView model =
    div []
        [ h1 [] [ text "Bowl" ]
        , h2 [] [ text "Make New Bowl" ]
        , text model.bowlMessage
        , div []
            [ input [ type_ "bowlAmount", placeholder "Bowl Amount", onInput BowlAmount ] []
            , input [ type_ "biteAmount", placeholder "Bite Amount", onInput BiteAmount ] []
            , passwordView
            , button [ onClick Bowl ] [ text "New Bowl" ]
            ]
        , h2 [] [ text "Redeem Bowl" ]
        , text model.redeemMessage
        , div []
            [ input [ type_ "bowlCode", placeholder "Bowl Code", onInput BowlCode ] []
            , button [ onClick RedeemBowl ] [ text "Redeem Bowl" ]
            ]
        , div [] (List.map bowlDataView model.bowls)
        ]


bowlDataView : BowlData -> Html Msg
bowlDataView bowlData =
    div []
        [ text ("Bowl Code: " ++ bowlData.bowlCode ++ " ")
        , text ("Amount: " ++ (toString bowlData.bowlAmount))
        ]


passwordView : Html Msg
passwordView =
    input [ type_ "password", placeholder "Password", onInput Password ] []


main : Program Flags Model Msg
main =
    Html.programWithFlags
        { init = init
        , subscriptions = subscriptions
        , update = update
        , view = view
        }
