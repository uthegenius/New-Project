/************************
Author:         Azfer Pervaiz
Created Date:   30/May/2018 
Purpose:        This class is the Helper class for the Account Trigger.

************************MODIFICATION HISTORY**************************************
Added on             Added By               Description
**********************************************************************************
30/May/2018          Azfer Pervaiz          Initial Development 
***********************************************************************************/
public class AccountTrgHelper{

    static Set<String> SetAccountRecordTypeToAssignAgencies = new Set<String>();
    static Set<String> SetAccountRecordTypeToAssignTeam = new Set<String>();
    static Set<String> SetAccountRecordTypeToNotAssignRegion = new Set<String>();
    
    static Set<Account> SetAccountToAssignRegion = new Set<Account>();
    static Set<Account> SetAccountToAssignAgencies = new Set<Account>();
    static Set<Account> SetAccountToAssignTeam = new Set<Account>();

    static Set<String> SetAccountPostalCode = new Set<String>();
    
    static Set<String> SetAccountRegion = new Set<String>();
    static Set<String> SetAccountRecordType = new Set<String>();

    static Set<Id> SetAccountToRemoveAgencies = new Set<Id>();
    static Set<Id> SetAccountToRemoveTeam = new Set<Id>();
    
    static Map<String,Agency_Zip_Code_Assignment__c> MapZipToRegion = new Map<String,Agency_Zip_Code_Assignment__c>();
    static Map<String,List<Team_Assignment_Rule__c>> MapAccountTeam = new Map<String,List<Team_Assignment_Rule__c>>();

    //Constructor
    public AccountTrgHelper(){
        populateRecordTypeSet();        
    }

    //Method To Populate Set collection
    private void populateRecordTypeSet(){

        SetAccountRecordTypeToAssignAgencies.add( 'dealer' );
        SetAccountRecordTypeToAssignAgencies.add( 'influencer' );
        
        SetAccountRecordTypeToAssignTeam.add( 'agency' );
        SetAccountRecordTypeToAssignTeam.add( 'customer' );
        SetAccountRecordTypeToAssignTeam.add( 'dealer' );
        SetAccountRecordTypeToAssignTeam.add( 'influencer' );

        SetAccountRecordTypeToNotAssignRegion.add( 'buying_group' );
        SetAccountRecordTypeToNotAssignRegion.add( 'customer' );

    }

    public void onBeforeInsert(List<Account> newObjects, Map<Id, Account> newMap){
        for( Account AccountObj : newObjects ){
            
            if( !SetAccountRecordTypeToNotAssignRegion.contains( AccountObj.RecordTypeDeveloperName__c.toLowerCase() ) &&
                AccountObj.ShippingPostalCode != null ){

                SetAccountToAssignRegion.add( AccountObj );
            }else{
                AccountObj.ShippingPostalCode = null; 
                if( SetAccountRecordTypeToAssignAgencies.contains( AccountObj.RecordTypeDeveloperName__c.toLowerCase() ) ){
                    SetAccountToRemoveAgencies.add( AccountObj.Id );               
                }
                SetAccountToRemoveTeam.add( AccountObj.Id );
            }

            if( AccountObj.ShippingPostalCode != null ){
                SetAccountPostalCode.add( AccountObj.ShippingPostalCode );
            }else{
                AccountObj.ShippingPostalCode = null;     
                if( SetAccountRecordTypeToAssignAgencies.contains( AccountObj.RecordTypeDeveloperName__c.toLowerCase() ) ){
                    SetAccountToRemoveAgencies.add( AccountObj.Id );               
                }
                SetAccountToRemoveTeam.add( AccountObj.Id );                        
            }

            if( AccountObj.RecalculateTeamAssignment__c ){
            
                AccountObj.RecalculateTeamAssignment__c = false;
                
                SetAccountToAssignAgencies.add( AccountObj );
                SetAccountToAssignTeam.add( AccountObj );
                if( SetAccountRecordTypeToAssignAgencies.contains( AccountObj.RecordTypeDeveloperName__c.toLowerCase() ) ){
                    SetAccountToRemoveAgencies.add( AccountObj.Id );               
                }
                SetAccountToRemoveTeam.add( AccountObj.Id );

            }
            SetAccountRegion.add( AccountObj.Sales_Region__c );
            SetAccountRecordType.add( AccountObj.RecordTypeDeveloperName__c );

        }
        if( SetAccountPostalCode.size() > 0 ){
            PopulatePostalCodeMap( SetAccountPostalCode );
        }

        if( SetAccountToAssignRegion.size() > 0 ){
            AssignRegionToAccount( SetAccountToAssignRegion );
        }

        if( SetAccountRegion.size() > 0 ){
            PopulateTeamMap( SetAccountRegion, SetAccountRecordType );
        }

        if( SetAccountRegion.size() > 0 ){
            AssignRegionalShowroomManager( SetAccountToAssignRegion );
        }        
    } 

