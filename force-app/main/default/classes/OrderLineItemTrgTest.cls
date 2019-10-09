@IsTest
public class OrderLineItemTrgTest 
{
    //Create Sample Data 
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
    
    // Test Method for order line item trigger code coverage.
    @isTest static void testProductDisContinuationEmails2(){
        Test.startTest();
        system.debug('hb^^^');
        Id StdPriceBookId = UtilityTest.getStandardPBId();
        
        Id AccountDealerId1;
        Id AccountCustomerId2;
        Id OppProjectId1;
        Id OppInitiativeId2;
        Id QuoteProjectId1;
        Id QuoteInitiativeId2;
        Id QuoteLineItemProjectId1;
        Id QuoteLineItemInitiativeId2;
        Id AmericanStandardProdId;
        Id GroheProdId;
        
        for( QuoteLineItem  QuoteLineItemObj : [SELECT Id, 
                                                Quote.Account__C, Quote.Account__r.RecordTypeDeveloperName__c, 
                                                Quote.OpportunityId, Quote.Opportunity.RecordTypeDeveloperName__c, 
                                                QuoteId 
                                                FROM QuoteLineItem 
                                                WHERE Quote.Account__C != null ])
        {
            AccountDealerId1 = QuoteLineItemObj.Quote.Account__C;            
            if( QuoteLineItemObj.Quote.Account__r.RecordTypeDeveloperName__c.toLowerCase() == 'dealer' ){
                AccountDealerId1 = QuoteLineItemObj.Quote.Account__C;
            }else{
                AccountCustomerId2 = QuoteLineItemObj.Quote.Account__C;
            }
            
            if( QuoteLineItemObj.Quote.Opportunity.RecordTypeDeveloperName__c.toLowerCase() == 'initiative' ){
                OppInitiativeId2 = QuoteLineItemObj.Quote.OpportunityId;
                QuoteInitiativeId2 = QuoteLineItemObj.QuoteId;
                QuoteLineItemInitiativeId2 = QuoteLineItemObj.Id;
            }
            else
            {
                OppProjectId1 = QuoteLineItemObj.Quote.OpportunityId;
                QuoteProjectId1 = QuoteLineItemObj.QuoteId;
                QuoteLineItemProjectId1 = QuoteLineItemObj.Id;
            }
        }
        
        
        for( Product2 ProductObj : [SELECT Id, Brand__c, SAP_Product_Code__C FROM Product2] ){
            if( ProductObj.Brand__c == 'American Standard' ){
                AmericanStandardProdId = ProductObj.Id; 
            }else{
                GroheProdId = ProductObj.Id;
            }
        }
        
        // OrderItem orditem2 = UtilityTest.CreateOrderItem(QuoteInitiativeId2,QuoteLineItemInitiativeId2,GroheProdId,ord2.Id);
        
        
        //Order ord1 = UtilityTest.CreateOrder(AccountDealerId1,QuoteProjectId1,StdPriceBookId);
        order ord1 = [select Id from order limit 1];
        //Order ord2 = UtilityTest.CreateOrder(AccountCustomerId2,QuoteInitiativeId2,StdPriceBookId);
        OrderItem orditem1 = UtilityTest.CreateOrderItem(QuoteProjectId1,QuoteLineItemProjectId1,AmericanStandardProdId,ord1.Id);
        
        List<OrderItem> ListOrderItems = [Select Id,Line_Status__c,Open_Quantity__c,Shipped_Quantities__c,Quantity,Remaining_Quantity__c from OrderItem Where OrderId = :ord1.Id limit 2];
        //List<OrderItem> lOI = new List<OrderItem>();
        
        if(ListOrderItems.size() > 0 && ListOrderItems != null)
        {
            for(OrderItem orditem:ListOrderItems)
            {
                orditem.Line_Status__c = 'Cancelled';
                orditem.Open_Quantity__c = 11;
                orditem.Quantity = 22;
                orditem.Remaining_Quantity__c = 11;
                orditem.Shipped_Quantities__c = 33;
                //lOI.add(orditem);
            }
            Update ListOrderItems;
            //update lOI;
            
        }
        Test.stopTest();
    }
    
    @isTest static void testUpdateORLI(){
        Test.startTest();
        List<OrderItem> ol = [Select Id,Line_Status__c from OrderItem limit 10];
        
        for(OrderItem orditem:ol){
           //orditem.Quantity = 0;
           orditem.Shipped_Quantities__c=0;
        }        
        update ol;        
        Test.stopTest();
    }
    
    
    @isTest static void testUpdateInitiiveORLI(){
        Test.startTest();
        List<OrderItem> ol = [Select Id,Line_Status__c from OrderItem limit 10];
        
        for(OrderItem orditem:ol){
           orditem.Line_Status__c = 'Cancelled';
        }        
        update ol;     
        Test.stopTest();
    }
    
}