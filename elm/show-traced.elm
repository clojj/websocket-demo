module WebsocketDemoShowTraced exposing (..)

import Html exposing (..)
import Html.App as Html
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import WebSocket
import String exposing (split)
import Json.Decode exposing (..)
-- import Json.Decode.Extra exposing ((|:))
import Debug

main =
  Html.program
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }


-- MODEL

type alias Model =
  { messages : List String }


init : (Model, Cmd Msg)
init =
  (Model [], Cmd.none)


-- UPDATE

type Msg = NewMessage String


update : Msg -> Model -> (Model, Cmd Msg)
update msg {messages} =
  case msg of
    NewMessage str ->
      -- let _ = Debug.log "received: " str
      -- in 
        (Model (str :: messages), Cmd.none)


-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model =
  WebSocket.listen "ws://localhost:9293/traced" NewMessage


-- VIEW

view : Model -> Html Msg
view model =
  div []
    [ div [] (List.map viewMessage model.messages) ]

type alias Traced =
  { timestamp: Float,
    elapsed:   Int
  }
  
myDecoder = "CamelMessageHistory" := Json.Decode.list (Json.Decode.object2 Traced 
                                                        ("timestamp" := Json.Decode.float)
                                                        ("elapsed" := Json.Decode.int))

viewMessage : String -> Html msg
viewMessage msg =
  let _ = Debug.log "view: " msg
  in
    case Json.Decode.decodeString myDecoder msg of -- todo toString here ?
      (Ok timestamps) -> div [] [ul [] (List.map viewItem timestamps)]
      (Err errMsg) -> div [] [text errMsg]

viewItem : Traced -> Html msg
viewItem {timestamp, elapsed} =
  li [] [text ((toString timestamp) ++ ", " ++ (toString elapsed))]
