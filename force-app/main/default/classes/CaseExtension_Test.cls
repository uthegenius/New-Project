/************************
Author:         Ibad Mohiuddin
Created Date:   08/Aug/2018 
Purpose:        Test Class .

************************MODIFICATION HISTORY**************************************
Added on             Added By               Description
**********************************************************************************
08/Aug/2018          Ibad Mohiuddin   Initial Development /*/

@istest
public class CaseExtension_Test {
    @TestSetup static void createTestSetupData(){
        insert new Email__c(Default_Email__c = 'sf_casemanagement@lixilamericas.com');

        Account anAccount = UtilityTest.createCustomerAccount();
        UtilityTest.createODMSRecord();
        List<sObject> ls = Test.loadData(ODMS_Team_Mapping__c.sObjectType, 'TestData_ODMS');         
        Case aCase = UtilityTest.CreateMultipleCase( anAccount.Id, 
                                                    Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Technical_Support').getRecordTypeId(),
                                                    1,
                                                    True)[0];
        aCase.Region__c = 'USA';
        aCase.Team__c = 'Customer Care';
        aCase.Sub_Team__c= 'Luxury Customer Care';
        aCase.Send_ODMS_email__c = True;
        //aCase.Send_email__c=true;
        aCase.Additional_Email_to_be_Included__c='hanif.babar@gettectonic.com;';
        update aCase;
        List<Case> cs = new List<Case>();
        cs.add(aCase);
        CaseExtension.multipleemailstobesend(cs);
        
        aCase = UtilityTest.CreateMultipleCase( anAccount.Id, 
                                               Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Customer_Success').getRecordTypeId(),
                                               1,
                                               True)[0];        
        aCase = UtilityTest.CreateMultipleCase( anAccount.Id, 
                                               Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Technical_Support').getRecordTypeId(),
                                               1,
                                               True)[0];
        aCase.Origin = 'Email';
        aCase.Original_Case_Origin__c = 'Email';
        Update aCase;
        aCase = UtilityTest.CreateMultipleCase( anAccount.Id, 
                                               Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Technical_Support').getRecordTypeId(),
                                               1,
                                               False)[0];
        aCase.SuppliedName = 'Test';
        aCase.Origin = 'Email';
        aCase.Additional_Email_to_be_Included__c='test@mail.com';
        Insert aCase;
        
    }
    private static testmethod void testMethod1()
    {
        CaseExtension.sendMail(new Map<string,List<String>>{'admin' => new List<String>{'abc@mailinator.com','def@mailinator.com'}});
        CaseExtension.sendEmail(new List<String>{'abc@mailinator.com','def@mailinator.com'},'Test','test');
        //CaseExtension.sendmail();
    }
}