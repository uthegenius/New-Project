/************************
Author:         Azfer Pervaiz
Created Date:   2/July/2018 
Purpose:        This handler class will used for the automation on the Project__c object and will be called by ProjectTrg.

************************MODIFICATION HISTORY**************************************
Added on             Added By               Description
10/July/2018           Abid Raza            Auto-Populate region on ZipCode (2 methods added. i)AssignSalesRegion ii)RemoveSalesOrigin)
**********************************************************************************
2/July/2018         Azfer Pervaiz           Initial Development 
***********************************************************************************/
public class ProjectTrgHandler {
   
    static Map<String, ProjectTeamApprover__c> MapGenericApprovers = new Map<String, ProjectTeamApprover__c>();
    static Map<String, ProjectTeamApprover__c> MapNonAgencyApprovers = new Map<String, ProjectTeamApprover__c>();

    static Map<String, List<ProjectTeam__c>> MapGenericProjectTeam = new Map<String, List<ProjectTeam__c>>();
    static Map<String, List<ProjectTeam__c>> MapNonAgencyProjectTeam = new Map<String, List<ProjectTeam__c>>();
    static Map<String, Set<Id>> MapProjectToWholeSellersParentAccount = new Map<String, Set<Id>>();
    
    Map<String, Agency_Zip_Code_Assignment__c> MapZipToRegion =new Map<String, Agency_Zip_Code_Assignment__c>();

    static Set<Id> SetIdDefinedUser = new Set<Id>();

    static List<Project__c> ListProjectApproverTeam = new List<Project__c>();
    static List<Project__c> ListProjectTeam = new List<Project__c>();
    static List<Id> ListProjectId = new List<Id>();
	private static ProjectTrgHandler instance = null;

    private ProjectTrgHandler(){
        PopulateApproversData();
        PopulateProjectTeamData();
    }
    public Id getSetupZipId(String  pZipCode){
        if(MapZipToRegion.containskey(pZipCode)){
            return MapZipToRegion.get(pZipCode).Id;
        }
        return null;
    }
    public static ProjectTrgHandler getInstance(){
        if(instance == null) instance = new ProjectTrgHandler();
		return instance;
    }
    
    
    public void AssignSalesRegion(List<Project__c> paramListProject, Set<String> paramSetOfZipCode)
    {
        Map<String,String> MapZipToRegion = new Map<String,String>();

        for( Agency_Zip_Code_Assignment__c AZCAObj : [SELECT ZipCode__c, Region__c 
                            FROM Agency_Zip_Code_Assignment__c 
                            WHERE ZipCode__c IN : paramSetOfZipCode ])
        {
            MapZipToRegion.put( AZCAObj.ZipCode__c, AZCAObj.Region__c );
        }

        for(Project__c ProjObj : paramListProject)
        {
            ProjObj.Project_Region__c = MapZipToRegion.get(ProjObj.Postal_Code__c);
        }
  
     }
     
      public void RemoveSalesOrigin(List<Project__c> paramListProject)
      {
          for(Project__c ProjObj : paramListProject)
          {
               ProjObj.Project_Region__c = '';
          }
      }

    public void onBeforeInsert(List<Project__c> newObjects, Map<Id, Project__c> newMap){ 
        Set<Project__c> SetProjectToAssignApprovers = new Set<Project__c>();

        for( Project__c ProjectObj : newObjects )
        {
            if( ProjectObj.Project_Region__c != null ){
                SetProjectToAssignApprovers.add( ProjectObj );  
            }
        }

        if( SetProjectToAssignApprovers.size() > 0 ){
            AssignApprovers( SetProjectToAssignApprovers );
        }
        
    
    }
    
    public void OnAfterInsert(List<Project__c> newObjects, Map<Id, Project__c> newMap){

        if( ListProjectApproverTeam.size() > 0 ){
            AssignApproversTeam( ListProjectApproverTeam, false );
            for(Project__C ProjectObj : newObjects){
                ListProjectId.add( ProjectObj.Id );
            }
            AssignProjectTeam( ListProjectApproverTeam, ListProjectId, false );

        }
    }
    