    public void OnAfterInsert(List<Account> newObjects, Map<Id, Account> newMap){
        Set<Id> setAcctIDs = new Set<Id>();

        for( Account AccountObj : newObjects )
        {
            
            if( SetAccountRecordTypeToAssignAgencies.contains( AccountObj.RecordTypeDeveloperName__c.toLowerCase() ) &&
                AccountObj.ShippingPostalCode != null ){

                SetAccountToAssignAgencies.add( AccountObj );

            }

            if( AccountObj.Sales_Region__c != null && SetAccountRecordTypeToAssignTeam.contains( AccountObj.RecordTypeDeveloperName__c.toLowerCase() ) ){
                SetAccountToAssignTeam.add( AccountObj );
            }
            
            setAcctIDs.add(AccountObj.Id);
        }
        if (setAcctIDs != null && setAcctIDs.size() > 0)
        {
            BoxIntegrationUtil.createFolderinBox (setAcctIDs, 'Account');
        }

        if( SetAccountToRemoveAgencies.size() > 0 ){
            RemoveAgencies( SetAccountToRemoveAgencies );
        }

        if( SetAccountToAssignAgencies.size() > 0 ){
            AssignAgencies( SetAccountToAssignAgencies );
        }

        if( SetAccountToAssignTeam.size() > 0 ){
            AssignAccountTeam( SetAccountToAssignTeam );
        }
    }

    public void onBeforeUpdate(List<Account> oldObjects, List<Account> newObjects, Map<Id, Account> oldMap, Map<Id, Account> newMap){
        Account OldAccount;
        for( Account AccountObj : newObjects ){
            
            OldAccount = oldMap.get( AccountObj.Id );

            if( !SetAccountRecordTypeToNotAssignRegion.contains( AccountObj.RecordTypeDeveloperName__c.toLowerCase() ) &&
                AccountObj.ShippingPostalCode != null && OldAccount.ShippingPostalCode != AccountObj.ShippingPostalCode ){

                SetAccountToAssignRegion.add( AccountObj );    
                if( SetAccountRecordTypeToAssignAgencies.contains( AccountObj.RecordTypeDeveloperName__c.toLowerCase() ) ){
                    SetAccountToRemoveAgencies.add( AccountObj.Id );               
                }
                SetAccountToRemoveTeam.add( AccountObj.Id );

            }else  if( AccountObj.ShippingPostalCode == null ){
            
                AccountObj.ShippingPostalCode = null;     
                if( SetAccountRecordTypeToAssignAgencies.contains( AccountObj.RecordTypeDeveloperName__c.toLowerCase() ) ){
                    SetAccountToRemoveAgencies.add( AccountObj.Id );               
                }
                SetAccountToRemoveTeam.add( AccountObj.Id );                          
            
            }

            if( AccountObj.ShippingPostalCode != null ){

                SetAccountPostalCode.add( AccountObj.ShippingPostalCode );
            
            }else  if( AccountObj.ShippingPostalCode == null ){
            
                AccountObj.ShippingPostalCode = null;                
                if( SetAccountRecordTypeToAssignAgencies.contains( AccountObj.RecordTypeDeveloperName__c.toLowerCase() ) ){
                    SetAccountToRemoveAgencies.add( AccountObj.Id );               
                }
                SetAccountToRemoveTeam.add( AccountObj.Id );               
            
            }

            if( AccountObj.RecalculateTeamAssignment__c ){
                
                AccountObj.RecalculateTeamAssignment__c = false;

                SetAccountToAssignAgencies.add( AccountObj );
                SetAccountToAssignTeam.add( AccountObj );
                if( SetAccountRecordTypeToAssignAgencies.contains( AccountObj.RecordTypeDeveloperName__c.toLowerCase() ) ){
                    SetAccountToRemoveAgencies.add( AccountObj.Id );               
                }
                SetAccountToRemoveTeam.add( AccountObj.Id );

            }

            SetAccountRegion.add( AccountObj.Sales_Region__c );
            SetAccountRecordType.add( AccountObj.RecordTypeDeveloperName__c );

        }

        if( SetAccountPostalCode.size() > 0 ){
            PopulatePostalCodeMap( SetAccountPostalCode );
        }

        if( SetAccountToAssignRegion.size() > 0 ){
            AssignRegionToAccount( SetAccountToAssignRegion );
        }

        if( SetAccountRegion.size() > 0 ){
            PopulateTeamMap( SetAccountRegion, SetAccountRecordType );
        }

        if( SetAccountRegion.size() > 0 ){
            AssignRegionalShowroomManager( SetAccountToAssignRegion );
        }
		
        // Added by Hanif to call Account Sub Type update for Integration
        setAccountSubType(newMap);
    }   

