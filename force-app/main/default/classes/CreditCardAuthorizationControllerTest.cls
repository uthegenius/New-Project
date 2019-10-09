/* Author		: Abid Raza
   Date			: 13th-Oct-2018
   Description	: Test class to cover coverage of Credit Card Authorization Controller class.
*/

@isTest
public class CreditCardAuthorizationControllerTest 
{
	//Create Sample Data 
	@TestSetup static void createTestSetupData()
    {
        Id StdPriceBookId = UtilityTest.getStandardPBId();
        Account acc = UtilityTest.createCustomerAccount();
        Product2 ASProd = UtilityTest.createAmericanStandardProduct(StdPriceBookId);
        Id RecordTypeId = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('Credit_Card_Sales').getRecordTypeId();
        Order ord = UtilityTest.CreateOrder(null,acc.Id,RecordTypeId,true);
        OrderItem orditem1 = UtilityTest.CreateOrderItem(null,null,ASProd.Id,ord.Id);
    }

    @isTest static void TestCreditCardAuthorizationController()
    {
        Order orderrec = [Select Id,Name,Card_Number__c,Card_Type__c,BillingStreet,BillingCity,BillingState,BillingPostalCode,BillingCountry,Card_Holder__c,CVV__c,Order_Amount__c,Merchant_ID__c,isOrder_Simulator__c from Order limit 1];
        Order ord = CreditCardAuthorizationController.InitCtrl(orderrec.Id);
        ord.BillingStreet = '45 Hoston';
        ord.BillingCity = 'Chicago';
        ord.BillingState = 'IL';
        ord.BillingPostalCode = '60606';
        ord.BillingCountry = 'US';
        CreditCardAuthorizationController.GetMerchantCurrency('329235988998');
        CreditCardAuthorizationController.getPickListValuesIntoList('Order','Card_Type__c');
        ord.Card_Number__c = '4111111111111111';
        ord.Card_Type__c = 'VISA';
        ord.Card_Holder__c = 'Abid';
        ord.CVV__c = '123';
        ord.Merchant_ID__c = '496160873888';
        Update ord;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CardConnectAuth_Mock());
        CreditCardAuthorizationController.RequestCardAuthorization(ord,'USD','1218');
        Test.stopTest();
    }
}