@isTest
public class QuoteUpdateTrg_Test {
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
            Quote quote1 = UtilityTest.createStandardQuote(StdPriceBookId, acc1.Id, OppProj);
            Product2 ASProd = UtilityTest.createAmericanStandardProduct(StdPriceBookId);
            QuoteLineItem qli1 = UtilityTest.createQLI(StdPriceBookId,quote1,ASProd);
            
            test.startTest();
            Order ord1 = UtilityTest.CreateOrder(acc1.Id,quote1.Id,StdPriceBookId);
            OrderItem orditem1 = UtilityTest.CreateOrderItem(quote1.Id,qli1.Id,ASProd.Id,ord1.Id);
            quote1.Unique_id__c = '0507525556';
            quote1.Num_Approvals__c = 0;
            quote1.Status = 'Processed';
            quote1.Review_Price__c = True;
            update quote1;
            
            test.stopTest();
        }
    }
    
    @isTest static void testUpdateQuote(){ 
        Quote qot = [select Id,Account__c, Num_Approvals__c,recordtypeid,Status from Quote limit 1];
        Quote_Account_Update__c qa = new Quote_Account_Update__c();
        
        qa.Account__c = qot.Account__c;
        qa.Quote__c = qot.Id;
        
        insert qa;
        
    }
}