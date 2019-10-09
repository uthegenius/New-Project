@isTest
public class QuoteLineItemTriggerHandlerTest 
{
    @TestSetup static void createTestSetupData(){
        Id StdPriceBookId = UtilityTest.getStandardPBId();
        Project__c proj = UtilityTest.createProject();
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        System.runAs ( thisUser ) {
            Project_Team__c projTeamMember1 = UtilityTest.createProjectTeam(proj.Id);            
            Account acc1 = UtilityTest.createCustomerAccount();            
            acc1.Brand__c = 'American Standard;Grohe;FIAT';
            update acc1;
            Wholesalers__c ws1 = UtilityTest.createWholesaler(acc1.Id, proj.Id);
            
            Opportunity OppProj = UtilityTest.createProjectOpportunity(proj.Id);   
            test.startTest();
            Quote quote1 = UtilityTest.createStandardQuote(StdPriceBookId, acc1.Id, OppProj);
            Product2 prod = UtilityTest.createAmericanStandardProduct(StdPriceBookId);
            Product2 prod1 = UtilityTest.createAmericanStandardProduct(StdPriceBookId);
            QuoteLineItem qli2 = UtilityTest.createQLI(StdPriceBookId, quote1,prod,10);
            QuoteLineItem altqli = UtilityTest.createQLI(StdPriceBookId, quote1,prod1,20);  
            
            /*
            Order ord1 = UtilityTest.CreateOrder(acc1.Id,quote1.Id,StdPriceBookId);
            OrderItem orditem1 = UtilityTest.CreateOrderItem(quote1.Id,qli2.Id,prod.Id,ord1.Id);
            quote1.Unique_id__c = '0507525556';
            quote1.Num_Approvals__c = 0;
            quote1.Status = 'Processed';
            quote1.Review_Price__c = True;
            update quote1;
            */
            test.stopTest();
        }
    }
    
    @istest static void testConsolidatedQLI()
    {        
        QuoteLineItem qli2 = [select Id, Alternate__c, Product2Id,QuoteId from QuoteLIneItem where Line_Number__c = 10 limit 1];
        
        QuoteLineItem altqli = [select Id, Alternate__c, Product2Id from QuoteLIneItem where Line_Number__c = 20 limit 1];
        
        altqli.Alternate__c = qli2.Product2Id;
        update altqli;
        Test.startTest();
        Quote qot = new quote(Id=qli2.QuoteId);
        Id fqId = [Select Id From RecordType where DeveloperName = 'Final_Quote'][0].Id;
        qot.Consolidation__c = True;
        update qot;
        Test.stopTest();
    }
}