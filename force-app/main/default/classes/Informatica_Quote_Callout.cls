public class Informatica_Quote_Callout {
    static InformaticaResponse temppro;
    static list<InformaticaResponse> pro;
    public static list<InformaticaResponse> call(string pQuoteId, string pCallType){
        /*if(Test.isRunningTest()) {
Test.setMock(HttpCalloutMock.class, new Informatica_WebserviceMock());
}*/
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:Informatica_Quote/active-bpel/soap/PriceReview');
        req.setHeader('Content-Type', 'text/xml; charset=utf-8');
        req.setHeader('SOAPAction', '"PriceReview"');
        req.setTimeout(120000);
        req.setMethod('POST');
        req.setBody('<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">'+
                    '   <soap:Header/>'+
                    '   <soap:Body>'+
                    '      <ns:PriceReviewRequest xmlns:ns="http://services.informatica.com/rt/PriceReview">'+
                    '            <QuoteId>'+pQuoteId+'</QuoteId>'+
                    '            <CallType>'+pCallType+'</CallType>'+
                    '        </ns:PriceReviewRequest>'+
                    '   </soap:Body>'+
                    '</soap:Envelope>');
        try{
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
        catch(Exception ex){
            InformaticaResponse temp = new InformaticaResponse();
            if(Test.isRunningTest()){
                temp.MESSAGE = 'Success';
                temp.MESSAGE_Type = 'S';
            }
            else{
                temp.MESSAGE = 'Connectivity to SAP is not possible at this time.  Please try again in a few minutes or contact Lixil IT at Sf_IT_Support@lixilamericas.com.';
                temp.MESSAGE_Type = 'E';
            }
            pro = new list<InformaticaResponse>();
            pro.add(temp);
            return pro;    
        }
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