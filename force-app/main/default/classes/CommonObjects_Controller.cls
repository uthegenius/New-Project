/*
Class       : CommonObjects_Controller 
Author      : Tectonic - Hanif
Date        : 4/24/2018
Description : This class contains all mothods for common objects for any Standard or custom objects like Task,Event,Note,Activity etc 
that is performing any bussniss use case.
*/
public class CommonObjects_Controller {
    // Jira LSCIP-29 (L-8)
    // This is a dynamic method, that can call to any child record of a record to track last touch date at parent lever.
    // It checks the required field (LastTransActivity__c) is exits on parent record then assign the system date.
    public static void setLastTransActivity(set<Id> ParentIds){
        map<id,sObject> recordToUpdate = new map<id,sObject>();
        set<string> allowObject = new set<string>{'Lead','Account','Opportunity'};
        for (Id anId:ParentIds){   
            system.debug(anId.getSObjectType());
            If ( allowObject.contains(string.valueOf( anId.getSObjectType()))){ 
                sObject Element = anId.getSobjectType().newSObject() ;
                Element.Id = anId;                
                Element.put('LastTransActivity__c',System.Datetime.now());
                Element.put('Bypass_Validation_Rules__c',True);
                recordToUpdate.put(Element.Id,Element);
                system.debug(Element);
            }
        }
        if (!recordToUpdate.isEmpty()){
            update recordToUpdate.values();
        }               
    }
    
}