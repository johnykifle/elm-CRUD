module Posts exposing (fetchPosts, fetchPostsUrl)

import Http
import Json.Decode as Decode
import Json.Decode.Pipeline exposing (required)
import Json.Encode as Encode
import Shared exposing (..)


fetchPosts : Cmd Msg
fetchPosts =
    Http.get fetchPostsUrl postsDecoder
        |> Http.send OnFetchPosts


fetchPostsUrl : String
fetchPostsUrl =
    "http://localhost:4000/posts"

-- Decoders

postsDecoder : Decode.Decoder (List Post)
postsDecoder =
    Decode.list postDecoder

postDecoder : Decode.Decoder Post
postDecoder =
    Decode.succeed Post
    |> required "id" Decode.int
    |> required "title" Decode.string
    |> required "author" authorDecoder

authorDecoder : Decode.Decoder Author
authorDecoder =
    Decode.succeed Author
    |> required "name" Decode.string
    |> required "url" Decode.string