    public void onAfterUpdate(List<Account> oldObjects, List<Account> newObjects, Map<Id, Account> oldMap, Map<Id, Account> newMap){
        Account OldAccount;
        Set<Id> SetAccountId = new Set<Id>();
        for( Account AccountObj : newObjects ){
            
            OldAccount = oldMap.get( AccountObj.Id );
            
            if( SetAccountRecordTypeToAssignAgencies.contains( AccountObj.RecordTypeDeveloperName__c.toLowerCase() ) &&
                AccountObj.ShippingPostalCode != null && OldAccount.ShippingPostalCode != AccountObj.ShippingPostalCode ){
                SetAccountToAssignAgencies.add( AccountObj );
                SetAccountId.add( AccountObj.Id );
            
            }
            if( AccountObj.Sales_Region__c != null && AccountObj.RecordTypeId != null && 
                ( AccountObj.Sales_Region__c != OldAccount.Sales_Region__c || AccountObj.RecordTypeId != OldAccount.RecordTypeId ) &&  
                SetAccountRecordTypeToAssignTeam.contains( AccountObj.RecordTypeDeveloperName__c.toLowerCase() ) ){

                SetAccountToRemoveTeam.add( AccountObj.Id );
                SetAccountToAssignTeam.add( AccountObj );
            }
        }
        if( SetAccountToRemoveAgencies.size() > 0 ){
            RemoveAgencies( SetAccountToRemoveAgencies );
        }               
        
        if( SetAccountToAssignAgencies.size() > 0 ){
            AssignAgencies( SetAccountToAssignAgencies );
            UpdateChildOpportunity( SetAccountId );
        }

        if( SetAccountToRemoveTeam.size() > 0 ){
            RemoveAccountTeam( SetAccountToRemoveTeam );
        }

        if( SetAccountToAssignTeam.size() > 0 ){
            AssignAccountTeam( SetAccountToAssignTeam );
        }
    }


    //This method will be used to populate the regions map for the account
    private void PopulatePostalCodeMap( Set<String> paramSetAccountPostalCode ){
        MapZipToRegion = new Map<String,Agency_Zip_Code_Assignment__c>();

        for( Agency_Zip_Code_Assignment__c AZCAObj : [SELECT ASRep__c, DXVRep__c, FiatRep__c, GroheRep__c, Region__c, ZipCode__c 
                                                        FROM Agency_Zip_Code_Assignment__c 
                                                        WHERE ZipCode__c IN : paramSetAccountPostalCode ])
        {
            MapZipToRegion.put( AZCAObj.ZipCode__c, AZCAObj );
        }

    }

    //This method will be used to populate map for the account team
    private void PopulateTeamMap( Set<String> paramSetRegions, Set<String> paramSetAccountRecordType ){
        MapAccountTeam = new Map<String,List<Team_Assignment_Rule__c>>();
    
        for(Team_Assignment_Rule__c TARObj :[SELECT Id, Account__c, Assignment_Type__c, Role__c, 
                                                SubChannel__c, Region__c, Team_Member__c, User__c
                                            FROM Team_Assignment_Rule__c
                                            WHERE RecordType.DeveloperName = 'Account_Team'
                                            AND Assignment_Type__c IN : paramSetAccountRecordType
                                            AND Region__c IN : paramSetRegions])
        {
            if( MapAccountTeam.get( TARObj.Assignment_Type__c+'-'+TARObj.Region__c ) == null ){
                MapAccountTeam.put( TARObj.Assignment_Type__c+'-'+TARObj.Region__c, new List<Team_Assignment_Rule__c>{ TARObj } );
            }else{
                List<Team_Assignment_Rule__c> TSRTempObj = MapAccountTeam.get( TARObj.Assignment_Type__c+'-'+TARObj.Region__c );
                TSRTempObj.add( TARObj );
            }
        
        }
    
    }

