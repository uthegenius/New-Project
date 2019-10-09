@isTest
global class Informatica_Order_Error_Mock implements HttpCalloutMock {
   global HTTPResponse respond(HTTPRequest req) {               
        HttpResponse res = new HttpResponse();
        req.setHeader('Content-Type', 'text/xml; charset=utf-8');
        res.setBody('<ZSF_ORDER_CREATEResponse_AnonymousType>'+
                       '<OUTPUT>'+
                          '<item>'+
                             '<ORDER_ID></ORDER_ID>'+
                             '<MESSAGE_TYPE>E</MESSAGE_TYPE>'+
                             '<MESSAGE>Successful</MESSAGE>'+
                          '</item>'+
                       '</OUTPUT>'+
                    '</ZSF_ORDER_CREATEResponse_AnonymousType>');
        res.setStatusCode(200);
        return res;        
    }
}