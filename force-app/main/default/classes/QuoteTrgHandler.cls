/************************
Author:         Azfer Pervaiz
Created Date:   27/July/2018 
Purpose:        Quote Trg Handler.

************************MODIFICATION HISTORY**************************************
Added on             Added By               Description
**********************************************************************************
27/July/2018          Azfer Pervaiz          Initial Development 
***********************************************************************************/

public class QuoteTrgHandler {

    static Set<Id> SetIdDefinedUser = new Set<Id>();
    static Map<String, ProjectTeamApprover__c> MapGenericApprovers = new Map<String, ProjectTeamApprover__c>();
    static Map<String, ProjectTeamApprover__c> MapNonAgencyApprovers = new Map<String, ProjectTeamApprover__c>();
	
    private static QuoteTrgHandler instance = null;
    
    private QuoteTrgHandler(){
        PopulateApproversData();
    }
    
    public static QuoteTrgHandler getInstance(){
        if(instance == null) instance = new QuoteTrgHandler();
		return instance;
    }
    
    public void onBeforeInsert(List<Quote> newObjects, Map<Id, Quote> newMap){

    	Map<String,Quote> MapQuoteIdToQuote = new Map<String,Quote>();
    	Map<String,String> MapQuoteIdProjectId = new Map<String,String>();
    	Set<Quote> SetQuoteToAssignApprovers = new Set<Quote>();

        for( Quote QuoteObj : newObjects ){
    		if( QuoteObj.ProjectId__c != null && QuoteObj.ProjectId__c != '' && QuoteObj.Account__c != null  ){
    			MapQuoteIdToQuote.put( QuoteObj.Id,QuoteObj);
				MapQuoteIdProjectId.put( QuoteObj.Id,QuoteObj.ProjectId__c);
    		}

            if( QuoteObj.ProjectId__c != null && QuoteObj.Project_Region__c != null ){
                SetQuoteToAssignApprovers.add( QuoteObj );                
            }
    	}

    	if( MapQuoteIdToQuote.size() > 0 ){
    		CheckWholeSalers( MapQuoteIdToQuote, MapQuoteIdProjectId );
    	}

        if( SetQuoteToAssignApprovers.size() > 0 ){
            AssignApprovers( SetQuoteToAssignApprovers );
        }
    
    }
    
    public void onBeforeUpdate(List<Quote> oldObjects, List<Quote> newObjects, Map<Id, Quote> oldMap, Map<Id, Quote> newMap){
    
    	Map<String,Quote> MapQuoteIdToQuote = new Map<String,Quote>();
    	Map<String,String> MapQuoteIdProjectId = new Map<String,String>();
        Set<Quote> SetQuoteToAssignApprovers = new Set<Quote>();
    	
        Quote OldQuoteObj;
    	for( Quote QuoteObj : newObjects ){

    		OldQuoteObj = oldMap.get( QuoteObj.Id );

    		if( QuoteObj.Status == 'Rejected' && QuoteObj.Status != OldQuoteObj.Status ){

    			QuoteObj.ExpirationDate = QuoteObj.OldExpirationDate__c;
    			QuoteObj.OldExpirationDate__c = null;
    		
    		}
    		
    		if( ( ( QuoteObj.ExpirationDate != null && QuoteObj.ExpirationDate != OldQuoteObj.ExpirationDate ) ||
    		( QuoteObj.Num_Approvals__c != null && QuoteObj.Num_Approvals__c != OldQuoteObj.Num_Approvals__c && QuoteObj.OldExpirationDate__c != null && QuoteObj.ExpirationDate != null ) ) &&
    		( QuoteObj.Num_Approvals__c == null || QuoteObj.Num_Approvals__c == 0 ) ){
    			
    			QuoteObj.Num_Approvals__c = 1;

    		}

    		if( QuoteObj.Status != 'Rejected' && QuoteObj.ExpirationDate != OldQuoteObj.ExpirationDate && 
    			QuoteObj.OldExpirationDate__c != QuoteObj.ExpirationDate && QuoteObj.ExpirationDate != null ){
    			
    			QuoteObj.OldExpirationDate__c = OldQuoteObj.ExpirationDate;
    		
    		}

    		if( QuoteObj.Account__c != null && QuoteObj.Project__c != null && 
    			( QuoteObj.Account__c != OldQuoteObj.Account__c || QuoteObj.Project__c != OldQuoteObj.Project__c ) ){
    			MapQuoteIdToQuote.put( QuoteObj.Id,QuoteObj);
				MapQuoteIdProjectId.put( QuoteObj.Id,QuoteObj.ProjectId__c);
    		}

            if( QuoteObj.Project__c != null && QuoteObj.Project_Region__c != null && 
                ( QuoteObj.Project__c != OldQuoteObj.Project__c ) || 
                ( QuoteObj.Project_Region__c != OldQuoteObj.Project_Region__c ) || 
                ( QuoteObj.OwnerId != OldQuoteObj.OwnerId ) ||
                QuoteObj.Recalculate_Approvers__c  ){
                
                QuoteObj.Recalculate_Approvers__c = false;
                SetQuoteToAssignApprovers.add( QuoteObj );    
            
            }
    	}
    	if( MapQuoteIdToQuote.size() > 0 ){
    		CheckWholeSalers( MapQuoteIdToQuote, MapQuoteIdProjectId );
    	}

        if( SetQuoteToAssignApprovers.size() > 0 ){
            AssignApprovers( SetQuoteToAssignApprovers );
        }
    }

