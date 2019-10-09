/************************
Author:         Abid Raza
Created Date:   11th/Sep/2018 
Purpose:        Find Scar record to Update Last Notified Vendor when email is send through quick action (Send Email).
************************/

trigger EmailMessageTrigger on EmailMessage (before insert, after insert) 
{ 
    
    
    
    List<id>emId = new List<id>();
    Map<id,id> emtoCaseId = new Map<id,id>();
    if(trigger.IsBefore && Trigger.IsInsert)
    {
        set<Id> SetSCARIds = new Set<Id>();
        string ObjectName = '';
        
        for(EmailMessage em: Trigger.New)
        {
            if(em.RelatedToId != null)
            {
                ObjectName = em.RelatedToId.getSObjectType().getDescribe().getName();
                
                if(ObjectName == 'SCAR__c')
                {
                    SetSCARIds.add(em.RelatedToId);
                }
            }
        }
        
        if(SetSCARIds.Size() > 0)
        {
            List<SCAR__c> ListScarsToUpdate = [Select Id,Name,Last_Notified_Vendor__c,SCAR_Issue_Date__c,X3D_Due_Date__c,X8D_Due_Date__c from SCAR__c where Id in:SetSCARIds and Last_Notified_Vendor__c =: null];
            
            if(ListScarsToUpdate.Size() > 0)
            {
                for(Scar__c scr: ListScarsToUpdate)
                {
                    scr.Last_Notified_Vendor__c = Date.today();
                    scr.X3D_Due_Date__c = Date.today().AddDays(2);
                    scr.X8D_Due_Date__c = Date.today().AddDays(12);
                }
                
                Update ListScarsToUpdate;
            }
        }
    }
    
    // After Insert part is Ibad's Code. 
    if(trigger.IsAfter && Trigger.IsInsert)
    {
        List<Id> listEMIds = new List<Id>();
        Map<Id, Id> mapEMtoCase = new Map<Id, Id>();
        String ObjectName='';
        Set<id> idd = new Set<id>();
        for (EmailMessage em : Trigger.New)
        {
            
            if (em.parentId != null && em.parentId.getSObjectType() == Case.sObjectType && em.HasAttachment && em.ContentDocumentIds!=null)
            {
                listEMIds.add(em.Id);
                system.debug('emailMessageId'+em.id);
                system.debug('Email Message ParentId'+em.ParentId);
                mapEMtoCase.put(em.Id, em.ParentId);
                system.debug('Inserted into loop');
            }
            
        }
        
        
        system.debug('Email message list size'+listEMIds.size());
        system.debug('Map email to case'+mapEMtoCase.size());
        if((listEMIds.size()>0&&listEMIds!=null)&&(mapEMtoCase.size()>0 &&mapEMtoCase!=null))
        {
            
            
            BoxConnectUtil.createFilefromEmailAttachment(listEMIds, mapEMtoCase);
            
            
        }
        
    }
    
    
    
    if(Trigger.isBefore && Trigger.IsInsert){
        List<EmailMessage> emList = new List<EmailMessage>();
        Email__c ac = Email__c.getInstance();
        List<case> cs = new List<Case>();
        set<id> existingcaseids = new set<id>();
        string accountName='';
        accountName= ac.Default_Email__c;
        List<EmailMessage> existemailMsg = new List<EmailMessage>();
        for(EmailMessage em : Trigger.new)
        {
            system.debug(em.Subject);
            system.debug(em.ParentId);
            if(em.parentId!=null && em.Subject!=null&&  em.ToAddress!=null && em.parentId.getSObjectType() == Case.sObjectType &&em.ToAddress==accountName && em.For_Odms__c==false )
            {
                if(em.Subject.Contains('Ref Number:'))
                {
                    
                    emailMessage emailMsg = new emailMessage();
                    String str = 'ODMS Team Assignment for Case #: 00005204 Ref Number: 5001k00000AEJerAAH cc';
                    string res,matchresult;
                    Pattern p = Pattern.compile('Ref Number: (\\S+)\\s');
                    Matcher pm = p.matcher(em.Subject);    
                    if (pm.find()) {
                        res = 'match = ' + pm.group(1);
                        System.debug(res);
                        matchresult=pm.group(1);
                        existingcaseids.add(matchresult);
                        existemailMsg.add(em);
                        
                        
                    }
                }
                
                if(existingcaseids!=null&&existingcaseids.size()>0)
                {
                    try
                    {
                        cs=[Select id from case where id in:existingcaseids];
                    }
                    catch(exception e)
                    {
                        system.debug('exception e'+e);
                    }
                    
                }
                
            }
            
            
        }
        
        if(existemailMsg!=null &&existemailMsg.size()>0 && cs!=null &&cs.size()>0)
        {
            for(emailMessage em :existemailMsg)
            {
                emailMessage emailMsg = new emailMessage();
                String str = 'ODMS Team Assignment for Case #: 00005204 Ref Number: 5001k00000AEJerAAH cc';
                string res,matchresult;
                Pattern p = Pattern.compile('Ref Number: (\\S+)\\s');
                Matcher pm = p.matcher(em.Subject);    
                if (pm.find()) {
                    res = 'match = ' + pm.group(1);
                    System.debug(res);
                    matchresult=pm.group(1);
                    emailmsg.ParentId=matchresult;
                    emailMsg.Subject=em.Subject;
                    emailMsg.FromAddress=em.FromAddress;
                    emailMsg.ToAddress=accountName;
                    emailMsg.HtmlBody=em.HtmlBody;
                    emailMsg.MessageDate = system.now();
                    emailMsg.Status = '0';
                    emailMsg.For_Odms__c=true;
                    emId.add(em.id);
                    emtoCaseId.put(em.id,Id.valueof(matchresult));
                    emList.add(emailMsg);
                    
                }else
                {
                    System.debug('No match');
                }
                
            }
            
            if(emList.size()>0 && emList!=null)
            {
                try{
                    insert emList;
                }
                catch(Exception e){
                    
                    system.debug('Exception'+e);
                }
                
            }
            
        }
        
    }
    
    
}