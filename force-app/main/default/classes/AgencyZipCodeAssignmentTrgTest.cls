@IsTest
public class AgencyZipCodeAssignmentTrgTest 
{
    //Create Sample Data 
    @TestSetup static void createTestSetupData()
    {
        Agency__c agn1 = UtilityTest.CreateAgency();
        UtilityTest.CreateAgencyZipCodeAssignment();
        
    }
    
    // Test Method check Assignment Zip Code
    @isTest static void testcheckAssignmentZipCode()
    {
        List<Agency_Zip_Code_Assignment__c> LstAGZC = [Select Id,Name,Recalculate_Assignment__c,ZipCode__c from Agency_Zip_Code_Assignment__c limit 4];
        List<Agency__c> ListOfAgencies = [Select Id,Name,Type__c,Account__c from Agency__c limit 4];
        Set<Id> SetofAccounts = new Set<Id>();
        Integer i = 1;
        for(Agency__c agn: ListOfAgencies)
        {
            if(i==1) agn.Type__c = 'AS';
            else if(i==2) agn.Type__c = 'DXV';
            else if(i==3) agn.Type__c = 'Fiat';
            else if(i==4) agn.Type__c = 'Grohe';
            i++;
            SetofAccounts.add(agn.Account__c);
        }
        
        for(Agency_Zip_Code_Assignment__c agnZC : LstAGZC)
        {
            agnZC.Recalculate_Assignment__c = true;
        }
        List<Account> LstAccountObj = new List<Account>();
        if(SetofAccounts.size() > 0)
        {
            for(Account acc: [Select Id,Name,ShippingPostalCode from Account where Id in: SetofAccounts])
            {
                acc.ShippingPostalCode = '220065';
                LstAccountObj.add(acc);
            }
            Update LstAccountObj;
        }
        
        
        /* Account AccountObj = UtilityTest.CreateAccount('Test Account1', false);
AccountObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Influencer').getRecordTypeId();
AccountObj.ShippingPostalCode = 'TEST';

insert AccountObj; */
        
        Test.startTest();
        system.debug('LstAccountObj::'+LstAccountObj);
        system.debug('ListOfAgencies::'+ListOfAgencies);
        system.debug('LstAGZC::'+LstAGZC);
        Update ListOfAgencies;
        Update LstAGZC;
        Test.stopTest();
    }
}