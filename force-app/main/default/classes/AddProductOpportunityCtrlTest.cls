/************************
Author:         Azfer Pervaiz
Created Date:   08/Aug/2018 
Purpose:        AddProductOpportunityCtrlTest Test class for the AddProductOpportunityCtrl.

************************MODIFICATION HISTORY**************************************
Added on             Added By               Description
**********************************************************************************
08/Aug/2018          Azfer Pervaiz          Initial Development 
***********************************************************************************/
@isTest
public class AddProductOpportunityCtrlTest {

	@isTest static void InitCtrlTest() {

    	Account AccountObj = UtilityTest.CreateAccount( 'Test Account',true);
		Opportunity OpportunityObj = UtilityTest.CreateDisplayOpportunity( AccountObj.Id );

        Test.startTest();
	    AddProductOpportunityCtrl.InitCtrl( OpportunityObj.Id );
        Test.stopTest();
    }

    @isTest static void AddProductCtrlTest() {

    	Account AccountObj = UtilityTest.CreateAccount( 'Test Account',true);
		Opportunity OpportunityObj = UtilityTest.CreateDisplayOpportunity( AccountObj.Id );

    	List<AddProductOpportunityCtrl.OpportunityProductWrapper> ListOpportunityProductWrapper = AddProductOpportunityCtrl.InitCtrl( OpportunityObj.Id );
        String JSONStringListOpportunityProductWrapper = JSON.serialize( ListOpportunityProductWrapper );

        Test.startTest();
        AddProductOpportunityCtrl.AddProductCtrl( JSONStringListOpportunityProductWrapper );
        Test.stopTest();
    }

    @isTest static void SaveProductCtrlReturnListTest() {

    	Account AccountObj = UtilityTest.CreateAccount( 'Test Account',true);
		Opportunity OpportunityObj = UtilityTest.CreateDisplayOpportunity( AccountObj.Id );

    	List<AddProductOpportunityCtrl.OpportunityProductWrapper> ListOpportunityProductWrapper = AddProductOpportunityCtrl.InitCtrl( OpportunityObj.Id );
        
        //Pricebook2 Pricebook2Obj = UtilityTest.CreatePriceBook('Test Pricebook2');
        
        Id StdPriceBookId = Test.getStandardPricebookId();
		Product2 Product2Obj = UtilityTest.createGroheProduct();
        //UtilityTest.createPricebookEntry( StdPriceBookId, Product2Obj );
		for( AddProductOpportunityCtrl.OpportunityProductWrapper OpportunityProductWrapperObj : ListOpportunityProductWrapper ){
			OpportunityProductWrapperObj.ProductCode = Product2Obj.SAP_Product_Code__c;
			OpportunityProductWrapperObj.ProductQuantity = 10;
			OpportunityProductWrapperObj.ProductAlterNumber = 10;
		}

		ListOpportunityProductWrapper[0].ProductCode = 'Test';
		ListOpportunityProductWrapper[0].ProductQuantity = 0;
        
        String JSONStringListOpportunityProductWrapper = JSON.serialize( ListOpportunityProductWrapper );

        Test.startTest();
		AddProductOpportunityCtrl.SaveProductCtrl( OpportunityObj.Id, 'Standard Price Book', JSONStringListOpportunityProductWrapper );
        Test.stopTest();

    }

    @isTest static void SaveProductCtrlTest() {

    	Account AccountObj = UtilityTest.CreateAccount( 'Test Account',true);
		Opportunity OpportunityObj = UtilityTest.CreateDisplayOpportunity( AccountObj.Id );

    	List<AddProductOpportunityCtrl.OpportunityProductWrapper> ListOpportunityProductWrapper = AddProductOpportunityCtrl.InitCtrl( OpportunityObj.Id );
        
        //Pricebook2 Pricebook2Obj = UtilityTest.CreatePriceBook('Test Pricebook2');
        
        Id StdPriceBookId = Test.getStandardPricebookId();
        
		Product2 Product2Obj = UtilityTest.createGroheProduct();
        //UtilityTest.createPricebookEntry( StdPriceBookId, Product2Obj );
		for( AddProductOpportunityCtrl.OpportunityProductWrapper OpportunityProductWrapperObj : ListOpportunityProductWrapper ){
			OpportunityProductWrapperObj.ProductCode = Product2Obj.SAP_Product_Code__c;
			OpportunityProductWrapperObj.ProductQuantity = 10;
			OpportunityProductWrapperObj.ProductAlterNumber = 10;
		}
        
        String JSONStringListOpportunityProductWrapper = JSON.serialize( ListOpportunityProductWrapper );

        Test.startTest();
		AddProductOpportunityCtrl.SaveProductCtrl( OpportunityObj.Id, 'Standard Price Book', JSONStringListOpportunityProductWrapper );
        Test.stopTest();

    }

    @isTest static void CheckPastedDateCtrlTest() {
        Account AccountObj = UtilityTest.CreateAccount( 'Test Account',true);
		Opportunity OpportunityObj = UtilityTest.CreateDisplayOpportunity( AccountObj.Id );

        String StringTableData = '<tr><td>Test</td><td>10</td></tr><tr><td>Test</td><td>10</td><td>10</td></tr><tr><td></td></tr>';

        Test.startTest();
		AddProductOpportunityCtrl.CheckPastedDateCtrl( OpportunityObj.Id, StringTableData );
        Test.stopTest();
    }

}