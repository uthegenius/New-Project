/************************
Author:         Hanif Babar
Created Date:   14/Oct/2018 
Purpose:        defectReturnBatchSchedule_Test

************************MODIFICATION HISTORY**************************************
Added on             Added By               Description
**********************************************************************************
14/Oct/2018           Hanif Babar          Initial Development 
***********************************************************************************/
@isTest
public class defectReturnBatchSchedule_Test {
    
    @TestSetup static void createTestSetupData(){
        List<sObject> ls = Test.loadData(Defect_Return_Form__c.sObjectType, 'TestData_DefectReturn');
    }
    @isTest static void createLoadDefectReturn() {
        Test.StartTest();
        defectReturnBatchSchedule sh1 = new defectReturnBatchSchedule();        
        String sch = '0 0 23 * * ?'; system.schedule('Test Territory Check', sch, sh1); 
        Test.stopTest(); 
        
    }
}