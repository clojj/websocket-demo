module WebsocketDemoShowTraced exposing (..)

import Html exposing (..)
import Html.App as Html
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import WebSocket


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
    NewMessage str -> (Model (str :: messages), Cmd.none)


-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model =
  WebSocket.listen "ws://localhost:9293/traced" NewMessage


-- VIEW

view : Model -> Html Msg
view model =
  div []
    [ div [] (List.map viewMessage model.messages) ]


viewMessage : String -> Html msg
viewMessage msg =
  div [] [ text msg ]
