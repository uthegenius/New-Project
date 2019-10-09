@IsTest
public class TaskSaveTest 
{
	@TestSetup static void createTestSetupData()
    {
        Account acc = UtilityTest.createDealerAccount();
        Opportunity Opp = UtilityTest.CreateDisplayOpportunity(acc.Id);
        Task OppTask = UtilityTest.CreateTask(Opp.Id);
    }
    
    @isTest static void testCopyAssetNameToProduct()
    {
        Test.startTest();
        	Task tsk = [Select Id,Status from Task limit 1];
        	tsk.Status = 'Completed';
        	Update tsk;
        Test.stopTest();
    }
}