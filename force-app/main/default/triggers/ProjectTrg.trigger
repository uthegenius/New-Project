trigger ProjectTrg on Project__c ( before insert, before update, after insert, after update) 
{
    // Return if trigger is inactive from custom meta data type
    Trigger_Active_Inactive_Flag__mdt objTrgActive = [Select Flag__c from Trigger_Active_Inactive_Flag__mdt where MasterLabel = 'ProjectTrg'];
    
    if(!objTrgActive.Flag__c ) return ; 
    
    Map<Id, Project__c> mapProject;
    Set<String> SetOfZipCode = new Set<String>();
    List<Project__c> ListProjectToUpdateSalesRegion = new List<Project__c>();
    List<Project__c> ListProjectToRemoveSalesRegion = new List<Project__c>();
    
    ProjectTrgHandler handler = ProjectTrgHandler.getInstance();
    Set<Id> setProjectId = new Set<Id>();
    Set<id> SetProjectToRemoveAgencies = new Set<id>();
    set<Project__c> setPojectIDtoAssignAgency = new set<Project__c>();
    Set<String> SetProjectPostalCode = new Set<String>();
    
    if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate))
    {
        mapProject = Trigger.newMap;
        
        for (Project__c pro : Trigger.New)
        {
            if(String.isNotBlank(pro.Postal_Code__c) && (Trigger.isInsert || Trigger.isUpdate && Trigger.oldMap.get(pro.id).Postal_Code__c != pro.Postal_Code__c))
            {
                setPojectIDtoAssignAgency.add(pro);
                SetProjectPostalCode.add(pro.Postal_Code__c);            
            }
        }
        
        if(SetProjectPostalCode.size() > 0)
        {
            handler.PopulatePostalCodeMap(SetProjectPostalCode);
        }
        
        if(setPojectIDtoAssignAgency.size() > 0)
        {
            handler.AssignAgencies(setPojectIDtoAssignAgency);
        }
        
        
    }
    
    if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate))
    {
        for (Project__c pro : Trigger.New)
        {
            
            if(String.isNotBlank(pro.Postal_Code__c) && ((Trigger.isUpdate && Trigger.oldMap.get(pro.id).Postal_Code__c != pro.Postal_Code__c))||Trigger.isInsert)
            {
                ListProjectToUpdateSalesRegion.add(pro);        
                SetOfZipCode.add(pro.Postal_Code__c);
                if(Trigger.isUpdate)
                {
                    SetProjectToRemoveAgencies.add(pro.id);
                }
                
            } 
            else if(Trigger.isUpdate && String.isBlank(pro.Postal_Code__c))
            {                   
                ListProjectToRemoveSalesRegion.add(pro);   
                SetProjectToRemoveAgencies.add(pro.id);
                pro.Agency_Zip_Code_Assignment__c = null; 
            }
            else if(Trigger.isUpdate && String.isBlank(pro.Project_Region__c))
            {                   
                SetProjectToRemoveAgencies.add(pro.id);              
            }
        }     
        
        if(SetProjectToRemoveAgencies.Size()> 0)
        {
            handler.RemoveAgencies(SetProjectToRemoveAgencies);
        }
        
        if(ListProjectToUpdateSalesRegion.size() > 0)
        {
            handler.AssignSalesRegion(ListProjectToUpdateSalesRegion, SetOfZipCode);
        }

        if(ListProjectToRemoveSalesRegion.size() > 0)
        {
            handler.RemoveSalesOrigin(ListProjectToRemoveSalesRegion);
        } 
        if(!SetOfZipCode.isempty()){
            handler.PopulatePostalCodeMap(SetOfZipCode);
            for( Project__c pro:Trigger.New){
                if(String.isNotBlank(pro.Postal_Code__c)){
                    pro.Agency_Zip_Code_Assignment__c = handler.getSetupZipId(pro.Postal_Code__c);    
                }            
            }
        }
    }
  
    // Before Insert
    if(Trigger.isInsert && Trigger.isBefore)
    {
        handler.OnBeforeInsert(Trigger.new, Trigger.newMap);
    }
    
    // After Insert
    else if(Trigger.isInsert && Trigger.isAfter)
    {
        handler.OnAfterInsert(Trigger.new, Trigger.newMap);
        
        for (Project__c pro : Trigger.New)
        {
            if (Trigger.newMap.get(pro.Id).First_Level_Approver__c != null || 
                Trigger.newMap.get(pro.Id).Second_Level_Approver__c != null  || 
                Trigger.newMap.get(pro.Id).Third_Level_Approver__c != null  
               )            
            {
                setProjectId.add(pro.Id);
            }
        }
        ////////// code added by kashif-- Assign owner to project team ///////////////
        List<Project_Team__c> projTeamList = new  List<Project_Team__c>();
        set<id> projectIdSet = new set<id>();
        Map<id,id> projownerIdMap = new Map<id,id>();
        List<String> ProjectId_UserId = new List<String>();
        Map<String,String> ProjectId_UserIdMap = new Map<String,String>();
        for (Project__c proj : Trigger.New)
        {
             Project_Team__c prjtm = new Project_Team__c(Project__c = proj.Id,User__c = proj.OwnerId, isQuotePDFEmail__c = true, Role__c=proj.Project_Team_Member_Role__c,
                                                        ProjectId_UserId__c=proj.Id+'-'+proj.OwnerId);	
        	 projTeamList.add(prjtm);
             ProjectId_UserId.add(proj.Id+'-'+proj.OwnerId);
        }
        List<Project_Team__c> checkExistingList = [ select id,ProjectId_UserId__c from Project_Team__c where  ProjectId_UserId__c in:ProjectId_UserId];
        if(checkExistingList.size() > 0)
        {
            Integer index = 0, index2=-1;
             for(Project_Team__c ptc : checkExistingList   )
             {
                 index = 0;
                 for(Project_Team__c pt : projTeamList )
                 {
                  	if(ptc.ProjectId_UserId__c == pt.ProjectId_UserId__c )
                  	{
                     	index2 = index; 
                  	}
                     else{
                         index++;
                     }
                 }
                 	if(index2 != -1)
                    {
                     	projTeamList.remove(index2);
                        index2 = -1;
                    }
 					  
             }
        }
        
         	if(projTeamList.size() > 0 )
        	{
            	upsert projTeamList;
        	}   

        ////////// code added by kashif ///////////////
    }
    
    // Before Update
    else if(Trigger.isUpdate && Trigger.isBefore)
    {
        handler.OnBeforeUpdate(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
    }
    
    // After Update
    else if(Trigger.isUpdate && Trigger.isAfter)
    {
        handler.OnAfterUpdate(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
        
        for (Project__c pro : Trigger.New)
        {
            if (Trigger.oldMap.get(pro.Id).First_Level_Approver__c != Trigger.newMap.get(pro.Id).First_Level_Approver__c ||
                Trigger.oldMap.get(pro.Id).Second_Level_Approver__c != Trigger.newMap.get(pro.Id).Second_Level_Approver__c ||
                Trigger.oldMap.get(pro.Id).Third_Level_Approver__c != Trigger.newMap.get(pro.Id).Third_Level_Approver__c
                )
            {
                setProjectId.add(pro.Id);
            }
        }   
         ////////// code added by kashif --  assing owner to project team on update ///////////////
        List<Project_Team__c> projTeamList = new  List<Project_Team__c>();
        set<id> projectIdSet = new set<id>();
        Map<id,id> projownerIdMap = new Map<id,id>();
        List<String> ProjectId_UserId = new List<String>();
        Map<String,String> ProjectId_UserIdMap = new Map<String,String>();
        for (Project__c proj : Trigger.New)
        {
            if(Trigger.oldMap.get(proj.id).OwnerId!= proj.OwnerId)
            {
              	 Project_Team__c prjtm = new Project_Team__c(Project__c = proj.Id,User__c = proj.OwnerId, isQuotePDFEmail__c = true, Role__c=proj.Project_Team_Member_Role__c,
                                                        ProjectId_UserId__c=proj.Id+'-'+proj.OwnerId);	
        	 projTeamList.add(prjtm);
             ProjectId_UserId.add(proj.Id+'-'+proj.OwnerId);               	
            }
        	
  
        }
        if(projTeamList.size() > 0)
        {
            List<Project_Team__c> checkExistingList = [ select id,ProjectId_UserId__c from Project_Team__c where  ProjectId_UserId__c in:ProjectId_UserId];
            if(checkExistingList.size() > 0)
            {
                Integer index = 0, index2=-1;
                 for(Project_Team__c ptc : checkExistingList   )
                 {
                     index = 0;
                     for(Project_Team__c pt : projTeamList )
                     {
                        if(ptc.ProjectId_UserId__c == pt.ProjectId_UserId__c )
                        {
                            index2 = index; 
                        }
                         else{
                             index++;
                         }
                     }
                        if(index2 != -1)
                        {
                            projTeamList.remove(index2);
                            index2 = -1;
                        }
                          
                 }
            }
            
                if(projTeamList.size() > 0 )
                {
                    upsert projTeamList;
                }   
 		}
        ////////// code added by kashif ///////////////
    }
    
    if (setProjectId != null && setProjectId.size() > 0)
    {
        List<Quote> listQuote = [select Id, First_Level_Approver__c, First_Level_Backup_Approver__c, Second_Level_Approver__c, Second_Level_Backup_Approver__c,
                                 Third_Level_Approver__c, Third_Level_Backup_Approver__c, Opportunity.Project__c
                                 from Quote where Opportunity.Project__c in :setProjectId and Opportunity.Recordtype.DeveloperName = 'Projects'];
        
        if (listQuote != null && listQuote.size() > 0)
        {
            List<Quote> listQuotetoUpdate = new List<Quote>();
            
            for (Quote q : listQuote)
            {
                if (mapProject.containsKey(q.Opportunity.Project__c))
                {
                    Project__c proj = mapProject.get(q.Opportunity.Project__c);
                    q.First_Level_Approver__c = proj.First_Level_Approver__c;
                    q.Second_Level_Approver__c = proj.Second_Level_Approver__c;
                    q.Third_Level_Approver__c = proj.Third_Level_Approver__c;
                    
                    listQuotetoUpdate.add(q);
                }
            }
            
            if (listQuotetoUpdate != null && listQuotetoUpdate.size() > 0)
            {
                update listQuotetoUpdate;
            }
        }
    }
}