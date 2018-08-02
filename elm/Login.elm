module Login exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput)
import Crypto.Hash exposing (sha512)


main =
    Html.beginnerProgram { model = model, view = view, update = update }



-- MODEL
    
type alias Model =
    { signUpName : String
    , signUpPassword : String
    , signUpPasswordAgain : String
    , signInName : String
    , signInPassword : String
    }


model : Model
model =
    Model "" "" "" "" ""

-- UPDATE


type Msg
    = SignUpName String
    | SignUpPassword String
    | SignUpPasswordAgain String
    | SignInName String
    | SignInPassword String


update : Msg -> Model -> Model
update msg model =
    case msg of
        SignUpName name ->
            { model | signUpName = name }

        SignUpPassword password ->
            { model | signUpPassword = password }

        SignUpPasswordAgain password ->
            { model | signUpPasswordAgain = password }

        SignInName name ->
            { model | signInName = name }

        SignInPassword password ->
            { model | signInPassword = password }
                

-- VIEW

view : Model -> Html Msg
view model =
    div [] [ signUpView model, signInView model ]

signInView : Model -> Html Msg
signInView model =
    div []        
        [ h2 [] [text "Sign In"]
        , input [ type_ "text", placeholder "Name", onInput SignInName ] []
        , input [ type_ "password", placeholder "Password", onInput SignInPassword ] []
        , a [ href ("/signin" ++ (urlParams model.signInName model.signInPassword)) ] [ text "Sign In" ]
        ]        

signUpView : Model -> Html Msg
signUpView model =
    div []        
        [ h2 [] [text "Sign Up"]
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
