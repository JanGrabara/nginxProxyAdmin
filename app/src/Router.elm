module Router exposing (..)

import Browser
import Url.Parser exposing (..)
import Browser.Navigation as Nav
import Html exposing (div, Html, text)
import Html exposing (Attribute)
import Html.Attributes as Attr
import Url


type Route
    = Login
    | FileList
    | FileDetails String
    | NotFound


parseRoute =
    oneOf
        [ map Login (s "login")
        , map FileList (s "fileList")
        , map FileDetails (s "file" </> string)
        ]


fromUrl : Url.Url -> Route
fromUrl url =
    (Url.Parser.parse parseRoute) url |> Maybe.withDefault NotFound


routeToString : Route -> String
routeToString page =
    let
        pieces =
            case page of
                Login ->
                    [ "login" ]

                NotFound ->
                    [ "notFound" ]

                FileList ->
                    [ "fileList" ]

                FileDetails s ->
                    [ "file", s ]

        -- MainRoute subRoute ->
        --     case subRoute of
        --         FileList ->
        --             [ "fileList" ]
        --         FileDetails fileName ->
        --             [ "fileDetails", fileName ]
    in
        "/" ++ String.join "/" pieces


type Msg
    = LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url


replaceUrl : Nav.Key -> Route -> Cmd msg
replaceUrl key route =
    Nav.replaceUrl key (routeToString route)


navigate : Nav.Key -> Route -> Cmd msg
navigate key route =
    Nav.pushUrl key (routeToString route)


href : Route -> Attribute msg
href targetRoute =
    Attr.href (routeToString targetRoute)



-- update : Msg -> Model -> ( Model, Cmd Msg )
-- update msg model =
--     case msg of
--         LinkClicked urlRequest ->
--             case urlRequest of
--                 Browser.Internal url ->
--                     ( model, Nav.pushUrl model.key (Url.toString url) )
--                 Browser.External h ->
--                     ( model, Nav.load h )
--         UrlChanged url ->
--             let
--                 parsed =
--                     Url.Parser.parse routeParser url
--             in
--                 ( { model | route = Maybe.withDefault NotFound parsed }
--                 , Cmd.none
--                 )
