@istest
public class ContactTrgTest 
{
    @TestSetup static void createTestSetupData()
    {
        Account acc = UtilityTest.createCustomerAccount();
        Contact con = UtilityTest.CreateContact(acc.Id,'Consumer');
        Agency_Zip_Code_Assignment__c azca = new Agency_Zip_Code_Assignment__c();
        azca.Region__c = 'Northeast';
        azca.ZipCode__c = '08854';
        insert azca;
        Industry_Region_Wise_Rep__c irwr = new Industry_Region_Wise_Rep__c();
        irwr.Region__c = 'Northeast';
        irwr.User__c = Userinfo.getUserId();
        insert irwr;
    }
    
    @isTest static void testUpdateProduct()
    {
        Test.startTest();
            Contact con = [Select Id,Name,Contact_Activity_in_Pardot__c from Contact limit 1];
            con.MailingPostalCode = '08854';
        	con.Contact_Activity_in_Pardot__c = 'Form Filled';
        	Update con;
        	con.Contact_Activity_in_Pardot__c = 'No Activity';
        	Update con;
        	con.Contact_Activity_in_Pardot__c = 'Hot Contact';
        	Update con;
        	con.Unqualified_Prospect_Status__c = '90 Days Prior';
        	Update con;
        	con.Unqualified_Prospect_Status__c = 'Launch Day';
        	Update con;
        Test.stopTest();
    }
	
}