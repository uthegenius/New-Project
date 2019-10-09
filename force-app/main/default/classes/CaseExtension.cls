/*-------------------------------------------------------------------------------------------------
Author:             Ibad Mohiuddin
Date:               30-July-2018
Version:            1.0
Description:        Case Trigger Handler
----------------------------------------------------------------------------------------------------*/
/************************MODIFICATION HISTORY*************************************
Added on                Added By                Description
**********************************************************************************
30-July-2018            Ibad Mohiuddin           Initial Development
***********************************************************************************/


public class CaseExtension {
    
    public static void multipleemailstobesend(List<Case> caseListTrg)
        
    {
        
        List<Messaging.SingleEmailMessage> ListOfEmailsSent = new List<Messaging.SingleEmailMessage>();
        List<EmailMessage> emailMessageList = new List<EmailMessage>();
        Messaging.SendEmailResult[] mailresult;
        List<string> strem = new List<string>();
        List<string> listofem = new List<string>();
        Set<id> csId = new Set<id>();
        LIst<EmailTemplate> temp = new List<EmailTemplate>();
        Email__c ac = Email__c.getInstance();
        string accountName;
        accountName= ac.Default_Email__c;
        OrgWideEmailAddress[] owea;
        if(accountName!=null){
            
            owea = [select Id,address from OrgWideEmailAddress where Address =: accountName];
            
        }
        
        
        for(Case cs :caseListTrg)
        {
            
            
            string additonalemail=cs.Additional_Email_to_be_Included__c;
            for(string sr:additonalemail.split(';'))
            {
                
                if(validateEmail(sr)==true)
                {
                    listofem.add(sr);
                    
                }
            }
            
            if(listofem.size()>0)
            {
                
                string fromaddress='';
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                if ( owea!=null && owea.size() > 0 ) 
                {
                    mail.setOrgWideEmailAddressId(owea.get(0).Id);
                    fromaddress=owea.get(0).address;
                }
                mail.setSubject('Feedback Assignment  [ Ref Number: '+cs.id+' ]');
                
                mail.setHtmlBody('<html><body> <br>Dear,<br><p>Your feedback is required on the Case '+cs.CaseNumber+'. Please provide feedback at earliest by replying to this email. For further details, Please reply on the email'+ '</p> Case Description: '+cs.Description+'<br>Sincerely,<br><br>  System Admin <br>LIXIL Water Technologies</body></html>');
                mail.setToAddresses(listofem);
                ListOfEmailsSent.add(mail);
                system.debug('CasetobeIncluded'+cs);
                mail.setSaveAsActivity(false);
                emailMessage em = new emailMessage();
                string emailaddress='';
                
                for(string emm:listofem)
                    
                {
                    if(emm!=null)
                        
                    {
                        
                        emailaddress+=emm+';';
                    }
                }
                
                if(emailaddress!=null){
                    EmailMessage emailMsg = new EmailMessage(); // Created a EmailMessage and copy all details from above.
                    emailMsg.ToAddress=(emailaddress);
                    emailMsg.FromAddress=fromaddress;
                    emailMsg.Subject=('Feedback Assignment for Case #: '+cs.CaseNumber);
                    emailMsg.HtmlBody=('<html><body> ' + System.URL.getSalesforceBaseURL().ToExternalForm() +'<br>Dear,<br><p>Your feedback is required on the Case '+cs.CaseNumber+'. Please provide feedback at earliest by replying to this email. For further details, please contact at '+cs.Case_Owner_Email__c+ '</p> Case Description: '+cs.Description+'<br>Sincerely,<br><br>  System Admin <br>LIXIL Water Technologies</body></html>');
                    emailMsg.ParentId = cs.Id; //Attach with the case
                    emailMsg.MessageDate = system.now();
                    emailMsg.Status = '0';
                    emailMessageList.add(emailMsg);
                    
                }
                
            }
            
            cs.Send_email__c=false;
            
            
        }
        
        if(ListOfEmailsSent.size()>0)
        {
            
            try
            {
                mailresult= Messaging.sendEmail(ListOfEmailsSent);
            }
            
            catch(Exception e)
            {
                system.debug('Exceptiion '+e);
            }
            system.debug(' Multiles Email Sent');
            boolean result=false;
            
            if(mailresult!=null &&mailresult.size()>0)
            {
            
                for(Messaging.SendEmailResult rr:mailresult)
            
                {
                    if(rr.isSuccess()==true)
                    {
                        result=true;
                    }
                }
            }
            
            
            if(emailMessageList!=null && emailMessageList.size()>0&&result==true)
            {
                
                try
                {
                    insert emailMessageList;
                }
                catch(exception e)
                    
                {
                    system.debug('Exception e '+e);
                }
                
            }
            
            
        }
        
    }
    
    
    
    
    public static void odmsTeam(List<Case> caseListTrg)
    {
        system.debug('Inserted into ODMS Team method');
        Set<id> csId = new Set<id>();
        for(Case cs :caseListTrg)
        {
            csId.add(cs.id);
            cs.Send_ODMS_email__c   =false;
        }
        
        List<Messaging.SingleEmailMessage> ListOfEmailsSent = new List<Messaging.SingleEmailMessage>();
        List<EmailMessage> emailMsglist = new List<EmailMessage>();
        
        system.debug('sendEmailToTeam');
        string res;
        List<ODMS_Team_Mapping__c> odms = new List<ODMS_Team_Mapping__c>();
        string team,subTeam,emailaddresses,address;
        odms = [Select id,Team__c,Sub_Team__c,Email_Addresses__c,Region__c From ODMS_Team_Mapping__c];
        system.debug('ODMS LIST SIZE'+odms.size());
        String[] nameParts = new String[] {};
            
            List<Case> caseList = new List<Case>();
        
        
        Map<string,string> maptoAddresses = new Map<string,string>();
        if(odms.size()>0){
            for(Case cs: caseListTrg)
            { 
                if(odms.size()>0){
                    for(ODMS_Team_Mapping__c odmsList :odms )
                    {
                        
                        if(cs.Team__c==odmsList.Team__c && cs.Sub_Team__c == odmsList.Sub_Team__c && cs.Region__c ==odmsList.Region__c)
                        {
                            system.debug('Record Exists');
                            system.debug('odms'+odmsList);
                            address = odmsList.Email_Addresses__c;
                            if(odmsList.Email_Addresses__c!=null)
                            {  
                                maptoAddresses.put(cs.id,odmsList.Email_Addresses__c);
                                system.debug(odmsList.Email_Addresses__c);
                                
                            }
                            
                        }
                        
                    }
                    
                }
                
            }     
            
        }
        
        
        Email__c ac = Email__c.getInstance();
        string accountName;
        accountName = ac.Default_Email__c;
        OrgWideEmailAddress[] owea;
        if(accountName!=null)
        {
        
            owea = [select Id,address  from OrgWideEmailAddress where Address =: accountName];
        
        }
        List<string> emaillist = new List<string>();
        string fromaddress='';
        for(case cs:caseListTrg)
        {
            List<string> emlist = new List<string>();
            string Strem;
            if(maptoAddresses.size()>0&&maptoAddresses!=null){
                Strem=maptoAddresses.get(cs.id);
                
                for(string sr:Strem.split(';'))
                {
                    
                    if(validateEmail(sr)==true&&sr!=null&&!String.isBlank(sr)&&!sr.contains('null'))
                    {
                        emlist.add(sr);
                    }
                    
                }
                
            }
            
            if(emlist.size()>0 &&emlist!=null)
            {
                
                
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                string subject,body; 
                subject= ' ODMS Team Assignment  [ Ref Number: '+cs.id+' ]';
                body='<html><body> <br>Dear Team,<br><p>Your feedback is required on the Case '+cs.CaseNumber+'. Please provide feedback at earliest by replying to this email. For further details, please reply on the email. </p> Case Description: '+cs.Description+'<br>Sincerely,<br><br>  System Admin <br>LIXIL Water Technologies</body></html>';
                
                if (  owea!=null && owea.size() > 0   ) 
                {
                    mail.setOrgWideEmailAddressId(owea.get(0).Id);
                    fromaddress=owea.get(0).address;
                }
                
                mail.setSubject(subject);
                mail.setHtmlBody(body);
                mail.setToAddresses(emlist);
                mail.setSaveAsActivity(false);
                ListOfEmailsSent.add(mail);
                cs.Send_email__c=false;
                string emailaddress='';
                for(string em:emlist)
                {
                    
                    if(em!=null)
                    {
                        emailaddress+=em+';';
                    }
                    
                    
                }
                
                EmailMessage emailMsg = new EmailMessage(); // Created a EmailMessage and copy all details from above.
                emailMsg.ToAddress=emailaddress;
                emailMsg.Subject=subject;
                //emailMsg.FromAddress=from
                emailMsg.FromAddress=fromaddress;
                emailMsg.HtmlBody=body;
                emailMsg.ParentId = cs.id; //Attach with the case
                emailMsg.MessageDate = system.now();
                emailMsg.ActivityId=null;
                emailMsg.Status = '0';
                emailMsglist.add(emailMsg);
                
                
            }
            
        }
        
        
        Messaging.SendEmailResult[] mailresult;
        
        if(ListOfEmailsSent.size()>0&&ListOfEmailsSent!=null)
        {
            try
            {
                mailresult= Messaging.sendEmail(ListOfEmailsSent);
            }
            catch(Exception e)
            {
                system.debug('Exception'+e);
            }
            
            
            boolean result;
            if(mailresult!=null && mailresult.size()>0)
            {
                for(Messaging.SendEmailResult rr:mailresult)
                {
                    if(rr.isSuccess()==true)
                    {
                        result=true;
                    }
                    
                }
            }
            
            
            if(emailMsgList!=null && emailMsgList.size()>0&&result==true)
            {
                
                try
                {
                    insert emailMsgList;
                }
                catch(exception e)
                    
                {
                    system.debug('Exception e '+e);
                }
                
            }
            
        }
        
        
    }
    
