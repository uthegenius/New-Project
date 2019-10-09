@IsTest
public class OrderTrg_Test {
    static Account anAccount = new Account();
    //Create Sample Data 
    @TestSetup static void createTestSetupData(){
        Id StdPriceBookId = UtilityTest.getStandardPBId();
        OrderTrg_Test.anAccount = UtilityTest.createCustomerAccount();
        Product2 ASProd = UtilityTest.createAmericanStandardProduct(StdPriceBookId);
        List<sObject> ls = Test.loadData(Order_Cost_Center_Setup__c.sObjectType, 'TestData_OrderLogic'); 
        system.debug(OrderTrg_Test.anAccount);
    }
    @isTest static void createOrderFromCaseValidation1() {
        anAccount = [select id from account limit 1][0];
        Contact con = UtilityTest.CreateContact(anAccount.Id,'Consumer');
        User aUser = UtilityTest.createUser();
        System.runAs(aUser){
            Product2 aProduct = UtilityTest.createAmericanStandardProduct(null);
            
        Asset ast = new Asset();
        ast.Name = 'Test Asset';
        ast.Quantity = 1;
        ast.Sub_Channels__c = 'Project';
        ast.AccountId = anAccount.Id;
        ast.Product2Id = aProduct.Id;
        ast.PurchaseDate = System.Date.today();
        ast.InstallDate =System.Date.today();
            ast.ContactId = con.Id;
        insert ast;
            
            Case aCase = UtilityTest.CreateMultipleCase( OrderTrg_Test.anAccount.Id,
                                                        Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Technical_Support').getRecordTypeId(),
                                                        1,
                                                        True)[0];
            aCase.contactId=con.Id;
            aCase.AssetId = ast.Id;
            Update aCase;
            
            Order anOrder = UtilityTest.CreateOrder(aCase.Id,
                                                    OrderTrg_Test.anAccount.Id,
                                                    Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('Good_Will_Order').getRecordTypeId(),
                                                    False);
            anOrder.Region__c = 'USA';
            anOrder.Call_Center__c = 'US - Tech';
            anOrder.Order_Type__c = 'Parts in SAP-974440000-ZCRS';
            anOrder.Order_Sub_Type__c = 'ZCRS';
            anOrder.isSent_To_SAP__c=True;
            insert anOrder;
            
            OrderItem anOrderLine = UtilityTest.CreateOrderItem(null,null,aProduct.Id,anOrder.Id);
            Test.startTest();
        	Test.setMock(HttpCalloutMock.class, new Informatica_Order_Mock());
            ConfirmationModalCtrl.callAction(anOrder.Id,'OSS');
            ConfirmationModalCtrl.callAction(anOrder.Id,'SSS');
            ConfirmationModalCtrl.callAction(anOrder.Id,'OSS');            
            ConfirmationModalCtrl.callAction(anOrder.Id,'GSD');
        	Test.stopTest();
        }
    }    
    @isTest static void createOrderFromCaseValidation2() {
        anAccount = [select id from account limit 1][0];
        Contact con = UtilityTest.CreateContact(anAccount.Id,'Consumer');
        User aUser = UtilityTest.createUser();
        System.runAs(aUser){
            Product2 aProduct = UtilityTest.createAmericanStandardProduct(null);
            
        Asset ast = new Asset();
        ast.Name = 'Test Asset';
        ast.Quantity = 1;
        ast.Sub_Channels__c = 'Project';
        ast.AccountId = anAccount.Id;
        ast.Product2Id = aProduct.Id;
        ast.PurchaseDate = System.Date.today();
        ast.InstallDate =System.Date.today();
            ast.ContactId = con.Id;
        insert ast;
            
            Case aCase = UtilityTest.CreateMultipleCase( OrderTrg_Test.anAccount.Id, 
                                                        Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Technical_Support').getRecordTypeId(),
                                                        1,
                                                        True)[0];
            aCase.contactId=con.Id;
            aCase.assetId = ast.Id;
            Update aCase;
            
            Order anOrder = UtilityTest.CreateOrder(aCase.Id,
                                                    OrderTrg_Test.anAccount.Id,
                                                    Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('Good_Will_Order').getRecordTypeId(),
                                                    False);
            anOrder.Region__c = 'USA';
            anOrder.Call_Center__c = 'US - Tech';
            anOrder.Order_Type__c = 'Non-Grohe-400211-FD';
            anOrder.Order_Sub_Type__c = 'DR';
            anOrder.Freight__c=0;
            insert anOrder;            
            
            OrderItem anOrderLine = UtilityTest.CreateOrderItem(null,null,aProduct.Id,anOrder.Id);
            Test.startTest();
        	Test.setMock(HttpCalloutMock.class, new Informatica_Order_Mock());
            ConfirmationModalCtrl.callAction(anOrder.Id,'SSS');
            ConfirmationModalCtrl.callAction(anOrder.Id,'OSS');            
            ConfirmationModalCtrl.callAction(anOrder.Id,'GSD');
        	Test.stopTest();
        }
    }
    @isTest static void createOrderFromCaseValidation3() {
        anAccount = [select id from account limit 1][0];
        Contact con = UtilityTest.CreateContact(anAccount.Id,'Consumer');
        User aUser = UtilityTest.createUser();
        System.runAs(aUser){
            Product2 aProduct = UtilityTest.createAmericanStandardProduct(null);
            
        Asset ast = new Asset();
        ast.Name = 'Test Asset';
        ast.Quantity = 1;
        ast.Sub_Channels__c = 'Project';
        ast.AccountId = anAccount.Id;
        ast.Product2Id = aProduct.Id;
        ast.PurchaseDate = System.Date.today();
        ast.InstallDate =System.Date.today();
            ast.ContactId = con.Id;
        insert ast;
            
            Case aCase = UtilityTest.CreateMultipleCase( OrderTrg_Test.anAccount.Id, 
                                                        Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Technical_Support').getRecordTypeId(),
                                                        1,
                                                        True)[0];
            
            aCase.contactId=con.Id;
            aCase.AssetId = ast.Id;
            Update aCase;
            
            Order anOrder = UtilityTest.CreateOrder(aCase.Id,
                                                    OrderTrg_Test.anAccount.Id,
                                                    Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('Good_Will_Order').getRecordTypeId(),
                                                    False);
            anOrder.Region__c = 'USA';
            anOrder.Call_Center__c = 'US - Tech';
            anOrder.Order_Type__c = 'Non-Grohe-400211-FD';
            anOrder.Order_Sub_Type__c = 'FD';
            anOrder.Order_SAP_ID__c = '0050700056';           
            insert anOrder;           
            
            
			anOrder.isOrder_Simulator__c = True; 
            anOrder.isOrderAmountApproved__c = True;
            update anOrder;
            
            OrderItem anOrderLine = UtilityTest.CreateOrderItem(null,null,aProduct.Id,anOrder.Id);
            Test.startTest();
        	Test.setMock(HttpCalloutMock.class, new Informatica_Order_Error_Mock());
            ConfirmationModalCtrl.callAction(anOrder.Id,'SSS');
            ConfirmationModalCtrl.callAction(anOrder.Id,'OSS');            
            ConfirmationModalCtrl.callAction(anOrder.Id,'GSD');
        	Test.stopTest();
        }
    }
    
