//we need to adjust below code for bulkification
public class BoxConnectUtil 
{
    
    @future (callout=true)
    public static void moveAttachmenttoBox(List<Id> listAttachmentId, List<Id> listCaseId)
    {
        system.debug('ah::making call-out... ' + listAttachmentId);
        system.debug('ah::making call-out... ' + listCaseId);

        
        Box_App_Detail__mdt bad = [select  Id, User_Id__c,  Enterprise_Id__c,  Public_Key__c,  Private_Key__c, Client_Id__c,  Client_Secret__c 
                                   from Box_App_Detail__mdt];
        
        String userId = bad.User_Id__c;
        String enterpriseId = bad.Enterprise_Id__c;
        String publicKeyId = bad.Public_Key__c;
        String privateKey = bad.Private_Key__c;
        String clientId = bad.Client_Id__c;
        String clientSecret = bad.Client_Secret__c;    

        BoxJwtEncryptionPreferences preferences = new BoxJwtEncryptionPreferences();
        preferences.setPublicKeyId(publicKeyId);
        preferences.setPrivateKey(privateKey);
        BoxPlatformApiConnection boxAPIConn = BoxPlatformApiConnection.getAppUserConnection(userId, clientId, clientSecret, preferences);
        
        List<Attachment> listAtt;
        
        if (listAttachmentId != null && listAttachmentId.size() > 0)
        {
        	listAtt = [select Id, Name, ParentId, ContentType, Body from Attachment where Id in :listAttachmentId];
        }
        
        Map<String, String> mapFRUP = new Map<String, String>();
        
        List<box__FRUP__c> listBoxFRUP;
        
        if (listCaseId != null && listCaseId.size() > 0)
        {
        	listBoxFRUP = [select box__Object_Name__c, box__Folder_ID__c, box__Record_ID__c from box__FRUP__c where box__Record_ID__c in :listCaseId];
        }
        
        if (listBoxFRUP != null && listBoxFRUP.size() > 0)
        {
            for (box__FRUP__c frup : listBoxFRUP)
            {
                mapFRUP.put(frup.box__Record_ID__c, frup.box__Folder_ID__c);
            }
        } 
        
        if (listAtt != null && listAtt.size() > 0)
        {
            box.Toolkit boxToolkit = new box.Toolkit();
            
            for (Attachment att : listAtt)
            {
                if (mapFRUP.containsKey(att.ParentId))
                {
                	String strBoxFolderId = mapFRUP.get(att.ParentId);   

                    String strBoxFileId = boxtoolkit.createFileFromAttachment(att, null, strBoxFolderId, null);
                    boxToolkit.commitChanges();
                    
                    
                    
                }
                else
                {
                    String strBoxFolderId = boxToolkit.createFolderForRecordId(att.ParentId,null, true);
                    String strBoxFileId = boxtoolkit.createFileFromAttachment(att, null, strBoxFolderId, null);
                    boxToolkit.commitChanges();
                   
                }
            }
        }
        
    }
    
    
    
    
    
     

    
    @future (callout=true)
    public static void createFilefromEmailAttachment(List<Id> listEMIds, Map<Id, Id> mapEMtoCase)
    {
        if (listEMIds != null && listEMIds.size() > 0)
        {
            List<Attachment> listAttachment = [select Id, ParentId, Body, Name, ContentType from Attachment where ParentId in :listEMIds];
            
            if (listAttachment != null && listAttachment.size() > 0)
            {
                
                Map<String, String> mapFRUP = new Map<String, String>();
                
                List<box__FRUP__c> listBoxFRUP;
                
                List<Id> listCaseId;
                
                if (mapEMtoCase != null && mapEMtoCase.size() > 0)
                {
                    listCaseId = mapEMtoCase.values();
                }
                
                system.debug('ibad:listCaseId ' + listCaseId);
                
                if (listCaseId != null && listCaseId.size() > 0)
                {
                    listBoxFRUP = [select box__Object_Name__c, box__Folder_ID__c, box__Record_ID__c from box__FRUP__c where box__Record_ID__c in :listCaseId];
                }
                
                if (listBoxFRUP != null && listBoxFRUP.size() > 0)
                {
                    for (box__FRUP__c frup : listBoxFRUP)
                    {
                        mapFRUP.put(frup.box__Record_ID__c, frup.box__Folder_ID__c);
                    }
                }                 
                
                box.Toolkit boxToolkit = new box.Toolkit();    
                
                for (Attachment att : listAttachment)
                {
                    system.debug('Inserted in attachments');
                    if (mapEMtoCase.containsKey(att.ParentId))
                    {
                        String strCaseId = mapEMtoCase.get(att.ParentId);
                        system.debug('CaseId in Loop'+strCaseId);
                        if (mapFRUP.containsKey(strCaseId))
                        {
                            
                            String strBoxFolderId = mapFRUP.get(strCaseId);   
                            system.debug('Folder exists');
                            String strBoxFileId = boxtoolkit.createFileFromAttachment(att, null, strBoxFolderId, null);
                            
                        }
                        else
                        {
                            system.debug('Folder does not exists');
                            String strBoxFolderId = boxToolkit.createFolderForRecordId(strCaseId, null, true);
                            mapFRUP.put(strCaseId,strBoxFolderId);
                            system.debug('ah::boxToolKit error: ' + boxToolkit.mostRecentError);
                            system.debug('Folder Id '+strBoxFolderId);
                            String strBoxFileId = boxtoolkit.createFileFromAttachment(att, null, strBoxFolderId, null);
                            system.debug('FileId'+strBoxFileId);
                            
                        }                        
                    }
                }
                
                boxToolkit.commitChanges();
                        
            }
        }       
    }
    
    
    
