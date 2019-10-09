@isTest
public class AttachmentToBoxTest 
{
	@isTest
    static void createPDFInBoxAndEmailTest()
    {
    	Test.startTest();
        Blob blb = Blob.valueOf('Test data for attachment');
        
        Account acc1 = UtilityTest.createCustomerAccount();
        
        Attachment att = new Attachment();
        att.ParentId = acc1.Id;
        att.Body = blb;
        att.Name = 'Test Attachment';
        insert att;
        
        box__FRUP__c frup = new box__FRUP__c();
		frup.box__Object_Name__c = 'Account';
    	frup.box__Folder_ID__c = '123'; 
    	frup.box__Record_ID__c = acc1.Id;      
        insert frup;
        
        AttachmentToBox.createPDFInBoxAndEmail(acc1.Id, acc1.Id);
        Test.stopTest();
    }
}