    //This method will be used to check the account of the quote against the  wholesalers 
    private void CheckWholeSalers( Map<String,Quote> paramMapQuoteIdToQuote, Map<String,String> paramMapQuoteIdProjectId){

    	Map<String,Set<String>> MapProjectToWholesaler = new Map<String,Set<String>>();

    	for( Wholesalers__c WholesalersObj : [SELECT Id, Wholesaler__c, Project__c 
											FROM Wholesalers__c 
											WHERE Project__c IN : paramMapQuoteIdProjectId.values() ] )
    	{
    		if( MapProjectToWholesaler.get( WholesalersObj.Project__c ) != null ){
    			
    			Set<String> SetTemp = MapProjectToWholesaler.get( WholesalersObj.Project__c );
    			SetTemp.add( WholesalersObj.Wholesaler__c );

    		}else{
    			MapProjectToWholesaler.put( WholesalersObj.Project__c, new Set<String>{ WholesalersObj.Wholesaler__c } );
    		} 
    	}
    
    	for( String Key : paramMapQuoteIdToQuote.keySet() )
    	{
    		Quote QuoteObj = paramMapQuoteIdToQuote.get( Key );
    		Set<String> SetWholeSaler;
            
    		if( MapProjectToWholesaler.get( QuoteObj.ProjectId__c ) != null )
            {
    			SetWholeSaler = MapProjectToWholesaler.get( QuoteObj.ProjectId__c );
                
    			if( !SetWholeSaler.contains( QuoteObj.Account__c ) )
                {
    				QuoteObj.addError('Please select appropriate wholesaler which is related to quote\'s project');
    			}
    		}
            else if (!String.isBlank(QuoteObj.Account__c ))
            {
                QuoteObj.addError('Please select appropriate wholesaler which is related to quote\'s project');
            }
    	}
    }

    
    
    
    //This method will be used to check the account of the quote against the  wholesalers 
    public  static string  CheckWholeSalersforCoummunity( Map<String,Quote> paramMapQuoteIdToQuote, Map<String,String> paramMapQuoteIdProjectId){

        string  errorMsg ='';
    	Map<String,Set<String>> MapProjectToWholesaler = new Map<String,Set<String>>();

    	for( Wholesalers__c WholesalersObj : [SELECT Id, Wholesaler__c, Project__c 
											FROM Wholesalers__c 
											WHERE Project__c IN : paramMapQuoteIdProjectId.values() ] )
    	{
    		if( MapProjectToWholesaler.get( WholesalersObj.Project__c ) != null ){
    			
    			Set<String> SetTemp = MapProjectToWholesaler.get( WholesalersObj.Project__c );
    			SetTemp.add( WholesalersObj.Wholesaler__c );

    		}else{
    			MapProjectToWholesaler.put( WholesalersObj.Project__c, new Set<String>{ WholesalersObj.Wholesaler__c } );
    		} 
    	}
    
    	for( String Key : paramMapQuoteIdToQuote.keySet() )
    	{
    		Quote QuoteObj = paramMapQuoteIdToQuote.get( Key );
    		Set<String> SetWholeSaler;
            system.debug('paramMapQuoteIdToQuote'+paramMapQuoteIdToQuote);
    		if( MapProjectToWholesaler.get( QuoteObj.ProjectId__c ) != null )
            {
                system.debug('Prooject id is not null');
                system.debug('MapProjectToWholesaler'+MapProjectToWholesaler);
    			SetWholeSaler = MapProjectToWholesaler.get( QuoteObj.ProjectId__c );
                system.debug('SetWholeSaler'+SetWholeSaler);
    			if( !SetWholeSaler.contains( QuoteObj.Account__c ) )
                {
                    system.debug('Project doest not contains');
    				//QuoteObj.addError('Please select appropriate wholesaler which is related to quote\'s project');
    				errorMsg='error';
    			
                }
    		}
            else if (!String.isBlank(QuoteObj.Account__c ))
            {
            
                 errorMsg='error';
                
            }
            
    	}
        
        return errorMsg;
    }

    
    
    
    private void AssignApprovers( Set<Quote> paramSetQuoteToAssignApprovers ){
       
        ProjectTeamApprover__c ProjectTeamApproverObj;
        for( Quote QuoteObj : paramSetQuoteToAssignApprovers )
        {       

            if( SetIdDefinedUser.contains( QuoteObj.OwnerId ) && MapNonAgencyApprovers.get( QuoteObj.OwnerId+'-'+QuoteObj.Project_Region__c ) != null ){                
                
                ProjectTeamApproverObj = MapNonAgencyApprovers.get( QuoteObj.OwnerId+'-'+QuoteObj.Project_Region__c );
                QuoteObj = AssignProjectApprovers( QuoteObj, ProjectTeamApproverObj );

            }else if ( !SetIdDefinedUser.contains( QuoteObj.OwnerId ) && MapGenericApprovers.get( QuoteObj.Project_Region__c ) != null ){

                ProjectTeamApproverObj = MapGenericApprovers.get( QuoteObj.Project_Region__c );
                QuoteObj = AssignProjectApprovers( QuoteObj, ProjectTeamApproverObj );
                
            }else{
                QuoteObj.First_Level_Approver__c = null;
                QuoteObj.Second_Level_Approver__c = null;
                QuoteObj.Third_Level_Approver__c = null;
            }
        }
    }

