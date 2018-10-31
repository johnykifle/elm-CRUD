module Shared exposing (Author, Model, Msg(..), Player, PlayerId, Post, PostId, RemoteData(..), Route(..), initialModel, mapRemoteData)

import Browser exposing (UrlRequest)
import Browser.Navigation exposing (Key)
import Http
import RemoteData exposing (WebData)
import Url exposing (Url)


type alias Model =
    { players : RemoteData (List Player)
    , posts : WebData (List Post)
    , errorPostMessage : Maybe String
    , key : Key
    , route : Route
    }


initialModel : Route -> Key -> Model
initialModel route key =
    { players = Loading
    , posts = RemoteData.NotAsked
    , errorPostMessage = Nothing
    , key = key
    , route = route
    }


type alias PlayerId =
    String


type alias PostId =
    String


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
    | PostRoute PostId
    | NotFoundRoute


type Msg
    = OnFetchPlayers (Result Http.Error (List Player))
    | OnFetchPosts (WebData (List Post))
    | SendHttpRequest
    | UpdateTitle PostId String
    | OnPostSave (Result Http.Error Post)
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