    //This method will be used to assign the Region to Account
    private void AssignRegionToAccount( Set<Account> paramSetAccountToAssignRegion ){
        for(Account AccountObj : paramSetAccountToAssignRegion )
        {
            if( MapZipToRegion.get( AccountObj.ShippingPostalCode ) != null ){
                AccountObj.Sales_Region__c = MapZipToRegion.get( AccountObj.ShippingPostalCode ).Region__c;
                SetAccountRegion.add( AccountObj.Sales_Region__c );
            }else{
                AccountObj.Sales_Region__c = null;
            }
        }
    }

    //This method will assigne the Regional ShowRoom manager to account
    //RSM = Regional ShowRoom manager
    private void AssignRegionalShowroomManager( Set<Account> paramSetAccountToAssignRSM ){
        for( Account AccountObj : paramSetAccountToAssignRSM )
        {
            String Key = AccountObj.RecordTypeDeveloperName__c+'-'+AccountObj.Sales_Region__c;
            if( MapAccountTeam.get( Key ) != null ){
                for( Team_Assignment_Rule__c TARObj : MapAccountTeam.get( Key ) )
                {
                    if( TARObj.Role__c == 'Regional Showroom Manager' ){
                        if( TARObj.Account__c == AccountObj.ParentId ){
                            AccountObj.Regional_Showroom_Manager2__c = TARObj.Team_Member__c;
                        }else if( TARObj.Account__c == null ) {
                            AccountObj.Regional_Showroom_Manager2__c = TARObj.Team_Member__c;
                        }
                    }
                }
            }
        }
    }

    //This method will be used to remove the agencyies
    private void RemoveAgencies( Set<Id> paramSetAccountId ){

        try{
           delete [SELECT Id FROM Agency__c WHERE Account__c IN : paramSetAccountId ];
        }catch(Exception Ex){
            system.debug('Exception :: '+Ex.getMessage());
        }
    }

    //This method will be used to assign the Agencies to Account
    private void AssignAgencies( Set<Account> paramSetAccountToAssignAgencies ){
        List<Agency__c> ListOfAgencyToCreate = new List<Agency__c>();
        
        for(Account AccountObj : paramSetAccountToAssignAgencies )
        {
            if( MapZipToRegion.get( AccountObj.ShippingPostalCode ) != null ){

                ListOfAgencyToCreate.addAll( GenerateAgencies( AccountObj , MapZipToRegion.get( AccountObj.ShippingPostalCode ) ) );
            }
        }
    
        if( ListOfAgencyToCreate.size() > 0 ){
            try{
               insert ListOfAgencyToCreate;
            }catch(Exception Ex){
                system.debug('Exception :: '+Ex.getMessage());
            }
        }
    }

    //This method will be used to generate agency records
    private List<Agency__c> GenerateAgencies(Account paramAccount, Agency_Zip_Code_Assignment__c paramAZCA ){

        List<Agency__c> ListToReturn = new List<Agency__c>();

        if( paramAZCA.ASRep__c != null ){
            ListToReturn.add ( new Agency__c( Account__c = paramAccount.Id, Agency_Account__c = paramAZCA.ASRep__c, Type__c = 'AS' ) ); 
        }

        if( paramAZCA.DXVRep__c != null ){
            ListToReturn.add ( new Agency__c( Account__c = paramAccount.Id, Agency_Account__c = paramAZCA.DXVRep__c, Type__c = 'DXV' ) ); 
        }

        if( paramAZCA.FiatRep__c != null ){
            ListToReturn.add ( new Agency__c( Account__c = paramAccount.Id, Agency_Account__c = paramAZCA.FiatRep__c, Type__c = 'Fiat' ) ); 
        }

        if( paramAZCA.GroheRep__c != null ){
            ListToReturn.add ( new Agency__c( Account__c = paramAccount.Id, Agency_Account__c = paramAZCA.GroheRep__c, Type__c = 'Grohe' ) ); 
        }

        return ListToReturn;

    }

    //This method will be used to delete account team
    private void RemoveAccountTeam( Set<Id> paramSetAccountId ){

        try{
           delete [SELECT Id FROM AccountTeamMember WHERE AccountId IN : paramSetAccountId ];
        }catch(Exception Ex){
            system.debug('Exception :: '+Ex.getMessage());
        }
    }

