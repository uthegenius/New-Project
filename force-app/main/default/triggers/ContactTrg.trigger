/*
* Created by: Tectonic (Abid Raza) on 10/Dec/18
* Description: To create task for Sales Rep when triggering from Pardot.
* Updated by: 
*/

trigger ContactTrg on Contact (before update, after insert, before insert) 
{     
    if(trigger.IsBefore && trigger.IsInsert)
    {
        for(Contact cont: trigger.new)
        {
            if(cont.Contact_Origin__c=='chat')
            {
                cont.ByPassVal__c = true;
            }
        } 
    } 

    if(trigger.IsBefore && trigger.IsUpdate)
    {
        set<string> SetOfZipCodes = new Set<string>();
        set<Contact> SetOfContactsForRegions = new Set<Contact>();
        Map<string,string> MapOfRegionsAsperZipCode = new  Map<string,string>();
        Map<string,string> MapofRepsAsPerRegion = new Map<string,string>();
        for(Contact cnt: Trigger.new)
        {
            if(cnt.MailingPostalCode != null)
            {
                SetOfZipCodes.add(cnt.MailingPostalCode);
                SetOfContactsForRegions.add(cnt);
            }
        }
        
        List<Agency_Zip_Code_Assignment__c> ListofAgencyZipCodeAssignemnts = [Select Id,Name,ZipCode__c,Region__c from Agency_Zip_Code_Assignment__c where ZipCode__c in: SetOfZipCodes];
        if(ListofAgencyZipCodeAssignemnts != null && ListofAgencyZipCodeAssignemnts.size() > 0)
        {
            for(Agency_Zip_Code_Assignment__c azca: ListofAgencyZipCodeAssignemnts)
            {
                MapOfRegionsAsperZipCode.put(azca.ZipCode__c,azca.Region__c);
            }
            
            for(Contact cnt: SetOfContactsForRegions)
            {
                cnt.Contact_Region__c = MapOfRegionsAsperZipCode.get(cnt.MailingPostalCode);
            }
        }
        system.debug('SetOfContactsForRegions'+SetOfContactsForRegions);
        
        if(MapOfRegionsAsperZipCode.size() > 0)
        {
            for(Industry_Region_Wise_Rep__c irwr: [Select Id,Name,Region__c,User__c from Industry_Region_Wise_Rep__c where Region__c in: MapOfRegionsAsperZipCode.Values()])
            {
                MapofRepsAsPerRegion.put(irwr.Region__c,irwr.User__c);
            }
        }
        
        List<Task> ListOfTasksToBeCreated = new List<Task>();
        Set<Contact> setOfUnqualifiedPardotContacts = new Set<Contact>();
        Task tsk;
        for(Contact cnt: Trigger.new)
        {
            if(cnt.Contact_Activity_in_Pardot__c != null && trigger.OldMap.get(cnt.Id).Contact_Activity_in_Pardot__c != cnt.Contact_Activity_in_Pardot__c)
            {
                tsk = new Task();
                tsk.Status = 'Open';
                tsk.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Standard').getRecordTypeId();
                tsk.ActivityDate = System.today().AddMonths(1);
                if(MapofRepsAsPerRegion.size() > 0)
                	tsk.OwnerId = MapofRepsAsPerRegion.get(cnt.Contact_Region__c);
                tsk.WhoId = cnt.Id;
                
                if(cnt.Contact_Activity_in_Pardot__c == 'Form Filled')
                {
                    tsk.Subject = 'Contact ' + cnt.FirstName + ' ' + cnt.LastName + ' is interested. Please follow-up.';
                }
                else if(cnt.Contact_Activity_in_Pardot__c == 'No Activity')
                {
                    tsk.Subject = 'Contact ' + cnt.FirstName + ' ' + cnt.LastName + ' has shown no interest. Please follow-up.';
                }
                else if(cnt.Contact_Activity_in_Pardot__c == 'Hot Contact')
                {
                    tsk.Subject = 'Contact ' + cnt.FirstName + ' ' + cnt.LastName + ' is a hot contact. Please follow-up.';
                }
                
                ListOfTasksToBeCreated.add(tsk);
                //cnt.Contact_Activity_in_Pardot__c = null;
            }
            
            //For Internal/Outside Reps Flow 2, Unqualified Reps identification.
            
            if(cnt.Unqualified_Prospect_Status__c != null && trigger.OldMap.get(cnt.Id).Unqualified_Prospect_Status__c != cnt.Unqualified_Prospect_Status__c)
            {
                setOfUnqualifiedPardotContacts.add(cnt);
            } 
        }
        
        if(setOfUnqualifiedPardotContacts.size() > 0)
        {
            Map<string,string> ReportNameByTag = new Map<string,string>();
            Map<string,string> ReportIDByTag = new Map<string,string>();
            List<Report> ListReports = new List<Report>();
            List<PardotInternalOutsideRepsFlowReportsList__mdt> mdtReportinfos = [Select Report_Tag__c, Report_Name__c from PardotInternalOutsideRepsFlowReportsList__mdt];
            if(mdtReportinfos != null && mdtReportinfos.size() > 0)
            {
                for(PardotInternalOutsideRepsFlowReportsList__mdt md: mdtReportinfos)
                {
                    ReportNameByTag.put(md.Report_Tag__c, md.Report_Name__c);
                }
                ListReports = [Select Id,Name from Report where Name in: ReportNameByTag.values()];
                
                if(ListReports.size() > 0)
                {
                    for(String key: ReportNameByTag.Keyset())
                    {
                        for(Report rpt: ListReports)
                        {
                            if(rpt.Name == ReportNameByTag.get(key))
                            {
                                ReportIDByTag.put(key,rpt.Id);
                            }
                        }
                    } 
                }
            }
            
            for(Contact cnt: setOfUnqualifiedPardotContacts)
            {
                tsk = new Task();
                tsk.Status = 'Open';
                tsk.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Standard').getRecordTypeId();
                tsk.ActivityDate = System.today();
                tsk.Subject = 'Contact ' + cnt.FirstName + ' ' + cnt.LastName + ' has not open any email of ' + cnt.Unqualified_Prospect_Status__c + '. Please follow-up.';
                if(MapofRepsAsPerRegion.size() > 0)
                    tsk.OwnerId = MapofRepsAsPerRegion.get(cnt.Contact_Region__c);
                tsk.WhoId = cnt.Id;
                if(cnt.Unqualified_Prospect_Status__c == '90 Days Prior')
                    tsk.Description = 'Please see the report ' + ReportNameByTag.get(cnt.Unqualified_Prospect_Status__c) + ': ' + System.Url.getSalesforceBaseUrl().Toexternalform() + '/' + ReportIDByTag.get(cnt.Unqualified_Prospect_Status__c);
                else  if(cnt.Unqualified_Prospect_Status__c == 'Launch Day')
                    tsk.Description = 'Please see the report ' + ReportNameByTag.get(cnt.Unqualified_Prospect_Status__c) + ': ' + System.Url.getSalesforceBaseUrl().Toexternalform() + '/' + ReportIDByTag.get(cnt.Unqualified_Prospect_Status__c);
                ListOfTasksToBeCreated.add(tsk);
            }
        }
        
        if(ListOfTasksToBeCreated.Size() > 0)
        {
            insert ListOfTasksToBeCreated;
        }
    } 
    
    if (Trigger.isAfter && Trigger.isInsert)
    {
        Set<Id> setContIDs = new Set<Id>();
        
        for (Contact con : Trigger.New)
        {
            setContIDs.add(con.Id);
        }
        
        if (setContIDs != null && setContIDs.size() > 0)
        {
            BoxIntegrationUtil.createFolderinBox(setContIDs, 'Contact');
        }       
    }
}