    public void onBeforeUpdate(List<Project__c> oldObjects, List<Project__c> newObjects, Map<Id, Project__c> oldMap, Map<Id, Project__c> newMap){   
        
        Set<Project__c> SetProjectToAssignApprovers = new Set<Project__c>();

        Project__c OldProject;
        for( Project__c ProjectObj : newObjects )
        {
            OldProject = oldMap.get( ProjectObj.Id );
            if( ( ProjectObj.Project_Region__c != null && OldProject.Project_Region__c != ProjectObj.Project_Region__c ) || 
                ( OldProject.OwnerId != ProjectObj.OwnerId ) ){

                SetProjectToAssignApprovers.add( ProjectObj );
            }

            if( ProjectObj.ReassignProjectTeam__c && OldProject.ReassignProjectTeam__c != ProjectObj.ReassignProjectTeam__c ){
                ProjectObj.ReassignProjectTeam__c = false;
                
                SetProjectToAssignApprovers.add( ProjectObj );

                ListProjectTeam.add( ProjectObj );
                ListProjectId.add( ProjectObj.Id );

            }
        }

        if( SetProjectToAssignApprovers.size() > 0 ){
            AssignApprovers( SetProjectToAssignApprovers );
        }
    }
    
    public void onAfterUpdate(List<Project__c> oldObjects, List<Project__c> newObjects, Map<Id, Project__c> oldMap, Map<Id, Project__c> newMap){

        if( ListProjectApproverTeam.size() > 0 ){
            AssignApproversTeam( ListProjectApproverTeam, true );
        }

        Project__c OldProjectObj;

        for( Project__c ProjectObj : newObjects ){

            OldProjectObj = oldMap.get( ProjectObj.Id );
            
            if( ProjectObj.Project_Region__c != OldProjectObj.Project_Region__c || 
                ProjectObj.Total_Project_Value__c != OldProjectObj.Total_Project_Value__c ||
                ProjectObj.Project_Type__c != OldProjectObj.Project_Type__c ||
                ProjectObj.OwnerId != OldProjectObj.OwnerId ){

                ListProjectTeam.add( ProjectObj );
                ListProjectId.add( ProjectObj.Id );
            }
        }

        if( ListProjectTeam.size() > 0 ){
            AssignProjectTeam( ListProjectTeam, ListProjectId, true );
        }        
    }

    private void PopulateApproversData(){

        MapGenericApprovers = new Map<String, ProjectTeamApprover__c>();
        MapNonAgencyApprovers = new Map<String, ProjectTeamApprover__c>();

        for( ProjectTeamApprover__c ProjectTeamApproverObj : [SELECT Id, 
                                                                X1stLevelApprover__c, X1stLevelApproverTeamRole__c,
                                                                X2ndLevelApprover__c, X2ndLevelApproverTeamRole__c,
                                                                X3rdLevelApprover__c, X3rdLevelApproverTeamRole__c,
                                                                AgencyAccount__c, Region__c, Requestor__c, RequestorRole__c, RequestorType__c
                                                            FROM ProjectTeamApprover__c ] )
        {   
            if( ProjectTeamApproverObj.Region__c != null && ProjectTeamApproverObj.RequestorType__c == 'Generic' && ProjectTeamApproverObj.AgencyAccount__c == null && ProjectTeamApproverObj.Requestor__c == null ){
            
                MapGenericApprovers.put( ProjectTeamApproverObj.Region__c , ProjectTeamApproverObj );
            
            }else if( ProjectTeamApproverObj.Region__c != null && ProjectTeamApproverObj.RequestorType__c == 'Non Agency' && ProjectTeamApproverObj.AgencyAccount__c == null && ProjectTeamApproverObj.Requestor__c != null ){
            
                SetIdDefinedUser.add( ProjectTeamApproverObj.Requestor__c );
                MapNonAgencyApprovers.put( ProjectTeamApproverObj.Requestor__c+'-'+ProjectTeamApproverObj.Region__c , ProjectTeamApproverObj );
            }
        }
    }

