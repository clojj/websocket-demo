package de.jwin;

import org.apache.camel.Exchange;
import org.apache.camel.RouteNode;
import org.apache.camel.processor.interceptor.DefaultTraceEventMessage;
import org.apache.camel.processor.interceptor.TraceEventMessage;
import org.apache.camel.spi.TracedRouteNodes;

import java.util.HashMap;
import java.util.Map;

public class MyTraceMessageProcessor implements org.apache.camel.Processor {
    @Override
    public void process(Exchange exchange) throws Exception {

        TraceEventMessage msg = exchange.getIn().getBody(DefaultTraceEventMessage.class);
        Exchange tracedExchange = msg.getTracedExchange();

        Map<String, Object> map = new HashMap<>();
        map.put("properties", tracedExchange.getProperties());
        map.put("time", msg.getTimestamp());

        //map.put("node", msg.getToNode());
        TracedRouteNodes traced = exchange.getUnitOfWork().getTracedRouteNodes();
        RouteNode last = traced.getLastNode();
        map.put("node", last.getProcessorDefinition().getId());

        exchange.getIn().setBody(map);
    }
}
