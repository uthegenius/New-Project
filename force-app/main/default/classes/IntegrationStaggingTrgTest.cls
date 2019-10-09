/*************************
Author:         Areeba Ali
Created Date:   15/August/2019 
Purpose:       this test class if for test coverage of onIntegrationStagingSave and its handler class.

************************MODIFICATION HISTORY**************************************
Added on             Added By               Description
**********************************************************************************
15/August/2019          Areeba Ali          Initial Development 
***********************************************************************************/
@isTest
public class IntegrationStaggingTrgTest {
    
    //Test Method with the RecordType Contact Us
    @isTest private static void ContactusIntegrationStg ()
    {
        List<Integration_Staging__c> ListofIntgrationStg = new List <Integration_Staging__c>();
        ListofIntgrationStg= UtilityTest.createContactusIntStg();
        
        Test.startTest();
        Insert ListofIntgrationStg;
        Test.stopTest();
        
    }
    
    //Test Method with the RecordType Warranty Registration
    @isTest private static void WarrantyIntegrationStg ()
    {
        List<Integration_Staging__c> ListofIntgrationStg = new List <Integration_Staging__c>();
        ListofIntgrationStg= UtilityTest.createWarrantyIntStg();
        
        Test.startTest();
        Insert ListofIntgrationStg;
        Test.stopTest();
        
        
        
    }
    
}