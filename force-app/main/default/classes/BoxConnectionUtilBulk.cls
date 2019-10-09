public class BoxConnectionUtilBulk {
    
    @future (callout=true)
    //public static void getFileContent(List<Id> caseIDs)
    public static void getFileContent(String strBoxFolderId,List<id> caseIds)
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
        
        
        //for(string strBoxFolderId2:caseIds)
        //{    
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
     //}
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