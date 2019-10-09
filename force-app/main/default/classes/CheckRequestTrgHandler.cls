/************************
Author:         Abid Raza
Created Date:   13/Sep/2018 
Purpose:        Trigger Handler class to attach and send Check Request PDF on approval.
************************/

public class CheckRequestTrgHandler 
{
    public void CreateAndSendCheckRequestPDFs(List<Check_Request__c> LstAppCheckReqs)
    {
        
        CheckRequestPDFRecipient__c RecipientEmailSettings =  CheckRequestPDFRecipient__c.getinstance();
        
        List<string> listCaseId = new List<string>();
        List<string> crListId = new List<string>();
        Map<string,string> crToBoxId = new Map<string,string>();
        //additionForBox
        for(Check_Request__c cr :LstAppCheckReqs)
        {
            crListId.add(cr.id);
        }
        
        List<box__FRUP__c> listBoxFRUP;
        if (crListId != null && crListId.size() > 0)
        {
            listBoxFRUP = [select box__Object_Name__c, box__Folder_ID__c, box__Record_ID__c from box__FRUP__c where box__Record_ID__c in :crListId];
        }
        
        if(listBoxFRUP!=null && listBoxFRUP.size()>0)
        {
            for(box__FRUP__c brid : listBoxFRUP )
            {
                crToBoxId.put(brid.box__Record_ID__c,brid.box__Folder_ID__c) ;   
            }
        } 
        
        for(Check_Request__c cr: LstAppCheckReqs)
        {
            string boxId;
            if(crToBoxId!=null && crToBoxId.size() > 0)
            {
                boxId=crToBoxId.get(cr.id);
            }
            
            if(RecipientEmailSettings.Recipient_Email__c != null && boxId != null)
                CreateAndSendPDF(cr.Record_Type_Name__c,cr.Id,cr.Name,cr.Case_Number__c,cr.Case_ID__c,RecipientEmailSettings.Recipient_Email__c,boxId);
        }
    }
    
    public static void createFolderinBox (List<Check_Request__c> CRList)
    {
        Set<id> crId = new Set<id>();
        Map<string,string>mapFRUP = new Map<string,string>();
        
        for(Check_Request__c cr:CRList)
        {
            crId.add(cr.id);
        }
        
        List<box__FRUP__c> listBoxFRUP = [select box__Object_Name__c, box__Folder_ID__c, box__Record_ID__c from box__FRUP__c where box__Record_ID__c in :crId];
        
        if (listBoxFRUP != null && listBoxFRUP.size() > 0)
        {
            for (box__FRUP__c frup : listBoxFRUP)
            {
                mapFRUP.put(frup.box__Record_ID__c, frup.box__Folder_ID__c);                
            }
        }  
        
        for(Check_Request__c cr:CRList)
        {
            if (!mapFRUP.containsKey(cr.Id))
            {
                BoxConnectUtil.createFolderinBox(cr.Id);
            }
        }
    }
    
