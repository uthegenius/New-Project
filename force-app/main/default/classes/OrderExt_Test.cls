@IsTest
public class OrderExt_Test {
    @TestSetup static void createTestSetupData(){
        Id StdPriceBookId = UtilityTest.getStandardPBId();
        Account anAccount = UtilityTest.createCustomerAccount();
        Product2 ASProd = UtilityTest.createAmericanStandardProduct(StdPriceBookId);
        List<sObject> ls = Test.loadData(Order_Cost_Center_Setup__c.sObjectType, 'TestData_OrderLogic');         
    }
    @isTest static void testMethod1() {
        Account anAccount = [select id from account limit 1][0];
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
            Case aCase = UtilityTest.CreateMultipleCase( anAccount.Id, 
                                                        Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Technical_Support').getRecordTypeId(),
                                                        1,
                                                        True)[0];
            aCase.contactId=con.Id;
            aCase.assetId = ast.Id;
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
            
            OrderItem anOrderLine = UtilityTest.CreateOrderItem(null,null,aProduct.Id,anOrder.Id);
            
            ApexPages.StandardController sc = new ApexPages.StandardController(anOrder);
            OrderExt obj = new OrderExt(sc);
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new Informatica_Order_Mock());
            obj.orderRefresh();
            obj.refreshOrderShipping(); 
            obj.submitTOSAP();
            Test.stopTest();
            
        }
    }
}