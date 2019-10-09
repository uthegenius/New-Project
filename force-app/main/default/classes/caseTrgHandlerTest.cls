/************************
Author:         Ibad Mohiuddin
Created Date:   08/Aug/2018 
Purpose:        Test Class .

************************MODIFICATION HISTORY**************************************
Added on             Added By               Description
**********************************************************************************
08/Aug/2018          Ibad Mohiuddin   Initial Development /*/

@isTest
public class caseTrgHandlerTest {
    
    public static TestMethod void test()
    {
        insert new Account__c(Name__c = 'Test Account');
        List<case> csList = new List<Case>();
        
        Product2 pr = new Product2(
            Name='Test',
            SAP_Product_Code__c='40664001',
            SAP_Product_Hierarchy__c='1234',
            brand__c = 'American Standard'
        );
        
        
        
        insert pr;
        
        Account ac = UtilityTest.CreateAccount('Test Account',True);
        
        
        //Condition For the Warranty Registration for a null Contact
        csList = UtilityTest.CreateMultipleCase(null,
                                                Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Warranty_Registration').getRecordTypeId(),
                                                10,
                                                false);
        
        
        
        //Condition For the Warranty Registration for a null Contact having Last Name Single
        Case cs2 = csList[0];
        cs2.SuppliedName='Test';
        insert csList;
        
        
        
        //Condition For the Warranty Registrtion Contact Exists and Asset does not exists
        List<Case> csList2 = new List<Case>();
        Contact cc = UtilityTest.CreateConsumerContact(ac.id,'Consumer');
        csList2 = UtilityTest.CreateMultipleCase(null,
                                                 Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Warranty_Registration').getRecordTypeId(),
                                                 3,
                                                 false); 
        //Asset does not 
        Case cs3 = csList2[0];
        cs3.SuppliedEmail='test@mail.com';
        
        
        Case cs_3 = csList2[1];
        cs_3.SuppliedEmail='test@mail.com';
        insert csList2;
        
        
        
        
        
        //Condition For the Warranty Registrtion Contact Exists and Asset Exists
        List<Case> csList4 = new List<Case>();
        csList4 = UtilityTest.CreateMultipleCase(null,
                                                 Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Warranty_Registration').getRecordTypeId(),
                                                 1,
                                                 false); 
        Case cs4 = csList4[0];
        cs4.SuppliedEmail='test@mail.com';
        insert csList4;
        
        
        
        
        //Product Does not Exists for Warranty Registration 
        List<Case> csList5 = new List<Case>();
        csList5 = UtilityTest.CreateMultipleCase(null,
                                                 Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Warranty_Registration').getRecordTypeId(),
                                                 1,
                                                 false); 
        Case cs6 = csList5[0];
        cs6.Model_SKU__c='46555';
        insert csList5;
        
        
        
        
        
        
        // Queue Assignment Condition
        
        Asset ass = new Asset(Name='Test Asset',
                              ContactId=cc.id,
                              AccountId=ac.id,
                              Product2Id=pr.id
                              
                             );               
        ass.Quantity = 1;
        ass.Sub_Channels__c = 'Project';
        ass.PurchaseDate = System.Date.today();
        ass.InstallDate =System.Date.today();
       
        insert ass;
        
        Case cs7 = new Case(Country__c='Canada',
                            SuppliedName='Test last',
                            Type='Quality',
                            RecordTypeId=Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Technical_Support').getRecordTypeId(),
                            contactId=cc.Id,
                            SuppliedEmail='test@mail.com',
                            Street_Address__c='Test Addresses',
                            Street_Address2__c='Test Address2',
                            City__c='Test',
                            State__c='Quebec',
                            Postal_Code__c='122',
                            AssetId=ass.id
                            
                            
                           );
        
        insert cs7;
        
        
        
    }
    
    
    public static TestMethod void ODMSTeam()
    {
       test.startTest();
        UtilityTest.createODMSRecord();
        List<Case> csList2 = new List<Case>();
        csList2 = UtilityTest.CreateMultipleCase(null,
                                                 Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Technical_Support').getRecordTypeId(),
                                                 2,
                                                 false);
        Case cs2=csList2[0];
        cs2.Origin='Web';
        cs2.SuppliedEmail='mail2test@test.com';
        insert csList2;
        
test.stopTest();
    }
    
    
    
    public static TestMethod void CaseExtensionTest()
    {
        
       Test.startTest(); 
        
        
        
        
        //for Email To Case
        List<Case> csList2 = new List<Case>();
        csList2 = UtilityTest.CreateMultipleCase(null,
                                                 Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Technical_Support').getRecordTypeId(),
                                                 1,
                                                 false);
        Case cs2=csList2[0];
        cs2.Origin='Email';
        cs2.SuppliedEmail='mailtest@test.com';
        insert csList2;
        
        List<Case> caseList3;
        
        //Warrnaty Registration  Controller
        
        List<Case> csList3 = new List<Case>();
        csList3 = UtilityTest.CreateMultipleCase(null,
                                                 Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Technical_Support').getRecordTypeId(),
                                                 1,
                                                 false);
        Case cs3=csList3[0];
        cs3.Origin='Email';
        cs3.SuppliedEmail='mailtest@test.com';
        insert csList3;
        Case cs = csList3[0];
        ApexPages.StandardController sc = new ApexPages.StandardController(cs);
        WarrantyRegistrationController wrc = new WarrantyRegistrationController();
        Attachment at = new Attachment(
            ParentId=cs.id,
            Name='Test');
        
        wrc.attachment1=At;
        wrc.attachment2=At;
        wrc.attachment3=At;
        wrc.attachment4=At;
        wrc.upload();
        Test.stopTest(); 
        
        
    }
    
    
}