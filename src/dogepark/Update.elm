module Update exposing (..)

import Model exposing (..)

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        WithdrawalAddress address ->
            ( { model | withdrawalAddress = address }, Cmd.none )

        WithdrawalAmount amount ->
            ( { model | withdrawalAmount = Maybe.withDefault 0 (String.toFloat amount) }, Cmd.none )

        Withdraw ->
            ( model, withdraw model )

        SendWithdraw (Ok message) ->
            ( { model | withdrawMessage = message }, getBalance model.token )

        SendWithdraw (Err error) ->
            ( { model | withdrawMessage = (errorToString error) }, Cmd.none )

        RefreshBalance ->
            ( model, getBalance model.token )

        UpdateBalance (Ok balance) ->
            ( { model | balance = balance }, Cmd.none )

        UpdateBalance (Err error) ->
            ( model, Cmd.none )

        RainAmount amount ->
            ( { model | rainAmount = Maybe.withDefault 0 (String.toFloat amount) }, Cmd.none )

        RainRadius radius ->
            ( { model | rainRadius = Maybe.withDefault 0 (String.toFloat radius) }, Cmd.none )

        Rain ->
            ( model, sendRain model )

        SendRain (Ok message) ->
            ( { model | rainMessage = message }, getBalance model.token )

        SendRain (Err error) ->
            ( { model | rainMessage = (errorToString error) }, Cmd.none )

        RefreshRainLogs ->
            ( model, getRainLogs model.token )

        UpdateRainLogs (Ok logs) ->
            ( { model | rainLogs = logs }, Cmd.none )

        UpdateRainLogs (Err _) ->
            ( model, Cmd.none )

        BowlAmount amount ->
            ( { model | bowlAmount = Maybe.withDefault 0 (String.toFloat amount) }, Cmd.none )

        BiteAmount amount ->
            ( { model | biteAmount = Maybe.withDefault 0 (String.toFloat amount) }, Cmd.none )

        Bowl ->
            ( model, newBowl model )

        NewBowl (Ok message) ->
            ( { model | bowlMessage = message }, Cmd.batch [ (getBalance model.token), (getBowls model.token) ] )

        NewBowl (Err error) ->
            ( { model | bowlMessage = (errorToString error) }, Cmd.none )

        BowlCode code ->
            ( { model | bowlCode = code }, Cmd.none )

        RedeemBowl ->
            ( model, bite model )

        Bite (Ok message) ->
            ( { model | redeemMessage = message }, getBalance model.token )

        Bite (Err error) ->
            ( { model | redeemMessage = (errorToString error) }, Cmd.none )

        Password password ->
            ( { model | password = password }, Cmd.none )

        UpdateBowls (Ok bowls) ->
            ( { model | bowls = bowls }, Cmd.none )

        UpdateBowls (Err _) ->
            ( model, Cmd.none )

        Price (Ok cryptonatorResult) ->
            ( { model | price = Maybe.withDefault 0 (String.toFloat cryptonatorResult.ticker.price) }, Cmd.none )

        Price (Err error) ->
            ( model, Cmd.none )
