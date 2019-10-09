/************************
Author:         Azfer Pervaiz
Created Date:   1/June/2018  
Purpose:        This class is the Helper class for the AgencyZipCodeAssignmentTrg Trigger.

************************MODIFICATION HISTORY**************************************
Added on             Added By               Description
**********************************************************************************
1/June/2018          Azfer Pervaiz          Initial Development 
***********************************************************************************/
public class AgencyZipCodeAssignmentTrgHelper {

  public static Set<String> SetZipCode = new Set<String>();
  public static Map<String, Agency_Zip_Code_Assignment__c> MapZipToAZCA = new Map<String, Agency_Zip_Code_Assignment__c>();
  
  //AZCA = Agency Zip Code Assignment
  public void UpdateRecalculationCheckbox(List<Agency_Zip_Code_Assignment__c> paramListAZCA){
    for( Agency_Zip_Code_Assignment__c AZCAObj : paramListAZCA )
    {
      AZCAObj.Recalculate_Assignment__c = false;  
    }
  }

    public void RecalculateAgencyAssignments( Map<String, Agency_Zip_Code_Assignment__c> paramMapZipToAZCA , set<string> paramSetZipCode ){
        
        List<Agency__c> ListAgencyToUpdate = new List<Agency__c>();
        Agency_Zip_Code_Assignment__c AZCAObj;
        
        system.debug(json.serialize([SELECT Id, Account__c,  Account__r.ShippingPostalCode, Agency_Account__c, Type__c 
                                    FROM Agency__c ]));
         system.debug(paramSetZipCode);
        for( Agency__c AgencyObj : [SELECT Id, Account__c,  Account__r.ShippingPostalCode, Agency_Account__c, Type__c 
                                    FROM Agency__c 
                                    WHERE Account__r.ShippingPostalCode IN : paramSetZipCode ])
        {
            AZCAObj = paramMapZipToAZCA.get( AgencyObj.Account__r.ShippingPostalCode );
            
            if( AgencyObj.Type__c == 'AS' ){
                AgencyObj.Agency_Account__c = AZCAObj.ASRep__c;
            }else if( AgencyObj.Type__c == 'DXV' ){
                AgencyObj.Agency_Account__c = AZCAObj.DXVRep__c;
            }else if( AgencyObj.Type__c == 'Fiat' ){
                AgencyObj.Agency_Account__c = AZCAObj.FiatRep__c;
            }else if( AgencyObj.Type__c == 'Grohe' ){
                AgencyObj.Agency_Account__c = AZCAObj.GroheRep__c;
            }
            
            ListAgencyToUpdate.add( AgencyObj );
            
        }
        if( ListAgencyToUpdate.size() > 0 ){
            try{
                update ListAgencyToUpdate;
            }catch(Exception Ex){
                system.debug('Exception :: '+Ex.getMessage());
            }
        }
    }  
    public void RecalculateAgencyAssignmentsforProjects( Map<String, Agency_Zip_Code_Assignment__c> paramMapZipToAZCA , set<string> paramSetZipCode ){
    
    List<Project_Agency__c> ListAgencyToUpdate = new List<Project_Agency__c>();
    Agency_Zip_Code_Assignment__c AZCAObj;
	
    for( Project_Agency__c AgencyObj : [SELECT Id, Project__c ,Project__r.Postal_Code__c,  Project_Agency__c, Type__c 
		FROM Project_Agency__c WHERE Project__r.Postal_Code__c IN:paramSetZipCode ])
    {
      AZCAObj = paramMapZipToAZCA.get( AgencyObj.Project__r.Postal_Code__c );
      
      if( AgencyObj.Type__c == 'AS' ){
        AgencyObj.Project_Agency__c = AZCAObj.ASRep__c;
      }else if( AgencyObj.Type__c == 'DXV' ){
        AgencyObj.Project_Agency__c = AZCAObj.DXVRep__c;
      }else if( AgencyObj.Type__c == 'Fiat' ){
        AgencyObj.Project_Agency__c = AZCAObj.FiatRep__c;
      }else if( AgencyObj.Type__c == 'Grohe' ){
        AgencyObj.Project_Agency__c = AZCAObj.GroheRep__c;
      }

      ListAgencyToUpdate.add( AgencyObj );
    }
    
    if( ListAgencyToUpdate.size() > 0 ){
      try{
        update ListAgencyToUpdate;
      }catch(Exception Ex){
        system.debug('Exception :: '+Ex.getMessage());
      }
    }
  }  
    
}