    public static Boolean validateEmail(String email) {
        Boolean res = true;
        
        
        String emailRegex = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$';
        Pattern MyPattern = Pattern.compile(emailRegex);
        Matcher MyMatcher = MyPattern.matcher(email);
        
        if (!MyMatcher.matches()) 
            res = false;
        return res; 
    }
    
    public static void addContactToContactUs(List<Case> CaseListTrg)
    {
        List<Case> caseList = new List<Case>();
        
        List<String> emailAddresses = new List<String>();
        for(Case cs:CaseListTrg)
        { 
            if(cs.RecordTypeId==Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Technical_Support').getRecordTypeId()&& cs.Origin=='Web'){
                
                caseList.add(cs);
            }
        }
        
        Id recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Consumer').getRecordTypeId();
        Id assetrecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Consumer_Asset').getRecordTypeId();
        Id productid;
        
        
        if(caseList.size()>0)
        {
            Account__c ac = Account__c.getInstance();
            string accountName = ac.Name__c;
            system.debug(accountName);
            id accountid;
            List<Account> accountidList  = [Select Id from Account where Name=:accountName limit 1];
            if(accountidList.size()>0)
            {
                accountid=accountidList[0].id;
                system.debug(accountid);
            }
            
            
            for (Case caseObj:CaseList)
            {
                
                if (caseObj.ContactId==null &&
                    caseObj.SuppliedEmail!='')
                {
                    emailAddresses.add(caseObj.SuppliedEmail);
                }
                
            }
            
            //Now we have a nice list of all the email addresses.  Let's query on it and see how many contacts already exist.
            List<Contact> listContacts = [Select Id,Email From Contact Where Email in:emailAddresses];
            system.debug(listContacts.size());
            Set<String> takenEmails = new Set<String>();
            for (Contact c:listContacts)
            {
                takenEmails.add(c.Email);
            }
            System.debug(takenEmails);
            Map<String,Contact> emailToContactMap = new Map<String,Contact>();
            List<Case> casesToUpdate = new List<Case>();
            List<string> emailaddress = new List<string>();
            for (Case caseObj:CaseList) 
            {
                
                
                //for Web  To Case Contact Creation
                if (caseObj.ContactId==null &&
                    caseObj.SuppliedName!=null &&
                    caseObj.SuppliedEmail!=null &&
                    caseObj.SuppliedName!='' &&
                    caseObj.SuppliedEmail!='' &&
                    caseObj.Origin=='Web'&&
                    !takenEmails.contains(caseObj.SuppliedEmail))
                {
                    //The case was created with a null contact
                    //Let's make a contact for it
                    System.debug('Case with Null Contact');
                    emailaddress.add(caseObj.SuppliedEmail);
                    String[] nameParts = caseObj.SuppliedName.split(' ',2);
                    System.debug(nameParts.size());
                    
                    if (nameParts.size() == 2)
                    {
                        System.debug(recordTypeId);
                        Contact cont = new Contact(FirstName=nameParts[0],
                                                   LastName=nameParts[1],
                                                   Email=caseObj.SuppliedEmail,
                                                   AccountId=accountId,
                                                   RecordTypeId= recordTypeId,
                                                   Phone=caseObj.SuppliedPhone,
                                                   OtherCity=caseObj.City__c,
                                                   OtherState=caseObj.State__c,
                                                   OtherCountry=caseObj.Country__c,
                                                   OtherPostalCode=caseObj.Postal_Code__c,
                                                   OtherStreet=caseObj.Street_Address__c,
                                                   ByPassVal__c = true
                                                   
                                                   
                                                  );
                        System.debug('Contact Name:'+nameParts[0]+nameParts[1]);
                        emailToContactMap.put(caseObj.SuppliedEmail,cont);
                        casesToUpdate.add(caseObj);
                    }
                    
                    else if (nameParts.size() == 1)
                    {
                        System.debug(recordTypeId);
                        
                        Contact cont = new Contact( LastName=nameParts[0],
                                                   Email=caseObj.SuppliedEmail,
                                                   AccountId=accountId,
                                                   RecordTypeId= recordTypeId,
                                                   Phone=caseObj.SuppliedPhone,
                                                   OtherCity=caseObj.City__c,
                                                   OtherState=caseObj.State__c,
                                                   OtherCountry=caseObj.Country__c,
                                                   OtherPostalCode=caseObj.Postal_Code__c,
                                                   OtherStreet=caseObj.Street_Address__c,
                                                   ByPassVal__c = true
                                                  );
                        System.debug('Contact Last Name:'+nameParts[0]);
                        emailToContactMap.put(caseObj.SuppliedEmail,cont);
                        casesToUpdate.add(caseObj);
                        system.debug('New Contact');
                        
                        
                    }
                    
                }
                
                
            }
            
            List<Contact> newContacts = emailToContactMap.values();
            if(newContacts.size()>0){
                
                try
                {
                    insert newContacts;
                }
                catch(Exception e)
                {
                    system.debug('Exception '+e);
                }
                
            }
            for (Case caseObj:casesToUpdate) 
            {
                
                
                Contact newContact = emailToContactMap.get(caseObj.SuppliedEmail);
                caseObj.ContactId = newContact.Id;
                
            }
            
            
        }
        
        
    }
    
