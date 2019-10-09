@istest
public class ContactUsController_Test {
    
    private static testmethod void testMethod1()
    {
        Test.startTest();
        Account anAccount = UtilityTest.createCustomerAccount();
        Case aCase = UtilityTest.CreateMultipleCase( anAccount.Id, 
                                                    Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Technical_Support').getRecordTypeId(),
                                                    1,
                                                    False)[0];
        PageReference pageref = Page.ContactUsVf;
        Test.setCurrentPage(pageref);
        ContactUsController caseCtrl = new ContactUsController();
        caseCtrl.c = aCase;
        
        caseCtrl.attachment1.Name = 'unit test Attachment';
        caseCtrl.attachment1.Body = Blob.valueOf('unit test Attachment Body');
        
        caseCtrl.attachment2.Name = 'unit test Attachment';
        caseCtrl.Attachment2.Body = Blob.valueOf('unit test Attachment Body');
        
        caseCtrl.Attachment3.Name = 'unit test Attachment';
        caseCtrl.Attachment3.Body = Blob.valueOf('unit test Attachment Body');
        
        caseCtrl.Attachment4.Name = 'unit test Attachment';
        caseCtrl.Attachment4.Body = Blob.valueOf('unit test Attachment Body');
        
        caseCtrl.Attachment5.Name = 'unit test Attachment';
        caseCtrl.Attachment5.Body = Blob.valueOf('unit test Attachment Body');
        Test.stopTest();
        
        String authResponse = BoxTestJsonResponseFactory.AUTH_USER_TOKEN;
        Test.setMock(HttpCalloutMock.class, new BoxTestMockCallout(authResponse, 'OK', 200)); 
        caseCtrl.upload();
        
    }
    

}