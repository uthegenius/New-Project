@isTest
public class ProductBatchSchedularTest 
{
	// Test Method to convert lead to account.
    @isTest static void testScheduleBatch()
    {
        String CRON_EXP = '0 0 0 1 1 ? 2025';  
        String jobId = System.schedule('testScheduledApex', CRON_EXP, new ProductBatchSchedular());
    }
}