    @Future(callout=true)
    public static void CreateAndSendPDF(string RecordTypeName, string CRID, string CRName, string CaseNumber, string CaseID, string RecipientEmail,string strBoxFolderId)
    {
         
        Email__c ac = Email__c.getInstance();
        string accountName = ac.Default_Email__c;
        OrgWideEmailAddress[] owea;
        List<string> crids = new List<String>();
        crids.add(CRID);
        List<Messaging.EmailFileAttachment> emailattach = getBoxFiles(crids).get(CRID);
        if(accountName!=null){
            
            owea = [select Id,Address from OrgWideEmailAddress where Address =: accountName];
            
        }
        boolean res;
        List<EmailMessage> emailMsglist = new List<EmailMessage>();
        PageReference pdf;
        box.Toolkit boxToolkit = new box.Toolkit();
        Case caserecord = [Select Id,Case_Owner_Email__c,Case_Owner_Name__c,Contact.Name,Product.Name from Case where Id =: CaseID];
        
        if(RecordTypeName == 'Payment_CA' || RecordTypeName == 'Payment_US')
        {
            pdf = page.PaymentCheckRequestPDF;
        }
        else if(RecordTypeName == 'Reimbursement_CA' || RecordTypeName == 'Reimbursement_US')
        {
            pdf = page.ReimbursementCheckPDF;
        }
        
        pdf.getParameters().put('id',CRID);
        Attachment attach = new Attachment();
        attach.ContentType='application/pdf';
        Blob body;
        try 
        {
            body = pdf.getContentAsPDF();
        } 
        catch (VisualforceException e) 
        {
            body = Blob.valueOf('No PDF');
        }             
        attach.Body = body;       
        attach.Name = 'Case: ' + CaseNumber + ' Check Request: ' + CRName + ' PDF.pdf';       
        attach.IsPrivate = false;      
        attach.ParentId = CRID;           
            String strBoxFileId = boxtoolkit.createFileFromAttachment(attach, null, strBoxFolderId, null);
            
            boxToolkit.commitChanges();
           
            
            Messaging.EmailFileAttachment anEmailattach = new Messaging.EmailFileAttachment();
            anEmailattach.setContentType('application/pdf');
            anEmailattach.setFileName('Case: ' + CaseNumber + ' Check Request: ' + CRName + ' PDF.pdf');
            anEmailattach.setBody(attach.body);
			Emailattach.add(anEmailattach);
            Messaging.SingleEmailMessage email;
            
            if(!string.isBlank(RecipientEmail))
            {
                email = new Messaging.SingleEmailMessage();
                String[] toAddresses = new String[] {RecipientEmail};
                    string mail_subject_rec,mail_body_rec;
                mail_subject_rec='Check Request has been Approved for Check Issuance for Case #: ' + CaseNumber;
                mail_body_rec='Dear Finance Team,<br/> <br/>A Check Request has been approved for the Case ID:'+ CaseNumber +', for payment/reimbursement of Field Service Agent/Customer '+caserecord.Contact.Name+ ' for the Product '+caserecord.Product.name+'. Please generate a check and reply with Check & Check number enclosed at '+ caserecord.Case_Owner_Email__c +'.<br/><br/>Sincerely,<br/><br/>System Admin/Submitter<br/>LIXIL Water Technologies';
                email.setSubject(mail_subject_rec);
                string fromaddress='';
                if ( owea!= null &&owea.size() > 0 ) 
                {
                    email.setOrgWideEmailAddressId(owea.get(0).Id);
                    fromaddress=owea.get(0).address;
                    
                }
                email.setToAddresses(toAddresses);
                email.setHtmlBody(mail_body_rec);
                email.setFileAttachments(emailattach);
                Messaging.SendEmailResult [] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
                
                // From here, its Ibad Code.
                EmailMessage emailMsg = new EmailMessage();
                emailMsg.ToAddress=RecipientEmail;
                emailMsg.Subject=mail_subject_rec;
                emailMsg.FromAddress=fromaddress;
                emailMsg.HtmlBody=mail_body_rec;
                emailMsg.ParentId = CaseID;
                emailMsg.MessageDate = system.now();
                emailMsg.ActivityId=null;
                emailMsg.Status = '0';
                emailMsglist.add(emailMsg);
                for(Messaging.SendEmailResult rr:results)
                {
                    if(rr.isSuccess()==true)
                    {
                        res=true;
                    }
                }
            }
            
            if(!string.isBlank(caserecord.Case_Owner_Email__c))
            {
                email = new Messaging.SingleEmailMessage();
                String[] toAddresses = new String[] {caserecord.Case_Owner_Email__c };
                    string mail_subject,mail_body;
                string fromaddress='';
                mail_subject='Check Request has been Approved & Submitted to Finance Team for Check Issuance for Case #: ' + CaseNumber;
                mail_body='Dear ' +caserecord.Case_Owner_Name__c+',<br/> <br/>A Check Request has been approved & submitted to Finance Team, for the Case ID:'+ CaseNumber +', for payment/reimbursement of Field Service Agent/Customer '+caserecord.Contact.Name+ ' for the Product '+caserecord.Product.name+'. Please find attached the PDF sent to finance team, and wait while check is being processed.<br/><br/>Sincerely,<br/><br/>System Admin/Submitter<br/>LIXIL Water Technologies';
                email.setSubject(mail_subject);
                if ( owea!= null &&  owea.size() > 0 ) 
                {
                    email.setOrgWideEmailAddressId(owea.get(0).Id);
                    fromaddress=owea.get(0).address;
                    
                }
                email.setToAddresses(toAddresses);
                email.setHtmlBody(mail_body);
                email.setFileAttachments(emailattach);
                Messaging.SendEmailResult [] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
                
                EmailMessage emailMsg = new EmailMessage(); // Created a EmailMessage and copy all details from above.
                emailMsg.ToAddress=caserecord.Case_Owner_Email__c;
                emailMsg.Subject=mail_subject;
                if ( owea!= null &&owea.size() > 0 ) 
                {
                    emailMsg.FromAddress=owea.get(0).address;
                }
                emailMsg.HtmlBody=mail_body;
                emailMsg.ParentId = CaseID ; //Attach with the case
                emailMsg.MessageDate = system.now();
                emailMsg.Status = '0';
                emailMsglist.add(emailMsg);
                
                for(Messaging.SendEmailResult rr:results)
                {
                    if(rr.isSuccess()==true)
                    {
                        res=true;
                    }
                }
            }
            if(emailMsglist.size()>0 && emailMsglist!=null && res==true)
            {
                try
                {
                    insert emailMsglist;
                }
                catch(Exception e)
                {
                    system.debug('Exception e'+e);
                }
            }
        }
        //catch(exception e)
        {
       //     system.debug('hb::'+e.getMessage()+' '+e.getLineNumber());
       //     Apexpages.addmessages(e);
       // }          
    }
    
