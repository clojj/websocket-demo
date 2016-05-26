Camel / Elm Websocket-Demo
==========================

To build the Java-part of this project use

    mvn install

To run the Camel application from within Maven use

    mvn exec:java

To run Elm client-pages use (inside 'elm' subdirectory)

    elm-reactor

    ...then open in separate browser windows
        http://localhost:8000/echo-send.elm
        http://localhost:8000/show-message-counts.elm

Operation
---------
Entering text and clicking the 'Send' button will trigger a websocket-based 'echo'-route
which is traced by Camel.
The traced Camel-messages can be observed in the second elm-page.

Tip: To see the async (Camel)Seda-route in action, click in fast succession !

TODO
----

- create the list of nodes *dynamically* in elm
