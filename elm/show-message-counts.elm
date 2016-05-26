module WebsocketDemoShowMessageCounts exposing (..)

import Html exposing (..)
import Html.App as Html
-- import Html.Attributes exposing (..)
-- import Html.Events exposing (..)
import WebSocket
import Json.Decode exposing (..)
-- import Json.Decode.Extra exposing ((|:))

import Set

main : Program Never
main =
  Html.program
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }


-- MODEL

type alias NodeId = String
type alias NodeName = String
type alias MessageSet = Set.Set NodeId

type alias Model =
  { nodes : List (NodeName, MessageSet),
    errorMessage : String
  }

init : (Model, Cmd Msg)
init =
  (Model [("node1", Set.empty), ("node2", Set.empty), ("node3", Set.empty)] "", Cmd.none)

type alias Trace =
  { id:   String,
    node: String,
    time: Float
  }

-- UPDATE

type Msg =
  NewMessage Trace |
  ErrorMessage String

updateSet : Trace -> (NodeName, MessageSet) -> (NodeName, MessageSet)
updateSet {id, node, time} (name, set) =
  if ((name /= node) && Set.member id set) then
    (name, Set.remove id set)
  else if (name == node) then
    (name, Set.insert id set)
  else
    (name, set)

update : Msg -> Model -> (Model, Cmd Msg)
update msg {nodes, errorMessage} =
  case msg of
    NewMessage trace ->
      (Model (List.map (updateSet trace) nodes) errorMessage, Cmd.none)

    ErrorMessage str -> (Model nodes str, Cmd.none)


-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model =
  WebSocket.listen "ws://localhost:9293/traced" jsonToTraceMsg

jsonToTraceMsg : String -> Msg
jsonToTraceMsg str =
  case Json.Decode.decodeString decoderTrace str of
    (Ok trace) -> NewMessage trace
    (Err errMsg) -> ErrorMessage errMsg

decoderTrace : Decoder Trace
decoderTrace = Json.Decode.object3 Trace
  ("id" := Json.Decode.string)
  ("node" := Json.Decode.string)
  ("time" := Json.Decode.float)


-- VIEW

view : Model -> Html Msg
view {nodes, errorMessage} =
  div []
    [ div [] (List.map viewCount nodes) ]

viewCount : (NodeName, MessageSet) -> Html msg
viewCount (name, set) =
  div [] [text (name ++ " " ++ (toString (Set.size set)))]
