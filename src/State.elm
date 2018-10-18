module State exposing (..)

import RemoteData exposing (WebData)
import Types exposing (..)
import Rest exposing (fetchPostsCommand)


init : ()  -> ( Model, Cmd Msg )
init _ =
    ( { posts = RemoteData.Loading }, fetchPostsCommand )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FetchPosts ->
            ( { model | posts = RemoteData.Loading }, fetchPostsCommand )

        PostsReceived response ->
            ( { model | posts = response }, Cmd.none )
