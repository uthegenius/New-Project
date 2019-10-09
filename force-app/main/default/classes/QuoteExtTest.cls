@isTest
public class QuoteExtTest {  
    
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
    
    @isTest static void testEveryDayPrice(){             
        Test.startTest();
        Quote qot = [select Id, Num_Approvals__c,recordtypeid,Status from Quote limit 1];        
        ApexPages.StandardController sc = new ApexPages.StandardController(qot);        
        QuoteExt qe = new QuoteExt(sc);
        qe.getEverydayPrice();
        Test.stopTest(); 
    }
    
    @isTest static void testQuoteApproval(){             
        Test.startTest();
        Quote qot = [select Id, Num_Approvals__c,recordtypeid,Status from Quote limit 1];        
        ApexPages.StandardController sc = new ApexPages.StandardController(qot);        
        QuoteExt qe = new QuoteExt(sc);
        // qe.getEverydayPrice();
        qe.reviewPrice();       
        qe.quoteRefresh();    
        qe.submitForApproval();
        qe.createAndEmailQuotePDFonButtonClick();
        Test.stopTest(); 
    }
    @isTest static void testFinalQuote(){
        Test.startTest();        
        Quote qot = [select Id, Num_Approvals__c,recordtypeid,Status from Quote limit 1];          
        QuoteExt.createFolderinBox(qot.id);
        set<Id> setId = new set<Id>();
        setid.add(qot.id);
        QuoteExt.createFolderinBox(setid,'Quote');
        ApexPages.StandardController sc = new ApexPages.StandardController(qot);        
        QuoteExt qe = new QuoteExt(sc);
        
        qe.markQuoteAsFinal();
        qot.RecordTypeId = Schema.SObjectType.Quote.getRecordTypeInfosByName().get('Final Quote').getRecordTypeId();
        qot.Final_Quote__c = true;
        qot.Status = 'Processed';
        update qot;
        Id StdPriceBookId = UtilityTest.getStandardPBId();
        Product2 ASProd = [select Id from Product2 Limit 1];        
        QuoteLineItem qli1 = UtilityTest.createQLI(StdPriceBookId,qot,ASProd);
        qe.getstrRecordType();        
        qe.setstrRecordType(qot.recordtypeid);
        qe.getItems();        
        QuoteExt.ProductDetails a = new QuoteExt.ProductDetails();
        qe.geterrorMessage();
        qe.seterrorMessage();
        qe.CheckPRoductPrices();
        
        qe.submittoSAP();
        qe.createAndEmailQuotePDFonButtonClick();
        
        Test.stopTest(); 
    }
    /*
@isTest static void testQuoteValidate(){
Test.startTest();
Test.setMock(HttpCalloutMock.class, new Informatica_WebserviceMock());
Quote qot = [select Id, Num_Approvals__c,recordtypeid from Quote limit 1];        
ApexPages.StandardController sc = new ApexPages.StandardController(qot);        
QuoteExt qe = new QuoteExt(sc);
qe.quoteRefresh();
qe.getEverydayPrice();
qe.reviewPrice();
qe.submitForApproval();
qe.markQuoteAsFinal();
QuoteExt.createFolderinBox(qot.id);
qe.createAndEmailQuotePDFonButtonClick();
qe.submittoSAP();
qe.CheckPRoductPrices();
qe.getstrRecordType();        
qe.setstrRecordType(qot.recordtypeid);
qe.getItems();        
QuoteExt.ProductDetails a = new QuoteExt.ProductDetails();
qe.geterrorMessage();
qe.seterrorMessage();
Test.stopTest(); 
}    
*/
    /*  @isTest static void testQuoteProcess(){        
Test.startTest();
Test.setMock(HttpCalloutMock.class, new Informatica_WebserviceMock());
Quote qot = [select Id, Num_Approvals__c from Quote limit 1];        
ApexPages.StandardController sc = new ApexPages.StandardController(qot);        
QuoteExt qe = new QuoteExt(sc);
qe.quoteRefresh();
qe.getEverydayPrice();
qot.Get_Everyday_Price__c=true;
update qot;
qe = new QuoteExt(sc);
qe.reviewPrice();
qot.Num_Approvals__c=0;
qot.Review_Price__c = true;
update qot;
qe = new QuoteExt(sc);
qe.submitForApproval();
qot.Status = 'Processed';
qot.Unique_id__c = '0507525556';
qot.SAP_Price_Review_Process_Response__c = 'Quote created';
update qot;        
qe = new QuoteExt(sc);
qe.markQuoteAsFinal();
qot.Final_Quote__c = true;
Id fqId = [Select Id From RecordType where DeveloperName = 'Final_Quote'][0].Id;
qot.RecordTypeId = fqId;
update qot;        
qe = new QuoteExt(sc);
qe.submittoSAP();
qe = new QuoteExt(sc);
qe.CheckPRoductPrices();        
qe.setstrRecordType('Standard_Quote');
qe.getstrRecordType();
qe.getItems();        
QuoteExt.ProductDetails a = new QuoteExt.ProductDetails();
qe.geterrorMessage();
qe.seterrorMessage();
Test.stopTest(); 
}    


@isTest static void testFinalQuote(){        
Test.startTest();
Test.setMock(HttpCalloutMock.class, new Informatica_WebserviceMock());
Quote qot = [select Id, Num_Approvals__c from Quote limit 1];        
ApexPages.StandardController sc = new ApexPages.StandardController(qot);        
QuoteExt qe = new QuoteExt(sc);       
qe.markQuoteAsFinal();
qot.Final_Quote__c = true;
Id fqId = [Select Id From RecordType where DeveloperName = 'Final_Quote'][0].Id;
qot.RecordTypeId = fqId;
update qot;
}    
*/
    @isTest static void testQuoteClone(){
        Test.startTest();
        Quote qot = [select Id, Num_Approvals__c from Quote limit 1];        
        ApexPages.StandardController sc = new ApexPages.StandardController(qot);        
        QuoteExt qe = new QuoteExt(sc);
        qe.setstrRecordType('Standard_Quote');
        qe.getstrRecordType();
        Product2 ASProd = [select Id from Product2 Limit 1];
        ASProd.isActive = False;
        update ASProd;
        qe.cloneQuote();
        //qe.cloneQuotewithQLI();
        Test.stopTest();
    }
    @isTest static void testQuoteClone2(){
        Test.startTest();
        Quote qot = [select Id, Num_Approvals__c from Quote limit 1];        
        ApexPages.StandardController sc = new ApexPages.StandardController(qot);        
        QuoteExt qe = new QuoteExt(sc);
        qe.setstrRecordType('Standard_Quote');
        qe.getstrRecordType();
        qe.cloneQuote();
        //qe.cloneQuotewithQLI();
        Test.stopTest();
    }
    @isTest static void testCalculatePrice()
    {
        Test.startTest();
        Quote qot = [select Id, Num_Approvals__c from Quote limit 1];
        
        
        Test.stopTest(); 
    }    
    
