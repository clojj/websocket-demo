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
        getContext().addInterceptStrategy(tracer);
        getContext().setMessageHistory(true);


        from("websocket://localhost:9292/").id("Websocket ECHO FROM")
                .log("INPUT ${body}").id("INPUT log")
                .to("seda:next").id("to seda");

        from("seda:next?concurrentConsumers=3").id("SEDA")
                .log("${body}").id("node1")
                .process(new Processor() {
                    @Override
                    public void process(Exchange exchange) throws Exception {
                        Thread.sleep(5000);
                    }
                }).id("node2")
                .to("websocket://localhost:9292/").id("Websocket ECHO REPLY");

        from("direct:traced").id("Websocket TRACER")
                .process(new TraceMessageProcessor())
                .marshal().json(JsonLibrary.Jackson)
                .convertBodyTo(String.class)
                .to("websocket://localhost:9293/traced?sendToAll=true");
    }
}