    private void PopulateProjectTeamData(){
        MapGenericProjectTeam = new Map<String, List<ProjectTeam__c>>();
        MapNonAgencyProjectTeam = new Map<String, List<ProjectTeam__c>>();
        SetIdDefinedUser = new Set<Id>();

		List<ProjectTeam__c> listPT = [SELECT Id, AgencyAccount__c, AmountOver__c ,ParentAccount__c ,ProjectType__c, Region__c,
                                               Requestor__c, RequestorRole__c, RequestorType__c, TeamMember__c, TeamRole__c
                                               FROM ProjectTeam__c ];         
        
        if (listPT != null && listPT.size() > 0)
        {
            for( ProjectTeam__c ProjectTeamObj : listPT)
            {   
                if( ProjectTeamObj.Region__c != null && ProjectTeamObj.RequestorType__c == 'Generic' && ProjectTeamObj.AgencyAccount__c == null && ProjectTeamObj.Requestor__c == null ){
                
                    if( MapGenericProjectTeam.containsKey( ProjectTeamObj.Region__c ) )
                    {
                        list<ProjectTeam__c> ListTemp = MapGenericProjectTeam.get( ProjectTeamObj.Region__c );
                        ListTemp.add( ProjectTeamObj );
                    }
                    else 
                    { 
                        MapGenericProjectTeam.put( ProjectTeamObj.Region__c , new List<ProjectTeam__c> { ProjectTeamObj } );
                    }
                
                }
                else if( ProjectTeamObj.Region__c != null && ProjectTeamObj.RequestorType__c == 'Non Agency' && ProjectTeamObj.AgencyAccount__c == null && ProjectTeamObj.Requestor__c != null )
                {
                    SetIdDefinedUser.add( ProjectTeamObj.Requestor__c );
                    
                    if( MapNonAgencyProjectTeam.containsKey( ProjectTeamObj.Requestor__c+'-'+ProjectTeamObj.Region__c ) )
                    {
                        list<ProjectTeam__c> ListTemp = MapNonAgencyProjectTeam.get( ProjectTeamObj.Requestor__c+'-'+ProjectTeamObj.Region__c );
                        ListTemp.add( ProjectTeamObj );
                    }
                    else 
                    { 
                        MapNonAgencyProjectTeam.put( ProjectTeamObj.Requestor__c+'-'+ProjectTeamObj.Region__c , new List<ProjectTeam__c> { ProjectTeamObj } );
                    }
                }
            }
        }
    }

    private Project__c AssignProjectApprovers(Project__c paramProjectObj, ProjectTeamApprover__c paramProjectTeamApprover ){
        Project__c ProjectObjToReturn = paramProjectObj;

        ProjectObjToReturn.First_Level_Approver__c          = paramProjectTeamApprover.X1stLevelApprover__c;
        ProjectObjToReturn.Second_Level_Approver__c         = paramProjectTeamApprover.X2ndLevelApprover__c;
        ProjectObjToReturn.Third_Level_Approver__c          = paramProjectTeamApprover.X3rdLevelApprover__c;

        return paramProjectObj;
    }

    private Project_Team__c CreateProjectTeam( Project__c paramProjectObj, ProjectTeam__c ProjectTeamObj ){
        
        System.debug('KA: paramProjectObj'+ paramProjectObj);
        System.debug('KA: ProjectTeamObj'+ ProjectTeamObj);
        return( new Project_Team__c ( Project__c = paramProjectObj.Id, IsProjectTeam__c = true, IsQuotePDFEmail__c = true, 
                                        Role__c = ProjectTeamObj.TeamRole__c, 
                                        User__c = ProjectTeamObj.TeamMember__c 
                                     	 
                                    ) );
    }

    private List<Project_Team__c> GenerateProjectApproversTeam(Project__c paramProjectObj, ProjectTeamApprover__c paramProjectTeamApproverObj ){
        List<Project_Team__c> ListToReturn = new List<Project_Team__c>();

        if( paramProjectTeamApproverObj.X1stLevelApprover__c != null ){
            ListToReturn.add( new Project_Team__c (Project__c = paramProjectObj.Id, IsApprover__c = true, IsQuotePDFEmail__c = false,
                                                    Role__c = paramProjectTeamApproverObj.X1stLevelApproverTeamRole__c, 
                                                    User__c = paramProjectTeamApproverObj.X1stLevelApprover__c   ) );
        }
        if( paramProjectTeamApproverObj.X2ndLevelApprover__c != null ){
            ListToReturn.add( new Project_Team__c (Project__c = paramProjectObj.Id, IsApprover__c = true, IsQuotePDFEmail__c = false,
                                                    Role__c = paramProjectTeamApproverObj.X2ndLevelApproverTeamRole__c, 
                                                    User__c = paramProjectTeamApproverObj.X2ndLevelApprover__c 
                                                   ) );
        }
        if( paramProjectTeamApproverObj.X3rdLevelApprover__c != null ){
            ListToReturn.add( new Project_Team__c (Project__c = paramProjectObj.Id, IsApprover__c = true, IsQuotePDFEmail__c = false,
                                                    Role__c = paramProjectTeamApproverObj.X3rdLevelApproverTeamRole__c, 
                                                    User__c = paramProjectTeamApproverObj.X3rdLevelApprover__c  
                                                   ) );
        }
        return ListToReturn;
    }

