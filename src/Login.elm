module Login exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput, onClick)
import Http
import Json.Decode as Decode
import Json.Encode as Encode
import Navigation


main =
    program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- SUBSCRIPTION


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



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
    { message : String, url : String }


init : ( Model, Cmd Msg )
init =
    ( Model "" "" "" "" "" "", Cmd.none )


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


encodeSignUp : Model -> Encode.Value
encodeSignUp model =
    Encode.object
        [ ( "username", Encode.string model.signUpName )
        , ( "password", Encode.string model.signUpPassword )
        ]


signIn : Model -> Cmd Msg
signIn model =
    Http.send PostSignIn (Http.post "/signin" (Http.jsonBody (encodeSignIn model)) decodeResponse)


encodeSignIn : Model -> Encode.Value
encodeSignIn model =
    Encode.object
        [ ( "username", Encode.string model.signInName )
        , ( "password", Encode.string model.signInPassword )
        ]


decodeResponse : Decode.Decoder Response
decodeResponse =
    Decode.map2 Response (Decode.field "message" Decode.string) (Decode.field "url" Decode.string)


errorToString : Http.Error -> String
errorToString error =
    case error of
        Http.BadStatus e ->
            ("Error: " ++ (toString e.status.code) ++ " " ++ e.body)

        _ ->
            (toString error)


type Msg
    = SignUpName String
    | SignUpPassword String
    | SignUpPasswordAgain String
    | SignInName String
    | SignInPassword String
    | SignUp
    | SignIn
    | PostSignUp (Result Http.Error Response)
    | PostSignIn (Result Http.Error Response)


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
            ( { model | message = response.message }, toDogePark response.url )

        PostSignIn (Err error) ->
            ( { model | message = (errorToString error) }, Cmd.none )


toDogePark : String -> Cmd Msg
toDogePark url =
    case url of
        "none" ->
            Cmd.none

        _ ->
            Navigation.load url



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
        div [ style [ ( "color", color ) ] ] [ text message ]


urlParams : String -> String -> String
urlParams name password =
    "?username=" ++ name ++ "&password=" ++ password