    @future (callout=true)
    public static void moveAttachmenttoBox2(List<Id> listAttachmentId, List<Id> listParentId)
    {
        system.debug('ah::making call-out... ' + listAttachmentId);
        system.debug('ah::making call-out... ' + listParentId);
        Set<id> st = new Set<id>();
        box.Toolkit boxToolkit = new box.Toolkit();
        
        for(id ss:listParentId)
        {
            
                    String strBoxFolderId = boxToolkit.createFolderForRecordId(ss,'Testfolderforemail', true);
                    boxToolkit.commitChanges();
        }

         if(listParentId!=null &&listParentId.size()>0)
        {
            
                    for(id parentid:listParentId)
                    {
                        if(!st.contains(parentid))
                        {
                            st.add(parentid);
                        }
                    }
        }
              List<box__FRUP__c> listBoxFRUP;
                    
        Map<string,string> mp = new Map<string,String>();
        //BoxConnectUtil boxToolkit2 = new BoxConnectUtil();
        if(st!=null && st.size()>0)
        {
            
                for(id idtocreate:st)
                {
                    String strBoxFolderId = boxToolkit.createFolderForRecordId(idtocreate,'Testfolderforemail', true);
                    //boxToolkit.commitChanges();
                    mp.put(idtocreate,strBoxFolderId );
        
                }
      
        
            
        }
        
        
                
        
        
        List<Attachment> listAtt;
        if (listAttachmentId != null && listAttachmentId.size() > 0)
        {
        	listAtt = [select Id, Name, ParentId, ContentType, Body from Attachment where Id in :listAttachmentId];
        }
        
        
        if (listAtt != null && listAtt.size() > 0)
        {
            
            for (Attachment att : listAtt)
            {
                    string strBoxFolderId = mp.get(att.ParentId);
                    String strBoxFileId = boxtoolkit.createFileFromAttachment(att, 'null', strBoxFolderId, null);
                    boxToolkit.commitChanges();
                   
                
            }
        }
        
    }
    
    
    
    
    
    
    
    
    
    
    
       
    @future (callout=true)
    public static void createemailFolderinBox (List<Id> AttachmentId)
    {
        box.Toolkit boxToolkit = new box.Toolkit();        
        List<Attachment> att;
        Set<id> stt;
        att=[select Id, Name, ParentId, ContentType, Body from Attachment where Id in :AttachmentId];
        if(att!=null && att.size()>0)
        {
            for(Attachment st:att)
            {
                stt.add(st.ParentId);
                
            }
        }
        
        if(stt!=null &&stt.size()>0)
        {
         
            for(id st:stt)
            {
                String strBoxFolderId = boxToolkit.createFolderForRecordId(st, 'asssssaa', true);
                boxToolkit.commitChanges(); 
                    
            }
        }
        
        //system.debug('ah::create folder for ' + objId + ' ' + strBoxFolderId);   
        system.debug('ah::boxToolKit error: ' + boxToolkit.mostRecentError);
    }  
    
    
    @future (callout=true)
    public static void createFolderinBox (Id objId)
    {
        box.Toolkit boxToolkit = new box.Toolkit();        
        
        String strBoxFolderId = boxToolkit.createFolderForRecordId(objId, null, true);
        boxToolkit.commitChanges(); 
        
        system.debug('ah::create folder for ' + objId + ' ' + strBoxFolderId);   
        system.debug('ah::boxToolKit error: ' + boxToolkit.mostRecentError);
    }    
    
    
    @future (callout=true)
    public static void createFolderinBoxList (Set<id> recordId)
    {
        system.debug('Inserted in box folder');
        box.Toolkit boxToolkit = new box.Toolkit();        
        for(id idd:recordId)
        {
            
            String strBoxFolderId = boxToolkit.createFolderForRecordId(idd, null, true);
            
        }           
        boxToolkit.commitChanges(); 

        //system.debug('ah::create folder for ' + objId + ' ' + strBoxFolderId);   
        //system.debug('ah::boxToolKit error: ' + boxToolkit.mostRecentError);
    }    
    
    
    
    
    @future(callout=true)
    public static void createfiles (List<id> att) 
    {
    
        
        box.Toolkit boxToolkit = new box.Toolkit();        
        List<Attachment> attach;
        Set<id> stt;
        attach=[select Id, Name, ParentId, ContentType, Body from Attachment where Id in :att];
        Set<id> Parentid;
        if(attach!=null&&attach.size()>0)
        {
            for(Attachment at:attach )
            {
                Parentid.add(at.ParentId);
            }
        }
        
        
        map<string,string> mapFRUP = new map<string,string>();
       List<box__FRUP__c> listBoxFRUP;
        
        if (Parentid != null && Parentid.size() > 0)
        {
        	listBoxFRUP = [select box__Object_Name__c, box__Folder_ID__c, box__Record_ID__c from box__FRUP__c where box__Record_ID__c in :Parentid];
        }
        
        if (listBoxFRUP != null && listBoxFRUP.size() > 0)
        {
            for (box__FRUP__c frup : listBoxFRUP)
            {
                mapFRUP.put(frup.box__Record_ID__c, frup.box__Folder_ID__c);
            }
        }
        
        
        for(attachment at:attach)
        {
            string folderid = mapFRUP.get(at.ParentId);
            String strBoxFileId = boxtoolkit.createFileFromAttachment(at, null, folderid, null);
            boxToolkit.commitChanges();
                    
            
            
        }
        
        
        
    }
    
