module Router exposing (..)

import Browser
import Url.Parser exposing (..)
import Url.Parser.Query as Query
import Browser.Navigation as Nav
import Html exposing (div, Html, text)
import Html exposing (Attribute)
import Html.Attributes as Attr
import Url
import Maybe
import Dict


type Route
    = Login
    | FileList
    | FileDetails String Bool
    | NotFound


newFileQueryParam : Query.Parser Bool
newFileQueryParam =
    Query.enum "isNew" (Dict.fromList [ ( "true", True ), ( "false", False ) ])
        |> Query.map (Maybe.withDefault False)


parseRoute =
    oneOf
        [ map Login (s "login")
        , map FileList (s "fileList")
        , map FileDetails (s "file" </> string <?> newFileQueryParam)
        ]


fromUrl : Url.Url -> Route
fromUrl url =
    (Url.Parser.parse parseRoute) url |> Maybe.withDefault NotFound


routeToString : Route -> String
routeToString page =
    case page of
        Login ->
            buildPath [ "login" ] []

        NotFound ->
            buildPath [ "notFound" ] []

        FileList ->
            buildPath [ "fileList" ] []

        FileDetails s isNew ->
            buildPath [ "file", s ]
                (if isNew then
                    [ ( "isNew", "true" ) ]
                 else
                    []
                )


buildPath : List String -> List ( String, String ) -> String
buildPath path query =
    let
        buildedQuery =
            String.join "&" (List.map (\( key, val ) -> key ++ "=" ++ val) query)

        segments =
            "/" ++ String.join "/" path
    in
        segments
            ++ (if buildedQuery /= "" then
                    "?" ++ buildedQuery
                else
                    ""
               )


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
