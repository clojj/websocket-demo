module WebsocketDemoShowTraced exposing (..)

import Html exposing (..)
import Html.App as Html
-- import Html.Attributes exposing (..)
-- import Html.Events exposing (..)
import WebSocket
import Json.Decode exposing (..)
-- import Json.Decode.Extra exposing ((|:))

import Dict

main : Program Never
main =
  Html.program
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }


-- MODEL
type alias Trace =
  { id: String,
    node: String,
    fromNode: String,
    toNode: String,
    time: Float
  }

type alias Model =
  { traces : List String,
    adj: Dict.Dict String (List String)}


init : (Model, Cmd Msg)
init =
  (Model [] Dict.empty, Cmd.none)


-- UPDATE

type Msg =
  NewMessage Trace |
  ErrorMessage String


update : Msg -> Model -> (Model, Cmd Msg)
update msg {traces, adj} =
  case msg of

    NewMessage {id, node, fromNode, toNode, time} ->
        let
            newAdj = Dict.insert node [toNode] adj
        in
            (Model ((node ++ ", " ++ (toString time)) :: traces) newAdj, Cmd.none)

    ErrorMessage str -> (Model traces adj, Cmd.none)


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
decoderTrace = Json.Decode.object5 Trace
  ("id" := Json.Decode.string)
  ("node" := Json.Decode.string)
  ("fromNode" := Json.Decode.string)
  ("toNode" := Json.Decode.string)
  ("time" := Json.Decode.float)


-- VIEW

view : Model -> Html Msg
view model =
  div []
    [ div [] (List.map viewTrace model.traces),
      div [] (List.map viewAdj (Dict.toList model.adj))
    ]

viewTrace : String -> Html msg
viewTrace trace =
  div [] [text trace]

viewAdj : (String, List String) -> Html msg
viewAdj (k, v) = div [] [text ("key: " ++ k ++ " value: " ++ toString v)]
-- viewAdj (k, v) = case v of
--   (x :: []) -> div [] [text ("key: " ++ k ++ " value: " ++ toString x)]
--   (x :: xs) -> div [] [text ("key: " ++ k ++ " value: " ++ toString x)]
--   [] -> div [] [text ("key: " ++ k ++ " value: []")]
