package de.jwin;

import org.apache.camel.Exchange;
import org.apache.camel.LoggingLevel;
import org.apache.camel.Processor;
import org.apache.camel.model.dataformat.JsonLibrary;
import org.apache.camel.processor.interceptor.Tracer;

class RouteBuilder extends org.apache.camel.builder.RouteBuilder {

    public void configure() {

        getContext().setTracing(true);
        Tracer tracer = new Tracer();
        tracer.setEnabled(true);
        tracer.setTraceOutExchanges(true);
        tracer.setDestinationUri("direct:traced");
        tracer.setLogLevel(LoggingLevel.DEBUG);
/*
        DefaultTraceFormatter defaultTraceFormatter = tracer.getDefaultTraceFormatter();
        defaultTraceFormatter.setShowExchangeId(true);
        defaultTraceFormatter.setShowBody(true);
        defaultTraceFormatter.setShowBodyType(true);
        defaultTraceFormatter.setShowNode(true);
*/

        getContext().addInterceptStrategy(tracer);

        getContext().setMessageHistory(true);

        from("websocket://foo").id("ROUTE websocket")
                .log("INPUT ${body}").id("websocket input")
                .to("seda:next");

        from("seda:next").id("SEDA")
                .to("direct:process");

        from("direct:process")
                .log("${body}").id("node1")
                .process(new Processor() {
                    @Override
                    public void process(Exchange exchange) throws Exception {
                        System.out.println("inside processor...");
                        try {
                            Thread.sleep(5000);
                        } catch (InterruptedException e) {
                        }
                        System.out.println("processor exit");
                    }
                }).id("node2")
                .to("websocket://foo").id("node3");

        from("direct:traced")
                .process(new TraceMessageProcessor())
                .marshal().json(JsonLibrary.Jackson)
                .convertBodyTo(String.class)
                .to("websocket://localhost:9293/traced?sendToAll=true");
    }
}
