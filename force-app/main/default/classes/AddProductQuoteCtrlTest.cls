/************************
Author:         Azfer Pervaiz
Created Date:   08/Aug/2018 
Purpose:        AddProductQuoteCtrlTest Test class for the AddProductQuoteCtrl.

************************MODIFICATION HISTORY**************************************
Added on             Added By               Description
**********************************************************************************
08/Aug/2018          Azfer Pervaiz          Initial Development 
***********************************************************************************/
@isTest
public class AddProductQuoteCtrlTest {
    @isTest static void InitCtrlTest() {
        
        Account AccountObj = UtilityTest.CreateAccount( 'Test Account',true);
        
        Opportunity OpportunityObj = UtilityTest.CreateDisplayOpportunity( AccountObj.Id );
        Pricebook2 Pricebook2Obj = UtilityTest.CreatePriceBook('Test Pricebook2');
        
        Wholesalers__c ws = UtilityTest.createWholesaler(AccountObj.Id, OpportunityObj.Project__c);        
        
        Quote QuoteObj = UtilityTest.createStandardQuote( Pricebook2Obj.Id, AccountObj, OpportunityObj );
        
        Test.startTest();
        AddProductQuoteCtrl.InitCtrl( QuoteObj.Id );
        Test.stopTest();
    }
    
    @isTest static void AddProductCtrlTest() {
        Project__c prj = UtilityTest.createProjectWithApprovers();
        Account AccountObj = UtilityTest.createCustomerAccount();
        //Account acct = UtilityTest.createCustomerAccount();
        Wholesalers__c ws = UtilityTest.createWholesaler(AccountObj.Id, prj.Id);
        
        Opportunity OpportunityObj = UtilityTest.createProjectOpportunity(prj.Id);
        
        Pricebook2 Pricebook2Obj = UtilityTest.CreatePriceBook('Test Pricebook2');
        Product2 Product2Obj = UtilityTest.createGroheProduct();
        
        Quote QuoteObj = UtilityTest.createStandardQuote( Pricebook2Obj.Id, AccountObj, OpportunityObj );
        
        
        List<AddProductQuoteCtrl.QuoteProductWrapper> ListQuoteProductWrapper = AddProductQuoteCtrl.InitCtrl( QuoteObj.Id );
        String JSONStringListQuoteProductWrapper = JSON.serialize( ListQuoteProductWrapper );
        
        Test.startTest();
        AddProductQuoteCtrl.AddProductCtrl( JSONStringListQuoteProductWrapper );
        Test.stopTest();
    }
    
    @isTest static void SaveProductCtrlReturnListTest() {
        Project__c prj = UtilityTest.createProjectWithApprovers();
        Account AccountObj = UtilityTest.createCustomerAccount();
        //Account acct = UtilityTest.createCustomerAccount();
        Wholesalers__c ws = UtilityTest.createWholesaler(AccountObj.Id, prj.Id);
        
        Opportunity OpportunityObj = UtilityTest.createProjectOpportunity(prj.Id);
        
        Pricebook2 Pricebook2Obj = UtilityTest.CreatePriceBook('Test Pricebook2');
        Product2 Product2Obj = UtilityTest.createGroheProduct();
        UtilityTest.createPricebookEntry( Pricebook2Obj.Id, Product2Obj );
        
        Quote QuoteObj = UtilityTest.createStandardQuote( Pricebook2Obj.Id, AccountObj, OpportunityObj );
        
        QuoteObj.Final_Quote__c = True;
        Update QuoteObj;
        List<AddProductQuoteCtrl.QuoteProductWrapper> ListQuoteProductWrapper = AddProductQuoteCtrl.InitCtrl( QuoteObj.Id );
        
        for( AddProductQuoteCtrl.QuoteProductWrapper QuoteProductWrapperObj : ListQuoteProductWrapper ){
            QuoteProductWrapperObj.ProductCode = Product2Obj.SAP_Product_Code__c;
            QuoteProductWrapperObj.ProductQuantity = 10;
            QuoteProductWrapperObj.ProductAlterNumber = 10;
        }
        
        ListQuoteProductWrapper[0].ProductCode = 'Test';
        ListQuoteProductWrapper[0].ProductQuantity = 0;
        
        String JSONStringListQuoteProductWrapper = JSON.serialize( ListQuoteProductWrapper );
        
        Test.startTest();
        AddProductQuoteCtrl.SaveProductCtrl( QuoteObj.Id, Pricebook2Obj.Name, JSONStringListQuoteProductWrapper );
        Test.stopTest();
        
    }
    
    
    @isTest static void SaveProductCtrlTest() {
        
        Account AccountObj = UtilityTest.CreateAccount( 'Test Account',true);
        Opportunity OpportunityObj = UtilityTest.CreateDisplayOpportunity( AccountObj.Id );
        Wholesalers__c ws = UtilityTest.createWholesaler(AccountObj.Id, OpportunityObj.Project__c);    
        //Pricebook2 Pricebook2Obj = UtilityTest.CreatePriceBook('Test Pricebook2');
        Product2 Product2Obj = UtilityTest.createGroheProduct();
        
        Id spbId = Test.getStandardPricebookId();
        //UtilityTest.createPricebookEntry( spbId, Product2Obj );
        
        Quote QuoteObj = UtilityTest.createStandardQuote( spbId, AccountObj, OpportunityObj );
        
        List<AddProductQuoteCtrl.QuoteProductWrapper> ListQuoteProductWrapper = AddProductQuoteCtrl.InitCtrl( QuoteObj.Id );
        
        for( AddProductQuoteCtrl.QuoteProductWrapper QuoteProductWrapperObj : ListQuoteProductWrapper ){
            QuoteProductWrapperObj.ProductCode = Product2Obj.SAP_Product_Code__c;
            QuoteProductWrapperObj.ProductQuantity = 10;
            QuoteProductWrapperObj.ProductAlterNumber = 10;
        }
        
        String JSONStringListQuoteProductWrapper = JSON.serialize( ListQuoteProductWrapper );
        
        Test.startTest();
        RequestStatus mstatus = AddProductQuoteCtrl.SaveProductCtrl( QuoteObj.Id, 'Standard Price Book', JSONStringListQuoteProductWrapper );
        system.debug(mstatus);
        Test.stopTest();
        
    }
    
