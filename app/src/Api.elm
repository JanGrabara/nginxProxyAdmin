module Api exposing (..)

import Http exposing (Body)
import Url.Builder exposing (QueryParameter)


-- import Json.Decode as Decode exposing (Decoder, Value, decodeString, field, string)

import Json.Encode
import Json.Decode as Decode exposing (Decoder, list)
import Json.Decode.Pipeline exposing (custom, hardcoded, required)


type alias OkResult =
    { ok : Bool }


okDecoder =
    Decode.succeed OkResult
        |> required "ok" Decode.bool


stringListDecoder =
    list Decode.string


buildUrl : List String -> List QueryParameter -> Endpoint
buildUrl paths queryParams =
    Url.Builder.crossOrigin "http://localhost:8080"
        ("api" :: paths)
        queryParams
        |> Endpoint


encodeLoginSecret : String -> Http.Body
encodeLoginSecret secret =
    (Json.Encode.object [ ( "secret", Json.Encode.string <| secret ) ]) |> Http.jsonBody


login : String -> Http.Request OkResult
login secret =
    post (buildUrl [ "login" ] []) (encodeLoginSecret secret) okDecoder


logout : Http.Request OkResult
logout =
    post (buildUrl [ "logout" ] []) Http.emptyBody okDecoder


fileList : Http.Request (List String)
fileList =
    get (buildUrl [ "file" ] []) stringListDecoder 

getFile : String -> Http.Request String
getFile fileName =
    get (buildUrl [ "file", fileName ] []) Decode.string


request :
    { body : Http.Body
    , expect : Http.Expect a
    , headers : List Http.Header
    , method : String
    , url : Endpoint
    }
    -> Http.Request a
request config =
    Http.request
        { body = config.body
        , expect = config.expect
        , headers = config.headers
        , method = config.method
        , timeout = Nothing
        , url = unwrap config.url
        , withCredentials = True
        }


unwrap : Endpoint -> String
unwrap (Endpoint str) =
    str


type Endpoint
    = Endpoint String


jsonHeaders =
    [ Http.header "content-type" "application/json" ]


get : Endpoint -> Decoder a -> Http.Request a
get url decoder =
    request
        { method = "GET"
        , url = url
        , expect = Http.expectJson decoder
        , headers = jsonHeaders
        , body = Http.emptyBody
        }


post : Endpoint -> Body -> Decoder a -> Http.Request a
post url body decoder =
    request
        { method = "POST"
        , url = url
        , expect = Http.expectJson decoder
        , headers = jsonHeaders
        , body = body
        }



-- put : Endpoint -> Body -> Decoder a -> Http.Request a
-- put url cred body decoder =
--     request
--         { method = "PUT"
--         , url = url
--         , expect = Http.expectJson decoder
--         , headers = jsonHeaders
--         , body = body
--         , timeout = Nothing
--         , withCredentials = False
--         }
-- delete : Endpoint -> Cred -> Body -> Decoder a -> Http.Request a
-- delete url cred body decoder =
--     request
--         { method = "DELETE"
--         , url = url
--         , expect = Http.expectJson decoder
--         , headers = jsonHeaders
--         , body = body
--         , timeout = Nothing
--         }
