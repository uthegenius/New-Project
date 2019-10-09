/************************
Author:         Azfer Pervaiz
Created Date:   08/Aug/2018 
Purpose:        AddProductOrderCtrlTest Test class for the AddProductOrderCtrl.

************************MODIFICATION HISTORY**************************************
Added on             Added By               Description
**********************************************************************************
08/Aug/2018          Azfer Pervaiz          Initial Development 
***********************************************************************************/
@isTest
public class AddProductOrderCtrlTest {
    static Account anAccount = new Account();
    //Create Sample Data 
    @TestSetup static void createTestSetupData(){
        Id StdPriceBookId = UtilityTest.getStandardPBId();
        anAccount = UtilityTest.createCustomerAccount();
        Product2 ASProd = UtilityTest.createAmericanStandardProduct(StdPriceBookId);
        List<sObject> ls = Test.loadData(Order_Cost_Center_Setup__c.sObjectType, 'TestData_OrderLogic'); 
    }
    
    @isTest static void InitCtrlTest() {
        
        Account anAccount = [select id from account limit 1][0];
        Contact con = UtilityTest.CreateContact(anAccount.Id,'Consumer');
        User aUser = UtilityTest.createUser();
        System.runAs(aUser){
            Product2 prod = UtilityTest.createGroheProduct();
            
            Asset ast = new Asset();
            ast.Name = 'Test Asset';
            ast.Quantity = 1;
            ast.Sub_Channels__c = 'Project';
            ast.AccountId = anAccount.Id;
            ast.Product2Id = prod.Id;
            ast.PurchaseDate = System.Date.today();
            ast.InstallDate =System.Date.today();
            ast.ContactId = con.Id;
            insert ast; 
            
            Case aCase = UtilityTest.CreateMultipleCase( anAccount.Id, 
                                                        Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Technical_Support').getRecordTypeId(),
                                                        1,
                                                        True)[0];
            aCase.contactId=con.Id;
            aCase.AssetId = ast.Id;
            Update aCase;
            Order anOrder = UtilityTest.CreateOrder(aCase.Id,
                                                    anAccount.Id,
                                                    Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('Good_Will_Order').getRecordTypeId(),
                                                    False);
            anOrder.Region__c = 'USA';
            anOrder.Call_Center__c = 'US - Tech';
            anOrder.Order_Type__c = 'Parts in SAP-974440000-ZCRS';
            anOrder.Order_Sub_Type__c = 'ZCRS';
            anOrder.isSent_To_SAP__c=True;
            insert anOrder;
            
            Test.startTest();
            AddProductOrderCtrl.InitCtrl( anOrder.Id );
            Test.stopTest();
        }
    }
    
    @isTest static void AddProductCtrlTest() {
        
        Account anAccount = [select id from account limit 1][0];
        Contact con = UtilityTest.CreateContact(anAccount.Id,'Consumer');
        User aUser = UtilityTest.createUser();
        System.runAs(aUser){
            
        Product2 prod = UtilityTest.createGroheProduct();
        
        Asset ast = new Asset();
        ast.Name = 'Test Asset';
        ast.Quantity = 1;
        ast.Sub_Channels__c = 'Project';
        ast.AccountId = anAccount.Id;
        ast.Product2Id = prod.Id;
        ast.PurchaseDate = System.Date.today();
        ast.InstallDate =System.Date.today();
		ast.ContactId = con.Id;            
        insert ast;            
            
            Case aCase = UtilityTest.CreateMultipleCase( anAccount.Id, 
                                                        Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Technical_Support').getRecordTypeId(),
                                                        1,
                                                        True)[0];
            aCase.contactId=con.Id;
            aCase.AssetId = ast.Id;
            Update aCase;
            Order anOrder = UtilityTest.CreateOrder(aCase.Id,
                                                    anAccount.Id,
                                                    Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('Good_Will_Order').getRecordTypeId(),
                                                    False);
            anOrder.Region__c = 'USA';
            anOrder.Call_Center__c = 'US - Tech';
            anOrder.Order_Type__c = 'Parts in SAP-974440000-ZCRS';
            anOrder.Order_Sub_Type__c = 'ZCRS';
            anOrder.isSent_To_SAP__c=True;
            insert anOrder;
            
            List<AddProductOrderCtrl.OrderItemWrapper> ListOrderItemWrapper = AddProductOrderCtrl.InitCtrl( anOrder.Id );
            String JSONStringListOrderItemWrapper = JSON.serialize( ListOrderItemWrapper );
            
            Test.startTest();
            AddProductOrderCtrl.AddProductCtrl( JSONStringListOrderItemWrapper );
            Test.stopTest();
        }
    }
    
