module Players.Edit exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class)
import Msgs exposing (Msg)
import Models exposing (Model)


view : Model -> Html Msg
view model =
    div []
        [ nav model
        , form model
        ]


nav : Model -> Html Msg
nav model =
    div [ class "clearfix mb2 white bg-black p1" ]
        []


form : Model -> Html Msg
form player =
    div [ class "m3" ]
        [ h1 [] [ "o kurde" ]
        ]

