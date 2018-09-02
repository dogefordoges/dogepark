module Model exposing (..)

import Http
import Task
import Json.Decode as Decode
import Json.Encode as Encode

type alias Flags =
    { token : String }


type alias BowlData =
    { bowlCode : String, bowlAmount : Float }


type alias Model =
    { 
    address : String
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
    , price : Float
    , physicalLocation : PhysicalLocation
    }


type alias PhysicalLocation =
     { latitude: Float, longitude: Float, address: String }

        
type Msg
    = 
    WithdrawalAddress String
    | WithdrawalAmount String
    | Withdraw
    | SendWithdraw (Result Http.Error String)
    | RefreshBalance
    | UpdateBalance (Result Http.Error Float)
    | RainAmount String
    | RainRadius String
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
    | Price (Result Http.Error CryptonatorResult)
    | GetLocation (Result Http.Error PhysicalLocation)

      
init : Flags -> ( Model, Cmd Msg )
init flags =
    ( { address = "0xNotAnAddress"
      , balance = 0
      , withdrawalAddress = ""
      , withdrawalAmount = 0
      , rainAmount = 0
      , rainRadius = 0
      , bowlAmount = 0
      , bowlCode = ""
      , biteAmount = 0
      , username = "Not a user name"
      , password = ""
      , locationMessage = "If you want to receive doge from local rain events, you have to save your current location at least once. "
      , withdrawMessage = ""
      , rainMessage = ""
      , bowlMessage = "You can create a bowl for other shibes to get bites out of. Set the total amount, and the bite size for each shibe."
      , redeemMessage = "If you know a bowl code, go ahead and try to receive some free doge!"
      , rainLogs = []
      , bowls = []
      , token = flags.token
      , price = 0
      , physicalLocation = { latitude = 0.0
                           , longitude = 0.0
                           , address = "Not available"
                           }
      }
    , Cmd.batch
        [ getBalance flags.token
        , getRainLogs flags.token
        , getBowls flags.token
        , getDogePrice
        , getLocation
        ]
    )

getBalance : String -> Cmd Msg
getBalance token =
    Http.send UpdateBalance (Http.get ( "/balance?token=" ++ token ) decodeBalance)


decodeBalance : Decode.Decoder Float
decodeBalance =
    Decode.field "balance" Decode.float


getRainLogs : String -> Cmd Msg
getRainLogs token =
    Http.send UpdateRainLogs (Http.get ("/rainlogs?token=" ++ token) decodeRainLogs)


decodeRainLogs : Decode.Decoder (List String)
decodeRainLogs =
    Decode.field "rainLogs" (Decode.list Decode.string)


getBowls : String -> Cmd Msg
getBowls token =
    Http.send UpdateBowls (Http.get ("/bowls?token=" ++ token) decodeBowls)


decodeBowls : Decode.Decoder (List BowlData)
decodeBowls =
    Decode.field "bowls" (Decode.list (Decode.map2 BowlData (Decode.field "bowlCode" Decode.string) (Decode.field "bowlAmount" Decode.float)))


getLocation : Cmd Msg
getLocation =
            Http.send GetLocation (Http.get "/location" decodeLocation)


decodeLocation : Decode.Decoder PhysicalLocation
decodeLocation =
               Decode.map3 PhysicalLocation
                           (Decode.field "latitude" Decode.float)
                           (Decode.field "longitude" Decode.float)
                           (Decode.field "address" Decode.string)


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


sendRain : Model -> Cmd Msg
sendRain model =
    Http.send SendRain (Http.post "/rain" (Http.jsonBody (encodeRainPost model)) decodeMessage)


encodeRainPost : Model -> Encode.Value
encodeRainPost model =
        Encode.object
            [ ( "username", Encode.string model.username )
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
            ("Error: " ++ (String.fromInt e.status.code) ++ " " ++ e.body)

        Http.BadPayload message _ ->
            ("Bad Payload: " ++ message)
            
        _ ->
            "error"

-- Cryptonator API
-- https://api.cryptonator.com/api/ticker/doge-usd

type alias CryptonatorTicker =
     { base : String
     , target : String
     , price : String
     , volume : String
     , change : String
     }

type alias CryptonatorResult =
     { ticker : CryptonatorTicker
     , timestamp : Int
     , success : Bool
     , error : String
     }

getDogePrice : Cmd Msg
getDogePrice =
             Http.send Price (Http.get "https://api.cryptonator.com/api/ticker/doge-usd" decodeCryptonatorResult)

decodeCryptonatorTicker : Decode.Decoder CryptonatorTicker
decodeCryptonatorTicker =
                        Decode.map5 CryptonatorTicker
                                ( Decode.field "base" Decode.string )
                                ( Decode.field "target" Decode.string )
                                ( Decode.field "price" Decode.string )
                                ( Decode.field "volume" Decode.string )
                                ( Decode.field "change" Decode.string )

decodeCryptonatorResult : Decode.Decoder CryptonatorResult
decodeCryptonatorResult =
                        Decode.map4 CryptonatorResult
                                ( Decode.field "ticker" decodeCryptonatorTicker )
                                ( Decode.field "timestamp" Decode.int )
                                ( Decode.field "success" Decode.bool )
                                ( Decode.field "error" Decode.string )
