package de.jwin;

import org.apache.camel.builder.RouteBuilder;
import org.apache.camel.processor.interceptor.DefaultTraceFormatter;
import org.apache.camel.processor.interceptor.Tracer;

/**
 * A Camel Java DSL Router
 */
public class MyRouteBuilder extends RouteBuilder {

    /**
     * Let's configure the Camel routing rules using Java code...
     */
    public void configure() {

        getContext().setTracing(true);
        Tracer tracer = new Tracer();
        tracer.setEnabled(true);
        tracer.setTraceOutExchanges(false);
        tracer.setDestinationUri("direct:traced");
        DefaultTraceFormatter defaultTraceFormatter = tracer.getDefaultTraceFormatter();
        defaultTraceFormatter.setShowExchangeId(true);
        defaultTraceFormatter.setShowBody(true);
        defaultTraceFormatter.setShowBodyType(true);
        defaultTraceFormatter.setShowNode(true);

//        tracer.setLogLevel(LoggingLevel.OFF);
        getContext().addInterceptStrategy(tracer);

        from("websocket://foo")
                .log("${body}")
                .to("websocket://foo");

        from("direct:traced")
                .process(new MyTraceMessageProcessor())
                .to("websocket://localhost:9293/traced?sendToAll=true");

    }

}