    @isTest static void createOrderFromCase() {
        anAccount = [select id from account limit 1][0];
        Contact con = UtilityTest.CreateContact(anAccount.Id,'Consumer');
        User aUser = UtilityTest.createUser();
        System.runAs(aUser){
            Product2 aProduct = UtilityTest.createAmericanStandardProduct(null);
        Asset ast = new Asset();
        ast.Name = 'Test Asset';
        ast.Quantity = 1;
        ast.Sub_Channels__c = 'Project';
        ast.AccountId = anAccount.Id;
        ast.Product2Id = aProduct.Id;
        ast.PurchaseDate = System.Date.today();
        ast.InstallDate =System.Date.today();
            ast.ContactId = con.Id;
        insert ast;
            
            Case aCase = UtilityTest.CreateMultipleCase( OrderTrg_Test.anAccount.Id, 
                                                        Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Technical_Support').getRecordTypeId(),
                                                        1,
                                                        True)[0];
            aCase.contactId=con.Id;
            aCase.assetId = ast.id;
            Update aCase;
            
            Order anOrder = UtilityTest.CreateOrder(aCase.Id,
                                                    OrderTrg_Test.anAccount.Id,
                                                    Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('Good_Will_Order').getRecordTypeId(),
                                                    False);
            anOrder.Region__c = 'USA';
            anOrder.Call_Center__c = 'US - Tech';
            anOrder.Order_Type__c = 'Non-Grohe-400211-FD';
            anOrder.Order_Sub_Type__c = 'FD';
            anOrder.Order_SAP_ID__c = '0050700056';           
            insert anOrder;            
			anOrder.isOrder_Simulator__c = True; 
            anOrder.isOrderAmountApproved__c = True;
            update anOrder;
            
            OrderItem anOrderLine = UtilityTest.CreateOrderItem(null,null,aProduct.Id,anOrder.Id);
            Test.startTest();
        	Test.setMock(HttpCalloutMock.class, new Informatica_Order_Mock());
            ConfirmationModalCtrl.callAction(anOrder.Id,'SSS');
            ConfirmationModalCtrl.callAction(anOrder.Id,'OSS');            
            ConfirmationModalCtrl.callAction(anOrder.Id,'GSD');
        	Test.stopTest();
        }
    }
    @isTest static void CreditCardOrderFromCase() {
        anAccount = [select id from account limit 1][0];
        Contact con = UtilityTest.CreateContact(anAccount.Id,'Consumer');
        User aUser = UtilityTest.createUser();
        System.runAs(aUser){
            Case aCase = UtilityTest.CreateMultipleCase( OrderTrg_Test.anAccount.Id, 
                                                        Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Technical_Support').getRecordTypeId(),
                                                        1,
                                                        True)[0];
            aCase.contactId=con.Id;
            Update aCase;
            
            Order anOrder = UtilityTest.CreateOrder(aCase.Id,
                                                    OrderTrg_Test.anAccount.Id,
                                                    Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('Credit_Card_Sales').getRecordTypeId(),
                                                    False);
            anOrder.Region__c = 'USA';
            anOrder.Call_Center__c = 'US - Tech';
            anOrder.Order_Type__c = 'Non-Grohe-400211-FD';
            anOrder.Order_Sub_Type__c = 'FD';
            anOrder.Order_SAP_ID__c = '0050700056';           
            insert anOrder;            
			anOrder.isOrder_Simulator__c = True; 
            anOrder.isOrderAmountApproved__c = True;
            update anOrder;
            Test.startTest();
        	Test.setMock(HttpCalloutMock.class, new Informatica_Order_Mock());
            ConfirmationModalCtrl.callAction(anOrder.Id,'SSS');
            ConfirmationModalCtrl.callAction(anOrder.Id,'OSS');
        	Test.stopTest();
        }
    }
    
