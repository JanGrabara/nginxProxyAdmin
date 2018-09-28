module Main exposing (..)

import Browser
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Router
import Url
import Page.LoginPage
import Session exposing (Session(..), navKey)
import Url.Parser exposing (..)
import Page.FileList
import Http
import Api
import Page.FileDetails


-- MAIN


main : Program () Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlChange = UrlChanged
        , onUrlRequest = LinkClicked
        }



-- MODEL


type MainRoute
    = FileList Page.FileList.Model
    | FileDetails Page.FileDetails.Model


type Model
    = Login Page.LoginPage.Model
    | MainRoute MainRoute
    | NotFound Session


init : () -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
    changeRouteTo (Router.fromUrl url) (NotFound (NotLogedIn key))



-- UPDATE


type Msg
    = UrlChanged Url.Url
    | LinkClicked Browser.UrlRequest
    | LoginPageMessage Page.LoginPage.Msg
    | FileListMessage Page.FileList.Msg
    | Logout
    | LogoutFinished (Result Http.Error Api.OkResult)
    | FileDetailsMessage Page.FileDetails.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update message model =
    case ( message, model ) of
        ( UrlChanged url, _ ) ->
            changeRouteTo (Router.fromUrl url) model

        ( LinkClicked urlRequest, _ ) ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, Nav.pushUrl (navKey (toSession model)) (Url.toString url) )

                Browser.External h ->
                    ( model, Nav.load h )

        ( Logout, _ ) ->
            ( model, Http.send LogoutFinished Api.logout )

        ( LogoutFinished (Ok _), _ ) ->
            ( model, Router.navigate (navKey (toSession model)) Router.Login )

        ( LoginPageMessage msg, Login m ) ->
            Page.LoginPage.update m msg
                |> updateWith Login LoginPageMessage model

        ( FileListMessage msg, MainRoute (FileList m) ) ->
            Page.FileList.update m msg
                |> updateWith (\x -> MainRoute (FileList x)) FileListMessage model

        ( FileDetailsMessage msg, MainRoute (FileDetails m) ) ->
            Page.FileDetails.update m msg
                |> updateWith (\x -> MainRoute (FileDetails x)) FileDetailsMessage model

        ( _, _ ) ->
            -- Disregard messages that arrived for the wrong page.
            ( model, Cmd.none )


updateWith : (subModel -> Model) -> (subMsg -> Msg) -> Model -> ( subModel, Cmd subMsg ) -> ( Model, Cmd Msg )
updateWith toModel toMsg model ( subModel, subCmd ) =
    ( toModel subModel
    , Cmd.map toMsg subCmd
    )


toSession : Model -> Session
toSession model =
    case model of
        Login m ->
            m.session

        NotFound m ->
            m

        MainRoute sub ->
            case sub of
                FileList m ->
                    m.session

                FileDetails m ->
                    m.session


changeRouteTo : Router.Route -> Model -> ( Model, Cmd Msg )
changeRouteTo route model =
    let
        session =
            toSession model
    in
        case route of
            Router.Login ->
                ( Page.LoginPage.initialModel session |> Login, Cmd.none )

            Router.FileDetails file isNew ->
                ( Page.FileDetails.initialModel session file |> FileDetails |> MainRoute
                , if isNew then
                    Cmd.none
                  else
                    Page.FileDetails.initialCmd file |> Cmd.map FileDetailsMessage
                )

            Router.FileList ->
                ( Page.FileList.initialModel session |> FileList |> MainRoute
                , Page.FileList.initialCommand |> Cmd.map FileListMessage
                )

            Router.NotFound ->
                ( NotFound (toSession model), Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


view : Model -> Browser.Document Msg
view model =
    { title = "Elm App"
    , body = [ router model ]
    }


router : Model -> Html Msg
router model =
    case model of
        Login loginModel ->
            Html.map LoginPageMessage (Page.LoginPage.view loginModel)

        NotFound _ ->
            div [] []

        MainRoute sub ->
            mainView sub


mainView : MainRoute -> Html Msg
mainView model =
    div []
        [ nav
        , case model of
            FileList fileListModel ->
                Page.FileList.view fileListModel |> Html.map FileListMessage

            FileDetails fileDetailsModel ->
                Page.FileDetails.view fileDetailsModel |> Html.map FileDetailsMessage
        ]


nav : Html Msg
nav =
    header []
        [ span []
            [ a [ Router.href Router.FileList, class "doc button" ] [ text "File List" ]
            ]
        , span []
            [ button [ class "doc button", onClick Logout ] [ text "logout" ]
            ]
        ]
