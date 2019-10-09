trigger EmailMessageTrg on EmailMessage (after insert) {
    
    // After Insert part is Ibad's Code. 
    if(trigger.IsAfter && Trigger.IsInsert)
    {
        List<Case> csList = new List<Case>();
        Set<id> caseId = new Set<id>();
        for (EmailMessage em : Trigger.New)
        {
            
            if (em.parentId != null && em.parentId.getSObjectType() == Case.sObjectType)
            {
                caseId.add(em.parentId);
            }
        }
        
        if(caseId!=null && caseId.size()>0)
        {
            try
            {
            
                csList=[Select id From Case where id in :caseId and origin ='From Reply'];
            }
            
            catch(Exception e)
            {
                system.debug('Exception'+e);
            }
            
            
        }

      
        if(csList!=null && csList.size()>0)
        {
            try
            {
                delete csList;
            }
            
            catch(Exception e)
            {
                system.debug('Exception'+e);
            }
            
        }
        
        
    }
}