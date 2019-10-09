@IsTest
public class EventSaveTest {
	@TestSetup static void createTestSetupData()
    {
        Account acc = UtilityTest.createDealerAccount();
        Opportunity Opp = UtilityTest.CreateDisplayOpportunity(acc.Id);
        Event OppEvent = UtilityTest.CreateEvent(Opp.Id);
    }
    
    @isTest static void testCopyAssetNameToProduct()
    {
        Test.startTest();
        	Event evt = [Select Id,Type from Event limit 1];
        	evt.Type = 'Email';
        	Update evt;
        Test.stopTest();
    }
}