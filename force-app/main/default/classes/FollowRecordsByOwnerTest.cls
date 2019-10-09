@isTest
public class FollowRecordsByOwnerTest {

    @isTest static void testCreateProjWithApprovers()
    {
        FollowRecordsByOwner frb = new FollowRecordsByOwner();
        Test.startTest();
        Account acct = UtilityTest.createCustomerAccount();
        Project__c prj = UtilityTest.createProjectWithApprovers();
        
      
    }
}