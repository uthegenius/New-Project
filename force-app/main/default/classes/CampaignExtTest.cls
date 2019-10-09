@isTest
public class CampaignExtTest 
{
    @TestSetup static void createTestSetupDate()
    {
        Account acct = UtilityTest.createCustomerAccount();
		Account acct2 = UtilityTest.createCustomerAccount();
        Account acct3 = UtilityTest.createCustomerAccount();
        User accountTeamMember = UtilityTest.createUser();
        
        String teamMemberRole = 'Regional Showroom Manager	';
        
        String accountAccessLevel = 'Edit', opportunityAccessLevel = 'Edit', caseAccessLevel = 'None';

        AccountTeamMember atm = new AccountTeamMember(AccountId = acct.id, TeamMemberRole = teamMemberRole, UserId= accountTeamMember.Id);
        
        AccountShare acctShare = new AccountShare(AccountAccessLevel = 'Edit', OpportunityAccessLevel = 'Edit', CaseAccessLevel = 'Edit', UserOrGroupId = accountTeamMember.Id, AccountId = acct.id);
        
        insert atm;
        insert acctShare;
        
        Contact cont = UtilityTest.CreateContact(acct.Id, 'Wholesaler');
        
        Contact contGM = UtilityTest.CreateContact(acct2.Id, 'Wholesaler');
        Contact contRSM = UtilityTest.CreateContact(acct3.Id, 'Wholesaler');
        
        acct.General_Manager__c = contGM.Id;
        acct.Regional_Showroom_manager__c = contRSM.Id;
        update acct;         
        
        Id spbId = UtilityTest.getStandardPBId();
        Product2 prod = UtilityTest.createAmericanStandardProduct(spbId);        
    }
    
    @isTest static void testExecuteDisplayCampaign()
    {
        Test.startTest();
        
        Campaign cam = UtilityTest.createCampaign('Display');
        
        Product2 prod = [select Id from Product2 limit 1];
        
        Campaign_Products__c cp = UtilityTest.createCampaignProduct(cam.Id, prod.Id);
        
        Account acct = [select Id from Account limit 1];
        
        Contact cont = [select Id from Contact limit 1];
        
        CampaignMember cm = UtilityTest.createCampaignMember(cam.Id, acct.Id, cont.Id);
        ApexPages.StandardController sc = new ApexPages.StandardController(cam);
        CampaignExt ce = new CampaignExt(sc);
        
        PageReference pageRef = Page.ExecuteCampaignVF;
        pageRef.getParameters().put('id', String.valueOf(cam.Id));
        Test.setCurrentPage(pageRef);
        //ce.executeCampaign(); 
        //cam.Status = 'In progress';
        //Update cam;
        //Campaign cam = [select Id, Reason_Code__c, Sales_Deal__c, EndDate, Name from Campaign limit 1];
        
        
        
        //ce.executeCampaign();        
  		
        CampaignExt.setCollaboration(acct.id);
        Test.stopTest();
    }
    
    @isTest static void testExecuteInitiativeCampaign()
    {
        Test.startTest();
        
        Campaign cam = UtilityTest.createCampaign('Initiative');
        
        Product2 prod = [select Id from Product2 limit 1];
        
        Campaign_Products__c cp = UtilityTest.createCampaignProduct(cam.Id, prod.Id);
        
        Account acct = [select Id from Account limit 1];
        
        Contact cont = [select Id from Contact limit 1];
      
        CampaignMember cm = UtilityTest.createCampaignMember(cam.Id, acct.Id, cont.Id);
        //cam.Status = 'In progress';
        //Update cam;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(cam);
        CampaignExt ce = new CampaignExt(sc);
        
        PageReference pageRef = Page.ExecuteCampaignVF;
        pageRef.getParameters().put('id', String.valueOf(cam.Id));
        Test.setCurrentPage(pageRef);
        
        //ce.executeCampaign();        
  
        
        Test.stopTest();
    }    
}