module Page.FileDetails exposing (..)

import Session exposing (Session, navKey)
import Http
import Api
import Html exposing (..)
import Json.Decode
import Json.Encode
import Html.Events
import Html.Attributes exposing(..)
import Debug exposing (log)
import Router


type alias Model =
    { session : Session
    , fileContent : String
    , fileName : String
    }


type Msg
    = FileLoaded (Result Http.Error String)
    | CodeChanged String
    | UpdateFile
    | FileUpdated (Result Http.Error Api.OkResult)
    | DeleteFile
    | FileDeleted (Result Http.Error Api.OkResult)


initialModel : Session -> String -> Model
initialModel session fileName =
    { session = session
    , fileName = fileName
    , fileContent = ""
    }


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
            ( { model | fileContent = str }, Cmd.none )

        UpdateFile ->
            ( model, Http.send FileUpdated (Api.updateFile model.fileName model.fileContent) )

        FileUpdated _ ->
            ( model, Cmd.none )

        DeleteFile ->
            ( model, Http.send FileDeleted (Api.deleteFile model.fileName) )

        FileDeleted _ ->
            ( model, Router.navigate (navKey model.session) Router.FileList )


view : Model -> Html Msg
view model =
    div []
        [ button [ Html.Events.onClick UpdateFile, class "primary" ] [ text "update" ]
        , button [ Html.Events.onClick DeleteFile, class "secondary" ] [ text "delete" ]
        , editor model
        ]


editor : Model -> Html Msg
editor model =
    Html.node "code-mirror-editor"
        [ Html.Attributes.property "editorValue" <| Json.Encode.string model.fileContent
        , Html.Events.on "editorChanged" <|
            Json.Decode.map CodeChanged <|
                Json.Decode.at [ "target", "editorValue" ] <|
                    Json.Decode.string
        ]
        []
