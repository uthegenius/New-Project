/* Author		: Abid Raza
   Date			: 13th-Oct-2018
   Description	: Test class to cover coverage of ScarVenforFormController class, Scar Trigger, ScarVendorFormEmailBatch and ScarVendorFormEmailBatch Schecular.
*/

@isTest
public class ScarVendorFormControllerTest 
{
	//Create Sample Data 
	@TestSetup static void createTestSetupData()
    {
        Account DealerAccount = UtilityTest.createDealerAccount();
        Contact WholesalerContact = UtilityTest.CreateContact(DealerAccount.Id,'Wholesaler');
        SCAR__c Scar1 =  UtilityTest.createScar(true,DealerAccount.Id,WholesalerContact.Id);
        SCAR_Team__c st1 = UtilityTest.CreateScarTeam(Scar1.Id);
        SCAR_Team__c st2 = UtilityTest.CreateScarTeam(Scar1.Id);
        SCAR__c Scar2 =  UtilityTest.createScar(true,DealerAccount.Id,WholesalerContact.Id);
    }
    
    @isTest static void TestScarVendorFormController()
    { 
        List<Scar__c> scar = [Select Id,Name,SCAR_Team_Count__c,Last_Notified_Vendor__c,Affected_Sites__c,Problem_Description__c,What_actions_were_taken_to_Immediately__c,Other_Production_Platform_Risk__c,Supplier_Soring_Results__c from Scar__c limit 2];
        
        ApexPages.StandardController sc = new ApexPages.StandardController(scar[0]);
        ApexPages.currentPage().getParameters().put('id',scar[0].id);
        ScarVendorFormController Svfc = new ScarVendorFormController();
        
        Svfc.addRows();
        Svfc.method1();
        Svfc.method1();
        Svfc.method1();
        Svfc.method1();
        Svfc.method1();
        Svfc.method1();
        Svfc.method1();
        Svfc.method1();
        Svfc.Save();
        
        for(Scar__c scr: scar)
        {
            if(scr.SCAR_Team_Count__c > 0)
            {
                scr.Affected_Sites__c = 'abc';
        		scr.Problem_Description__c = 'abc';
        		scr.What_actions_were_taken_to_Immediately__c = 'abc';
        		scr.Other_Production_Platform_Risk__c = 'abc';
        		scr.Supplier_Soring_Results__c = 'abc';
                scr.Last_Notified_Vendor__c = Date.today().addDays(-10);
            }
            else
            {
                scr.Last_Notified_Vendor__c = Date.today().addDays(-2);
            }
            
        }
        Update scar;
        
        SCAR_Vendor_Form_Email__c svfe = new SCAR_Vendor_Form_Email__c();
        svfe.First_Notification_Days__c = 2;
        svfe.Second_Notification_Days__c = 10;
        insert svfe;
        Database.executeBatch(new SendSCARFormToVendorEmailBatch());
        
        String CRON_EXP = '0 0 0 1 1 ? 2025';  
        String jobId = System.schedule('testScheduledApex', CRON_EXP, new SendSCARFormToVendorEmailBatchSchedular());
        
    }
}