    //This method will used to assign account team
    private void AssignAccountTeam( Set<Account> paramSetAccount){
        
        List<AccountTeamMember> ListATMtoCreate = new List<AccountTeamMember>();
        for( Account AccountObj : paramSetAccount )
        {
            String Key = AccountObj.RecordTypeDeveloperName__c+'-'+AccountObj.Sales_Region__c;

            if( MapAccountTeam.get( Key ) != null ){
                for( Team_Assignment_Rule__c TARObj : MapAccountTeam.get( Key ) )
                {
                    if( TARObj.Account__c == AccountObj.ParentId && AccountObj.ParentId != null && 
                        AccountObj.Sub_Channel__c != null && TARObj.SubChannel__c != null && AccountObj.Sub_Channel__c.contains( TARObj.SubChannel__c ) ){

                        ListATMtoCreate.add( GenerateMember( AccountObj.Id, TARObj) );

                    }else if( TARObj.Account__c == AccountObj.ParentId && AccountObj.ParentId != null && 
                        TARObj.SubChannel__c == null && AccountObj.Sub_Channel__c == null ){

                        ListATMtoCreate.add( GenerateMember( AccountObj.Id, TARObj) );

                    }else if ( TARObj.Account__c == null ){

                        ListATMtoCreate.add( GenerateMember( AccountObj.Id, TARObj) );

                    }
                }
            }
        }
        if( ListATMtoCreate.size() > 0 ){
            try{
               insert ListATMtoCreate;
            }catch(Exception Ex){
                system.debug('Exception :: '+Ex.getMessage());
            } 
        }
    }

    //This method will return a Account Team Member reocrd
    private AccountTeamMember GenerateMember(Id paramAccountId, Team_Assignment_Rule__c paramTARObj ){
        return ( new AccountTeamMember ( AccountAccessLevel = 'Edit', AccountId = paramAccountId, CaseAccessLevel = 'Edit', 
                                            ContactAccessLevel = 'Edit', OpportunityAccessLevel = 'Edit', TeamMemberRole = paramTARObj.Role__c, 
                                            UserId = paramTARObj.Team_Member__c ) );       
    }

    //This methos will update the child opporutnity when region is chagnes
    private void UpdateChildOpportunity( Set<Id> paramSetAccountId ){
        List<opportunity> ListOpportunityToUpdate = new List<opportunity>();

        for( Opportunity OpportunityObj :[SELECT 
                                                Id, AccountSalesRegionUpdated__c 
                                        FROM Opportunity
                                        WHERE AccountId IN : paramSetAccountId] )
        {
            OpportunityObj.AccountSalesRegionUpdated__c = true;
            ListOpportunityToUpdate.add( OpportunityObj );
        }

        if( ListOpportunityToUpdate.size() > 0 ){
            try{
                update ListOpportunityToUpdate;
            }catch(Exception Ex){
                system.debug('Exception :: '+Ex.getMessage());
            }
        }
    }
    // Add by Hanif to set Account subtype recieved from partnerfunction
    private void setAccountSubType(Map<Id, Account> newMap){
        // Get last account subt type value
        List<Account> lstAccount = [Select Account_Subtype__c From Account Where id = :newMap.keySet()];
        
        for(Account anAccount:lstAccount){
            // Account sub type from old, new and Integration Partnerfunction field
            Account trgAccount  = newMap.get(anAccount.Id);
            String newAST = trgAccount.Account_Subtype__c;  
            //String existingAST = anAccount.Account_Subtype__c;
            String partnerFunction = trgAccount.Partner_Function__c;
            String strAccountSubType = newAST+';'/*+existingAST+';'*/+partnerFunction;
            strAccountSubType.removeEnd(';');
            strAccountSubType.removeStart(';');
            // Make AST unique
            List<String> lstAST = strAccountSubType.split(';');
            Set<String> setAST = new Set<String>();
            for (string AST:lstAST){
                system.debug(AST);
                if(String.isNotBlank(AST)&&AST!='null'&&AST!=null){
                    string pfAST='';                
                    if (AST=='SH'){
                       pfAST = 'Ship to';
                    }
                    else if (AST=='BP'){
                       pfAST = 'Bill to';
                    }
                    else if (AST=='SP'){
                       pfAST = 'Sold to';
                    }
                    else{
                        pfAST=AST;
                    }
                    if(!setAST.contains(pfAST) && string.isNotBlank(pfAST)){                        
                        setAST.add(pfAST);
                    }
                }
            }			
            if(!setAST.isEmpty()){
                lstAST.clear();
            	lstAST.AddAll(setAST);
                system.debug(lstAST);
                if(setAST.contains('Sold to') && !setAST.contains('Ship to')){
                    lstAST.add('Ship to');
                }
                trgAccount.Account_Subtype__c = string.join(lstAST, ';');
            }
            
        }
    }
}