/*
* Created by: Tectonic (MB) on 5/21/18
* Description: (LSCIP-80) - (AM-3) - As a result of display opportunity closure, system should be able to add asset in asset manager
*               When the Opp rec type: Display, and it is Closed-won, then create Assets against each Quote line item with Status Inactive.
* Updated by        Updated on      Reason 
*/
trigger OpportunityTrg on Opportunity (before update, after update, after insert, before delete) 
{
     // Abid Raza - 23/7/2018 - Day3 IssueLog(#39) - Except Admin profiles users, no user can delete Opportunity.
    if (Trigger.isBefore && Trigger.isDelete)
    {
        Id profileId=userinfo.getProfileId();
        String profileName=[Select Name from Profile where Id=:profileId].Name;
        
        for (Opportunity opp : Trigger.Old)
        {
            if (profileName != 'System Administrator' && profileName != 'Lixil System Administrator' && profileName != 'Integration System Administrator')
            {
                opp.addError('Opportunity cannot be deleted. Please contact your Salesforce administrator.');
            }
        }
    }
    
    // check to avoid recursion
//    if(AvoidRecursion.isFirstRun())
  //  {
        string context = trigger.isAfter? 'After' : 'Before';
        string dmlContext = trigger.isInsert ? 'Insert' : 'Update';
        system.debug(context + '-' + dmlcontext);
        Set<Id> setShippedOpp = new Set<Id>();
        
        if (Trigger.isUpdate && Trigger.isAfter)
        {
            Map<Id, Opportunity> mapOppsWithAcc = new Map<Id, Opportunity>();
            // get Opp's Display record type
            //Id oppRecId1 = [SELECT id, DeveloperName, SObjectType FROM RecordType WHERE DeveloperName = 'Display' AND SObjectType = 'Opportunity' LIMIT 1].Id;
            
            // create a set of Opp Ids whose rec type "Display" and are closed-won.
            for(Opportunity opp: trigger.new)
            {
                System.debug('Opp stage: ' + opp.StageName );
                // following conditions resets recursion flag, if the trigger was fired in other situations.
                system.Debug('Opp stage name::'+opp.StageName.toLowerCase());
                //if(trigger.oldMap.get(opp.Id).StageName != trigger.newMap.get(opp.Id).StageName && opp.StageName.toLowerCase() == 'shipped' ) AvoidRecursion.resetFirstRun();
                if(trigger.oldMap.get(opp.Id).StageName != trigger.newMap.get(opp.Id).StageName && opp.StageName.toLowerCase() == 'closed won' )
                {
                    mapOppsWithAcc.put(opp.Id, opp);
                }
                // shipped opp set
                // MB: 7/20/18 - changes as per OIL - Day2 / 44
                //if (Trigger.oldMap.get(opp.Id).StageName != Trigger.newMap.get(opp.Id).StageName && opp.StageName == 'Shipped')
                if (Trigger.oldMap.get(opp.Id).StageName != Trigger.newMap.get(opp.Id).StageName && opp.StageName == 'Confirming Display')
                {
                    setShippedOpp.add(opp.Id);
                }
            }   
            // create a task when the opp stage changes to "Confirming Display"
            if ( setShippedOpp.size() > 0 )
            {
                List<Task> listTask = new List<Task>();
                
                for (Opportunity opp : [select Id, Responsible__c, RecordType.DeveloperName, StageName from opportunity where Id in :setShippedOpp and RecordType.DeveloperName = 'Display' and Responsible__c != null])
                {
                    System.debug('Old stage:' + Trigger.oldMap.get(opp.Id).StageName);
                    System.debug('new stage:' + Trigger.newMap.get(opp.Id).StageName);
                    Task tsk =  new Task();
                    tsk.Status = 'Open';
                    tsk.WhatId = opp.Id;
                    tsk.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Display').getRecordTypeId();
                    tsk.ActivityDate = System.today().AddMonths(1);
                    tsk.Subject = Label.Shipped_Opportunity_Task_Subject;
                    tsk.OwnerId = opp.Responsible__c;
                    listTask.add(tsk);
                }
                
                if (listTask != null && listTask.size() > 0)
                {
                    insert listTask;
                }
            }

            // Create Assets against QLI when the Opp stage changes to "closed won"            
            List<Asset> assetsToInsert = new List<asset>();
            if(mapOppsWithAcc.size() > 0)
            {
                System.debug('mapOppsWithAcc: ' + mapOppsWithAcc);
                // retrieve related Quote Line Items
                // map of tasks, with OppId as the key field
                // Map<id, Task> mapTasks = new Map<id, Task>();
                Map<id, Task> mapOppTasks = new Map<Id, Task>();
                for(Task t: [SELECT Asset_Type__c, Sub_Channels__c, Asset_Condition__c, WhatId, Asset_Added_On__c, Description
                             FROM Task 
                             WHERE Status = 'Completed' 
                             AND WhatId IN: mapOppsWithAcc.keySet() ])
                {
                    mapOppTasks.put(t.WhatId, t);
                }
                
                // get asset's "display" record type id
                Id assetRT = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Display').getRecordTypeId();
                
                for(QuoteLineItem qt: [SELECT QuoteId, Quote.OpportunityId, Product2.Name, Product2Id, Quantity, Quote.Opportunity.AccountId
                                       FROM QuoteLineItem 
                                       WHERE QuoteId IN (SELECT Id FROM Quote WHERE OpportunityId IN: mapOppsWithAcc.keySet() ) ])
                {
                    System.debug('QuotelineItem:' + qt);
                    // create asset
                    Asset a = new Asset(Name = qt.Product2.Name
                                        , Product2Id = qt.Product2Id
                                        , Quantity = qt.Quantity
                                        , Asset_Status__c = 'Active'
                                        , RecordTypeId = assetRT
                                        , AccountId = mapOppsWithAcc.get(qt.Quote.OpportunityId).AccountId
                                        , Opportunity__c = mapOppsWithAcc.get(qt.Quote.OpportunityId).Id
                                        , Asset_Condition__c = mapOppTasks.size() > 0 ? mapOppTasks.get(mapOppsWithAcc.get(qt.Quote.OpportunityId).Id).Asset_Condition__c: Null
                                        , Sub_Channels__c = mapOppTasks.size() > 0 ? mapOppTasks.get(mapOppsWithAcc.get(qt.Quote.OpportunityId).Id).Sub_Channels__c: Null
                                        , Asset_Type__c = mapOppTasks.size() > 0 ? mapOppTasks.get(mapOppsWithAcc.get(qt.Quote.OpportunityId).Id).Asset_Type__c: Null
                                        , InstallDate = mapOppTasks.size() > 0 ? mapOppTasks.get(mapOppsWithAcc.get(qt.Quote.OpportunityId).Id).Asset_Added_On__c: Null
                                        , Comments__c = mapOppTasks.size() > 0 ? mapOppTasks.get(mapOppsWithAcc.get(qt.Quote.OpportunityId).Id).Description: Null); 
                    assetsToInsert.add(a);
                    // create task 
                    /*
                    Task t = new Task( WhatId = mapOppsWithAcc.get(qt.Quote.OpportunityId).Id
                                    , Subject = 'Task created:' + Date.today()
                                    , OwnerId = mapOppsWithAcc.get(qt.Quote.OpportunityId).Responsible__c
                                    , Asset_Added_on__c = Date.today()
                                    , Asset_Type__c = 'Working'
                                    , Sub_Channels__c = 'Showroom');
                    mapTasks.put (mapOppsWithAcc.get(qt.Quote.OpportunityId).Id, t);
                    */
                }
            }
            
            // create assets against Quote Line items fetched above
            if (assetsToInsert != null && assetsToInsert.size() > 0)
            {
                System.debug('Assets:' + assetsToInsert);
                insert assetsToInsert;
            }
            // create tasks
            //insert mapTasks.values();
            //System.debug('Tasks:' + mapTasks);    
             ////////// code added by kashif --  assing owner to project team on update ///////////////
        List<Project_Team__c> projTeamList = new  List<Project_Team__c>();
        set<id> projectIdSet = new set<id>();
        Map<id,id> projownerIdMap = new Map<id,id>();
        List<String> ProjectId_UserId = new List<String>();
        Map<String,String> ProjectId_UserIdMap = new Map<String,String>();
        for (Opportunity proj : Trigger.New)
        {
            if(Trigger.oldMap.get(proj.id).OwnerId!= proj.OwnerId)
            {
                 Project_Team__c prjtm = new Project_Team__c(Project__c = proj.Project__c,User__c = proj.OwnerId, isQuotePDFEmail__c = true, Role__c=proj.Project_Team_Member_Role__c,
                                                        ProjectId_UserId__c= proj.Project__c+'-'+proj.OwnerId); 
             projTeamList.add(prjtm);
             ProjectId_UserId.add(proj.Project__c+'-'+proj.OwnerId);  
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
    
        
/*
 *         if (Trigger.isUpdate || Trigger.isInsert && trigger.isAfter)
        {
            /*
              following code commented: MB - 3-Jul-18 - LSCIP-181- Avoid multi task creation
            */
        /*
            for (Opportunity opp : Trigger.New)
            {
                if (Trigger.oldMap.get(opp.Id).StageName != Trigger.newMap.get(opp.Id).StageName && Trigger.newMap.get(opp.Id).StageName == 'Shipped')
                {
                    setShippedOpp.add(opp.Id);
                }
            }
            
            //if (setShippedOpp != null && setShippedOpp.size() > 0 )
            if (setShippedOpp != null && setShippedOpp.size() > 0 )
            {
                List<Task> listTask = new List<Task>();
                
                for (Opportunity opp : [select Id, Responsible__c, RecordType.DeveloperName, StageName from opportunity where Id in :setShippedOpp and RecordType.DeveloperName = 'Display' and Responsible__c != null])
                {
                    System.debug('Old stage:' + Trigger.oldMap.get(opp.Id).StageName);
                    System.debug('new stage:' + Trigger.newMap.get(opp.Id).StageName);
                    //if(Trigger.oldMap.get(opp.Id).StageName != Trigger.newMap.get(opp.Id).StageName && Trigger.newMap.get(opp.Id).StageName == 'Shipped')
                    //{
                        Task tsk =  new Task();
                        tsk.Status = 'Open';
                        tsk.WhatId = opp.Id;
                        tsk.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Display').getRecordTypeId();
                        tsk.ActivityDate = System.today();
                        tsk.Subject = Label.Shipped_Opportunity_Task_Subject;
                        tsk.OwnerId = opp.Responsible__c;
                        listTask.add(tsk);
                    //}
                }
                
                if (listTask != null && listTask.size() > 0)
                {
                    insert listTask;
                }
            }
        }
        */
    /*
    Following code was added by Azfer Pervaiz
    For Team Assignment 
    */
    
    //if(AvoidRecursion.isFirstRun())
    //{
        OpportunityTrgHandler OpportunityTrgHandlerObj = new OpportunityTrgHandler();
        
        if( Trigger.isInsert && Trigger.isAfter ){
            OpportunityTrgHandlerObj.OnAfterInsert(Trigger.new, Trigger.newMap);                         
            
        }else if( Trigger.isUpdate && Trigger.isBefore ){
            OpportunityTrgHandlerObj.onBeforeUpdate(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);            
        }else if( Trigger.isUpdate && Trigger.isAfter ){
            OpportunityTrgHandlerObj.onAfterUpdate(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
        } 
    //}   

}