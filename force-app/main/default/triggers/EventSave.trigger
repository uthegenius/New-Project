trigger EventSave on Event (after insert, after update, after delete, after undelete, before insert, before update) {
    
    // Jira LSCIP-29 (L-8)
    // Track last modify date on parent object ever after delete or undelete
    /*
    Set<Id> parentId = new Set<Id>();
    for(Event anEvent:Trigger.new){
        if(string.isNotBlank(anEvent.WhatId)){
            parentId.add(anEvent.WhatId);
        }            
    }
    
    if(Trigger.isAfter){        
        CommonObjects_Controller.setLastTransActivity(parentId);
    }
    // Jira LSCIP-142 Validation rule on asset type to accept values on for display opportunities
    // Capture Opportunitie's related record's record type.
    else if (Trigger.isBefore){
        map<id,opportunity> mapOpp = new map<id,opportunity>([select RecordType.DeveloperName from Opportunity where id = :parentId]);
        for(Event anEvent:Trigger.new){
            if(mapOpp.containsKey(anEvent.WhatId)){
                anEvent.Related_Record_s_Record_Type__c =  mapOpp.get(anEvent.WhatId).RecordType.DeveloperName;
            }            
        }
    }
   */
}