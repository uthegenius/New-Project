@istest
public class CaseControllerExt_Test {
    @TestSetup static void createTestSetupData(){
        Account anAccount = UtilityTest.createCustomerAccount();
        Case aCase = UtilityTest.CreateMultipleCase( anAccount.Id, 
                                                    Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Technical_Support').getRecordTypeId(),
                                                    1,
                                                    True)[0];
    }
    private static testmethod void testMethod1()
    {
        Case aCase = [Select id from case limit 1][0];
        
        ApexPages.StandardController sc = new ApexPages.StandardController(aCase);
        CaseControllerExt caseCtrl = new CaseControllerExt(sc);
        caseCtrl.afile = blob.valueOf('test');
        caseCtrl.fileName = 'test.txt';
        caseCtrl.contentType =  'plain/text';        
        String authResponse = BoxTestJsonResponseFactory.AUTH_USER_TOKEN;
        Test.setMock(HttpCalloutMock.class, new BoxTestMockCallout(authResponse, 'OK', 200));
        Test.startTest();
        caseCtrl.createCaseWithAttachment();
        Test.stopTest();
    }
}