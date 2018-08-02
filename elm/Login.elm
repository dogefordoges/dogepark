module Login exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput)
import Crypto.Hash exposing (sha512)


main =
    programWithFlags
        { init = model
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


-- SUBSCRIPTION


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


-- MODEL


type alias Flags =
    { signedUp : String }


type alias Model =
    { signUpName : String
    , signUpPassword : String
    , signUpPasswordAgain : String
    , signInName : String
    , signInPassword : String
    , signedUp : String
    }


model : Flags -> ( Model, Cmd Msg )
model flags =
    ( Model "" "" "" "" "" flags.signedUp, Cmd.none )


translateSignedUp : Model -> String
translateSignedUp model =
    case model.signedUp of
        "signed up" ->
            "You've been signed up! Go ahead and log in!"

        "password incorrect" ->
            "The username or password you put in is incorrect, please try again."

        "not signed up" ->
            "The username you entered is not registered. Go ahead and sign up to make an account!"

        _ ->
            ""


-- UPDATE


type Msg
    = SignUpName String
    | SignUpPassword String
    | SignUpPasswordAgain String
    | SignInName String
    | SignInPassword String


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
        , a [ href ("/signin" ++ (urlParams model.signInName model.signInPassword)) ] [ text "Sign In" ]
        ]


signUpView : Model -> Html Msg
signUpView model =
    div []
        [ h2 [] [ text "Sign Up" ]
        , input [ type_ "text", placeholder "Name", onInput SignUpName ] []
        , input [ type_ "password", placeholder "Password", onInput SignUpPassword ] []
        , input [ type_ "password", placeholder "Re-enter Password", onInput SignUpPasswordAgain ] []
        , a [ href ("/signup" ++ (urlParams model.signUpName model.signUpPassword)) ] [ text "Sign Up" ]
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
        div [ style [ ( "color", color ) ] ] [ text message ]


urlParams : String -> String -> String
urlParams name password =
    "?username=" ++ (sha512 name) ++ "&password=" ++ (sha512 password)
