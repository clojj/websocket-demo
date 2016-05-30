module WebsocketDemoShowMessageCounts exposing (..)

import Html exposing (..)
import Html.App as Html
-- import Html.Attributes exposing (..)
-- import Html.Events exposing (..)
import WebSocket
import Json.Decode exposing (..)
-- import Json.Decode.Extra exposing ((|:))

import Set
import Dict
import Time exposing (Time, second)



main : Program Never
main =
  Html.program
    { init = init
    , view = view
    , update = update
    , subscriptions = websocketMessages
    }

-- MODEL

type alias MessageId = String
type alias NodeName = String
type alias MessageSet = Set.Set MessageId

type alias Model =
  { ids : Dict.Dict MessageId (NodeName, Float),
    errorMessage : String,
    currentTime : Time
  }

init : (Model, Cmd Msg)
init =
  (Model Dict.empty "" 0.0, Cmd.none)

type alias Trace =
  { traceid:   String,
    tracenode: String,
    tracetime: Float
  }

-- UPDATE

type Msg =
  NewMessage Trace |
  ErrorMessage String |
  Tick Time

update : Msg -> Model -> (Model, Cmd Msg)
update msg {ids, errorMessage, currentTime} =
  case msg of
    NewMessage {traceid, tracenode, tracetime} ->
      if Dict.member traceid ids then
        case Dict.get traceid ids of
          Nothing -> (Model ids errorMessage currentTime, Cmd.none)
          Just (name, time) ->
            if name /= tracenode then
              (Model (Dict.insert traceid (tracenode, 0.0) ids) errorMessage currentTime, Cmd.none)
            else
              -- TODO don't hardcode last node
              if tracenode /= "node3" then
                (Model (Dict.insert traceid (tracenode, tracetime) ids) errorMessage currentTime, Cmd.none)
              else
                (Model ids errorMessage currentTime, Cmd.none)
      else
        (Model (Dict.insert traceid (tracenode, 0.0) ids) errorMessage currentTime, Cmd.none)

    ErrorMessage str -> (Model ids str currentTime, Cmd.none)

    Tick newTime -> (Model ids errorMessage newTime, Cmd.none)


-- SUBSCRIPTIONS

websocketMessages : Model -> Sub Msg
websocketMessages model =
  Sub.batch [
    WebSocket.listen "ws://localhost:9293/traced" jsonToTraceMsg,
    Time.every second Tick
  ]

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
overLimit : Time -> (MessageId, (NodeName, Float)) -> Bool
overLimit currTime (mid, (_, time)) =
  if time > 0 && currTime - time > 8000 then
    True
  else
    False

view : Model -> Html Msg
view {ids, errorMessage, currentTime} =
  div []
    [ div [] (List.map viewQueues (List.filter (overLimit currentTime) (Dict.toList ids))),
      div [] [text ("time " ++ toString currentTime)]]

viewQueues : (MessageId, (NodeName, Float)) -> Html msg
viewQueues (mid, (name, time)) =
  div [] [text (mid ++ " at " ++ name ++ " " ++ toString time)]
