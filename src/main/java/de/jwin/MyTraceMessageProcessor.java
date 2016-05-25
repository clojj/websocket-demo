package de.jwin;

import org.apache.camel.Exchange;
import org.apache.camel.processor.interceptor.DefaultTraceEventMessage;
import org.apache.camel.processor.interceptor.TraceEventMessage;

public class MyTraceMessageProcessor implements org.apache.camel.Processor {
    @Override
    public void process(Exchange exchange) throws Exception {

        TraceEventMessage msg = exchange.getIn().getBody(DefaultTraceEventMessage.class);
        Exchange tracedExchange = msg.getTracedExchange();

//        exchange.getIn().setBody("traced");
        exchange.getIn().setBody(tracedExchange.getProperties());

        /*
        String message =
                msg.getFromEndpointUri() + ";" +
                        msg.getRouteId() + ";" +
                        msg.getToNode() + ";" +
                        msg.getTimestamp() +
                        "|body: " + msg.getBody() +
                        "|props: " + msg.getProperties();
*/

//        tracedExchange.getProperty("CamelMessageHistory");
//        exchange.getIn().setBody(message);
    }
}
