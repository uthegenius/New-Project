@istest
public class WarrantyRegController_Test {
    
    private static testmethod void testMethod1()
    {
        Test.startTest();
        Account anAccount = UtilityTest.createCustomerAccount();
        Case aCase = UtilityTest.CreateMultipleCase( anAccount.Id, 
                                                    Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Technical_Support').getRecordTypeId(),
                                                    1,
                                                    False)[0];
        Contact cc = UtilityTest.CreateConsumerContact(anAccount.id,'Consumer');
        aCase.ContactId=cc.id;
        aCase.Model_SKU__c='1234';
        aCase.Product_Purchase_Date__c=date.today();
        PageReference pageref = Page.WarrantyRegistration;
        Test.setCurrentPage(pageref);
        WarrantyRegistrationController caseCtrl = new WarrantyRegistrationController();
        
        Product2  pr = UtilityTest.createProduct(false);
        pr.SAP_Product_Code__c='1234';
        pr.Brand__c='American Standard';
        insert pr;
        


        
        Asset anAsset = new Asset(
        AccountId=anAccount.Id,
        Product2Id=pr.id,
        PurchaseDate=date.today(),
        ContactId=cc.id,
        Name = 'Test Asset11'
        );
        anAsset.Quantity = 1;
        anAsset.PurchaseDate = System.Date.today();
        anAsset.InstallDate =System.Date.today();        
        insert anAsset;
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