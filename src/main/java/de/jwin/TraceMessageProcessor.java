package de.jwin;

import org.apache.camel.Exchange;
import org.apache.camel.processor.interceptor.DefaultTraceEventMessage;
import org.apache.camel.processor.interceptor.TraceEventMessage;

import java.util.HashMap;
import java.util.Map;

class TraceMessageProcessor implements org.apache.camel.Processor {

    @Override
    public void process(Exchange exchange) throws Exception {

        TraceEventMessage msg = exchange.getIn().getBody(DefaultTraceEventMessage.class);
        Exchange tracedExchange = msg.getTracedExchange();
        Object breadcrumbid = tracedExchange.getIn().getHeader("breadcrumbid");
        String nodeId = exchange.getUnitOfWork().getTracedRouteNodes().getLastNode().getProcessorDefinition().getId();

        Map<String, Object> map = new HashMap<>();
        map.put("id", breadcrumbid);
        map.put("node", nodeId);
        map.put("time", msg.getTimestamp());
        //map.put("fromNode", msg.getPreviousNode() != null ? msg.getPreviousNode() : "---");
        //map.put("toNode", msg.getToNode() != null ? msg.getToNode() : "---");

        exchange.getIn().setBody(map);
    }
}
