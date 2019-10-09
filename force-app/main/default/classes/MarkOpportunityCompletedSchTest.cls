@isTest
public class MarkOpportunityCompletedSchTest 
{
	// Test Method to mark opportunity completed.
    @isTest static void testScheduleBatch()
    {
        Test.startTest();
            Campaign cmp = UtilityTest.createCampaign('Display');
            cmp.EndDate = Date.today().addDays(-1);
        	Update cmp;
        
            Account acc = UtilityTest.createDealerAccount();
        
            Opportunity Opp = UtilityTest.CreateDisplayOpportunity(acc.Id);
            opp.CampaignId = cmp.Id;
            opp.Has_Order__c = true;
            opp.StageName = 'Closed Won';
            Update opp;
        
            String CRON_EXP = '0 0 0 1 1 ? 2025';  
            String jobId = System.schedule('testScheduledApex', CRON_EXP, new MarkOpportunityCompletedSch());
        Test.StopTest();
    }
}