    private List<Project_Team__c> GenerateProjectTeam( Project__c paramProjectObj, List<ProjectTeam__c> paramListProjectTeam ){
        List<Project_Team__c> ListToReturn = new List<Project_Team__c>();
        Set<Id> SetWholeSellerParentAccount; 
        for(ProjectTeam__c ProjectTeamObj : paramListProjectTeam ){
             
            if( MapProjectToWholeSellersParentAccount.get( paramProjectObj.Id ) != null ){
                SetWholeSellerParentAccount = MapProjectToWholeSellersParentAccount.get( paramProjectObj.Id );
            }else{
                SetWholeSellerParentAccount = new Set<Id>();
            }

            if( ProjectTeamObj.AmountOver__c <= paramProjectObj.Total_Project_Value__c ){

                if( ProjectTeamObj.ParentAccount__c == null && ProjectTeamObj.ProjectType__c == null ){
                 
                    ListToReturn.add( CreateProjectTeam( paramProjectObj, ProjectTeamObj) );  
                
                }else if( ProjectTeamObj.ParentAccount__c != null && SetWholeSellerParentAccount.contains( ProjectTeamObj.ParentAccount__c) && 
                    ProjectTeamObj.ProjectType__c == null && paramProjectObj.Project_Type__c != null ){
                    
                    ListToReturn.add( CreateProjectTeam( paramProjectObj, ProjectTeamObj) );  
                
                }else if( ProjectTeamObj.ParentAccount__c == null && ProjectTeamObj.ProjectType__c != null && paramProjectObj.Project_Type__c != null &&
                    ProjectTeamObj.ProjectType__c.toLowerCase() == paramProjectObj.Project_Type__c.toLowerCase() ){
                    
                    ListToReturn.add( CreateProjectTeam( paramProjectObj, ProjectTeamObj) );  
                
                }else if( ProjectTeamObj.ParentAccount__c != null && ProjectTeamObj.ProjectType__c == null && paramProjectObj.Project_Type__c == null &&
                    SetWholeSellerParentAccount.contains( ProjectTeamObj.ParentAccount__c ) ){

                    ListToReturn.add( CreateProjectTeam( paramProjectObj, ProjectTeamObj) );  

                }else if( ProjectTeamObj.ParentAccount__c != null && SetWholeSellerParentAccount.contains( ProjectTeamObj.ParentAccount__c) && 
                    ProjectTeamObj.ProjectType__c != null && paramProjectObj.Project_Type__c != null &&
                    ProjectTeamObj.ProjectType__c.toLowerCase() == paramProjectObj.Project_Type__c.toLowerCase() ){

                    ListToReturn.add( CreateProjectTeam( paramProjectObj, ProjectTeamObj) );  

                }
                
            } 
        }
        return ListToReturn;
    }

    private void AssignApprovers( Set<Project__c> paramSetProject ){
       
        ProjectTeamApprover__c ProjectTeamApproverObj;
        system.debug(MapNonAgencyApprovers);
        for( Project__c ProjectObj : paramSetProject )
        {       
			system.debug(ProjectObj.OwnerId+'-'+ProjectObj.Project_Region__c);
            
            if( SetIdDefinedUser.contains( ProjectObj.OwnerId ) && MapNonAgencyApprovers.get( ProjectObj.OwnerId+'-'+ProjectObj.Project_Region__c ) != null ){                
                
                ProjectTeamApproverObj = MapNonAgencyApprovers.get( ProjectObj.OwnerId+'-'+ProjectObj.Project_Region__c );
                ProjectObj = AssignProjectApprovers( ProjectObj, ProjectTeamApproverObj );

            }else if ( !SetIdDefinedUser.contains( ProjectObj.OwnerId ) && MapGenericApprovers.get( ProjectObj.Project_Region__c ) != null ){

                ProjectTeamApproverObj = MapGenericApprovers.get( ProjectObj.Project_Region__c );
                ProjectObj = AssignProjectApprovers( ProjectObj, ProjectTeamApproverObj );
                
            }else{
                ProjectObj.First_Level_Approver__c = null;
                ProjectObj.Second_Level_Approver__c = null;
                ProjectObj.Third_Level_Approver__c = null;
            }

            ListProjectApproverTeam.add( ProjectObj );
        }

    }

