module Login exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput, onClick)
import Http
import Json.Decode as Decode
import Json.Encode as Encode
import Browser
import Browser.Navigation as Navigation


main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }


-- MODEL


type alias Model =
    { signUpName : String
    , signUpPassword : String
    , signUpPasswordAgain : String
    , signInName : String
    , signInPassword : String
    , message : String
    }


type alias Response =
    { message : String }

type alias TokenResponse =
    { message : String, token : String }


init : () -> (Model, Cmd Msg)
init flags =
    (Model "" "" "" "" "" "", Cmd.none)


translateSignedUp : Model -> String
translateSignedUp model =
    case model.message of
        "signed up" ->
            "You've been signed up! Go ahead and sign in!"

        "already signed up" ->
            "That account has already been signed up. Go ahead and sign in!"

        "password incorrect" ->
            "The username or password you put in is incorrect, please try again."

        "not signed up" ->
            "The username you entered is not registered. Go ahead and sign up to make an account!"

        _ ->
            ""



-- UPDATE


signUp : Model -> Cmd Msg
signUp model =
    Http.send PostSignUp (Http.post "/signup" (Http.jsonBody (encodeSignUp model)) decodeResponse)

        
decodeResponse : Decode.Decoder Response
decodeResponse =
    Decode.map Response (Decode.field "message" Decode.string)
        

encodeSignUp : Model -> Encode.Value
encodeSignUp model =
    Encode.object
        [ ( "username", Encode.string model.signUpName )
        , ( "password", Encode.string model.signUpPassword )
        ]


signIn : Model -> Cmd Msg
signIn model =
    Http.send PostSignIn (Http.post "/signin" (Http.jsonBody (encodeSignIn model)) decodeTokenResponse)

        
decodeTokenResponse : Decode.Decoder TokenResponse
decodeTokenResponse =
    Decode.map2 TokenResponse
        (Decode.field "message" Decode.string)
        (Decode.field "token" Decode.string)
        

encodeSignIn : Model -> Encode.Value
encodeSignIn model =
    Encode.object
        [ ( "username", Encode.string model.signInName )
        , ( "password", Encode.string model.signInPassword )
        ]
        

errorToString : Http.Error -> String
errorToString error =
    case error of
        Http.BadStatus e ->
            ("Error Status: " ++ e.status.message)

        Http.BadPayload message _ ->
            ("Bad Payload: " ++ message)                

        _ ->
            "error"

type Msg
    = SignUpName String
    | SignUpPassword String
    | SignUpPasswordAgain String
    | SignInName String
    | SignInPassword String
    | SignUp
    | SignIn
    | PostSignUp (Result Http.Error Response)
    | PostSignIn (Result Http.Error TokenResponse)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SignUpName name ->
            ( { model | signUpName = name }, Cmd.none )

        SignUpPassword password ->
            ( { model | signUpPassword = password }, Cmd.none )

        SignUpPasswordAgain password ->
            ( { model | signUpPasswordAgain = password }, Cmd.none )

        SignInName name ->
            ( { model | signInName = name }, Cmd.none )

        SignInPassword password ->
            ( { model | signInPassword = password }, Cmd.none )

        SignUp ->
            ( model, signUp model )

        PostSignUp (Ok response) ->
            ( { model | message = response.message }, Cmd.none )

        PostSignUp (Err error) ->
            ( { model | message = (errorToString error) }, Cmd.none )

        SignIn ->
            ( model, signIn model )

        PostSignIn (Ok response) ->
            ( { model | message = response.message }, toDogePark response.token )

        PostSignIn (Err error) ->
            ( { model | message = (errorToString error) }, Cmd.none )


toDogePark : String -> Cmd Msg
toDogePark token =
    case token of
        "403 Forbidden" ->
            Cmd.none

        _ ->
            Navigation.load ( "/dogepark?token=" ++ token )



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ signUpView model
        , signInView model
        , text (translateSignedUp model)
        ]


signInView : Model -> Html Msg
signInView model =
    div []
        [ h2 [] [ text "Sign In" ]
        , input [ type_ "text", placeholder "Name", onInput SignInName ] []
        , input [ type_ "password", placeholder "Password", onInput SignInPassword ] []
        , button [ onClick SignIn ] [ text "Sign In" ]
        ]


signUpView : Model -> Html Msg
signUpView model =
    div []
        [ h2 [] [ text "Sign Up" ]
        , input [ type_ "text", placeholder "Name", onInput SignUpName ] []
        , input [ type_ "password", placeholder "Password", onInput SignUpPassword ] []
        , input [ type_ "password", placeholder "Re-enter Password", onInput SignUpPasswordAgain ] []
        , button [ onClick SignUp ] [ text "Sign Up" ]
        , viewValidation model
        ]


viewValidation : Model -> Html msg
viewValidation model =
    let
        ( color, message ) =
            if model.signUpPassword == "" && model.signUpPasswordAgain == "" then
                ( "black", "" )
            else if model.signUpPassword == model.signUpPasswordAgain then
                ( "green", "OK" )
            else
                ( "red", "Passwords do not match!" )
    in
        div [ style "color" color ] [ text message ]
