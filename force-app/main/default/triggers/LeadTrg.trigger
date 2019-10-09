/*
* Created by: Tectonic (Abid Raza) on 10/Dec/18
* Description: To create task for Sales Rep when triggering from Pardot.
* Updated by: 
*/

trigger LeadTrg on Lead (before insert, before update,after insert,after update) 
{
    LeadTrgHelper LeadTrgHelperObj = new LeadTrgHelper();
    set<string> SetOfZipCodes = new Set<string>();
    set<Lead> SetOfZIPToRegionLeads = new Set<Lead>();
    Set<String> regionLst = new Set<string>();
    set<Lead> SetOfQualifiedLeads = new Set<Lead>();
    
    if(Trigger.isBefore && Trigger.isInsert)
    {
        for (Lead led : Trigger.new)
        {
            if(led.PostalCode != null)
            {
                SetOfZipCodes.add(led.PostalCode);
                SetOfZIPToRegionLeads.add(led);
            }
        }
        
         //Update Region based on Zip Code
        if(SetOfZipCodes.size() > 0 && SetOfZIPToRegionLeads.size() > 0)
        {
            LeadTrgHelperObj.AssignRegionAsPerZipCode(SetOfZipCodes, SetOfZIPToRegionLeads);
        }
    }
    
    if(Trigger.IsAfter && Trigger.Isinsert)
    {
        for (Lead led : Trigger.new)
        {   
            if (led.LeadSource =='Pardot' && led.status == 'Qualified') 
            {   
             	regionLst.add(led.Region__c);
                SetOfQualifiedLeads.add(led);
            }
        }
        
        //Create and Assign Task to Regional Manager for Pardot Leads.
        if(SetOfQualifiedLeads.size() > 0)
        {
            LeadTrgHelperObj.CreateAndAssignTask(regionLst, SetOfQualifiedLeads);
        }
    }
    
    If (Trigger.isBefore && Trigger.isUpdate)
    {
        Set<Id> setAcctId = new Set<Id>();
        
        List<Industry_Region_Wise_Rep__c> setupObj = new List<Industry_Region_Wise_Rep__c>();
        
        for (Lead led : Trigger.new)
        {
            if (led.isConverted) 
            {
                if (led.ConvertedAccountId != null) 
                {            
					setAcctId.add(led.ConvertedAccountId);
                }
            }
            
            if(led.PostalCode != null && led.PostalCode != Trigger.OldMap.get(led.Id).PostalCode)
            {
                SetOfZipCodes.add(led.PostalCode);
                SetOfZIPToRegionLeads.add(led);
            }
        }
        
        //Update Region based on Zip Code
        if(SetOfZipCodes.size() > 0 && SetOfZIPToRegionLeads.size() > 0)
        {
            LeadTrgHelperObj.AssignRegionAsPerZipCode(SetOfZipCodes, SetOfZIPToRegionLeads);
        }
        
        List<Account> listAcct = [select Id, RecordType.Name from Account where Id = :setAcctId];
        Map<Id, String> mapAcctRecordType = new Map<Id, String>();
        
        if (listAcct != null && listAcct.size() > 0)
        {
            for (Account acct : listAcct)
            {
                mapAcctRecordType.put(acct.Id, acct.RecordType.Name);
            }
        }
        
            
        for (Lead led : Trigger.new)
        {
            if (led.isConverted) 
            {
                if (mapAcctRecordType.containsKey(led.ConvertedAccountId)) 
                {            
                    if (mapAcctRecordType.get(led.ConvertedAccountId) == 'Customer' || mapAcctRecordType.get(led.ConvertedAccountId) == 'Agency')
                    {
                        led.addError('You cannot convert this lead to a Customer or Agency account.');
                    }
                }
            }
        }            
    }   
    
    if(Trigger.IsAfter && Trigger.Isupdate)
    {
        for (Lead led : Trigger.new)
        {   
            if (led.LeadSource =='Pardot' && led.status == 'Qualified' && led.Status != Trigger.OldMap.get(led.Id).Status) 
            {   
             	regionLst.add(led.Region__c);
                SetOfQualifiedLeads.add(led);
            }
        }
        
        //Create and Assign Task to Regional Manager for Pardot Leads.
        if(SetOfQualifiedLeads.size() > 0)
        {
            LeadTrgHelperObj.CreateAndAssignTask(regionLst, SetOfQualifiedLeads);
        }
    }
}