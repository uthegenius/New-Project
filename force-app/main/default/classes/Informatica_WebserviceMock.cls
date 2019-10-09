@isTest
global class Informatica_WebserviceMock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {               
        HttpResponse res = new HttpResponse();
        req.setHeader('Content-Type', 'text/xml; charset=utf-8');
        res.setBody('<ZSF_GET_MARGIN_ANALYSISResponse_AnonymousType><OUTPUT><item><ORDER_ID></ORDER_ID><MESSAGE_TYPE>S</MESSAGE_TYPE><MESSAGE>Success</MESSAGE></item></OUTPUT></ZSF_GET_MARGIN_ANALYSISResponse_AnonymousType>');
        res.setStatusCode(200);
        return res;        
    }
}