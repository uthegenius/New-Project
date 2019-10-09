@isTest
public class QuoteLineItemTrgTest 
{
    @TestSetup static void createTestSetupData()
    {
        Account acct = UtilityTest.createCustomerAccount();
        //Account acct2 = UtilityTest.createCustomerAccount();
        Project__c prj = UtilityTest.createProject();

        User approver1 = UtilityTest.createUser();
        prj.First_Level_Approver__c = approver1.Id;        
        
        User approver2 = UtilityTest.createUser();
        prj.Second_Level_Approver__c = approver2.Id;
        
        User approver3 = UtilityTest.createUser();
        prj.Third_Level_Approver__c = approver3.Id;        
        
        update prj;
        
        
        
        Project_Team__c pt = UtilityTest.createProjectTeam(prj.Id);
        Wholesalers__c ws = UtilityTest.createWholesaler(acct.Id, prj.Id);
        Test.startTest();
        Opportunity opp = UtilityTest.createProjectOpportunity(prj.Id);

        Id spbId = UtilityTest.getStandardPBId();
        Product2 prod = UtilityTest.createAmericanStandardProduct(spbId);
        
        
       
        Quote qot = UtilityTest.createStandardQuote(spbId, acct, opp);
        Quote qot2 = UtilityTest.createInfluencerQuote(spbId, acct.id, opp);
        qot2.Budget__c=4;
        update qot2;
        
        
        QuoteLineItem qli = UtilityTest.createQLI(spbId, qot,prod);
        Test.stopTest();
    }
    
    @isTest public static void testUpdateGM()
    {
        Test.startTest();
        QuotelineItem qli = [select Id, GM__c, GM_Percentage__c from QuotelineItem limit 1];
         
        qli.GM__c = 10;
        qli.GM_Percentage__c = 10;
        qli.Everyday_Price__c = 111;
        qli.Num_Approvals__c = 0;
        update qli;
        Test.stopTest();
    }
    
    @isTest public static void testDeleteQLI()
    {
        Test.startTest();
        QuotelineItem qli = [select Id, GM__c, GM_Percentage__c from QuotelineItem limit 1];

        delete qli;
        Test.stopTest();

    }   
    
    
}