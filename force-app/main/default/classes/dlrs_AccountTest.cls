/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_AccountTest
{
    @IsTest(SeeAllData=true)
    private static void testTrigger()
    {
        // Force the dlrs_AccountTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        Account anAccount = UtilityTest.createCustomerAccount();
        anAccount.Id = null;
        dlrs.RollupService.testHandler(anAccount);
    }
}