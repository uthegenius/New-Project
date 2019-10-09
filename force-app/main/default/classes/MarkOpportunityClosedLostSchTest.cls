@isTest
public class MarkOpportunityClosedLostSchTest 
{
	// Test Method to mark opportunity completed.
    @isTest static void testScheduleBatch()
    {
        System.debug('In Test');
        Test.startTest();
            
            Account AccountObj = UtilityTest.CreateAccount( 'Test Account', true);
        
        Id StdPriceBookId = UtilityTest.getStandardPBId();
        Product2 ASProd = UtilityTest.createAmericanStandardProduct(StdPriceBookId);
        Product2 GroheProd = UtilityTest.createGroheProduct();		

		Opportunity OpportunityObj = UtilityTest.CreateDisplayOpportunity( AccountObj.Id );
        System.debug(OpportunityObj);
        Wholesalers__c ws = UtilityTest.createWholesaler(AccountObj.Id, OpportunityObj.Project__c);     
        Quote QuoteObj = UtilityTest.createStandardQuote(StdPriceBookId, AccountObj, OpportunityObj);
        
            QuoteObj.ExpirationDate = Date.today().addDays(-1);
        QuoteObj.Unique_id__c = '0507525556';
            QuoteObj.Num_Approvals__c = 0;
            QuoteObj.Status = 'Processed';
            QuoteObj.Review_Price__c = True;
        QuoteObj.Final_Quote__c = true;
            update QuoteObj;
        
            OpportunityObj.Has_Order__c = false;
            OpportunityObj.FinalQuote__c = QuoteObj.Id;
            Update OpportunityObj;
        
            String CRON_EXP = '0 0 0 1 1 ?';  
            String jobId = System.schedule('MarkOpportunityClosedLostSchedule', CRON_EXP, new MarkOpportunityClosedLostSch());
        Test.StopTest();
    }
}