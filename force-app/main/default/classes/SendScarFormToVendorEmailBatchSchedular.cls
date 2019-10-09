global class SendScarFormToVendorEmailBatchSchedular implements Schedulable 
{
    global void execute(SchedulableContext sc) 
    {
        SendSCARFormToVendorEmailBatch svf = new SendSCARFormToVendorEmailBatch(); 
        database.executebatch(svf);
    }
    
}