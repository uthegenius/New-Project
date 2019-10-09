@isTest
global class CardConnectAuth_Mock implements HttpCalloutMock
{
	global HTTPResponse respond(HTTPRequest req) 
    {           
        HttpResponse res = new HttpResponse();
        req.setHeader('Content-Type', 'application/json; charset=utf-8');
        res.setBody('{"amount":"1.00","resptext":"Approval","commcard":" C ","cvvresp":"M","avsresp":"Z","respcode":"00","entrymode":"Moto","merchid":"496160873888","token":"41-1fEVcban-1111","authcode":"PPS202","respproc":"FNOR","bintype":"","retref":"282091210827","respstat":"A","account":"41-1fEVcban-1111"}');
        res.setStatusCode(200);
        return res;          
    }
}