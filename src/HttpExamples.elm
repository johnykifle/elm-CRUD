module HttpExamples exposing (..)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Decode exposing (Decoder, field, int, list, string, map3)
import Http
import Json.Decode.Pipeline exposing (required, optional, requiredAt, optionalAt)
import RemoteData exposing (WebData)

-- Model
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

type RemoteData error value
  = NotAsked
  | Loading
  | Failure error
  | Success value

type Msg 
  = FetchPosts
  | PostsReceived (WebData (List Post))

init : () -> (Model, Cmd Msg)
init _ =
  ( { posts = RemoteData.Loading
    }
  , fetchPostsCommand
  )
  
--view

view : Model -> Html Msg
view model =
  div []
    [
      button [ onClick FetchPosts] [ text "Refresh data"]
    , listView model 
    ]

listView : Model -> Html Msg
listView model =
  case model.posts of
    RemoteData.NotAsked ->
      div []
      [
        text ""
      ]
    
    RemoteData.Loading ->
      div []
        [ text "Loading ..."
        ]
    
    RemoteData.Success posts ->
      viewPosts posts

    RemoteData.Failure httpError ->
      viewError (createHttpError httpError)

viewError : String -> Html Msg
viewError error =
  div []
    [ text error
    ]

viewPosts : List Post -> Html Msg
viewPosts posts =
    div []
        [ h3 [] [ text "Posts" ]
        , table []
            ([ viewTableHeader ] ++ List.map viewPost posts)
        ]

viewTableHeader : Html Msg
viewTableHeader =
  tr []
    [ th []
      [ text  "ID" ]
    , th []
      [ text "Title" ]
    , th []
        [ text "Author" ]
    ]

viewPost : Post -> Html Msg
viewPost post =
  tr []
    [ td []
        [ text (String.fromInt post.id) ]
    , td []
        [ text post.title ]
    , td []
        [ a [ href post.author.url ] [ text post.author.name ] ]
    ]

-- update

url : String
url =
  "http://localhost:5019/posts"

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of 
    FetchPosts ->
      ( model, fetchPostsCommand)
    
    PostsReceived response ->
      ( { model | posts = response }, Cmd.none)
    
fetchPostsCommand : Cmd Msg
fetchPostsCommand =
  postsDecoder
    |> Http.get url
    |> RemoteData.sendRequest 
    |> Cmd.map PostsReceived

createHttpError : Http.Error -> String
createHttpError httpError =
  case httpError of
    Http.BadUrl message ->
      message
    
    Http.Timeout ->
       "Server is taking too long to respond. Please try again later."
      
    Http.NetworkError ->
      "It appears you don't have an Internet connection right now."
    
    Http.BadStatus response ->
      response.status.message
    
    Http.BadPayload message response ->
      message
    
postsDecoder =
  list postDecoder

postDecoder : Decoder Post
postDecoder =
  Decode.succeed Post
    |> required "id" int
    |> required "title" string
    |> required "author" authorDecoder


authorDecoder : Decoder Author
authorDecoder =
    Decode.succeed Author
        |> required "name" string
        |> required "url" string

subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
  
main =
 Browser.element
  {
    init = init,
    update = update,
    view = view,
    subscriptions = subscriptions
  }