    @isTest static void SaveProductCtrlWithoutPBTest() {
        
        Account AccountObj = UtilityTest.CreateAccount( 'Test Account',true);
        Opportunity OpportunityObj = UtilityTest.CreateDisplayOpportunity( AccountObj.Id );
        Wholesalers__c ws = UtilityTest.createWholesaler(AccountObj.Id, OpportunityObj.Project__c);    
        Pricebook2 Pricebook2Obj = UtilityTest.CreatePriceBook('Test Pricebook2');
        Product2 Product2Obj = UtilityTest.createGroheProduct();
        UtilityTest.createPricebookEntry( Pricebook2Obj.Id, Product2Obj );
        
        Quote QuoteObj = UtilityTest.createStandardQuote( Pricebook2Obj.Id, AccountObj, OpportunityObj );
        //QuoteObj.Final_Quote__c = True;
        QuoteObj.Pricebook2Id=null;
        Update QuoteObj;
        List<AddProductQuoteCtrl.QuoteProductWrapper> ListQuoteProductWrapper = AddProductQuoteCtrl.InitCtrl( QuoteObj.Id );
        
        for( AddProductQuoteCtrl.QuoteProductWrapper QuoteProductWrapperObj : ListQuoteProductWrapper ){
            QuoteProductWrapperObj.ProductCode = Product2Obj.SAP_Product_Code__c;
            QuoteProductWrapperObj.ProductQuantity = 10;
            QuoteProductWrapperObj.ProductAlterNumber = 10;
        }
        
        ListQuoteProductWrapper[0].ProductCode = 'Test';
        ListQuoteProductWrapper[0].ProductQuantity = 0;
        
        String JSONStringListQuoteProductWrapper = JSON.serialize( ListQuoteProductWrapper );
        
        Test.startTest();
        AddProductQuoteCtrl.SaveProductCtrl( QuoteObj.Id, Pricebook2Obj.Name, JSONStringListQuoteProductWrapper );
        Test.stopTest();
        
    }
    
    
    
    @isTest static void CheckPastedDateCtrlTest() {
        Account AccountObj = UtilityTest.CreateAccount( 'Test Account',true);
        Opportunity OpportunityObj = UtilityTest.CreateDisplayOpportunity( AccountObj.Id );
        //Pricebook2 Pricebook2Obj = UtilityTest.CreatePriceBook('Test Pricebook2');
        Wholesalers__c ws = UtilityTest.createWholesaler(AccountObj.Id, OpportunityObj.Project__c);    
        Id spbId = Test.getStandardPricebookId();
        Quote QuoteObj = UtilityTest.createStandardQuote( spbId, AccountObj , OpportunityObj );
        
        String StringTableData = '<tr><td>Test</td><td>10</td></tr><tr><td>Test</td><td>10</td><td>10</td></tr><tr><td></td></tr>';
        
        Test.startTest();
        AddProductQuoteCtrl.CheckPastedDateCtrl( QuoteObj.Id, StringTableData );
        Test.stopTest();
    }
    
    
    @isTest static void UpdateEveryDayPriceTest() {
        Account AccountObj = UtilityTest.CreateAccount( 'Test Account',true);
        Opportunity OpportunityObj = UtilityTest.CreateDisplayOpportunity( AccountObj.Id );
        //Pricebook2 Pricebook2Obj = UtilityTest.CreatePriceBook('Test Pricebook2');
        Wholesalers__c ws = UtilityTest.createWholesaler(AccountObj.Id, OpportunityObj.Project__c);    
        Id spbId = Test.getStandardPricebookId();
        Quote QuoteObj = UtilityTest.createStandardQuote( spbId, AccountObj, OpportunityObj );
        Test.setMock(HttpCalloutMock.class, new Informatica_WebserviceMock());
        Test.startTest();
        AddProductQuoteCtrl.UpdateEveryDayPrice( QuoteObj.Id );
        Test.stopTest();
    }    
}