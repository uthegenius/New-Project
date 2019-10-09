/************************
Author:         Abid Raza
Created Date:   08/Sep/2018 
Purpose:        Batch Class to send Email to Supplier Contact(Vendor) to fill Scar Form..
************************/

global with sharing class SendSCARFormToVendorEmailBatch implements Database.Batchable<sObject>, Database.Stateful
{
   // List<Messaging.SingleEmailMessage> LstEmailMessages = new List<Messaging.SingleEmailMessage>();
    SCAR_Vendor_Form_Email__c scarformsettings = SCAR_Vendor_Form_Email__c.getinstance();
   // List<SCAR__c> ListOfSCARsToBeUpdated = new List<SCAR__c>();
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        string query = 'SELECT Id,Name,Last_Notified_Vendor__c,Supplier_Contact__r.Email,Case_Owner_Email__c,Is_Last_5_Sections_Email_Sent__c,Send_10_Days_Reminder_Email__c,Send_48_Hours_Reminder_Email__c,';
		query += 'Affected_Sites__c, Problem_Description__c,';
		query += 'What_actions_were_taken_to_Immediately__c,Other_Production_Platform_Risk__c,Supplier_Soring_Results__c,';
		query += 'How_Made_and_How_Verified__c,Why_Shipped_and_How_Verified__c,';
		query += 'Corrective_Action_for_Why_Made__c,Corrective_Action_Owner_s_Name__c,Corrective_Action_for_Why_Shipped__c,Corrective_Action_Owner_s_Email__c,Target_Completion_Date__c,Corrective_Action_Owner_s_Phone_Number__c,';
		query += 'Verification_of_Corrective_Action__c,Build_Date_for_Certified_Marterial__c,How_will_new_parts_be_identified__c,';
		query += 'How_this_issues_be_avoided_in_the_future__c,Other_Facilities_or_Platform_at_Risk__c,Other_Facilities_Platform_at_Risk_Part__c,Other_Facilities_Platform_at_Risk_CA_Own__c,Other_Facilities_Platform_at_Risk_DueDt__c,Affected_Document_1__c,Affected_Document_1_Owners_to_Update__c,Affected_Document_1_Date__c,Affected_Document_2__c,Affected_Document_2_Owners_to_Update__c,Affected_Document_2_Date__c,Affected_Document_3__c,Affected_Document_3_Owners_to_Update__c,Affected_Document_3_Date__c,Affected_Document_4__c,Affected_Document_4_Owners_to_Update__c,Affected_Document_4_Date__c,Affected_Document_5__c,Affected_Document_5_Owners_to_Update__c,Affected_Document_5_Date__c,Affected_Document_6__c,Affected_Document_6_Owners_to_Update__c,Affected_Document_6_Date__c,Affected_Document_7__c,Affected_Document_7_Owners_to_Update__c,Affected_Document_7_Date__c,Affected_Document_8__c,Affected_Document_8_Owners_to_Update__c,Affected_Document_8_Date__c,';
        query += 'Closure_Statement_Validation__c';
		query += ' FROM SCAR__c';
        system.Debug('query::'+query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<SCAR__c> scope)
    {
         List<Messaging.SingleEmailMessage> LstEmailMessages = new List<Messaging.SingleEmailMessage>();
    	 //SCAR_Vendor_Form_Email__c scarformsettings = SCAR_Vendor_Form_Email__c.getinstance();
    	 List<SCAR__c> ListOfSCARsToBeUpdated = new List<SCAR__c>();
        try
        {
            Date TodayDate = Date.today();
            Date NotifiedDate;
            set<Id> SetScarIds = new set<Id>();
            Map<Id,integer> MapScarTeamCount = new Map<Id,integer>();
            Integer ScarTeamCount;
            for(SCAR__c scar: (List<SCAR__c>) scope)
            {
                SetScarIds.add(scar.Id);
            }
            
            List<SCAR_Team__c> LstScarTeam = [Select Id,Name,SCAR_Form__c from SCAR_Team__c where SCAR_Form__c in: SetScarIds and Contact_Role__c = 'Team Member' and Email__c != null and SCAR_Contact_Name__c != null and SCAR_Contact_Name__c != ''];
            
            for(SCAR_Team__c st:LstScarTeam)
            {
                if(MapScarTeamCount.containsKey(st.SCAR_Form__c))
                {
                    Integer i = MapScarTeamCount.get(st.SCAR_Form__c);
                    i = i+1;
                    MapScarTeamCount.put(st.SCAR_Form__c,i);
                }
                else
                {
                    MapScarTeamCount.put(st.SCAR_Form__c,1);
                }
                   
            }

            system.Debug('(List<SCAR__c>) scope::'+(List<SCAR__c>) scope);
            for(SCAR__c scar: (List<SCAR__c>) scope)
            {
                ScarTeamCount = 0;
                NotifiedDate = Date.valueOf(scar.Last_Notified_Vendor__c);
                if(MapScarTeamCount.ContainsKey(scar.Id)) ScarTeamCount = MapScarTeamCount.get(scar.Id);
                system.debug('ScarTeamCount::'+ScarTeamCount);
                if(ScarTeamCount == 0 || string.IsBlank(scar.Affected_Sites__c) || string.IsBlank(scar.Problem_Description__c) || string.IsBlank(scar.What_actions_were_taken_to_Immediately__c) || string.IsBlank(scar.Other_Production_Platform_Risk__c) || string.IsBlank(scar.Supplier_Soring_Results__c))
                {
                    system.Debug('48HoursScenerio::');
                    NotifiedDate = NotifiedDate.AddDays(Integer.valueOf(scarformsettings.First_Notification_Days__c));
                    system.Debug('NotifiedDate::'+NotifiedDate);
                    if(NotifiedDate.isSameDay(TodayDate))
                    {
                        //Messaging.SingleEmailMessage mail = GetEmaiMessage(scar,True);
                        //LstEmailMessages.add(mail);
                        scar.Last_Notified_Vendor__c = TodayDate;
                        scar.Send_48_Hours_Reminder_Email__c = true;
                        ListOfSCARsToBeUpdated.add(scar);
                    }
                }
                else if(string.isBlank(scar.How_Made_and_How_Verified__c) || string.isBlank(scar.Why_Shipped_and_How_Verified__c) || string.isBlank(scar.Corrective_Action_for_Why_Made__c) || string.isBlank(scar.Corrective_Action_Owner_s_Name__c) || string.isBlank(scar.Corrective_Action_for_Why_Shipped__c) || string.isBlank(scar.Corrective_Action_Owner_s_Email__c) || scar.Target_Completion_Date__c != null || string.isBlank(scar.Corrective_Action_Owner_s_Phone_Number__c) || string.isBlank(scar.Verification_of_Corrective_Action__c) || scar.Build_Date_for_Certified_Marterial__c != null || string.isBlank(scar.How_will_new_parts_be_identified__c) || string.isBlank(scar.How_this_issues_be_avoided_in_the_future__c) || string.isBlank(scar.Other_Facilities_or_Platform_at_Risk__c) || string.isBlank(scar.Other_Facilities_Platform_at_Risk_Part__c) || string.isBlank(scar.Other_Facilities_Platform_at_Risk_CA_Own__c) || string.isBlank(scar.Other_Facilities_Platform_at_Risk_DueDt__c) || string.isBlank(scar.Affected_Document_1__c) || string.isBlank(scar.Affected_Document_1_Owners_to_Update__c) || scar.Affected_Document_1_Date__c != null || string.isBlank(scar.Affected_Document_2__c) || string.isBlank(scar.Affected_Document_2_Owners_to_Update__c) || scar.Affected_Document_2_Date__c != null  || string.isBlank(scar.Affected_Document_3__c) || string.isBlank(scar.Affected_Document_3_Owners_to_Update__c) || scar.Affected_Document_3_Date__c != null || string.isBlank(scar.Affected_Document_4__c) || string.isBlank(scar.Affected_Document_4_Owners_to_Update__c) || scar.Affected_Document_4_Date__c != null || string.isBlank(scar.Affected_Document_5__c) || string.isBlank(scar.Affected_Document_5_Owners_to_Update__c) || scar.Affected_Document_5_Date__c != null || string.isBlank(scar.Affected_Document_6__c) || string.isBlank(scar.Affected_Document_6_Owners_to_Update__c) || scar.Affected_Document_6_Date__c != null || string.isBlank(scar.Affected_Document_7__c) || string.isBlank(scar.Affected_Document_7_Owners_to_Update__c) || scar.Affected_Document_7_Date__c != null || string.isBlank(scar.Affected_Document_8__c) || string.isBlank(scar.Affected_Document_8_Owners_to_Update__c) || scar.Affected_Document_8_Date__c != null || string.isBlank(scar.Closure_Statement_Validation__c)) 
                {
                    system.Debug('10DaysScenerio::');
                    NotifiedDate = NotifiedDate.AddDays(Integer.valueOf(scarformsettings.Second_Notification_Days__c));
                    system.Debug('NotifiedDate::'+NotifiedDate);
                    if(NotifiedDate.isSameDay(TodayDate))
                    {
                        //Messaging.SingleEmailMessage mail = GetEmaiMessage(scar,False);
                        //LstEmailMessages.add(mail);
                        scar.Send_10_Days_Reminder_Email__c = true;
                        scar.Last_Notified_Vendor__c = TodayDate;
                        ListOfSCARsToBeUpdated.add(scar);
                    }
                }
            }
            
            
            //System.debug('LstEmailMessages::'+LstEmailMessages);
            System.debug('ListOfSCARsToBeUpdated::'+ListOfSCARsToBeUpdated);
            //if(LstEmailMessages.size() > 0)
            	//Messaging.sendEmail(LstEmailMessages);
            if(ListOfSCARsToBeUpdated.size() > 0)
            	Update ListOfSCARsToBeUpdated;
        }
        catch(Exception e)
        {
            System.debug('Error:: '+e.getMessage());
        }
    }
    
    global void finish(Database.BatchableContext BC)
    {
        
    }
    
 /*   public Messaging.SingleEmailMessage GetEmaiMessage(Scar__c scar, Boolean Is48HoursEmail)
    {
        List<string> ListEmailAddresses = new List<string>();
        String body = '<p>Greetings</p> <p>Please provide the required information of scar on the following link: </p> <br/> <b>Link : </b>'+ scarformsettings.URL__c +''+ scar.Id;
        if(Is48HoursEmail)
        {
            ListEmailAddresses.add(scar.Supplier_Contact__r.Email);
        }	
        else
        {
            ListEmailAddresses.add(scar.Supplier_Contact__r.Email);
            ListEmailAddresses.add(scar.Case_Owner_Email__c);
        }
        system.debug('ListEmailAddresses::'+ListEmailAddresses);
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(ListEmailAddresses);
        mail.setSubject('Fill SCAR Form');
        mail.setHtmlBody(body);
        System.debug('Mail::'+mail);
        
        return mail;
    } */
    
}