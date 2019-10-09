/************************
Author:         Azfer Pervaiz
Created Date:   05/July/2018 
Purpose:        AddProductCampaignCtrlTest this test class if for test coverage of AddProductCampaignCtrl class.

************************MODIFICATION HISTORY**************************************
Added on             Added By               Description
**********************************************************************************
05/July/2018           Azfer Pervaiz          Initial Development 
***********************************************************************************/
@isTest
public class AddProductCampaignCtrlTest {

	@isTest static void InitCtrlTest() {
        Campaign CampaignObj = new Campaign(); 
        CampaignObj.RecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Initiative').getRecordTypeId();
        CampaignObj.Name = 'Test Campaign Name';
        CampaignObj.EndDate = Date.today().addYears(1);
        CampaignObj.Sales_Deal__c = 'Test Sales Text';

        insert CampaignObj;
        
        Test.startTest();
        
        AddProductCampaignCtrl.InitCtrl( CampaignObj.Id );
        
        Test.stopTest();
    }


    @isTest static void AddProductCtrlTest() {
        Campaign CampaignObj = new Campaign(); 
        CampaignObj.RecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Initiative').getRecordTypeId();
        CampaignObj.Name = 'Test Campaign Name';
        CampaignObj.EndDate = Date.today().addYears(1);
        CampaignObj.Sales_Deal__c = 'Test Sales Text';

        insert CampaignObj;
        
        List<AddProductCampaignCtrl.CampaignProductWrapper> ListCampaignProductWrapper = AddProductCampaignCtrl.InitCtrl( CampaignObj.Id );

        String JSONStringListCampaignProductWrapper = JSON.serialize( ListCampaignProductWrapper );

        Test.startTest();
        
		AddProductCampaignCtrl.AddProductCtrl( JSONStringListCampaignProductWrapper );
        
        Test.stopTest();
    }

    @isTest static void SaveProductCtrlReturnListTest() {
        Campaign CampaignObj = new Campaign(); 
        CampaignObj.RecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Initiative').getRecordTypeId();
        CampaignObj.Name = 'Test Campaign Name';
        CampaignObj.EndDate = Date.today().addYears(1);
        CampaignObj.Sales_Deal__c = 'Test Sales Text';

        insert CampaignObj;

        //Pricebook2 Pricebook2Obj = UtilityTest.CreatePriceBook('Test Pricebook2');
		Product2 Product2Obj = UtilityTest.createGroheProduct();
        
        Id StdPriceBookId = Test.getStandardPricebookId();
        
        //UtilityTest.createPricebookEntry( StdPriceBookId, Product2Obj );

        List<AddProductCampaignCtrl.CampaignProductWrapper> ListCampaignProductWrapper = AddProductCampaignCtrl.InitCtrl( CampaignObj.Id );
		
		for( AddProductCampaignCtrl.CampaignProductWrapper CampaignProductWrapperObj : ListCampaignProductWrapper ){
			CampaignProductWrapperObj.ProductCode = Product2Obj.SAP_Product_Code__c;
			CampaignProductWrapperObj.ProductQuantity = 10;
			CampaignProductWrapperObj.CampaignPrice = 10;
		}

		ListCampaignProductWrapper[0].ProductCode = '00';
		ListCampaignProductWrapper[0].ProductQuantity = 00;
		ListCampaignProductWrapper[0].CampaignPrice = 00;
        
        String JSONStringListCampaignProductWrapper = JSON.serialize( ListCampaignProductWrapper );

        Test.startTest();
		
		AddProductCampaignCtrl.SaveProductCtrl( CampaignObj.Id, 'Standard Price Book', JSONStringListCampaignProductWrapper );
        
        Test.stopTest();
    }

    @isTest static void SaveProductCtrlTest() {
        Campaign CampaignObj = new Campaign(); 
        CampaignObj.RecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Initiative').getRecordTypeId();
        CampaignObj.Name = 'Test Campaign Name';
        CampaignObj.EndDate = Date.today().addYears(1);
        CampaignObj.Sales_Deal__c = 'Test Sales Text';

        insert CampaignObj;

        //Pricebook2 Pricebook2Obj = UtilityTest.CreatePriceBook('Test Pricebook2');
		Product2 Product2Obj = UtilityTest.createGroheProduct();
        
        
        Id StdPriceBookId = Test.getStandardPricebookId();
        //UtilityTest.createPricebookEntry( StdPriceBookId, Product2Obj );

        List<AddProductCampaignCtrl.CampaignProductWrapper> ListCampaignProductWrapper = AddProductCampaignCtrl.InitCtrl( CampaignObj.Id );
		
		for( AddProductCampaignCtrl.CampaignProductWrapper CampaignProductWrapperObj : ListCampaignProductWrapper ){
			CampaignProductWrapperObj.ProductCode = Product2Obj.SAP_Product_Code__c;
			CampaignProductWrapperObj.ProductQuantity = 10;
			CampaignProductWrapperObj.CampaignPrice = 10;
		}

        String JSONStringListCampaignProductWrapper = JSON.serialize( ListCampaignProductWrapper );

        Test.startTest();
		
		AddProductCampaignCtrl.SaveProductCtrl( CampaignObj.Id, 'Standard Price Book', JSONStringListCampaignProductWrapper );
        
        Test.stopTest();
    }

    @isTest static void CheckPastedDateCtrlTest() {
        Campaign CampaignObj = new Campaign(); 
        CampaignObj.RecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Initiative').getRecordTypeId();
        CampaignObj.Name = 'Test Campaign Name';
        CampaignObj.EndDate = Date.today().addYears(1);
        CampaignObj.Sales_Deal__c = 'Test Sales Text';

        insert CampaignObj;

        String StringTableData = '<tr><td>Test</td><td>10</td></tr><tr><td></td></tr><tr><td>Test</td><td>10</td><td>10</td></tr><tr><td>Test</td><td>10</td><td>10</td></tr><tr><td>Test</td><td>10</td><td>10</td></tr>';

        Test.startTest();
		
		AddProductCampaignCtrl.CheckPastedDateCtrl( CampaignObj.Id, StringTableData );
        
        Test.stopTest();
    }
}