    private void AssignApproversTeam( List<Project__c> paramListProject, Boolean paramDeletePreviousTeam){
        List<Project_Team__c> ListProjectApproversTeamToCreate = new List<Project_Team__c>();
        List<Id> ListIdProjectApproversTeamToDelete = new List<Id>();
        ProjectTeamApprover__c ProjectTeamApproverObj;
        
        for( Project__c ProjectObj : paramListProject)
        {
            ListIdProjectApproversTeamToDelete.add( ProjectObj.Id );

            if( SetIdDefinedUser.contains( ProjectObj.OwnerId ) && MapNonAgencyApprovers.get(  ProjectObj.OwnerId+'-'+ProjectObj.Project_Region__c ) != null ){

                ProjectTeamApproverObj = MapNonAgencyApprovers.get(  ProjectObj.OwnerId+'-'+ProjectObj.Project_Region__c );
                ListProjectApproversTeamToCreate.addAll( GenerateProjectApproversTeam( ProjectObj, ProjectTeamApproverObj ) );
            
            }else if ( !SetIdDefinedUser.contains( ProjectObj.OwnerId ) && MapGenericApprovers.get( ProjectObj.Project_Region__c ) != null ){

                ProjectTeamApproverObj = MapGenericApprovers.get( ProjectObj.Project_Region__c );
                ListProjectApproversTeamToCreate.addAll( GenerateProjectApproversTeam( ProjectObj, ProjectTeamApproverObj ) );

            }
        }

        if( ListIdProjectApproversTeamToDelete.size() > 0 ){
            List<Project_Team__c> ListProjectTeamToDelete = [SELECT Id FROM Project_Team__c WHERE Project__C IN : ListIdProjectApproversTeamToDelete AND IsApprover__c = true];
            
            List<Database.DeleteResult> DeleteResults = Database.delete(ListProjectTeamToDelete, false);
            
            for(Database.DeleteResult DeleteResult : DeleteResults)
            {
                if(DeleteResult.isSuccess())
                    continue;
                for(Database.Error err : DeleteResult.getErrors())
                {
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                }
            }
        }        
        if( ListProjectApproversTeamToCreate.size() > 0 ){
            List<Database.SaveResult> saveResults = Database.insert(ListProjectApproversTeamToCreate, false);
            
            for(Database.SaveResult saveResult : saveResults)
            {
                if(saveResult.isSuccess())
                    continue;
                for(Database.Error err : saveResult.getErrors())
                {
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                }
            }
        }
    }

    private void AssignProjectTeam( List<Project__c> paramListProject, List<Id> paramListProjectId, Boolean paramDeletePreviousTeam){

        List<Project_Team__c> ListProjectTeamToCreate = new List<Project_Team__c>();
        List<Id> ListIdProjectTeamToDelete = new List<Id>();
        List<ProjectTeam__c> ListProjectTeam;

        for( Wholesalers__c WholesalersObj : [SELECT Project__c, WholeSellerParentAccount__c 
                                                FROM Wholesalers__c 
                                                WHERE Project__c IN : paramListProjectId ] )
        {
            if( MapProjectToWholeSellersParentAccount.containsKey( WholesalersObj.Project__c ) ){
                Set<Id> TempSetId = MapProjectToWholeSellersParentAccount.get( WholesalersObj.Project__c );
                TempSetId.add( WholesalersObj.WholeSellerParentAccount__c );
            }else{
                MapProjectToWholeSellersParentAccount.put( WholesalersObj.Project__c, new Set<Id>{ WholesalersObj.WholeSellerParentAccount__c } );
            }
        }
        for( Project__c ProjectObj : paramListProject)
        {
            ListIdProjectTeamToDelete.add( ProjectObj.Id );
            
            if( SetIdDefinedUser.contains( ProjectObj.OwnerId ) && MapNonAgencyProjectTeam.get( ProjectObj.OwnerId+'-'+ProjectObj.Project_Region__c ) != null ){
                
                ListProjectTeam = MapNonAgencyProjectTeam.get( ProjectObj.OwnerId+'-'+ProjectObj.Project_Region__c );
                ListProjectTeamToCreate.addAll( GenerateProjectTeam( ProjectObj, ListProjectTeam ) );
            
            }else if ( !SetIdDefinedUser.contains( ProjectObj.OwnerId ) && MapGenericProjectTeam.get( ProjectObj.Project_Region__c ) != null ){
                
                ListProjectTeam = MapGenericProjectTeam.get( ProjectObj.Project_Region__c );
                ListProjectTeamToCreate.addAll( GenerateProjectTeam( ProjectObj, ListProjectTeam ) );

            }
        }

        if( ListIdProjectTeamToDelete.size() > 0 ){
            List<Project_Team__c> ListProjectTeamToDelete = [SELECT Id FROM Project_Team__c WHERE Project__C IN : ListIdProjectTeamToDelete AND IsProjectTeam__c = true];
            
            List<Database.DeleteResult> DeleteResults = Database.delete(ListProjectTeamToDelete, false);
            
            for(Database.DeleteResult DeleteResult : DeleteResults)
            {
                if(DeleteResult.isSuccess())
                    continue;
                for(Database.Error err : DeleteResult.getErrors())
                {
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                }
            }
        }        

        if( ListProjectTeamToCreate.size() > 0 ){
            List<Database.SaveResult> saveResults = Database.insert(ListProjectTeamToCreate, false);
            
            for(Database.SaveResult saveResult : saveResults)
            {
                if(saveResult.isSuccess())
                    continue;
                for(Database.Error err : saveResult.getErrors())
                {
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                }
            }
        }
    }
    
