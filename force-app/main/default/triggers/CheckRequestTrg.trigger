/************************
Author:         Abid Raza
Created Date:   11th/Sep/2018 
Purpose:        Check Request Trigger to send PDF on check Request Apporoval.
************************/

trigger CheckRequestTrg on Check_Request__c (before  insert, after Update,after insert) 
{
    CheckRequestTrgHandler crHandler = new CheckRequestTrgHandler();
    //Ibad : To create folder for box.
    if(Trigger.IsAfter && Trigger.IsInsert)
    {
        CheckRequestTrgHandler.createFolderinBox(Trigger.new);
    }
    
    // Send Check Request PDFs on Approval.
    if(Trigger.IsAfter && Trigger.IsUpdate)
    {
        List<Check_Request__c> ApprovedCRList = new List<Check_Request__c>();
        for(Check_Request__c cc :Trigger.new)
        {
            if(cc.Approved__c == true && cc.Approved__c != Trigger.OldMap.get(cc.Id).Approved__c)
            {
                ApprovedCRList.add(cc);
            }
        }
        system.debug('ApprovedCRList::'+ApprovedCRList);
        if(ApprovedCRList.size() > 0)
        {
            crHandler.CreateAndSendCheckRequestPDFs(ApprovedCRList); 
        }
    }
}