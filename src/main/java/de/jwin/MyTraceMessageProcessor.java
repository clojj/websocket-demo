package de.jwin;

import org.apache.camel.Exchange;
import org.apache.camel.processor.interceptor.DefaultTraceEventMessage;
import org.apache.camel.processor.interceptor.TraceEventMessage;

public class MyTraceMessageProcessor implements org.apache.camel.Processor {
    @Override
    public void process(Exchange exchange) throws Exception {
        TraceEventMessage msg = exchange.getIn().getBody(DefaultTraceEventMessage.class);

        String message = msg.getFromEndpointUri() + ";" + msg.getToNode() + ";" + msg.getExchangeId() + " BODY: " + msg.getBody();

        exchange.getIn().setBody(message);
    }
}
