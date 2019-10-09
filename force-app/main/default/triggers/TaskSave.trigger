/*
 * Change log:
 * Updated by		Updated on		Reason 
 * Tectonic (MB)	5/23/18			LSCIP-80 - (AM-3) - Funcionality added to "Activate" related Assets upon task completion 
 */
trigger TaskSave on Task  (after update, before insert, before update, after insert) {
        
    
    // Jira LSCIP-29 (L-8)
    // Track last modify date on parent object ever after delete or undelete
    
    Set<Id> parentId = new Set<Id>();
    Set<Id> oppWhatIds = new Set<Id>();
    for(Task aTask:Trigger.new){
        if(string.isNotBlank(aTask.WhatId)){
            parentId.add(aTask.WhatId);
            if(aTask.Status == 'Completed' && aTask.What.Type == 'Opportunity') oppWhatIds.add(aTask.WhatId);
        }            
    }
    
    if(Trigger.isAfter){
        
        CommonObjects_Controller.setLastTransActivity(parentId);
        // MB-5/23/18 - update related Opp > Account > Asset status to "Active"
        /*
        List<Asset> assetsToUpdate = new List<Asset>();
        if (oppWhatIds.size() > 0 )
        {
            // get related accounts
            for(Account acc: [SELECT Id, (SELECT Asset_Status__c FROM Assets WHERE Opportunity__c IN: oppWhatIds ) 
                           	  FROM Account 
                              WHERE Id IN (SELECT AccountId FROM Opportunity WHERE Id IN: oppWhatIds) ])
            {
                for(Asset a: acc.Assets)
                {
                    a.Asset_Status__c = 'Active';
                    assetsToUpdate.add(a);
                }
            }
            update assetsToUpdate;
            System.debug('Assets to update:' + assetsToUpdate);
        }
		*/
        
        // AR : Added 1st-March-2019 : Updating Lead Owner from Task Owner for Pardot Leads.
        if (Trigger.isinsert)
        {
            Map<string,string> MapofLeadswithOwners = new Map<string,string>();
            
            for (Task t : Trigger.New)
            {
                if(t.WhoId != null && t.WhoId.getSObjectType() == Lead.sObjectType)
                {
                    MapofLeadswithOwners.put(t.WhoId,t.OwnerId);
                }
            }
            List<Lead> ListsOfPardotLeads = [Select Id,name,OwnerId from Lead where Id in: MapofLeadswithOwners.keySet() and status =: 'Qualified' and LeadSource =: 'Pardot'];
            
            if(ListsOfPardotLeads != null && ListsOfPardotLeads.size() > 0)
            {
                for(Lead led: ListsOfPardotLeads)
                {
                    led.OwnerId = MapofLeadswithOwners.get(led.Id);
                }
                Update ListsOfPardotLeads;
            }
        }
        
        if (Trigger.isUpdate)
        {
            Set<Id> setId = new Set<Id>();
            
            for (Task t : Trigger.New)
            {
            	if (t.WhatId != null && t.WhatId.getSObjectType() == Opportunity.sObjectType && Trigger.oldMap.get(t.Id).Status != Trigger.newMap.get(t.Id).Status && Trigger.newMap.get(t.Id).Status == 'Completed')
                {
                    setId.add(t.WhatId);
                }
            }
            
            List<Opportunity> listOpp = [select Id, StageName from Opportunity where Id in :setId and Recordtype.DeveloperName = 'Display'];
            
            List<Opportunity> listOpptoUpdate = new List<Opportunity>();
            
            if (listOpp != null && listOpp.size() > 0)
            {
                for (Opportunity op : listOpp)
                {
                    op.StageName = 'Closed Won';
                    op.TaskCompletedOn__c = Date.today();
                    listOpptoUpdate.add(op);
                }
            }
            
            if (listOpptoUpdate != null && listOpptoUpdate.size() > 0)
            {
                update listOpptoUpdate;
            }
        }
    }
    // Jira LSCIP-142 Validation rule on asset type to accept values on for display opportunities
    // Capture Opportunitie's related record's record type.
    /*
    else if (Trigger.isBefore){
        map<id,opportunity> mapOpp = new map<id,opportunity>([select RecordType.DeveloperName from Opportunity where id = :parentId]);
		system.debug(parentId);
        system.debug(mapOpp);
        for(Task aTask:Trigger.new){
            if(mapOpp.containsKey(aTask.WhatId)){
                aTask.Related_Record_s_Record_Type__c =  mapOpp.get(aTask.WhatId).RecordType.DeveloperName;
            }            
        }
    }
*/
}