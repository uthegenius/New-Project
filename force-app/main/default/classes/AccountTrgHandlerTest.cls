/************************
Author:         Azfer Pervaiz
Created Date:   05/July/2018 
Purpose:        AccountTrgHandlerTest this test class if for test coverage of Account trg and its handler class.

************************MODIFICATION HISTORY**************************************
Added on             Added By               Description
**********************************************************************************
05/July/2018           Azfer Pervaiz          Initial Development 
***********************************************************************************/
@isTest
public class AccountTrgHandlerTest {
  
    @TestSetup static void CreateTestDate(){
        UtilityTest.CreateAgencyZipCodeAssignment();
        UtilityTest.CreateTeamAssignmentRule();
    }

    @isTest static void CreateAccountWithPostalCode() {
        Account AccountObj = UtilityTest.CreateAccount('Test Account1', false);
        AccountObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Influencer').getRecordTypeId();
        AccountObj.ShippingPostalCode = 'TEST';

        Test.startTest();
        insert AccountObj;
        Test.stopTest();
    }
    
    
    @isTest static void updateLastAccountOwner()
    {
        Account AccountObj = UtilityTest.CreateAccount('Test Account1', false);
        AccountObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Influencer').getRecordTypeId();
        AccountObj.ShippingPostalCode = 'TEST';

        Test.startTest();
        insert AccountObj;
        User usr = UtilityTest.createUser();
        AccountObj.ShippingPostalCode='Test';
        AccountObj.OwnerId=usr.id;
        update AccountObj;
        Test.stopTest();
    }

    @isTest static void CreateAccountWithOutPostalCode() {
        Account AccountObj = UtilityTest.CreateAccount('Test Account1', false);
        AccountObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Influencer').getRecordTypeId();
        AccountObj.RecalculateTeamAssignment__c = true;
        Test.startTest();
        insert AccountObj;
        Test.stopTest();
    }

    @isTest static void UpdateAccountWithoutPostalCode() {
        Account AccountObj = UtilityTest.CreateAccount('Test Account1', false);
        AccountObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Influencer').getRecordTypeId();
        AccountObj.ShippingPostalCode = 'TEST';
        
        insert AccountObj;
        AccountObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Dealer').getRecordTypeId();
        AccountObj.ShippingPostalCode = null;
        
        Test.startTest();
        update AccountObj;
        Test.stopTest();
    } 

    @isTest static void UpdateAccountDiffPostalCode() {
        Account AccountObj = UtilityTest.CreateAccount('Test Account1', false);
        AccountObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Influencer').getRecordTypeId();
        AccountObj.ShippingPostalCode = 'TEST';
        
        insert AccountObj;
        AccountObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Dealer').getRecordTypeId();
        AccountObj.ShippingPostalCode = 'TEST2';
        
        Test.startTest();
        update AccountObj;
        Test.stopTest();
    }  

    @isTest static void UpdateAccountWithChildOpp() {
        Account AccountObj = UtilityTest.CreateAccount('Test Account1', false);
        AccountObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Influencer').getRecordTypeId();
        AccountObj.ShippingPostalCode = 'TEST';
        
        insert AccountObj;
        UtilityTest.CreateOpportunity( AccountObj.Id );
        
        AccountObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Dealer').getRecordTypeId();
        AccountObj.ShippingPostalCode = 'TEST2';
        
        Test.startTest();
        update AccountObj;
        Test.stopTest();
    } 

    @isTest static void UpdateAccountCalculateTeam() {
        Account AccountObj = UtilityTest.CreateAccount('Test Account1', false);
        AccountObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Influencer').getRecordTypeId();
        AccountObj.ShippingPostalCode = 'TEST';
        
        insert AccountObj;
        AccountObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Dealer').getRecordTypeId();
        AccountObj.RecalculateTeamAssignment__c = true;

        Test.startTest();
        update AccountObj;
        Test.stopTest();
    }  
}