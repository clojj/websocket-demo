package de.jwin;

import org.apache.camel.Exchange;
import org.apache.camel.Processor;
import org.apache.camel.builder.RouteBuilder;
import org.apache.camel.model.dataformat.JsonLibrary;
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
/*
        DefaultTraceFormatter defaultTraceFormatter = tracer.getDefaultTraceFormatter();
        defaultTraceFormatter.setShowExchangeId(true);
        defaultTraceFormatter.setShowBody(true);
        defaultTraceFormatter.setShowBodyType(true);
        defaultTraceFormatter.setShowNode(true);
*/

//        tracer.setLogLevel(LoggingLevel.OFF);
        getContext().addInterceptStrategy(tracer);

        getContext().setMessageHistory(true);

        // enable Jackson json type converter
//        getContext().getProperties().put("CamelJacksonEnableTypeConverter", "true");
        // allow Jackson json to convert to pojo types also (by default jackson only converts to String and other simple types)
        getContext().getProperties().put("CamelJacksonTypeConverterToPojo", "true");

        from("websocket://foo").id("ROUTE websocket")
                .log("${body}").id("Log body!")
                .process(new Processor() {
                    @Override
                    public void process(Exchange exchange) throws Exception {
                        System.out.println("inside processor...");
                        Thread.sleep(2000);
                        System.out.println("processor exit");
                    }
                }).id("Test Processor")
                .to("websocket://foo").id("TO websocket");

        from("direct:traced")
                .process(new MyTraceMessageProcessor())
                .marshal().json(JsonLibrary.Jackson)
                .convertBodyTo(String.class)
                .to("websocket://localhost:9293/traced?sendToAll=true");

    }

}
