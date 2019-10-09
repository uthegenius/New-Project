/*-------------------------------------------------------------------------------------------------
Author:             Azfer Pervaiz
Date:               13-June-2018oo
Version:            1.0
Description:        Opportunity Trigger Handler
----------------------------------------------------------------------------------------------------*/
/************************MODIFICATION HISTORY*************************************
Added on                Added By                Description
**********************************************************************************
13-June-2018            Azfer Pervaiz           Initial Development
***********************************************************************************/

public class OpportunityTrgHandler {
    
    public static List<Id> StaticListOpportunityIdToRemoveTeam = new List<Id>();
    public static List<Opportunity> StaticListOpportunityToAssignTeam = new List<Opportunity>();
    
    public static Set<String> StaticSetSalesRegion = new Set<String>();
    
    public void OnAfterInsert(List<Opportunity> newObjects, Map<Id, Opportunity> newMap)
    {
        List<Opportunity> ListOpportunityToAssignTeam = new List<Opportunity>();
        Set<String> SetSalesRegion = new Set<String>();
        Set<Id> setOppIDs = new Set<Id>();
        ////////// code added by kashif --  assing owner to project team on update ///////////////
        List<Project_Team__c> projTeamList = new  List<Project_Team__c>();
        set<id> projectIdSet = new set<id>();
        Map<id,id> projownerIdMap = new Map<id,id>();
        List<String> ProjectId_UserId = new List<String>();
        Map<String,String> ProjectId_UserIdMap = new Map<String,String>();
        
        
        if ( newObjects != null && newObjects.size() > 0)
        {
            for( Opportunity OpportunityObj : newObjects )
            {
                if( OpportunityObj.AccountId != null && String.isNotBlank( OpportunityObj.AccountSalesRegion__c ) && 
                   ( OpportunityObj.RecordTypeDeveloperName__c == 'Display' || OpportunityObj.RecordTypeDeveloperName__c == 'Initiative' ) ) {
                       
                       ListOpportunityToAssignTeam.add( OpportunityObj );
                       SetSalesRegion.add(OpportunityObj.AccountSalesRegion__c);
                   }
                
                setOppIDs.add(OpportunityObj.Id);
                if(string.isNotBlank(OpportunityObj.Project__c)){
                    Project_Team__c prjtm = new Project_Team__c(Project__c = OpportunityObj.Project__c,User__c = OpportunityObj.OwnerId, isQuotePDFEmail__c = true, Role__c='Showroom Manager',
                                                                ProjectId_UserId__c= OpportunityObj.Project__c+'-'+OpportunityObj.OwnerId);	
                    projTeamList.add(prjtm);
                    ProjectId_UserId.add(OpportunityObj.Project__c+'-'+OpportunityObj.OwnerId);  
                }
            }
            
            if (setOppIDs != null && setOppIDs.size() > 0)
            {
                BoxIntegrationUtil.createFolderinBox (setOppIDs, 'Opportunity');
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
            
            
        }
        
        if( SetSalesRegion.size() > 0 ){
            AssignTeamToOpportuniy( ListOpportunityToAssignTeam, SetSalesRegion );
        }
        
        
        ////////// code added by kashif ///////////////  
        
        
    }
    
    public void onBeforeUpdate(List<Opportunity> oldObjects, List<Opportunity> newObjects, Map<Id, Opportunity> oldMap, Map<Id, Opportunity> newMap){
        
        Opportunity OldOpportunityObj;
        
        if ( newObjects != null && newObjects.size() > 0)
        {
            Id profileId=userinfo.getProfileId();
            
            String profileName = '';
            
            if (profileId != null)
            {
                profileName = [Select Name from Profile where Id=:profileId].Name;
            }
            
            for( Opportunity OpportunityObj : newObjects ){
                OldOpportunityObj = oldMap.get( OpportunityObj.Id );
                
                if( OpportunityObj.AccountId != null && String.isNotBlank( OpportunityObj.AccountSalesRegion__c ) && 
                   OpportunityObj.AccountSalesRegionUpdated__c && !OldOpportunityObj.AccountSalesRegionUpdated__c  && 
                   ( OpportunityObj.RecordTypeDeveloperName__c == 'Display' || OpportunityObj.RecordTypeDeveloperName__c == 'Initiative' ) ) { 
                       
                       OpportunityObj.AccountSalesRegionUpdated__c = false;
                       
                       StaticListOpportunityIdToRemoveTeam.add( OpportunityObj.Id );
                       StaticListOpportunityToAssignTeam.add( OpportunityObj );
                       StaticSetSalesRegion.add( OpportunityObj.AccountSalesRegion__c );
                   }
                
                //Remove these check from here and add validation rules for these conditions (02/10/2019)
                // if(profileName != 'Integration System Administrator' && profileName != 'System Administrator' && OpportunityObj.StageName != OldOpportunityObj.StageName && (OpportunityObj.StageName == 'Won'))
                // {
                //     OpportunityObj.addError('Opportunity stage cannot be marked as Won manually.');
                // }
                // if(profileName != 'Integration System Administrator' && profileName != 'System Administrator' && OpportunityObj.StageName != OldOpportunityObj.StageName && (OpportunityObj.StageName == 'Closed Won') && OpportunityObj.Won_Reason__c == null)
                // {
                //     OpportunityObj.addError('Please enter Closed Won Reason.');
                // }
            }
        }
    }
    
    public void onAfterUpdate(List<Opportunity> oldObjects, List<Opportunity> newObjects, Map<Id, Opportunity> oldMap, Map<Id, Opportunity> newMap){
        
        Opportunity OldOpportunityObj;
        
        List<Id> ListOpportunityIdToRemoveTeam = new List<Id>();
        List<Opportunity> ListOpportunityToAssignTeam = new List<Opportunity>();
        
        Set<String> SetSalesRegion = new Set<String>();
        
        if ( newObjects != null && newObjects.size() > 0)
        {
            for( Opportunity OpportunityObj : newObjects )
            {   
                if (oldMap.containsKey( OpportunityObj.Id ))
                {
                    OldOpportunityObj = oldMap.get( OpportunityObj.Id );
                }
                
                if( OpportunityObj.AccountId != null && String.isNotBlank( OpportunityObj.AccountSalesRegion__c ) && 
                   OldOpportunityObj.AccountId != null && OpportunityObj.AccountId != OldOpportunityObj.AccountId && 
                   ( OpportunityObj.RecordTypeDeveloperName__c == 'Display' || OpportunityObj.RecordTypeDeveloperName__c == 'Initiative' ) ) 
                {
                    
                    ListOpportunityIdToRemoveTeam.add( OpportunityObj.Id );
                    ListOpportunityToAssignTeam.add( OpportunityObj );
                    SetSalesRegion.add( OpportunityObj.AccountSalesRegion__c  );
                    
                }
                else if( OpportunityObj.AccountId != null && String.isNotBlank( OpportunityObj.AccountSalesRegion__c ) && 
                        OldOpportunityObj.AccountId == null )
                {
                    ListOpportunityToAssignTeam.add( OpportunityObj );
                    SetSalesRegion.add( OpportunityObj.AccountSalesRegion__c  );
                }
            }
        }
        
        if( StaticSetSalesRegion.size() > 0 ){
            ListOpportunityIdToRemoveTeam.addAll( StaticListOpportunityIdToRemoveTeam );
            ListOpportunityToAssignTeam.addAll( StaticListOpportunityToAssignTeam );
            SetSalesRegion.addAll( StaticSetSalesRegion );
        }
        
        if( SetSalesRegion.size() > 0 ){
            RecalculateOpportuniyTeam( ListOpportunityIdToRemoveTeam, ListOpportunityToAssignTeam, SetSalesRegion);
        }
    }
    
    private void AssignTeamToOpportuniy(List<Opportunity> paramListOpportunityToAssignTeam, Set<String> paramSetSalesRegion){
        
        List<OpportunityTeamMember> ListOpportunityTeamMemberToCreate = new List<OpportunityTeamMember>();
        
        Map<String, List<Team_Assignment_Rule__c>> MapTeamAssignmentRule = new Map<String, List<Team_Assignment_Rule__c>>();
        Set<Id> SetAccountsinRule = new Set<Id>();
        
        if (paramSetSalesRegion != null && paramSetSalesRegion.size() > 0){
            
            for(Team_Assignment_Rule__c TARObj :[SELECT Id, Account__c, Assignment_Type__c, IsParentFerguson__C, 
                                                 Role__c, Region__c, Team_Member__c, User__c
                                                 FROM Team_Assignment_Rule__c
                                                 WHERE RecordType.DeveloperName = 'Opportunity'
                                                 AND Region__c IN : paramSetSalesRegion])
            {
                if( MapTeamAssignmentRule.get( TARObj.Region__c ) == null ){
                    MapTeamAssignmentRule.put( TARObj.Region__c, new List<Team_Assignment_Rule__c>{ TARObj } );
                }else{
                    List<Team_Assignment_Rule__c> TSRTempObj = MapTeamAssignmentRule.get( TARObj.Region__c );
                    TSRTempObj.add( TARObj );
                }
                SetAccountsinRule.add( TARObj.Account__c );
            }
        }
        
        if (paramListOpportunityToAssignTeam != null && paramListOpportunityToAssignTeam.size() > 0){
            
            for( Opportunity OpportunityObj : paramListOpportunityToAssignTeam )
            {
                if( MapTeamAssignmentRule.get( OpportunityObj.AccountSalesRegion__c ) != null ){
                    for( Team_Assignment_Rule__c TSRTempObj : MapTeamAssignmentRule.get( OpportunityObj.AccountSalesRegion__c ) )
                    {
                        if( OpportunityObj.RecordTypeDeveloperName__c == TSRTempObj.Assignment_Type__c && OpportunityObj.AccountSalesRegion__c == TSRTempObj.Region__c ){
                            if( OpportunityObj.AccountsParentAccount__c == TSRTempObj.Account__c && OpportunityObj.AccountsParentAccount__c != null && 
                               TSRTempObj.Account__c != null ){
                                   ListOpportunityTeamMemberToCreate.add( GenerateMember( OpportunityObj.Id, TSRTempObj ) );
                                   
                               }else if( OpportunityObj.AccountsParentAccount__c != null && TSRTempObj.Account__c == null && 
                                        !SetAccountsinRule.contains( OpportunityObj.AccountsParentAccount__c ) ){
                                            ListOpportunityTeamMemberToCreate.add( GenerateMember( OpportunityObj.Id, TSRTempObj ) );
                                            
                                        }else if( OpportunityObj.AccountsParentAccount__c == null && TSRTempObj.Account__c == null ){
                                            ListOpportunityTeamMemberToCreate.add( GenerateMember( OpportunityObj.Id, TSRTempObj ) );
                                        }
                        }
                    }
                }
            }
        }
        
        if( ListOpportunityTeamMemberToCreate.size() > 0 ){
            try{
                insert ListOpportunityTeamMemberToCreate;
            }catch(Exception Ex){
                system.debug('Exception :: '+Ex.getMessage());
            }
        }
    }
    
    private void RecalculateOpportuniyTeam(List<Id> paramListOpportunityIdToRemoveTeam, List<Opportunity> paramListOpportunityToAssignTeam, Set<String> paramSetSalesRegion){
        if( paramListOpportunityIdToRemoveTeam.size() > 0 ){
            try{
                delete [SELECT Id FROM OpportunityTeamMember WHERE OpportunityId IN : paramListOpportunityIdToRemoveTeam];
            }catch(Exception Ex){
                system.debug('Exception :: '+Ex.getMessage());
            }
        }
        
        if( paramSetSalesRegion.size() > 0 ){
            AssignTeamToOpportuniy(paramListOpportunityToAssignTeam, paramSetSalesRegion);
        }
    } 
    
    //This method will return a Account Team Member reocrd
    private OpportunityTeamMember GenerateMember(Id paramOpportunityObjId, Team_Assignment_Rule__c paramTARObj ){
        return ( new OpportunityTeamMember( OpportunityAccessLevel = 'Edit', OpportunityId = paramOpportunityObjId,
                                           TeamMemberRole = paramTARObj.Role__c, UserId = paramTARObj.User__c ) );     
    }
}