    private static map<Id,List<Messaging.EmailFileAttachment>> getBoxFiles(List<String> RecordsId){  
        map<Id,List<Messaging.EmailFileAttachment>> result = new map<Id,List<Messaging.EmailFileAttachment>>();
        if (!RecordsId.isEmpty())
        {
            Box_App_Detail__mdt bad = [select  Id, User_Id__c,  Enterprise_Id__c,  Public_Key__c,  Private_Key__c, Client_Id__c,  Client_Secret__c 
                                       from Box_App_Detail__mdt];
            
            String userId = bad.User_Id__c;
            String enterpriseId = bad.Enterprise_Id__c;
            String publicKeyId = bad.Public_Key__c;
            String privateKey = bad.Private_Key__c;
            String clientId = bad.Client_Id__c;
            String clientSecret = bad.Client_Secret__c; 
            
            
            Http h = new Http();
            box.Toolkit boxToolkit = new box.Toolkit();
            string endPointValue = 'https://api.box.com/2.0/files/';
            
            BoxJwtEncryptionPreferences preferences = new BoxJwtEncryptionPreferences();
            preferences.setPublicKeyId(publicKeyId);
            preferences.setPrivateKey(privateKey);
            BoxPlatformApiConnection boxAPIConn = BoxPlatformApiConnection.getAppUserConnection(userId, clientId, clientSecret, preferences);
            
            Map<String, String> mapFRUP = new Map<String, String>();
            Map<String, String> mapFRUPFST = new Map<String, String>();
            
            List<box__FRUP__c> listBoxFRUP;
            List<box__FRUP__c> listBoxFRUPFST;
            listBoxFRUP = [select box__Object_Name__c, box__Folder_ID__c, box__Record_ID__c from box__FRUP__c where box__Record_ID__c in :RecordsId];
            
            
            if (!listBoxFRUP.isEmpty())
            {
                for (box__FRUP__c frup : listBoxFRUP)
                {
                    mapFRUP.put(frup.box__Record_ID__c, frup.box__Folder_ID__c);
                }
                
                for (Id recId : RecordsId)
                {
                    List<Messaging.EmailFileAttachment> fileAttachments = new List<Messaging.EmailFileAttachment>();
                    if (mapFRUP.containsKey(recId))
                    {
                        String strBoxFolderId = mapFRUP.get(recId);
                        
                        BoxFolder folder = new BoxFolder(boxAPIConn, strBoxFolderId);
                        list<BoxItem.Info> children = folder.getChildren();     
                        
                        if (children != null && children.size() > 0) 
                        {
                            for (BoxItem.Info itemInfo : children) 
                            {
                                if (itemInfo instanceOf BoxFile.Info) 
                                {
                                    BoxFile.Info fileInfo = (BoxFile.Info) itemInfo;                                
                                    String strFileContentURL = endPointValue + fileInfo.Id + '/content';
                                    HttpRequest req = new HttpRequest();
                                    req.setEndpoint(strFileContentURL);
                                    req.setMethod('GET');
                                    req.setHeader('Authorization', 'Bearer ' + boxAPIConn.accessToken);
                                    HttpResponse res = h.send(req);
                                    req.setEndpoint(res.getHeader('Location'));
                                    req.setMethod('GET');
                                    HttpResponse res2 = h.send(req);
                                    string blb = res2.getBody();
                                    Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                                    //BoxFile bfile = new BoxFile(boxAPIConn, strFileId);
                                    //BoxFile.Info info = bfile.getFileInfo();
                                    efa.setFileName(fileInfo.Name);
                                    efa.setBody(res2.getBodyAsBlob());
                                    fileAttachments.add(efa);
                                    
                                }
                            } 
                        }
                    }
                    
                    result.put(recId, fileAttachments);
                    
                }   
            }
        }
        return result;
    }
}