    private void PopulateApproversData(){

        MapGenericApprovers = new Map<String, ProjectTeamApprover__c>();
        MapNonAgencyApprovers = new Map<String, ProjectTeamApprover__c>();

		List<ProjectTeamApprover__c> listPTA = [SELECT Id, X1stLevelApprover__c, X1stLevelApproverTeamRole__c,
                                                X2ndLevelApprover__c, X2ndLevelApproverTeamRole__c,
                                                X3rdLevelApprover__c, X3rdLevelApproverTeamRole__c,
                                                AgencyAccount__c, Region__c, Requestor__c, RequestorRole__c, RequestorType__c
                                                FROM ProjectTeamApprover__c ]   ;
        
        if (listPTA != null && listPTA.size() > 0)
        {
            for( ProjectTeamApprover__c ProjectTeamApproverObj : listPTA )
            {   
                if( ProjectTeamApproverObj.Region__c != null && ProjectTeamApproverObj.RequestorType__c == 'Generic' && ProjectTeamApproverObj.AgencyAccount__c == null && ProjectTeamApproverObj.Requestor__c == null ){
                
                    MapGenericApprovers.put( ProjectTeamApproverObj.Region__c , ProjectTeamApproverObj );
                
                }else if( ProjectTeamApproverObj.Region__c != null && ProjectTeamApproverObj.RequestorType__c == 'Non Agency' && ProjectTeamApproverObj.AgencyAccount__c == null && ProjectTeamApproverObj.Requestor__c != null ){
                
                    SetIdDefinedUser.add( ProjectTeamApproverObj.Requestor__c );
                    MapNonAgencyApprovers.put( ProjectTeamApproverObj.Requestor__c+'-'+ProjectTeamApproverObj.Region__c , ProjectTeamApproverObj );
                }
            }
        }
    }

    private Quote AssignProjectApprovers(Quote paramQuoteObj, ProjectTeamApprover__c paramProjectTeamApprover ){
        Quote QuoteObjToReturn = paramQuoteObj;

        QuoteObjToReturn.First_Level_Approver__c          = paramProjectTeamApprover.X1stLevelApprover__c;
        QuoteObjToReturn.Second_Level_Approver__c         = paramProjectTeamApprover.X2ndLevelApprover__c;
        QuoteObjToReturn.Third_Level_Approver__c          = paramProjectTeamApprover.X3rdLevelApprover__c;

        return paramQuoteObj;
    }
    
    public static void PopulateWholeSalerAgency(Map<Id,Id> mapQuote){
        Map<string,Id> mapWholeSalerAgency = new Map<String,Id>();
            if(!mapQuote.isempty()){
                List<Agency__c> lstAgency = [select Account__c,Type__c, Id from Agency__c where Account__c = :mapQuote.values()];
                system.debug(lstAgency);
                List<QuoteLineItem> lstQLI = [Select Id, Wholesaler_Agency__c,QuoteId,QLI_Brand__c,Quote.Account__c
                                              From QuoteLineItem
                                              Where QuoteId = :mapQuote.keySet()];
                
                for(Agency__c ag:lstAgency){
                    if(ag.Type__c=='AS'){
                      mapWholeSalerAgency.put(ag.Account__c+'American Standard',ag.Id);  
                    }
                    else{
                        mapWholeSalerAgency.put(ag.Account__c+ag.Type__c,ag.Id);
                    }
                    
                }
                system.debug(mapWholeSalerAgency);
                List<QuoteLineItem> lstQLIUpdate =  new List<QuoteLineItem> ();
                for(QuoteLineItem aqli:lstQLI){
                    system.debug(aqli.quote.account__c+aqli.QLI_Brand__c);
                    Id wholeSalerAgencyId = mapWholeSalerAgency.get(aqli.quote.account__c+aqli.QLI_Brand__c);
                    if(aqli.Wholesaler_Agency__c!=wholeSalerAgencyId || (aqli.Wholesaler_Agency__c==null && wholeSalerAgencyId!=null) 
                      || (aqli.Wholesaler_Agency__c!=null && wholeSalerAgencyId==null)){
                        aqli.Wholesaler_Agency__c = wholeSalerAgencyId;
                        lstQLIUpdate.add(aqli);
                    }
                    
                }
                system.debug('hb::'+lstQLIUpdate);
                if(!lstQLIUpdate.isEmpty()){
                    update lstQLIUpdate;
                }
                    
                
            }
            
    }
    
    
}