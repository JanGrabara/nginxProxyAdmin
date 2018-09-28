module Page.FileList exposing (Model, Msg, view, initialModel, initialCommand, update)

import Session exposing (Session, navKey)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events
import Html.Events
import List
import Api
import Http
import Router

type alias Model =
    { session : Session
    , fileNames : List String
    , newFileName : String
    }


type Msg
    = LoadFiles
    | FilesReceved (Result Http.Error (List String))
    | CreateNewFile
    | UpdateCreateNewFile String


update : Model -> Msg -> ( Model, Cmd Msg )
update model msg =
    case msg of
        LoadFiles ->
            ( model, Cmd.none )

        FilesReceved (Ok files) ->
            ( { model | fileNames = files }, Cmd.none )

        FilesReceved (Err _) ->
            ( model, Cmd.none )

        CreateNewFile ->
            ( model, Router.navigate (navKey model.session) (Router.FileDetails model.newFileName True) )

        UpdateCreateNewFile name ->
            ( { model | newFileName = name }, Cmd.none )


initialModel : Session -> Model
initialModel session =
    { session = session
    , fileNames = []
    , newFileName = ""
    }


initialCommand : Cmd Msg
initialCommand =
    Http.send FilesReceved Api.fileList


isNameDuplicateOrEmpty : Model -> Bool
isNameDuplicateOrEmpty model =
    if model.newFileName /= "" then
        List.member model.newFileName model.fileNames
    else
        True


view : Model -> Html Msg
view model =
    div []
        [ newFileForm model
        , div [] (List.map fileHtml model.fileNames)
        ]


fileHtml : String -> Html msg
fileHtml file =
    a [ Router.href (Router.FileDetails file False) ]
        [ div [ class "card fluid" ]
            [ h3 [] [ text file ] ]
        ]


newFileForm : Model -> Html Msg
newFileForm model =
    div []
        [ label []
            [ text "New file"
            , input
                [ value model.newFileName
                , placeholder "New file name"
                , Html.Events.onInput UpdateCreateNewFile
                ]
                []
            , button
                [ class "button"
                , Html.Events.onClick CreateNewFile
                , disabled (isNameDuplicateOrEmpty model)
                ]
                [ text "Go" ]
            ]
        ]
