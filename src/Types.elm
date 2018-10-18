module Types exposing (..)

import RemoteData exposing (WebData)


type alias Author =
    { name : String
    , url : String
    }


type alias Post =
    { id : Int
    , title : String
    , author : Author
    }


type alias Model =
    { posts : WebData (List Post)
    }


type Msg
    = FetchPosts
    | PostsReceived (WebData (List Post))
