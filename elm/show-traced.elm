module WebsocketDemoShowTraced exposing (..)

import Html exposing (..)
import Html.App as Html
-- import Html.Attributes exposing (..)
-- import Html.Events exposing (..)
import WebSocket
import Json.Decode exposing (..)
-- import Json.Decode.Extra exposing ((|:))

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
  { traces : List Trace }


init : (Model, Cmd Msg)
init =
  (Model [], Cmd.none)


-- UPDATE

type Msg =
  NewMessage Trace |
  ErrorMessage String


update : Msg -> Model -> (Model, Cmd Msg)
update msg {traces} =
  case msg of
    NewMessage trace -> (Model (trace :: traces), Cmd.none)
    ErrorMessage str -> (Model (traces), Cmd.none)


-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model =
  WebSocket.listen "ws://localhost:9293/traced" jsonToTraceMsg

jsonToTraceMsg : String -> Msg
jsonToTraceMsg str =
  case Json.Decode.decodeString decoderTrace str of
    (Ok trace) -> NewMessage trace
    (Err errMsg) -> ErrorMessage errMsg

type alias Trace =
  { node: String,
    time: Float
  }

decoderTrace : Decoder Trace
decoderTrace = Json.Decode.object2 Trace
  ("node" := Json.Decode.string)
  ("time" := Json.Decode.float)


-- VIEW

view : Model -> Html Msg
view model =
  div []
    [ div [] (List.map viewTrace model.traces) ]

viewTrace : Trace -> Html msg
viewTrace {node, time} =
  div [] [text (node ++ ", " ++ (toString time))]
