module WebsocketDemoShowMessageCounts exposing (..)

import Html exposing (..)
import WebSocket
import Json.Decode exposing (..)

import Set

main : Program Never Model Msg
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
    traces : List Trace,
    errorMessage : String
  }

init : (Model, Cmd Msg)
init =
  (Model [("node1", Set.empty), ("node2", Set.empty), ("Websocket ECHO REPLY", Set.empty)] [] "", Cmd.none)

type alias Trace =
  { id:   String,
    node: String,
    unitOfWork: String,
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
update msg model =
  case msg of
    NewMessage trace ->
      ({ model |
            nodes = (List.map (updateSet trace) model.nodes),
            traces = trace :: model.traces
       }, Cmd.none)

    ErrorMessage errMsg -> ({ model | errorMessage = errMsg }, Cmd.none)


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
decoderTrace = Json.Decode.map4 Trace
  (at ["id"] Json.Decode.string)
  (at ["node"] Json.Decode.string)
  (at ["unitOfWork"] Json.Decode.string)
  (at ["time"] Json.Decode.float)


-- VIEW

view : Model -> Html Msg
view {nodes, traces, errorMessage} =
  div []
    [ div [] (List.map viewCount nodes),
      hr [] [],
      table [] (List.map viewTrace traces) ]

viewCount : (NodeName, MessageSet) -> Html msg
viewCount (name, set) =
  div [] [text (name ++ " " ++ (toString (Set.size set)))]

viewTrace : Trace -> Html msg
viewTrace {node, unitOfWork} =
  tr [] [
    td [] [text node],
    td [] [text unitOfWork]
  ]
