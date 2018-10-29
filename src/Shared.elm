module Shared exposing (Model, Msg(..), Player, PlayerId, RemoteData(..), Route(..), initialModel, mapRemoteData, Post, Author)

import Browser exposing (UrlRequest)
import Browser.Navigation exposing (Key)
import Http
import Url exposing (Url)


type alias Model =
    { players : RemoteData (List Player)
    , posts : RemoteData (List Post)
    , key : Key
    , route : Route
    }


initialModel : Route -> Key -> Model
initialModel route key =
    { players = Loading
    , posts = Loading
    , key = key
    , route = route
    }


type alias PlayerId =
    String


type alias PostId =
    Int


type alias Player =
    { id : PlayerId
    , name : String
    , level : Int
    }


type alias Post =
    { id : PostId
    , title : String
    , author : Author
    }


type alias Author =
    { name : String
    , url : String
    }


type Route
    = PlayersRoute
    | PlayerRoute PlayerId
    | HomeRoute
    | PostsRoute
    | NotFoundRoute


type Msg
    = OnFetchPlayers (Result Http.Error (List Player))
    | OnFetchPosts (Result Http.Error (List Post))
    | OnUrlChange Url
    | OnUrlRequest UrlRequest
    | ChangeLevel Player Int
    | OnPlayerSave (Result Http.Error Player)


type RemoteData a
    = NotAsked
    | Loading
    | Loaded a
    | Failure


mapRemoteData : (a -> b) -> RemoteData a -> RemoteData b
mapRemoteData fn remoteData =
    case remoteData of
        NotAsked ->
            NotAsked

        Loading ->
            Loading

        Loaded data ->
            Loaded (fn data)

        Failure ->
            Failure
