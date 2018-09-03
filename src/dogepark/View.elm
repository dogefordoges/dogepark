module View exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput, onClick)
import Model exposing (..)

view : Model -> Html Msg
view model =
    div []
        [ h1 [] [ text "Welcome Shibe!" ]
        , physicalLocationView model
        , walletView model
        , rainView model
        , bowlView model
        ]

physicalLocationView : Model -> Html Msg
physicalLocationView model =
                     div []
                         [ h1 [] [ text "Location" ]
                         , h2 [] [ text ("Latitude: " ++ (String.fromFloat model.physicalLocation.latitude)) ]
                         , h2 [] [ text ("Longitude: " ++ (String.fromFloat model.physicalLocation.latitude)) ]
                         , h2 [] [ text ("Street Address: " ++ model.physicalLocation.address) ]
                         ]


walletView : Model -> Html Msg
walletView model =
    div []
        [ h1 [] [ text "Wallet" ]
        , h2 [] [ text ("1 Ð = $" ++ (String.fromFloat model.price)) ]
        , h2 [] [ text ("Public Key: " ++ model.publicKey) ]
        , div []
            [ h2 [] [ text ("balance: " ++ (String.fromFloat model.balance) ++ " Ð") ]
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
        div []
            [ h1 [] [ text "Rain" ]
            , h2 [] [ text ("latitude: 0.0") ]
            , h2 [] [ text ("longitude: 0.0") ]
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
        [ button [ ] [ text "Save Location" ]
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
        , text ("Amount: " ++ (String.fromFloat bowlData.bowlAmount))
        ]


passwordView : Html Msg
passwordView =
    input [ type_ "password", placeholder "Password", onInput Password ] []