    @isTest static void SaveProductCtrlReturnListTest() {
        
        Account anAccount = [select id from account limit 1][0];
        Product2 Product2Obj = UtilityTest.createGroheProduct();
        Contact con = UtilityTest.CreateContact(anAccount.Id,'Consumer');
        User aUser = UtilityTest.createUser();
        System.runAs(aUser){
        
        Asset ast = new Asset();
        ast.Name = 'Test Asset';
        ast.Quantity = 1;
        ast.Sub_Channels__c = 'Project';
        ast.AccountId = anAccount.Id;
        ast.Product2Id = Product2Obj.Id;
        ast.PurchaseDate = System.Date.today();
        ast.InstallDate =System.Date.today();
		ast.ContactId = con.Id;            
        insert ast;             
            Case aCase = UtilityTest.CreateMultipleCase( anAccount.Id, 
                                                        Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Technical_Support').getRecordTypeId(),
                                                        1,
                                                        True)[0];
            aCase.contactId=con.Id;
            aCase.AssetId = ast.Id;
            Update aCase;
            Order anOrder = UtilityTest.CreateOrder(aCase.Id,
                                                    anAccount.Id,
                                                    Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('Good_Will_Order').getRecordTypeId(),
                                                    False);
            anOrder.Region__c = 'USA';
            anOrder.Call_Center__c = 'US - Tech';
            anOrder.Order_Type__c = 'Parts in SAP-974440000-ZCRS';
            anOrder.Order_Sub_Type__c = 'ZCRS';
            anOrder.isSent_To_SAP__c=True;
            insert anOrder;
            List<AddProductOrderCtrl.OrderItemWrapper> ListOrderItemWrapper = AddProductOrderCtrl.InitCtrl( anOrder.Id );
            
            for( AddProductOrderCtrl.OrderItemWrapper OrderItemWrapperObj : ListOrderItemWrapper ){
                OrderItemWrapperObj.ProductCode = Product2Obj.SAP_Product_Code__c;
                OrderItemWrapperObj.ProductQuantity = 10;
                //OrderItemWrapperObj.ProductAlterNumber = 10;
            }
            
            ListOrderItemWrapper[0].ProductCode = 'Test';
            ListOrderItemWrapper[0].ProductQuantity = 0;
            
            String JSONStringListOrderItemWrapper = JSON.serialize( ListOrderItemWrapper );
            
            Test.startTest();
            AddProductOrderCtrl.SaveProductCtrl( anOrder.Id, 'Standard Price Book', JSONStringListOrderItemWrapper );
            Test.stopTest();
        }
    }
    
    @isTest static void SaveProductCtrlReturnListTest2() {
        
        Account anAccount = [select id from account limit 1][0];
        Product2 Product2Obj = UtilityTest.createGroheProduct();
        Product2Obj.Description='d';
        update Product2Obj;
        Contact con = UtilityTest.CreateContact(anAccount.Id,'Consumer');
        User aUser = UtilityTest.createUser();
        System.runAs(aUser){
            Asset ast = new Asset();
            ast.Name = 'Test Asset';
            ast.Quantity = 1;
            ast.Sub_Channels__c = 'Project';
            ast.AccountId = anAccount.Id;
            ast.Product2Id = Product2Obj.Id;
            ast.PurchaseDate = System.Date.today();
            ast.InstallDate =System.Date.today();
			ast.ContactId = con.Id;            
            insert ast;            
            Case aCase = UtilityTest.CreateMultipleCase( anAccount.Id, 
                                                        Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Technical_Support').getRecordTypeId(),
                                                        1,
                                                        True)[0];
            aCase.contactId=con.Id;
            aCase.AssetId = ast.Id;
            Update aCase;
            Order anOrder = UtilityTest.CreateOrder(aCase.Id,
                                                    anAccount.Id,
                                                    Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('Good_Will_Order').getRecordTypeId(),
                                                    False);
            anOrder.Region__c = 'USA';
            anOrder.Call_Center__c = 'US - Tech';
            anOrder.Order_Type__c = 'Parts in SAP-974440000-ZCRS';
            anOrder.Order_Sub_Type__c = 'ZCRS';
            anOrder.isSent_To_SAP__c=True;
            anOrder.CurrencyISOCode = 'USD';
            anOrder.Pricebook2Id = null;
            insert anOrder;
            List<AddProductOrderCtrl.OrderItemWrapper> ListOrderItemWrapper = AddProductOrderCtrl.InitCtrl( anOrder.Id );
            
            for( AddProductOrderCtrl.OrderItemWrapper OrderItemWrapperObj : ListOrderItemWrapper ){
                OrderItemWrapperObj.ProductCode = Product2Obj.SAP_Product_Code__c;
                OrderItemWrapperObj.ProductQuantity = 10;
                //OrderItemWrapperObj.ProductAlterNumber = 10;
            }
            
            ListOrderItemWrapper[0].ProductCode = 'Test';
            ListOrderItemWrapper[0].ProductQuantity = 0;
            
            String JSONStringListOrderItemWrapper = JSON.serialize( ListOrderItemWrapper );
            
            Test.startTest();
            AddProductOrderCtrl.SaveProductCtrl( anOrder.Id, 'Standard Price Book', JSONStringListOrderItemWrapper );
            Test.stopTest();
        }
    }
    
