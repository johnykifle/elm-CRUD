module Rest exposing (fetchPostsCommand)

import Http
import RemoteData
import Types exposing (..)
import Json.Decode as Decode exposing (Decoder, int, list, string)
import Json.Decode.Pipeline exposing (required)


authorDecoder : Decoder Author
authorDecoder =
    Decode.succeed Author
        |> required "name" string
        |> required "url" string


postDecoder : Decoder Post
postDecoder =
    Decode.succeed Post
        |> required "id" int
        |> required "title" string
        |> required "author" authorDecoder


fetchPostsCommand : Cmd Msg
fetchPostsCommand =
    list postDecoder
        |> Http.get "http://localhost:5019/posts"
        |> RemoteData.sendRequest
        |> Cmd.map PostsReceived