    @future (callout=true)
    public static void createFolderinBoxdefaultName (Id objId)
    {
        box.Toolkit boxToolkit = new box.Toolkit();        
        
        String strBoxFolderId = boxToolkit.createFolderForRecordId(objId, 'emailmsg', true);
        boxToolkit.commitChanges(); 
        
        system.debug('ah::create folder for ' + objId + ' ' + strBoxFolderId);   
        system.debug('ah::boxToolKit error: ' + boxToolkit.mostRecentError);
    }    
    
    
    
    
    
    
    @future (callout=true)
    //public static void getFileContent(List<Id> caseIDs)
    public static void getFileContent(String strBoxFolderId)
    {
        Box_App_Detail__mdt bad = [select  Id, User_Id__c,  Enterprise_Id__c,  Public_Key__c,  Private_Key__c, Client_Id__c,  Client_Secret__c 
                                   from Box_App_Detail__mdt];
        
        String userId = bad.User_Id__c;
        String enterpriseId = bad.Enterprise_Id__c;
        String publicKeyId = bad.Public_Key__c;
        String privateKey = bad.Private_Key__c;
        String clientId = bad.Client_Id__c;
        String clientSecret = bad.Client_Secret__c;    
        

        BoxJwtEncryptionPreferences preferences = new BoxJwtEncryptionPreferences();
        preferences.setPublicKeyId(publicKeyId);
        preferences.setPrivateKey(privateKey);
        BoxPlatformApiConnection boxAPIConn = BoxPlatformApiConnection.getAppUserConnection(userId, clientId, clientSecret, preferences);
        
        system.debug(boxAPIConn.accessToken);
  
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        string endPointValue = 'https://api.box.com/2.0/files/';
        
        //String fileId = '306715869169';
        
        BoxFolder folder = new BoxFolder(boxAPIConn, strBoxFolderId);
        list<BoxItem.Info> children = folder.getChildren();     
        
        Map<String, BoxFile.Info> mapBoxFileInfo = new Map<String, BoxFile.Info>();
        
        if (children != null && children.size() > 0) 
        {
            for (BoxItem.Info itemInfo : children) 
            {
				if (itemInfo instanceOf BoxFile.Info) 
                {
                    BoxFile.Info fileInfo = (BoxFile.Info) itemInfo;
                    mapBoxFileInfo.put(fileInfo.Id, fileInfo);
                }
            }   
        }        
        
        if (mapBoxFileInfo != null && mapBoxFileInfo.size() > 0)
        {
            if (mapBoxFileInfo.containsKey(strBoxFolderId))
            {
                String fileId = mapBoxFileInfo.get(strBoxFolderId).Id;
                
                endPointValue = endPointValue + fileId + '/content';
                req.setEndpoint(endPointValue);
                req.setMethod('GET');
                req.setHeader('Authorization', 'Bearer ' + boxAPIConn.accessToken);
                
                HttpResponse res = h.send(req);
                box.Toolkit boxToolkit = new box.Toolkit();
                system.debug('pANY' + res.getBody());
                
                system.debug('ah::boxToolKit error: ' + boxToolkit.mostRecentError);
                
                system.debug(res.getHeader('Location'));
                
                
                req.setEndpoint(res.getHeader('Location'));
                
                    req.setMethod('GET');
                
                        HttpResponse res2 = h.send(req);
                
                        string blb = res2.getBody();
                
                
                
                system.debug('ah::blb ' + blb);
                
                List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
                Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
                efa.setFileName('test.pdf');
                efa.setBody(res2.getBodyAsBlob());
                fileAttachments.add(efa);
                
                
                List<string> email = new List<string>();
                
                email.add('atif.hassan@gettectonic.com');
                email.add('muhammad.asif@gettectonic.com');
                email.add('ibad.mohiuddin@gettectonic.com');
                
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setUseSignature(false);
                mail.setToAddresses(email);
                mail.setSubject('test: PDF from Box.com');
                mail.setHtmlBody('<p>Attached file is emailed from Box.com</p>');
                mail.setFileAttachments(fileAttachments); 
                
                Messaging.SendEmailResult[] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            }
        }
    }
}