    //This method will be used to assign the Agencies to Project__c
    public void AssignAgencies( Set<Project__c> paramSetAccountToAssignAgencies ){
        List<Project_Agency__c> ListOfAgencyToCreate = new List<Project_Agency__c>();
        System.debug('KA:: Assign Agencies Called ');
        for(Project__c projObj : paramSetAccountToAssignAgencies )
        {
            if( MapZipToRegion.get( projObj.Postal_Code__c ) != null ){
                
                ListOfAgencyToCreate.addAll( GenerateAgencies( projObj , MapZipToRegion.get( projObj.Postal_Code__c ) ) );
            }
        }
        
        if( ListOfAgencyToCreate.size() > 0 ){
            try{
                insert ListOfAgencyToCreate;
            }catch(Exception Ex){
                system.debug('KA::Exception :: '+Ex.getMessage());
            }
        }
    }
    //This method will be used to generate agency records
    private List<Project_Agency__c> GenerateAgencies(Project__c paramProject, Agency_Zip_Code_Assignment__c paramAZCA ){
        
        List<Project_Agency__c> ListToReturn = new List<Project_Agency__c>();
        System.debug('KA:: GenerateAgencies Init: '+ListToReturn.size() );
        if( paramAZCA.ASRep__c != null ){
            ListToReturn.add ( new Project_Agency__c( Project__c = paramProject.Id, Project_Agency__c = paramAZCA.ASRep__c, Type__c = 'AS' ) ); 
        }
        
        if( paramAZCA.DXVRep__c != null ){
            ListToReturn.add ( new Project_Agency__c( Project__c = paramProject.Id, Project_Agency__c = paramAZCA.DXVRep__c, Type__c = 'DXV' ) ); 
        }
        
        if( paramAZCA.FiatRep__c != null ){
            ListToReturn.add ( new Project_Agency__c( Project__c = paramProject.Id, Project_Agency__c = paramAZCA.FiatRep__c, Type__c = 'Fiat' ) ); 
        }
        
        if( paramAZCA.GroheRep__c != null ){
            ListToReturn.add ( new Project_Agency__c( Project__c = paramProject.Id, Project_Agency__c = paramAZCA.GroheRep__c, Type__c = 'Grohe' ) ); 
        }
        System.debug('KA::Project Agency Created: '+ListToReturn.size() );
        return ListToReturn;  
    }
    public void PopulatePostalCodeMap( Set<String> paramSetProjectPostalCode ){
        MapZipToRegion = new Map<String,Agency_Zip_Code_Assignment__c>();
        
        for( Agency_Zip_Code_Assignment__c AZCAObj : [SELECT ASRep__c, DXVRep__c, FiatRep__c, GroheRep__c, Region__c, ZipCode__c 
                                                      FROM Agency_Zip_Code_Assignment__c 
                                                      WHERE ZipCode__c IN : paramSetProjectPostalCode ])
        {
            MapZipToRegion.put( AZCAObj.ZipCode__c, AZCAObj );
        }
        
    }
    
    //This method will be used to remove the agencyies
    public void RemoveAgencies(Set<Id> paramSetProjectId)
    {
        try{
            delete [SELECT Id FROM Project_Agency__c WHERE Project__c IN : paramSetProjectId ];
        }catch(Exception Ex){
            system.debug('Exception :: '+Ex.getMessage());
        }
    }
    
    
  
    
   
    
    
}