@isTest
public class Informatica_Quote_CalloutTest {
    @isTest static void Testsearchaddress() {
        String param ='Base Product';
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = 'callout:Informatica_Quote/active-bpel/soap/PriceReview';  
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Informatica_WebserviceMock());
        Informatica_Quote_Callout.call('0Q01k000000089zCAA','EP');
        Test.stopTest();
    }    

}