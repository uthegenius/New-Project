@isTest
public class FSTHandlerTest {
    
    @TestSetup static void createTestSetupData()
    {
         String authResponse2 = BoxTestJsonResponseFactory.AUTH_USER_TOKEN;
         Test.setMock(HttpCalloutMock.class, new BoxTestMockCallout(authResponse2, 'OK', 200)); 
        
        Account ac = UtilityTest.CreateAccount('TestAccount', true);
        Contact cc = UtilityTest.CreateContact(ac.id,'Other');
        List<Case> csList2 = new List<Case>();
        csList2 = UtilityTest.CreateMultipleCase(null,
                                                     Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Technical_Support').getRecordTypeId(),
                                                     1,
                                                     true);
        
        
        Field_Service_Ticket__c fst = UtilityTest.createFieldServiceTicket(cc.id,
                                             Schema.SObjectType.Field_Service_Ticket__c.getRecordTypeInfosByDeveloperName().get('FST_US').getRecordTypeId(),
                                             csList2[0].id,
                                            false
                                            );
        
        fst.Business_Name__c='Test';
        fst.Approved__c=false;
        fst.Negotiated_Labor_Cost__c=500;
        insert fst;
              
    }
    public static  TestMethod void testFst2(){
        
        Field_Service_Ticket__c fst = [select id from Field_Service_Ticket__c limit 1];        
        fst.Approved__c=true;
        Test.startTest();
                 String authResponse2 = BoxTestJsonResponseFactory.AUTH_USER_TOKEN;
         Test.setMock(HttpCalloutMock.class, new BoxTestMockCallout(authResponse2, 'OK', 200)); 
        update fst;
        Test.stopTest();
    }

}