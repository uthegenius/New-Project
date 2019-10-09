trigger AgentWork_BeforeCreate on AgentWork (before update) {
	// Return if trigger is inactive from custom meta data type
    Trigger_Active_Inactive_Flag__mdt objTrgActive = [Select Flag__c from Trigger_Active_Inactive_Flag__mdt where MasterLabel = 'AgentWorkTrg'];
    
    if(!objTrgActive.Flag__c )
        return ;
    
    if( Trigger.isUpdate && Trigger.isBefore) {
		List<Case> casesToUpdate = new List<Case>();
        for(AgentWork aw:Trigger.New){
          AgentWork oldAw = Trigger.OldMap.get(aw.Id);
            if(oldAw.Status != 'Opened' && aw.Status == 'Opened') {
                casesToUpdate.add(New Case(Id=aw.WorkItemId, Status='In Progress'));
            }
        }
        if(!casesToUpdate.isEmpty()){
            update casesToUpdate;
        }        
    }
}