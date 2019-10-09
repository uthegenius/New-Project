/************************
Author:         Abid Raza
Created Date:   21/Aug/2018 
Purpose:        Test class to cover code coverage of Product Discontinuation batch class.
************************/


@isTest
public class ProductDiscontinuationEmailBatchTest 
{
    //Create Sample Data 
    @TestSetup static void createTestSetupData()
    {
        List<sObject> ls = Test.loadData(ProjectTeamApprover__c.sObjectType, 'TestData_ProjectTeam_Approver'); 
        Id StdPriceBookId = UtilityTest.getStandardPBId();
        Project__c proj = UtilityTest.createProject();
        Project_Team__c projTeamMember1 = UtilityTest.createProjectTeam(proj.Id);
        //Project_Team__c projTeamMember2 = UtilityTest.createProjectTeam(proj.Id);
        Account acc = UtilityTest.createCustomerAccount();
        Wholesalers__c ws1 = UtilityTest.createWholesaler(acc.Id, proj.Id);
        
        
        Opportunity OppProj = UtilityTest.createProjectOpportunity(proj.Id);
        Quote quote1 = UtilityTest.createStandardQuote(StdPriceBookId, acc, OppProj);
        Product2 ASProd = UtilityTest.createAmericanStandardProduct(StdPriceBookId);
        QuoteLineItem qli1 = UtilityTest.createQLI(StdPriceBookId,quote1,ASProd);
        
        Test.startTest();
        Opportunity Opp = UtilityTest.CreateDisplayOpportunity(acc.Id);
        Wholesalers__c ws = UtilityTest.createWholesaler(acc.Id, opp.Project__c);
        
        OpportunityTeamMember OppTeamMember1 = UtilityTest.createOpportunityTeam(Opp.Id);
        //OpportunityTeamMember OppTeamMember2 = UtilityTest.createOpportunityTeam(Opp.Id);        
        
        Quote quote2 = UtilityTest.createStandardQuote(StdPriceBookId, acc, Opp);        
        Product2 GroheProd = UtilityTest.createGroheProduct();        
        QuoteLineItem qli2 = UtilityTest.createQLI(StdPriceBookId,quote2,GroheProd);
        Test.stopTest();
    }
    
    // Test Method check email sending to Project and Account Team about Product Discontinuation.
    @isTest static void testProductDisContinuationEmails()
    {        
        Test.startTest();
        set<Id> SetProductIds = new Set<Id>();
        for(Product2 prod: [Select Id,Name,Discontinue_date__c from Product2 limit 2])
        {
            SetProductIds.add(prod.Id);
        }
        if(SetProductIds.size() > 0)
        {
            Database.executeBatch(new ProductDiscontinuationEmailBatch(SetProductIds));
        }
        Test.stopTest();
        
    }
}