module Page.FileList exposing (Model, Msg, view, initialModel, initialCommand, update)

import Session exposing (Session)
import Html exposing (..)
import Html.Attributes exposing (..)
import List
import Api
import Http
import Router


type alias Model =
    { session : Session
    , fileNames : List String
    }


type Msg
    = LoadFiles
    | FilesReceved (Result Http.Error (List String))


update : Model -> Msg -> ( Model, Cmd Msg )
update model msg =
    case msg of
        LoadFiles ->
            ( model, Cmd.none )

        FilesReceved (Ok files) ->
            ( { model | fileNames = files }, Cmd.none )

        FilesReceved (Err _) ->
            ( model, Cmd.none )


initialModel : Session -> Model
initialModel session =
    { session = session
    , fileNames = []
    }


initialCommand : Cmd Msg
initialCommand =
    Http.send FilesReceved Api.fileList


view : Model -> Html msg
view model =
    div [] (List.map fileHtml model.fileNames)


fileHtml : String -> Html msg
fileHtml file =
    a [ Router.href (Router.FileDetails file) ]
        [ div [ class "card fluid" ]
            [ h3 [] [ text file ] ]
        ]
