module Page.LoginPage exposing (..)

import Html exposing (..)
import Session exposing (Session)
import Html.Attributes exposing (..)
import Html.Events exposing (onSubmit, onInput, onClick)
import Router exposing (Route(..), navigate)
import Url
import Session exposing (navKey)
import Api
import Http


type Status
    = Initial
    | Error String
    | Loading


type alias Model =
    { session : Session
    , login : String
    , password : String
    , status : Status
    }


initialModel : Session -> Model
initialModel session =
    { session = session, login = "", password = "", status = Initial }


type Msg
    = SubmitForm
    | UpdateLogin String
    | UpdatePassword String
    | ComplitedLogin (Result Http.Error Api.OkResult)


update : Model -> Msg -> ( Model, Cmd Msg )
update model msg =
    case msg of
        SubmitForm ->
            ( { model | status = Loading }, Api.login model.password |> Http.send ComplitedLogin )

        UpdateLogin login ->
            ( { model | login = login }, Cmd.none )

        UpdatePassword password ->
            ( { model | password = password }, Cmd.none )

        ComplitedLogin (Ok _) ->
            ( model, navigate (navKey model.session) FileList )

        ComplitedLogin (Err _) ->
            ( { model | status = Error "invalid secret" }, Cmd.none )


view : Model -> Html Msg
view model =
    div [ class "login-page" ]
        [ loginForm model ]


loginForm : Model -> Html Msg
loginForm model =
    Html.form [ onSubmit SubmitForm ]
        [ fieldset []
            [ legend []
                [ text "Login" ]
            , div []
                [ case model.status of
                    Error errormMsg ->
                        label [ class "text-danger" ] [ text errormMsg ]

                    _ ->
                        text ""
                ]
            , div [ class "input-group" ]
                [ label []
                    [ text "Secret"
                    , input [ value model.password, onInput UpdatePassword, placeholder "Secret", type_ "password" ]
                        []
                    ]
                ]
            , button [ class "large primary login-button" ]
                [ if model.status == Loading then
                    div [] [ div [ class "spinner secondary" ] [] ]
                  else
                    div [] [ text "Login" ]
                ]
            ]
        ]
