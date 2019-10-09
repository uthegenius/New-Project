@isTest
public class OrderShippedNotificationBatchClass_Test {
    static Account anAccount = new Account();
    //Create Sample Data 
    @TestSetup static void createTestSetupData(){
        Id StdPriceBookId = UtilityTest.getStandardPBId();
        OrderShippedNotificationBatchClass_Test.anAccount = UtilityTest.createCustomerAccount();
        Product2 ASProd = UtilityTest.createAmericanStandardProduct(StdPriceBookId);
        List<sObject> ls = Test.loadData(Order_Cost_Center_Setup__c.sObjectType, 'TestData_OrderLogic'); 
        system.debug(OrderShippedNotificationBatchClass_Test.anAccount);
    }
    
    @isTest static void createOrderFromCase() {
        anAccount = [select id from account limit 1][0];
        anAccount.SAP_Account_Number__c='1212121';
        update anAccount;
        Contact con = UtilityTest.CreateContact(anAccount.Id,'Consumer');
        
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
        
        Case aCase = UtilityTest.CreateCase( OrderShippedNotificationBatchClass_Test.anAccount.Id, 
                                            Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Technical_Support').getRecordTypeId(),
                                            True);
        
        aCase.contactId=con.Id;
        aCase.Type='Defect Return';
        aCase.Product_Type__c='Fittings';
        aCase.Product_Sub_Type__c='Kitchen';
        aCase.assetid = ast.Id;
        Update aCase;
        
        Order anOrder = UtilityTest.CreateOrder(aCase.Id,
                                                OrderShippedNotificationBatchClass_Test.anAccount.Id,
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
        
        OrderItem anOrderLine =  CreateOrderItem(null,null,aProduct.Id,anOrder.Id,'USPS');
        
        Product2 aProduct1 = UtilityTest.createAmericanStandardProduct(null);
        OrderItem anOrderLine1 =  CreateOrderItem(null,null,aProduct1.Id,anOrder.Id,'FEGC');
        
        for(AggregateResult  ordItm:[select id, Attribute6__c,Attribute5__c,Ship_To_Account__r.SAP_Account_Number__c ,Carrier__r.URL__c, Shipping_Tracking__c,
                                     Order.Case__r.Web_to_Case_URL__c,   Order.ownerid,Order.Order_SAP_ID__c,Order.Case__r.CaseNumberForEmail__c,
                                     Product2Id,Product2.Name,Order.Case__c,Order.Case__r.Contact.Email,Order.Case__r.Contact.LastName,
                                     Customer_Order_Number__c,sum(Quantity) qty,Carrier__c from OrderItem where Attribute6__c !=null 
                                     and Remaining_Quantity__c=0 and Shipment_Email_Status__c!=true group by id,
                                     Attribute6__c,Attribute5__c,Order.ownerid,Product2Id,Order.Case__c,Order.Case__r.Contact.Email,Customer_Order_Number__c,
                                     Carrier__c,Product2.Name,Order.Case__r.Contact.LastName,Order.Order_SAP_ID__c,Order.Case__r.CaseNumberForEmail__c,
                                     Ship_To_Account__r.SAP_Account_Number__c ,Carrier__r.URL__c,Shipping_Tracking__c,Order.Case__r.Web_to_Case_URL__c])
        {
            // checking if trakcing is same for multiple order items
            System.debug('KA:: Attribute6__c'+ String.valueOf(ordItm.get('Attribute6__c')));
            System.debug('KA:: Attribute5__c'+ String.valueOf(ordItm.get('Attribute5__c')));
            System.debug('KA:: SAP_Account_Number__c'+ String.valueOf(ordItm.get('SAP_Account_Number__c')));
            System.debug('KA:: URL__c'+ String.valueOf(ordItm.get('URL__c')));
            System.debug('KA:: Shipping_Tracking__c'+ String.valueOf(ordItm.get('Shipping_Tracking__c')));
            System.debug('KA:: Web_to_Case_URL__c'+ String.valueOf(ordItm.get('Web_to_Case_URL__c')));
            System.debug('KA:: Name'+ String.valueOf(ordItm.get('Name')));
            System.debug('KA:: Case__c'+ String.valueOf(ordItm.get('Case__c')));
            System.debug('KA:: Email'+ String.valueOf(ordItm.get('Email')));
            System.debug('KA:: LastName'+ String.valueOf(ordItm.get('LastName')));
            System.debug('KA:: Carrier__c'+ String.valueOf(ordItm.get('Carrier__c')));
            
        }
        Test.startTest();
        OrderShippedNotificationBatchClass.scheduleJobForEveryHour('Test');
        Test.stopTest();
        
        
    }
    
    
    public static OrderItem CreateOrderItem(Id QuoteId,Id QuoteLineItemId,Id ProductId,Id OrderId, String Carrier_Code){
        Id pbeID = [select Id from PricebookEntry where Product2Id = :ProductId and CurrencyISOCode = 'USD' limit 1].Id;
        
        OrderItem orditem = new OrderItem();
        orditem.UnitPrice = 200;
        orditem.Open_Quantity__c = 2;
        orditem.Shipped_Quantities__c = 2;
        orditem.Quote__c = QuoteId;
        orditem.Quote_Line_Item__c = QuoteLineItemId;
        orditem.Line_Status__c = 'Open';
        orditem.Product2Id = ProductId;
        orditem.PricebookEntryId = pbeID;
        orditem.OrderId = OrderId;
        orditem.Quantity = 2;
        orditem.Remaining_Quantity__c=0;
        orditem.Attribute6__c='12131314';
        orditem.Attribute5__c = Carrier_Code;
        orditem.Shipping_Tracking__c='121121';
        Carrier__c car = new Carrier__c();
        car.Carrier_Code__c=Carrier_Code;
        car.Name=Carrier_Code;
        car.URL__c='http://testurl.com';
        insert car;
        orditem.Carrier__c=car.id;
        
        insert orditem;
        return orditem;
    }
    
}