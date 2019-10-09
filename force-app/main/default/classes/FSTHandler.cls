/*-------------------------------------------------------------------------------------------------
Author:             Ibad Mohiuddin
Date:               30-July-2018
Version:            1.0
Description:        Feild Service Ticket Handler
----------------------------------------------------------------------------------------------------*/
/************************MODIFICATION HISTORY*************************************
Added on                Added By                Description
**********************************************************************************
30-July-2018            Ibad Mohiuddin           Initial Development
***********************************************************************************/


public class FSTHandler 
{
    @future(callout=true) 
    public static void sendEmail(List<string> fstListId, List<Id> listCaseId)
    {
        Email__c ac = Email__c.getInstance();
        string accountName = ac.Default_Email__c;
        OrgWideEmailAddress[] owea;
        if(accountName!=null){
            
            owea = [select Id,Address from OrgWideEmailAddress where Address =: accountName];
            
        }
        Box_App_Detail__mdt bad = [select  Id, User_Id__c,  Enterprise_Id__c,  Public_Key__c,  Private_Key__c, Client_Id__c,  Client_Secret__c 
                                   from Box_App_Detail__mdt];
        
        String userId = bad.User_Id__c;
        String enterpriseId = bad.Enterprise_Id__c;
        String publicKeyId = bad.Public_Key__c;
        String privateKey = bad.Private_Key__c;
        String clientId = bad.Client_Id__c;
        String clientSecret = bad.Client_Secret__c; 
        system.debug('Inserted into trigger');
        
        BoxJwtEncryptionPreferences preferences = new BoxJwtEncryptionPreferences();
        preferences.setPublicKeyId(publicKeyId);
        preferences.setPrivateKey(privateKey);
        BoxPlatformApiConnection boxAPIConn = BoxPlatformApiConnection.getAppUserConnection(userId, clientId, clientSecret, preferences);
        
        Map<String, String> mapFRUP = new Map<String, String>();
        Map<String, String> mapFRUPFST = new Map<String, String>();
        
        List<box__FRUP__c> listBoxFRUP;
        List<box__FRUP__c> listBoxFRUPFST;
        
        if (listCaseId != null && listCaseId.size() > 0)
        {
            listBoxFRUP = [select box__Object_Name__c, box__Folder_ID__c, box__Record_ID__c from box__FRUP__c where box__Record_ID__c in :listCaseId];
        }
        
        
        if (fstListId != null && fstListId.size() > 0)
        {
            listBoxFRUPFST = [select box__Object_Name__c, box__Folder_ID__c, box__Record_ID__c from box__FRUP__c where box__Record_ID__c in :fstListId];
        }
        
        
        if (listBoxFRUPFST != null && listBoxFRUPFST.size() > 0)
        {
            for (box__FRUP__c frup : listBoxFRUPFST)
            {
                mapFRUPFST.put(frup.box__Record_ID__c, frup.box__Folder_ID__c);
            }
        }  
        
        
        
        
        if (listBoxFRUP != null && listBoxFRUP.size() > 0)
        {
            for (box__FRUP__c frup : listBoxFRUP)
            {
                mapFRUP.put(frup.box__Record_ID__c, frup.box__Folder_ID__c);
            }
        }         
        
        Map<Id, List<String>> mapCaseFiles = new Map<Id, List<String>>();
        
        if (listCaseId != null && listCaseId.size() > 0)
        {
            for (Id caseId : listCaseId)
            {
                if (mapFRUP.containsKey(caseId))
                {
                    String strBoxFolderId = mapFRUP.get(caseId);
                    
                    BoxFolder folder = new BoxFolder(boxAPIConn, strBoxFolderId);
                    list<BoxItem.Info> children = folder.getChildren();     
                    
                    if (children != null && children.size() > 0) 
                    {
                        List<String> listFileIDs = new List<String>();
                        
                        for (BoxItem.Info itemInfo : children) 
                        {
                            if (itemInfo instanceOf BoxFile.Info) 
                            {
                                BoxFile.Info fileInfo = (BoxFile.Info) itemInfo;
                                listFileIDs.add(fileInfo.Id);
                            }
                        } 
                        
                        if (listFileIDs != null && listFileIDs.size() > 0)
                        {
                            mapCaseFiles.put(caseId, listFileIDs);
                        }
                    }
                }
            }   
        }
        
        
        
        //working for email functionality
        //************************************************************************************************************************************************************************
        List<Messaging.SingleEmailMessage> listEmailMessages = new List<Messaging.SingleEmailMessage>();
        List<Messaging.SingleEmailMessage> ListOfEmailsSent = new List<Messaging.SingleEmailMessage>();
        List<EmailMessage> emailMsgList = new List <EmailMessage>(); // Created a EmailMessage and copy all details from above.
        List<Attachment> attList = new List <Attachment>();
        
        Messaging.SendEmailResult[] mailresult;
        
        Set<id> fstid = new Set<id>();
        List<Field_Service_Ticket__c> fstList = new List<Field_Service_Ticket__c>();
        
        if (fstListId != null && fstListId.size() > 0)
        {
            fstList = [Select id,Case_Owner_Email__c, Field_Service_Agent_Email__c,Case_ID__c,Related_Case_Contact_Name__c,Related_Case_Product__c,Related_Case_Number__c,	Case_ID__r.Case_Owner_Email__c 
                       From Field_Service_Ticket__c 
                       where id IN: fstListId];
            system.debug('FILED SERVICE TICKET LIST '+fstList.size());
        }
        
        if (fstList != null && fstList.size() > 0)
        {
            
            Http h = new Http();
            box.Toolkit boxToolkit = new box.Toolkit();
            string endPointValue = 'https://api.box.com/2.0/files/';
            for (Field_Service_Ticket__c fst : fstList)
            {
                List<string> em = new List<string>();
                
                if(fst.Case_Owner_Email__c != null)
                {
                    em.add(fst.Case_Owner_Email__c);
                    system.debug('Owner Email'+fst.Case_Owner_Email__c);
                    
                }
                
                if(fst.Field_Service_Agent_Email__c != null)
                {
                    em.add(fst.Field_Service_Agent_Email__c);
                }
                
                if(em.size()>0)
                {
                    system.debug('Map Size '+mapFRUPFST.size());
                    String strBoxFolderId = mapFRUPFST.get(fst.id);
                    List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
                    if (mapCaseFiles.containsKey(fst.Case_ID__c))
                    {
                        List<String> listOfFiles = mapCaseFiles.get(fst.Case_ID__c);
                        
                        for (String strFileId : listOfFiles)
                        {
                            String strFileContentURL = endPointValue + strFileId + '/content';
                            HttpRequest req = new HttpRequest();
                            req.setEndpoint(strFileContentURL);
                            req.setMethod('GET');
                            req.setHeader('Authorization', 'Bearer ' + boxAPIConn.accessToken);
                            HttpResponse res = h.send(req);
                            req.setEndpoint(res.getHeader('Location'));
                            req.setMethod('GET');
                            HttpResponse res2 = h.send(req);
                            string blb = res2.getBody();
                            Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
                            BoxFile bfile = new BoxFile(boxAPIConn, strFileId);
                            BoxFile.Info info = bfile.getFileInfo();
                            efa.setFileName(info.Name);
                            efa.setBody(res2.getBodyAsBlob());
                            fileAttachments.add(efa);                            
                        }
                        
                        PageReference ref = Page.pdfvfpage;
                        ref.getParameters().put('id', fst.id);
                        Blob pdfContent ;
                        if(Test.isRunningTest())
                        {
                            pdfContent = Blob.valueOf('Test');
                            
                        }else{
                            pdfContent = ref.getContentAsPDF();
                            
                        }
                        
                        Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
                        attach.setContentType('application/pdf');
                        attach.setFileName('Field Service Ticket Attachement.pdf');
                        attach.setInline(false);
                        attach.Body = pdfContent;
                        fileAttachments.add(attach);
                        attachment att = new attachment();
                        att.Name = 'Field Service Ticket.pdf';
                        att.OwnerId = UserInfo.getUserId();
                        att.ParentId = fst.Case_ID__c; // the record the file is attached to
                        att.IsPrivate = false;
                        att.body = pdfContent;
                        
                        String strBoxFileId = boxtoolkit.createFileFromAttachment(att, null, strBoxFolderId, null);
                        system.debug('ah::new file created ' + strBoxFileId);
                        boxToolkit.commitChanges();  
                        string fromaddress;
                        
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        if ( owea.size() > 0 ) 
                            
                        {
                            mail.setOrgWideEmailAddressId(owea.get(0).Id);
                            fromaddress=owea.get(0).address;

                            
                        } 
                        mail.setUseSignature(false);
                        mail.setToAddresses(em);
                        mail.setSubject('Field Service Ticket has been Approved for '+fst.Related_Case_Number__c);
                        mail.setHtmlBody('<p>Dear,<p>A Field Service Ticket has been assigned for the Case '+fst.Related_Case_Number__c+', for serving the issue of customer'+fst.Related_Case_Contact_Name__c+' for the Product '+fst.Related_Case_Product__c+'. For further discussion Please Contact at '+fst.Case_ID__r.Case_Owner_Email__c+'</p><br> <br> Sincerely,<br>System Admin/Submitter<br>LIXIL Water Technologies</p>');
                        mail.setFileAttachments(fileAttachments);    
                        system.debug('EMail Created');
                        
                        listEmailMessages.add(mail);
                        string addresses='';
                        for(string sr:em)
                        {
                            addresses+=sr+';';
                        } 
                        EmailMessage emailMsg = new EmailMessage(); // Created a EmailMessage and copy all details from above.
                        emailMsg.ToAddress=addresses;
                        emailMsg.Subject='Field Service Ticket has been Approved for '+fst.Related_Case_Number__c;
                        emailMsg.FromAddress=fromaddress;
                        emailMsg.HtmlBody=('<p>Dear,<p>A Field Service Ticket has been assigned for the Case '+fst.Related_Case_Number__c+', for serving the issue of customer'+fst.Related_Case_Contact_Name__c+' for the Product '+fst.Related_Case_Product__c+'. For further discussion Please Contact at '+fst.Case_ID__r.Case_Owner_Email__c+'</p><br> <br> Sincerely,<br>System Admin/Submitter<br>LIXIL Water Technologies</p>');
                        emailMsg.ParentId = fst.Case_ID__c; //Attach with the case
                        emailMsg.MessageDate = system.now();
                        emailMsg.Status = '0';
                        emailMsgList.add(emailMSg);
                        
                    }
                    
                    else
                    {
                        PageReference ref = Page.pdfvfpage;
                        ref.getParameters().put('id', fst.id);
                        
                        Blob pdfContent ;
                        if(Test.isRunningTest())
                        {
                            pdfContent = blob.valueOf('TestPDF');
                            
                        }
                        else
                        {
                            pdfContent = ref.getContentAsPDF();
                        }
                        Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
                        attach.setContentType('application/pdf');
                        attach.setFileName('Field Service Ticket Attachement.pdf');
                        attach.setInline(false);
                        attach.Body = pdfContent;
                        fileAttachments.add(attach);
                        attachment att = new attachment();
                        att.Name = 'Field Service Ticket.pdf';
                        att.OwnerId = UserInfo.getUserId();
                        att.ParentId = fst.Case_ID__c; // the record the file is attached to
                        att.IsPrivate = false;
                        att.body = pdfContent;
                        String strBoxFileId = boxtoolkit.createFileFromAttachment(att, null, strBoxFolderId, null);
                        system.debug('ah::new file created ' + strBoxFileId);
                        boxToolkit.commitChanges();                        
                        
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        
                        mail.setUseSignature(false);
                        mail.setToAddresses(em);
                        string fromaddress='';
                        if (owea !=null  &&owea.size() > 0 ) 
                            
                        {
                            mail.setOrgWideEmailAddressId(owea.get(0).Id);
                            fromaddress=owea.get(0).address;

                            
                        } 
                        mail.setSubject('Field Service Ticket has been Approved for '+fst.Related_Case_Number__c);
                        mail.setHtmlBody('<p>Dear,<p>A Field Service Ticket has been assigned for the Case '+fst.Related_Case_Number__c+', for serving the issue of customer'+fst.Related_Case_Contact_Name__c+' for the Product '+fst.Related_Case_Product__c+'</p><br> <br> Sincerely,<br>System Admin/Submitter<br>LIXIL Water Technologies</p>');
                        mail.setFileAttachments(fileAttachments);    
                        system.debug('EMail Created');
                        listEmailMessages.add(mail);
                        string addresses='';
                        for(string sr:em)
                        {
                            addresses+=sr+';';
                        } 
                        EmailMessage emailMsg = new EmailMessage(); // Created a EmailMessage and copy all details from above.
                        emailMsg.ToAddress=addresses;
                        emailMsg.Subject='Field Service Ticket has been Approved for '+fst.Related_Case_Number__c; 
                        emailMsg.HtmlBody=('<p>Dear,<p>A Field Service Ticket has been assigned for the Case '+fst.Related_Case_Number__c+', for serving the issue of customer'+fst.Related_Case_Contact_Name__c+' for the Product '+fst.Related_Case_Product__c+'. </p><br> <br> Sincerely,<br>System Admin/Submitter<br>LIXIL Water Technologies</p>');
                        emailMsg.ParentId = fst.Case_ID__c; //Attach with the case
                        emailMsg.MessageDate = system.now();
                        emailMsg.FromAddress=fromaddress;
                        emailMsg.Status = '0';
                        emailMsgList.add(emailMSg);                        
                    }
                    
                }
                
            }
            
        }
        
        
        if (listEmailMessages != null && listEmailMessages.size() > 0)
        {
            Messaging.SendEmailResult[] results = Messaging.sendEmail(listEmailMessages);
            system.debug('Email Send');
            
            boolean res;
            for(Messaging.SendEmailResult rr:results)
            {
                if(rr.isSuccess()==true)
                {
                    res=true;
                }
                
            }
            
            if(emailMsgList!=null && emailMsgList.size()>0&&res==true)
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
    
    
    
}