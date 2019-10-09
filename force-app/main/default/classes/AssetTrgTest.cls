@IsTest
public class AssetTrgTest 
{
    @TestSetup static void createTestSetupData()
    {
        Asset ast = UtilityTest.CreateAsset();
        Task tsk = UtilityTest.CreateTask(ast.Id);
    }
    
    @isTest static void testCopyAssetNameToProduct()
    {
        
        Test.startTest();
        Asset ast = [select Id,Name,Product2Id,Asset_Status__c,AccountId,ContactId from Asset limit 1];
        ast.Product2Id = null;
        ast.Quantity = 2.0;
        ast.PurchaseDate = System.Date.today();
        ast.InstallDate =System.Date.today();
        ast.Asset_Status__c = 'Cancelled';
        Update ast;
        
        Asset ast2 = new Asset();
        ast2.Name = 'Test Asset';
        ast2.AccountId = ast.AccountId;
        ast2.ContactId = ast.ContactId;
        
        ast2.Sub_Channels__c = 'Project';
        ast2.Quantity = 1;
        ast2.PurchaseDate = System.Date.today();
        ast2.InstallDate =System.Date.today();
        Product2 prod = UtilityTest.createGroheProduct();
        ast2.Product2Id = prod.Id;
        insert ast2;
        Test.stopTest();
    }
}