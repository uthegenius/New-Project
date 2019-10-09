@IsTest
public class ProductTrgTest 
{
    @TestSetup static void createTestSetupData()
    {
        Product2 prod = UtilityTest.createGroheProduct();
    }
    
     @isTest static void testUpdateProduct()
    {
        Test.startTest();
            Product2 prod = [Select Id,Name,Discontinue_date__c from Product2 limit 1];  
        	//prod.Discontinue_date__c = Date.today();
        	prod.Discontinue_date__c = System.today().AddMonths(1);
        	Update prod;
        Test.stopTest();
    }

}