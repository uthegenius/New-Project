/************************
Author:         Azfer Pervaiz
Created Date:   14/Aug/2018 
Purpose:        OpportunityTrgHandlerTest is the test class for the handler OpportunityTrgHandler.

************************MODIFICATION HISTORY**************************************
Added on             Added By               Description
**********************************************************************************
14/Aug/2018          Azfer Pervaiz          Initial Development 
***********************************************************************************/
@isTest
public class OpportunityTrgHandlerTest {

	@isTest static void OppTrg_InsertTest() {

    	Account AccountObj = UtilityTest.CreateAccount( 'Test Account', true);

        Test.startTest();
		Opportunity OpportunityObj = UtilityTest.CreateDisplayOpportunity( AccountObj.Id );
        Test.stopTest();
    }

    @isTest static void OppTrg_DeleteTest() {

    	Account AccountObj = UtilityTest.CreateAccount( 'Test Account', true);

		Opportunity OpportunityObj = UtilityTest.CreateDisplayOpportunity( AccountObj.Id );
        Test.startTest();
        Database.delete(OpportunityObj,false);
        Test.stopTest();
    }

    @isTest static void OppTrg_UpdateStageTest() {

    	Account AccountObj = UtilityTest.CreateAccount( 'Test Account', true);

        User usr = UtilityTest.createUser();
        
		Opportunity OpportunityObj = UtilityTest.CreateDisplayOpportunity( AccountObj.Id );
        OpportunityObj.Responsible__c = usr.Id;
        
        OpportunityObj.StageName = 'Confirming Display';
        Test.startTest();
        update OpportunityObj;
        Test.stopTest();
    }

    @isTest static void OppTrg_UpdateStageToClosedWonTest() {
		Test.startTest();
    	Account AccountObj = UtilityTest.CreateAccount( 'Test Account', true);
        
        Id StdPriceBookId = UtilityTest.getStandardPBId();
        Product2 ASProd = UtilityTest.createAmericanStandardProduct(StdPriceBookId);
        Product2 GroheProd = UtilityTest.createGroheProduct();		

		Opportunity OpportunityObj = UtilityTest.CreateDisplayOpportunity( AccountObj.Id );
        Wholesalers__c ws = UtilityTest.createWholesaler(AccountObj.Id, OpportunityObj.Project__c);     
        Quote QuoteObj = UtilityTest.createStandardQuote(StdPriceBookId, AccountObj, OpportunityObj);
        
        QuoteLineItem QuoteLineItemObj1 = UtilityTest.createQLI(StdPriceBookId,QuoteObj,ASProd);
        //QuoteLineItem QuoteLineItemObj2 = UtilityTest.createQLI(StdPriceBookId,QuoteObj,GroheProd);

        OpportunityObj.StageName = 'Closed Won';
        
        
        update OpportunityObj;
        Test.stopTest();
    }

    @isTest static void OppTrg_AfterInsertTest() {

    	UtilityTest.CreateAgencyZipCodeAssignment();
        UtilityTest.CreateTeamAssignmentRule();
		
		Account AccountObj = UtilityTest.CreateAccount('Test Account1', false);
        AccountObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Influencer').getRecordTypeId();
        AccountObj.ShippingPostalCode = 'TEST';

        insert AccountObj;

        Test.startTest();
		Opportunity OpportunityObj = UtilityTest.CreateDisplayOpportunity( AccountObj.Id );
        Test.stopTest();
    }


    @isTest static void OppTrg_BeforeUpdateTest() {

    	UtilityTest.CreateAgencyZipCodeAssignment();
        UtilityTest.CreateTeamAssignmentRule();
		
		Account AccountObj = UtilityTest.CreateAccount('Test Account1', false);
        AccountObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Influencer').getRecordTypeId();
        AccountObj.ShippingPostalCode = 'TEST';

        insert AccountObj;
        AccountObj.Sales_Region__c='Midwest';
        update AccountObj;
		Opportunity OpportunityObj = UtilityTest.CreateDisplayOpportunity( AccountObj.Id );
        
        Test.startTest();
		OpportunityObj.AccountSalesRegionUpdated__c = true;
		update OpportunityObj;
        Test.stopTest();
    }

    @isTest static void OppTrg_BeforeUpdateRecordTypeTest() {

    	UtilityTest.CreateAgencyZipCodeAssignment();
        UtilityTest.CreateTeamAssignmentRule();
		Account AccountObj = UtilityTest.CreateAccount('Test Account1', false);
        AccountObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Influencer').getRecordTypeId();
        AccountObj.ShippingPostalCode = 'TEST';

        insert AccountObj;

        Account AccountObj2 = UtilityTest.CreateAccount('Test Account1', false);
        AccountObj2.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Influencer').getRecordTypeId();
        AccountObj2.ShippingPostalCode = 'TEST';

        insert AccountObj2;
		Opportunity OpportunityObj = UtilityTest.CreateInitiativeOpportunity( AccountObj.Id );
        OpportunityObj.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Display').getRecordTypeId();
        
        Test.startTest();
		OpportunityObj.AccountSalesRegionUpdated__c = true;
		OpportunityObj.AccountId = AccountObj2.Id;
        
		update OpportunityObj;
        Test.stopTest();
    }

    
    
}