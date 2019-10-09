/************************
Author:         Azfer Pervaiz
Created Date:   1/June/2018 
Purpose:        This Trigger will be used for automation that will be customized on the Agency Zip Code Assignment object.

************************MODIFICATION HISTORY**************************************
Added on             Added By               Description
**********************************************************************************
1/June/2018          Azfer Pervaiz          Initial Development 
***********************************************************************************/
trigger AgencyZipCodeAssignmentTrg on Agency_Zip_Code_Assignment__c (before update, after update) {
    
     // Return if trigger is inactive from custom meta data type
    Trigger_Active_Inactive_Flag__mdt objTrgActive = [Select Flag__c from Trigger_Active_Inactive_Flag__mdt where MasterLabel = 'AgencyZipCodeAssignmentTrg'];
    
    if(!objTrgActive.Flag__c ) return ;    

	AgencyZipCodeAssignmentTrgHelper AZCATrgHelperObj = new AgencyZipCodeAssignmentTrgHelper();
	//ProjectAgencyZipCodeAssignmentTrgHelper ProjectAZCATrgHelperObj = new ProjectAgencyZipCodeAssignmentTrgHelper();
	
	//AZCA = Agency Zip Code Assignment
	
	if( Trigger.isUpdate && Trigger.isBefore ){
		
		List<Agency_Zip_Code_Assignment__c> ListAZCAToUpdate = new List<Agency_Zip_Code_Assignment__c>();
        List<Agency_Zip_Code_Assignment__c> ProjectListAZCAToUpdate = new List<Agency_Zip_Code_Assignment__c>();
		
		AgencyZipCodeAssignmentTrgHelper.MapZipToAZCA 	= new Map<String, Agency_Zip_Code_Assignment__c>();
		AgencyZipCodeAssignmentTrgHelper.SetZipCode  	= new Set<String>();
 
		for( Agency_Zip_Code_Assignment__c AZCAObj : Trigger.new )
		{
			if( AZCAObj.Recalculate_Assignment__c ){
				ListAZCAToUpdate.add( AZCAObj );
				AgencyZipCodeAssignmentTrgHelper.MapZipToAZCA.put( AZCAObj.ZipCode__c, AZCAObj);
				AgencyZipCodeAssignmentTrgHelper.SetZipCode.add( AZCAObj.ZipCode__c );
			}
		}

		if( ListAZCAToUpdate.size() > 0 ){
			AZCATrgHelperObj.UpdateRecalculationCheckbox(ListAZCAToUpdate);
		}
		 

	}

	if( Trigger.isUpdate && Trigger.isAfter ){
		if( AgencyZipCodeAssignmentTrgHelper.SetZipCode.size() > 0 ){
            system.debug(AgencyZipCodeAssignmentTrgHelper.SetZipCode);
			AZCATrgHelperObj.RecalculateAgencyAssignments( AgencyZipCodeAssignmentTrgHelper.MapZipToAZCA, AgencyZipCodeAssignmentTrgHelper.SetZipCode );
            AZCATrgHelperObj.RecalculateAgencyAssignmentsforProjects( AgencyZipCodeAssignmentTrgHelper.MapZipToAZCA, AgencyZipCodeAssignmentTrgHelper.SetZipCode );
		}
		 
	}
}