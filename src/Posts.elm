module Posts exposing (fetchPosts, fetchPostsUrl, savePostCmd)

import Http
import Json.Decode as Decode
import Json.Decode.Pipeline exposing (required)
import Json.Encode as Encode
import RemoteData
import Shared exposing (..)


fetchPosts : Cmd Msg
fetchPosts =
    postsDecoder
        |> Http.get fetchPostsUrl
        |> RemoteData.sendRequest
        |> Cmd.map OnFetchPosts


fetchPostsUrl : String
fetchPostsUrl =
    "http://localhost:4000/posts"


savePostUrl : PostId -> String
savePostUrl postId =
    "http://localhost:4000/posts/" ++ postId


savePostCmd : Maybe Post -> Cmd Msg
savePostCmd post =
    case post of
        Just data ->
            savePostRequest data
                |> Http.send OnPostSave

        Nothing ->
            Cmd.none


savePostRequest : Post -> Http.Request Post
savePostRequest post =
    Http.request
        { body = postEncoder post |> Http.jsonBody
        , expect = Http.expectJson postDecoder
        , headers = []
        , method = "PATCH"
        , timeout = Nothing
        , url = savePostUrl post.id
        , withCredentials = False
        }


postEncoder : Post -> Encode.Value
postEncoder post =
    let
        attributes =
            [ ( "id", Encode.string post.id )
            , ( "title", Encode.string post.title )
            ]
    in
    Encode.object attributes



-- Decoders


postsDecoder : Decode.Decoder (List Post)
postsDecoder =
    Decode.list postDecoder


postDecoder : Decode.Decoder Post
postDecoder =
    Decode.succeed Post
        |> required "id" Decode.string
        |> required "title" Decode.string
        |> required "author" authorDecoder


authorDecoder : Decode.Decoder Author
authorDecoder =
    Decode.succeed Author
        |> required "name" Decode.string
        |> required "url" Decode.string