    public static void addContactToContactUsemail(List<Case> CaseListTrg){
        List<Case> caseList = new List<Case>();
        
        List<String> emailAddresses = new List<String>();
        for(Case cs:CaseListTrg)
        { 
            if((cs.RecordTypeId==Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Customer_Success').getRecordTypeId()||cs.RecordTypeId==Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Technical_Support').getRecordTypeId())&& cs.Origin=='Email'){
                
                caseList.add(cs);
            }
        }
        
        Id recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Consumer').getRecordTypeId();
        
        
        
        if(caseList.size()>0)
        {
            Account__c ac = Account__c.getInstance();
            string accountName = ac.Name__c;
            system.debug(accountName);
            id accountid;
            List<Account> accountidList  = [Select Id from Account where Name=:accountName limit 1];
            if(accountidList.size()>0)
            {
                accountid=accountidList[0].id;
                system.debug(accountid);
            }
            
            
            for (Case caseObj:CaseList)
            {
                
                if (caseObj.ContactId==null &&
                    caseObj.SuppliedEmail!='')
                {
                    emailAddresses.add(caseObj.SuppliedEmail);
                    system.debug('Email Address: '+caseObj.SuppliedEmail);
                }
                
            }
            
            //Now we have a nice list of all the email addresses.  Let's query on it and see how many contacts already exist.
            List<Contact> listContacts = [Select Id,Email From Contact Where Email in:emailAddresses];
            system.debug(listContacts.size());
            Set<String> takenEmails = new Set<String>();
            for (Contact c:listContacts)
            {
                takenEmails.add(c.Email);
            }
            System.debug(takenEmails);
            Map<String,Contact> emailToContactMap = new Map<String,Contact>();
            List<Case> casesToUpdate = new List<Case>();
            List<string> emailaddress = new List<string>();
            for (Case caseObj:CaseList) 
            {
                
                
                //for Web  To Case Contact Creation
                if (caseObj.ContactId==null &&
                    caseObj.SuppliedEmail!=null &&
                    caseObj.SuppliedEmail!='' &&
                    caseObj.Origin=='Email'&&
                    !takenEmails.contains(caseObj.SuppliedEmail))
                {
                    //The case was created with a null contact
                    //Let's make a contact for it
                    System.debug('Case with Null Contact');
                    emailaddress.add(caseObj.SuppliedEmail);
                    String[] nameParts = caseObj.SuppliedEmail.split('@',2);
                    System.debug(nameParts.size());
                    
                    if (nameParts.size() >0)
                    {
                        System.debug(recordTypeId);
                        Contact cont = new Contact(LastName=nameParts[0],
                                                   Email=caseObj.SuppliedEmail,
                                                   AccountId=accountId,
                                                   RecordTypeId= recordTypeId,
                                                   From_Email__c=true,
                                                   ByPassVal__c = true
                                                   
                                                   
                                                  );
                        emailToContactMap.put(caseObj.SuppliedEmail,cont);
                        casesToUpdate.add(caseObj);
                    }
                    
                    
                }
                
                
            }
            
            List<Contact> newContacts = emailToContactMap.values();
            if(newContacts.size()>0){
                
                try
                {
                    
                    insert newContacts;
                }
                catch(Exception e)
                {
                    system.debug('Exception Error:'+e);
                }
                
            }
            for (Case caseObj:casesToUpdate) 
            {
                
                
                Contact newContact = emailToContactMap.get(caseObj.SuppliedEmail);
                caseObj.ContactId = newContact.Id;
                
            }
            
            
        }
        
    }
    
    public static void sendMail(Map<string,List<string>> maptoSendEmail){
        Messaging.SendEmailResult[] mailresult;
        List<Messaging.SingleEmailMessage> ListOfEmailsSent = new List<Messaging.SingleEmailMessage>();
        
        for(string mm: maptoSendEmail.keyset())
        {
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setHtmlBody('<html><body> ' + System.URL.getSalesforceBaseURL().ToExternalForm() +mm+   ' </body></html>');
            mail.setSubject('Test Email to be send for html');
            mail.setToAddresses(maptoSendEmail.get(mm));
            ListOfEmailsSent.add(mail);
            
        }
        if(ListOfEmailsSent.size()>0)
        {
            mailresult= Messaging.sendEmail(ListOfEmailsSent);
            system.debug('Email Sent');
        }
        
    }
    


    
    
    
    @Future(callout=true)
    public static void sendEmail(List<string> emailaddress,string subject,string body)
    {
        Messaging.SendEmailResult [] mailresult; 
        List<Messaging.SingleEmailMessage> ListOfEmailsSent = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(emailaddress);
        mail.setSubject(subject);
        mail.setHtmlBody('<html><body> ' + System.URL.getSalesforceBaseURL().ToExternalForm() +body+   ' </body></html>');
        System.debug('Mail::'+mail);
        ListOfEmailsSent.add(mail);
        if(ListOfEmailsSent.size()>0)
        {
            mailresult= Messaging.sendEmail(ListOfEmailsSent);
            system.debug('Email Sent');
        }
        
        
    }
}