    @isTest static void SaveProductCtrlTest() {
        
        Account anAccount = [select id from account limit 1][0];
        Product2 Product2Obj = UtilityTest.createGroheProduct();
        Contact con = UtilityTest.CreateContact(anAccount.Id,'Consumer');
        User aUser = UtilityTest.createUser();
        System.runAs(aUser){
            Asset ast = new Asset();
            ast.Name = 'Test Asset';
            ast.Quantity = 1;
            ast.Sub_Channels__c = 'Project';
            ast.AccountId = anAccount.Id;
            ast.Product2Id = Product2Obj.Id;
            ast.PurchaseDate = System.Date.today();
            ast.InstallDate =System.Date.today();
			ast.ContactId = con.Id;            
            insert ast;             
            Case aCase = UtilityTest.CreateMultipleCase( anAccount.Id, 
                                                        Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Technical_Support').getRecordTypeId(),
                                                        1,
                                                        True)[0];
            aCase.contactId=con.Id;
            aCase.AssetId = ast.Id;
            Update aCase;
            Order anOrder = UtilityTest.CreateOrder(aCase.Id,
                                                    anAccount.Id,
                                                    Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('Good_Will_Order').getRecordTypeId(),
                                                    False);
            anOrder.Region__c = 'USA';
            anOrder.Call_Center__c = 'US - Tech';
            anOrder.Order_Type__c = 'Parts in SAP-974440000-ZCRS';
            anOrder.Order_Sub_Type__c = 'ZCRS';
            anOrder.isSent_To_SAP__c=True;
            insert anOrder;
            List<AddProductOrderCtrl.OrderItemWrapper> ListOrderItemWrapper = AddProductOrderCtrl.InitCtrl( anOrder.Id );
            
            for( AddProductOrderCtrl.OrderItemWrapper OrderItemWrapperObj : ListOrderItemWrapper ){
                OrderItemWrapperObj.ProductCode = Product2Obj.SAP_Product_Code__c;
                OrderItemWrapperObj.ProductQuantity = 10;
                //OrderItemWrapperObj.ProductAlterNumber = 10;
            }
            
            String JSONStringListOrderItemWrapper = JSON.serialize( ListOrderItemWrapper );
            
            Test.startTest();
            AddProductOrderCtrl.SaveProductCtrl( anOrder.Id, 'Standard Price book', JSONStringListOrderItemWrapper );
            Test.stopTest();
        }
    }
    
    @isTest static void SaveProductCtrlWithOrderWithOutPBTest() {
        
        Account anAccount = [select id from account limit 1][0];
        Product2 Product2Obj = UtilityTest.createGroheProduct();
        Contact con = UtilityTest.CreateContact(anAccount.Id,'Consumer');
        User aUser = UtilityTest.createUser();
        System.runAs(aUser){
            Asset ast = new Asset();
            ast.Name = 'Test Asset';
            ast.Quantity = 1;
            ast.Sub_Channels__c = 'Project';
            ast.AccountId = anAccount.Id;
            ast.Product2Id = Product2Obj.Id;
            ast.PurchaseDate = System.Date.today();
            ast.InstallDate =System.Date.today();
            ast.ContactId = con.Id; 
            insert ast;             
            Case aCase = UtilityTest.CreateMultipleCase( anAccount.Id, 
                                                        Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Technical_Support').getRecordTypeId(),
                                                        1,
                                                        True)[0];
            aCase.contactId=con.Id;
            aCase.AssetId = ast.Id;
            Update aCase;
            Order anOrder = UtilityTest.CreateOrder(aCase.Id,
                                                    anAccount.Id,
                                                    Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('Good_Will_Order').getRecordTypeId(),
                                                    False);
            anOrder.Region__c = 'USA';
            anOrder.Call_Center__c = 'US - Tech';
            anOrder.Order_Type__c = 'Parts in SAP-974440000-ZCRS';
            anOrder.Order_Sub_Type__c = 'ZCRS';
            anOrder.isSent_To_SAP__c=True;
            insert anOrder;
            
            List<AddProductOrderCtrl.OrderItemWrapper> ListOrderItemWrapper = AddProductOrderCtrl.InitCtrl( anOrder.Id );
            
            for( AddProductOrderCtrl.OrderItemWrapper OrderItemWrapperObj : ListOrderItemWrapper ){
                OrderItemWrapperObj.ProductCode = Product2Obj.SAP_Product_Code__c;
                OrderItemWrapperObj.ProductQuantity = 10;
                // OrderItemWrapperObj.ProductAlterNumber = 10;
            }
            
            String JSONStringListOrderItemWrapper = JSON.serialize( ListOrderItemWrapper );
            
            Test.startTest();
            AddProductOrderCtrl.SaveProductCtrl( anOrder.Id, 'Standard Price Book', JSONStringListOrderItemWrapper );
            Test.stopTest();
        }
    }
    
    
    
