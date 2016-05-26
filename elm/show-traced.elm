module WebsocketDemoShowTraced exposing (..)

import Html exposing (..)
import Html.App as Html
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import WebSocket
import Json.Decode exposing (..)
-- import Json.Decode.Extra exposing ((|:))
import Debug

main : Program Never
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


type alias History =
  { timestamp: Float,
    elapsed:   Int,
    node: Node
  }

type alias Node =
  {
    id: String
  }

decoderHistory : Decoder (List History)
decoderHistory = "CamelMessageHistory" := Json.Decode.list (Json.Decode.object3 History
  ("timestamp" := Json.Decode.float)
  ("elapsed" := Json.Decode.int)
  ("node" := Json.Decode.object1 Node
  ("id" := Json.Decode.string)))

type alias Trace =
  { node: String,
    time: Float
  }

decoderTrace : Decoder Trace
decoderTrace = Json.Decode.object2 Trace
  ("node" := Json.Decode.string)
  ("time" := Json.Decode.float)


viewMessage : String -> Html msg
viewMessage msg =
  let _ = Debug.log "view: " msg
  in
    case Json.Decode.decodeString decoderTrace msg of
      (Ok trace) -> viewTrace trace
      -- (Ok history) -> div [] [ul [] (List.map viewHistoryItem history)]
      (Err errMsg) -> div [] [text errMsg]

viewTrace : Trace -> Html msg
viewTrace {node, time} =
  div [] [text (node ++ ", " ++ (toString time))]

-- viewHistoryItem : History -> Html msg
-- viewHistoryItem {timestamp, elapsed, node} =
--   li [] [text (node.id ++ (toString timestamp) ++ ", " ++ (toString elapsed))]