    @isTest static void testShipQLI()
    {
        Test.startTest();
        QuoteLineItem qli = [select Id, Quantity, Shipped_Quantity__c from QuoteLineItem limit 1];
        qli.Quantity = 1;
        qli.Shipped_Quantity__c = 2;
        update qli;
        
        Test.stopTest(); 
    } 
    
    @isTest static void testRejectQuote()
    {
        Test.startTest();
        Quote qot = [select Id, Status from Quote limit 1];
        qot.Status = 'Rejected';
        update qot;
        
        Test.stopTest(); 
    }   
    
    @isTest static void testDeleteQuote()
    {
        Test.startTest();
        Quote qot = [select Id, Status from Quote limit 1];
        delete qot;
        
        Test.stopTest(); 
    }     
    
    @isTest static void testAssignApprovers()
    {
        
        Opportunity opp = [select Id from Opportunity limit 1];
        Project__c prj = [Select Id, First_Level_Approver__c, Second_Level_Approver__c, Third_Level_Approver__c from Project__c limit 1];
        
        Quote qot = new Quote();
        qot.Name = 'Test Quote';
        qot.OpportunityId = opp.Id;
        qot.Status = 'Draft';
        Test.startTest();
        qot.RecordTypeId = Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName().get('Standard_Quote').getRecordTypeId();
        qot.ExpirationDate = Date.today().AddMonths(1);
        
        Id stdPriceBookId = Test.getStandardPricebookId();
        qot.Pricebook2Id = stdPriceBookId;
        
        qot.First_Level_Approver__c = prj.First_Level_Approver__c;
        qot.Second_Level_Approver__c = prj.Second_Level_Approver__c;
        qot.Third_Level_Approver__c = prj.Third_Level_Approver__c;
        
        insert qot;
        
        Test.stopTest(); 
    }
}