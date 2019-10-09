@isTest
public class onAgencySave_Test {
    @isTest static void CreateAgency()
    {
        Account acc1 = UtilityTest.createCustomerAccount();
        Account acc2 = UtilityTest.createAgencyAccount();
        Agency__c a = new Agency__c();
        a.Account__c = acc1.id;
        a.Agency_Account__c= acc2.id;
        insert a;
        
        Account acc3 = UtilityTest.createAgencyAccount();
        Agency__c a1 = new Agency__c();
        a1.Account__c = acc1.id;
        a1.Agency_Account__c= acc2.id;
        insert a1;
        
    }
}