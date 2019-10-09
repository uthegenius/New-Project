/*
* Created by: Tectonic (Abid Raza) on 11/Feb/19
* Description: This class is used as helper class to Lead trigger.
* Updated by: 
*/

public class LeadTrgHelper 
{
    // Update Region based on Zip Code.
    public void AssignRegionAsPerZipCode(set<string> SetOfZipCodes, set<Lead> SetOfZIPToRegionLeads)
    {
        Map<string,string> MapOfRegionsAsperZipCode = new  Map<string,string>();
        List<Agency_Zip_Code_Assignment__c> ListofAgencyZipCodeAssignemnts = [Select Id,Name,ZipCode__c,Region__c from Agency_Zip_Code_Assignment__c where ZipCode__c in: SetOfZipCodes];
        system.debug('ListofAgencyZipCodeAssignemnts::'+ListofAgencyZipCodeAssignemnts);
        if(ListofAgencyZipCodeAssignemnts.size() > 0)
        {
            for(Agency_Zip_Code_Assignment__c azca: ListofAgencyZipCodeAssignemnts)
            {
                MapOfRegionsAsperZipCode.put(azca.ZipCode__c,azca.Region__c);
            }
            
            for(Lead led: SetOfZIPToRegionLeads)
            {
                led.Region__c = MapOfRegionsAsperZipCode.get(led.PostalCode);
            }
            system.debug('SetOfZIPToRegionLeads::'+SetOfZIPToRegionLeads);
        }
    }
    
     // Create Task based on region to Regional Manager for Contacts source Pardot.
    public void CreateAndAssignTask(set<string> SetOfRegions, set<Lead> SetOfQualifiedLeads)
    {
        system.debug('SetOfRegions::'+SetOfRegions);
        system.debug('SetOfQualifiedLeads::'+SetOfQualifiedLeads);
        List<Industry_Region_Wise_Rep__c> setupObj = new List<Industry_Region_Wise_Rep__c>();
        List<Task> listTask = new List<Task>();
        
        if(SetOfRegions.size()>0)
        {
            setupObj = [Select id,User__c,Industry__c,Region__c From  Industry_Region_Wise_Rep__c where Region__c IN : SetOfRegions];
            system.debug('setup'+setupObj.size());
        }
        if(setupObj.size()>0)
        {
            for (Lead led : SetOfQualifiedLeads)
            {
                for(Industry_Region_Wise_Rep__c sObj: setupObj)
                {
                    if(sObj.Region__c==led.Region__c)
                    {
                        Task tsk =  new Task();
                        tsk.Status = 'Open';
                        tsk.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Standard').getRecordTypeId();
                        tsk.ActivityDate = System.today().AddMonths(1);
                        if(led.Rating == 'Hot')
                        	tsk.Subject = 'Lead ' + led.FirstName + ' ' + led.LastName +' is hot lead and qualified. Please follow-up.';
                        else
                            tsk.Subject = 'Lead ' + led.FirstName + ' ' + led.LastName +' is qualified. Please follow-up.';
                        tsk.OwnerId = sObj.User__c;
                        tsk.WhoId = led.Id;
                        listTask.add(tsk);
                    }
                }
            }
            
            if(listTask.size() > 0)
            {
                Insert listTask;
                system.debug('listTask'+listTask);
            }
        }
    }
}