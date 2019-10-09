@IsTest
public class LeadTrgTest 
{
	@TestSetup static void createTestSetupData()
    {
        Account Customeracct = UtilityTest.createDealerAccount();
        Lead lea = UtilityTest.createLead();
        UtilityTest.CreateAgencyZipCodeAssignment();
    }
    
    // Test Method to convert lead to account.
    @isTest static void testCheckAccountRecordTypeForLead()
    {
        Test.startTest();
        	Account acc = [select Id, Name from Account limit 1];
            Lead lea = [Select Id,Name,LeadSource,status,Region__c,PostalCode from Lead limit 1];
        	Industry_Region_Wise_Rep__c ind = new Industry_Region_Wise_Rep__c();
        	ind.Region__c = 'Midwest';
        	ind.User__c = Userinfo.getUserId();
        	insert ind;
        	lea.PostalCode = '220067';
        	Update lea;
        	
        	lea.LeadSource = 'Pardot';
        	lea.status = 'Qualified';
        	Update lea;
            
        	Database.LeadConvert lc = new database.LeadConvert();
            LeadStatus status = [SELECT Id,MasterLabel FROM LeadStatus WHERE IsConverted = TRUE LIMIT 1];
            lc.setLeadId(lea.Id);
            lc.setDoNotCreateOpportunity(true);
            lc.setAccountId(acc.id);
            lc.setOverwriteLeadSource(true);
        	lc.setConvertedStatus(status.MasterLabel);
        	
        	Database.LeadConvertResult lcr = Database.convertLead(lc);
        	System.assertEquals(true, lcr.isSuccess());

        Test.stopTest();
    }
}