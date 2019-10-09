public class AttachmentToBox {
    @future (callout=true) 
    public static void createPDFInBoxAndEmail(String ParentId, String toParentId){
        List<Attachment> lstAttachment = [Select Id, ContentType, ParentId,Body,Name
                                          From Attachment
                                          Where ParentId = :ParentId];
        if(!lstAttachment.isEmpty()){
            
            Map<String, String> mapFRUP = new Map<String, String>();
            List<box__FRUP__c> listBoxFRUP = [select box__Object_Name__c, box__Folder_ID__c, box__Record_ID__c from box__FRUP__c where box__Record_ID__c =:toParentId  ];
            
            if (listBoxFRUP != null && listBoxFRUP.size() > 0) 
            {
                for (box__FRUP__c frup : listBoxFRUP)
                {
                    mapFRUP.put(frup.box__Record_ID__c, frup.box__Folder_ID__c);
                }
            } 
            
            String strBoxFolderId = mapFRUP.get(toParentId);     
            
            Box_App_Detail__mdt bad = [select  Id, User_Id__c,  Enterprise_Id__c,  Public_Key__c,  Private_Key__c, Client_Id__c,  Client_Secret__c 
                                       from Box_App_Detail__mdt];
            String userId = bad.User_Id__c;
            String enterpriseId = bad.Enterprise_Id__c;
            String publicKeyId = bad.Public_Key__c;
            String privateKey = bad.Private_Key__c;
            String clientId = bad.Client_Id__c;
            String clientSecret = bad.Client_Secret__c;
            
            BoxJwtEncryptionPreferences.EncryptionAlgorithm algorithm = BoxJwtEncryptionPreferences.EncryptionAlgorithm.RSA_SHA_256;
            
            box.Toolkit boxToolkit = new box.Toolkit();
            
            system.debug('ah::boxToolKit error: ' + boxToolkit.mostRecentError);
            
            BoxJwtEncryptionPreferences preferences = new BoxJwtEncryptionPreferences();
            preferences.setPublicKeyId(publicKeyId);
            preferences.setPrivateKey(privateKey);
            
            BoxPlatformApiConnection boxAPIConn = BoxPlatformApiConnection.getAppUserConnection(userId, clientId, clientSecret, preferences);            
            BoxFolder folder = new BoxFolder(boxAPIConn, strBoxFolderId);
            
            String strBoxFileId = '';
            for(Attachment element:lstAttachment){
                Attachment att = new Attachment();
				att.ParentId = toParentId;
				att.Body = element.Body;
				att.Name = element.Name;
				att.ContentType = element.ContentType;
				att.IsPrivate = false;                
                //if file does not exist, create one
                strBoxFileId = boxtoolkit.createFileFromAttachment(att, null, strBoxFolderId, null);
                system.Debug('ar new file created');
            }
            boxToolkit.commitChanges();
        }
        
    }
    
}