    @isTest static void CheckPastedDateCtrlTest() {
        
        Account anAccount = [select id from account limit 1][0];
        Product2 Product2Obj = UtilityTest.createGroheProduct();
        Contact con = UtilityTest.CreateContact(anAccount.Id,'Consumer');
        User aUser = UtilityTest.createUser();
        System.runAs(aUser){
            Asset ast = new Asset();
            ast.Name = 'Test Asset';
            ast.Quantity = 1;
            ast.Sub_Channels__c = 'Project';
            ast.AccountId = anAccount.Id;
            ast.Product2Id = Product2Obj.Id;
            ast.PurchaseDate = System.Date.today();
            ast.InstallDate =System.Date.today();
            ast.ContactId = con.Id; 
            insert ast;             
            Case aCase = UtilityTest.CreateMultipleCase( anAccount.Id, 
                                                        Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Technical_Support').getRecordTypeId(),
                                                        1,
                                                        True)[0];
            aCase.contactId=con.Id;
            aCase.AssetId = ast.Id;
            Update aCase;
            Order anOrder = UtilityTest.CreateOrder(aCase.Id,
                                                    anAccount.Id,
                                                    Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('Good_Will_Order').getRecordTypeId(),
                                                    False);
            anOrder.Region__c = 'USA';
            anOrder.Call_Center__c = 'US - Tech';
            anOrder.Order_Type__c = 'Parts in SAP-974440000-ZCRS';
            anOrder.Order_Sub_Type__c = 'ZCRS';
            anOrder.isSent_To_SAP__c=True;
            insert anOrder;
            String StringTableData = '<tr><td>Test</td><td>10</td></tr><tr><td>Test</td><td>10</td><td>10</td></tr><tr><td></td></tr>';
            
            Test.startTest();
            AddProductOrderCtrl.CheckPastedDateCtrl( anOrder.Id, StringTableData );
            Test.stopTest();
        }
    }
    
    
    @isTest static void UpdateEveryDayPriceTest() {
        
        Account anAccount = [select id from account limit 1][0];
        Product2 Product2Obj = UtilityTest.createGroheProduct();
        Contact con = UtilityTest.CreateContact(anAccount.Id,'Consumer');
        User aUser = UtilityTest.createUser();
        System.runAs(aUser){
            Asset ast = new Asset();
            ast.Name = 'Test Asset';
            ast.Quantity = 1;
            ast.Sub_Channels__c = 'Project';
            ast.AccountId = anAccount.Id;
            ast.Product2Id = Product2Obj.Id;
            ast.PurchaseDate = System.Date.today();
            ast.InstallDate =System.Date.today();
            ast.ContactId = con.Id; 
            insert ast;             
            Case aCase = UtilityTest.CreateMultipleCase( anAccount.Id, 
                                                        Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Technical_Support').getRecordTypeId(),
                                                        1,
                                                        True)[0];
            aCase.contactId=con.Id;
            aCase.AssetId = ast.Id;
            Update aCase;
            Order anOrder = UtilityTest.CreateOrder(aCase.Id,
                                                    anAccount.Id,
                                                    Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('Good_Will_Order').getRecordTypeId(),
                                                    False);
            anOrder.Region__c = 'USA';
            anOrder.Call_Center__c = 'US - Tech';
            anOrder.Order_Type__c = 'Parts in SAP-974440000-ZCRS';
            anOrder.Order_Sub_Type__c = 'ZCRS';
            anOrder.isSent_To_SAP__c=True;
            insert anOrder;
            Test.startTest();
        	Test.setMock(HttpCalloutMock.class, new Informatica_Order_Mock());
            AddProductOrderCtrl.UpdateOrderSimulator( anOrder.Id );
            Test.stopTest();
        }
    }
}