    @isTest static void submitDefectReturnCaseToSAP_Validate1(){
        anAccount = [select id from account limit 1][0];
        User aUser = UtilityTest.createUser();
        System.runAs(aUser){
            Case aCase = UtilityTest.CreateMultipleCase( OrderTrg_Test.anAccount.Id, 
                                                        Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Defect_Return').getRecordTypeId(),
                                                        1,
                                                        True)[0];
            aCase.isSent_To_SAP__c=True;
            Update aCase;
            Test.startTest();
        	Test.setMock(HttpCalloutMock.class, new Informatica_Order_Mock());                    
            ConfirmationModalCtrl.callAction(aCase.Id,'DSS');
        	Test.stopTest();
        }
    }
    @isTest static void submitDefectReturnCaseToSAP(){
        anAccount = [select id from account limit 1][0];
        User aUser = UtilityTest.createUser();
        System.runAs(aUser){
            Case aCase = UtilityTest.CreateMultipleCase( OrderTrg_Test.anAccount.Id, 
                                                        Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Defect_Return').getRecordTypeId(),
                                                        1,
                                                        True)[0];
            
            Test.startTest();
        	Test.setMock(HttpCalloutMock.class, new Informatica_Order_Mock());                    
            ConfirmationModalCtrl.callAction(aCase.Id,'DSS');
        	Test.stopTest();
        }
    }
}