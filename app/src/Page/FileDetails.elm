module Page.FileDetails exposing (..)

import Session exposing (Session)
import Http
import Api
import Html exposing (..)
import Json.Decode
import Json.Encode
import Html.Events
import Html.Attributes
import Debug exposing (log)


type alias Model =
    { session : Session
    , fileContent : String
    }


type Msg
    = FileLoaded (Result Http.Error String)
    | CodeChanged String


initialModel : Session -> Model
initialModel session =
    { session = session, fileContent = "" }


initialCmd : String -> Cmd Msg
initialCmd fileName =
    Http.send FileLoaded (Api.getFile fileName)


update : Model -> Msg -> ( Model, Cmd Msg )
update model msg =
    case msg of
        FileLoaded (Ok file) ->
            ( { model | fileContent = file }, Cmd.none )

        FileLoaded (Err e) ->
            ( model, Cmd.none )

        CodeChanged str ->
            let
                a =
                    log str
            in
                ( { model | fileContent = str }, Cmd.none )


view : Model -> Html Msg
view model =
    div []
        [ Html.node "code-mirror-editor"
            [ Html.Attributes.property "editorValue" <| Json.Encode.string model.fileContent
            , Html.Events.on "editorChanged" <|
                Json.Decode.map CodeChanged <|
                    Json.Decode.at [ "target", "editorValue" ] <|
                        Json.Decode.string
            ]
            []
        ]
