public class Informatica_Order_Callout {
    static InformaticaResponse temppro;
    static list<InformaticaResponse> pro;
    public static list<InformaticaResponse> callShippmentDetail(string pOrderId){
            HttpRequest req = new HttpRequest();
            req.setEndpoint('callout:Informatica_Quote//active-bpel/soap/OrderShippingDetail');
            req.setHeader('Content-Type', 'text/xml; charset=utf-8');
            req.setHeader('SOAPAction', '"OrderShippingDetail"');
            req.setMethod('POST');
        	req.setTimeout(120000);
            req.setBody('<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">'+
                        '   <soap:Header/>'+
                        '   <soap:Body>'+
                        '      <ns:OrderShippingDetailRequest xmlns:ns="http://services.informatica.com/rt/OrderShippingDetail">'+
                        '            <SAP_Order_Number>'+pOrderId+'</SAP_Order_Number>'+
                        '      </ns:OrderShippingDetailRequest>'+
                        '   </soap:Body>'+
                        '</soap:Envelope>');
            HttpResponse response = new Http().send(req);
            string Body = response.getBody();            
            
            pro = new list<InformaticaResponse>();
            Dom.Document doc = new Dom.Document();
            doc.load(Body);
            //Retrieve the root element for this document.
            Dom.XMLNode quoteDtls = doc.getRootElement();
            parseXML(quoteDtls);
            system.debug(pro);
            return pro;
    }
    
    public static list<InformaticaResponse> callSubmitToSAP(string pOrderId){
        try{
            HttpRequest req = new HttpRequest();
            req.setEndpoint('callout:Informatica_Quote/active-bpel/soap/sfOrders');
            req.setHeader('Content-Type', 'text/xml; charset=utf-8');
            req.setHeader('SOAPAction', '"sfOrders"');
            req.setMethod('POST');
            req.setTimeout(120000);
            req.setBody('<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">'+
                        '   <soap:Header/>'+
                        '   <soap:Body>'+
                        '      <sfOrdersRequest xmlns="http://services.informatica.com/rt/sfOrders">'+
                        '            <OrderId>'+pOrderId+'</OrderId>'+
                        '      </sfOrdersRequest>'+
                        '   </soap:Body>'+
                        '</soap:Envelope>');
            HttpResponse response = new Http().send(req);
            string Body = response.getBody();            
            
            pro = new list<InformaticaResponse>();
            Dom.Document doc = new Dom.Document();
            doc.load(Body);
            //Retrieve the root element for this document.
            Dom.XMLNode quoteDtls = doc.getRootElement();
            parseXML(quoteDtls);
            system.debug(pro);
            return pro;
        }
        catch(exception ex){
            system.debug(ex.getMessage());
            return null;
        }
    }        
    
    public static list<InformaticaResponse> callOrderSimulator(string pOrderId){
            HttpRequest req = new HttpRequest();
            req.setEndpoint('callout:Informatica_Quote/active-bpel/soap/GertOrderProductPrice');
            req.setHeader('Content-Type', 'text/xml; charset=utf-8');
            req.setHeader('SOAPAction', '"GertOrderProductPrice"');
            req.setMethod('POST');
        	req.setTimeout(120000);
            req.setBody('<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">'+
                        '   <soap:Header/>'+
                        '   <soap:Body>'+
                        '      <GertOrderProductPriceRequest xmlns="http://services.informatica.com/rt/GertOrderProductPrice">'+
                        '            <OrderId>'+pOrderId+'</OrderId>'+
                        '      </GertOrderProductPriceRequest>'+
                        '   </soap:Body>'+
                        '</soap:Envelope>');
            HttpResponse response = new Http().send(req);
            string Body = response.getBody();            
            
            pro = new list<InformaticaResponse>();
            Dom.Document doc = new Dom.Document();
            doc.load(Body);
            //Retrieve the root element for this document.
            Dom.XMLNode quoteDtls = doc.getRootElement();
            parseXML(quoteDtls);
            system.debug(pro);
            return pro;
    }
    
    private static void parseXML(DOM.XMLNode node) {
        if (node.getNodeType() == DOM.XMLNodeType.ELEMENT) {
            if(node.getName()=='item'){
                if(temppro!=null){
                    if(string.isNotBlank(temppro.MESSAGE)){
                        pro.add(temppro);
                    }
                }                    
                temppro = new InformaticaResponse();
            }
            if(node.getName()=='MESSAGE'){
                system.debug(node.getText().trim());
                temppro.MESSAGE=node.getText().trim();
            }
            
            if(node.getName()=='MESSAGE_TYPE'){
                system.debug(node.getText().trim());
                temppro.MESSAGE_TYPE=node.getText().trim();
            }
            
        }
        for (Dom.XMLNode child: node.getChildElements()) {
            parseXML(child);
        }
        
        if(pro.size()==0){
            if(temppro!=null){
                if(string.isNotBlank(temppro.MESSAGE)){
                    pro.add(temppro);
                }
            }  
        }
    }
    
    public class InformaticaResponse{
        public string MESSAGE;
        public string MESSAGE_TYPE;
        public InformaticaResponse(){
            MESSAGE='';
            MESSAGE_TYPE='';
        }        
    }
}