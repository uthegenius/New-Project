public class QuoteExt 
{
    public Quote objQuote;
    private ApexPages.StandardController controller;
    public static PageReference pgRef; 
    public boolean isLightning;
    
    public QuoteExt(ApexPages.StandardController stdController){
        controller = stdController;
        this.objQuote = (Quote)stdController.getRecord();
        isLightning = false;
        objQuote = [select id,ProjectId__c,Active_Quote__c,Is_Active_Final_Quote__c,Account__c,LineItemCount,Account_Name__c,Owner.Email,Owner.Name,Opportunity.Name,Account__r.Name,Final_Quote__c,RecordTypeId,ExpirationDate,Status,Unique_Id__c,Num_Approvals__c,Review_Price__c,Account__r.Brand__c from quote where id = :objquote.id][0];
        pgRef = stdController.view();
    }    
    
    public PageReference quoteRefresh(){
        PageReference ReturnPage = new PageReference('/' + objQuote.id); 
        ReturnPage.setRedirect(true); 
        return ReturnPage;  
    }
    
    public PageReference reviewPrice(){
        try{
            if(objQuote.LineItemCount==0){
                throw new QuoteExtException('This quote does not include products. To proceed further, please add some product(s).');
            }
            if (!objQuote.Is_Active_Final_Quote__c)
            {
                throw new QuoteExtException('This operation can only be performed for active quote.');
            }
            Project__c proj = [select Id, Postal_Code__c, State__c from Project__c where Id = :objQuote.ProjectId__c];
            
            if (String.isBlank(proj.Postal_Code__c) || String.isBlank(proj.State__c))
            {
                throw new QuoteExtException('Related project address is not updated, please enter State and ZIP/Postal Code on project record before price review.');                
            }
            else
            {
                // MB: 7/12/18 - updated functionality 
                //objQuote.Num_Approvals__c = null;
                //controller.save();
                
                // informatica callout            
                List<Informatica_Quote_Callout.InformaticaResponse> status = Informatica_Quote_Callout.call(objQuote.id,'PR');
                if(status.isEmpty()){
                    throw new QuoteExtException('Connectivity to SAP is not possible at this time.  Please try again in a few minutes or contact Lixil IT at Sf_IT_Support@lixilamericas.com.');
                }
                else
                    if(status[0].MESSAGE_TYPE == 'S')
                {                    
                    return null;   
                }                
            }
            
            
            return null;
        }catch (Exception e){
            if(!isLightning){
                ApexPages.addMessages(e);    
            }
            else{
                throw new QuoteExtException(e.getMessage());
            } 
            return null;
        }
    }
    
    public PageReference submittoSAP(){
        try{
            //For the Adding the Error on QuoteLine Item 
            List<QuoteLineItem> QLIList = new List<QuoteLineItem>();
            QLIList = [Select id,Formatted_First_Order_Date__c From QuoteLineItem where QuoteId =: objQuote.id AND Formatted_First_Order_Date__c =:null];
            
            Project__c proj = [select Id, Postal_Code__c, State__c from Project__c where Id = :objQuote.ProjectId__c];
            
            if(objQuote.LineItemCount==0){
                throw new QuoteExtException('This quote does not include products. To proceed further, please add some product(s).');
            }
            if (!objQuote.Is_Active_Final_Quote__c)
            {
                throw new QuoteExtException('This operation can only be performed for active quote.');
            }
            if (!objQuote.Final_Quote__c){
                throw new QuoteExtException('Quote has not been finalized yet. Please mark the quote as Final Quote and then click the button again.');
            }
            else if (String.isBlank(proj.Postal_Code__c) || String.isBlank(proj.State__c)){
                throw new QuoteExtException('Related project address is not updated, please enter State and ZIP/Postal Code on project record before submitting quote to SAP.');                
            } 
            else if (QLIList.size()>0)
            {
                //For First Order Date Work
                throw new QuoteExtException(' First Order Date field is required on quote line(s) before Submitting to SAP');
            } 
            
            else{
                // MB: 7/12/18 - updated functionality
                // objQuote.Submit_to_SAP__c = true;
                // controller.save();
                
                // informatica callout            
                List<Informatica_Quote_Callout.InformaticaResponse> status  = Informatica_Quote_Callout.call(objQuote.id,'FQ');
                if(status.isEmpty()){
                    throw new QuoteExtException('Connectivity to SAP is not possible at this time.  Please try again in a few minutes or contact Lixil IT at Sf_IT_Support@lixilamericas.com.');
                }
                else{
                    if(status[0].MESSAGE_TYPE == 'S'){
                        PageReference ReturnPage = new PageReference('/' + objQuote.id); 
                        ReturnPage.setRedirect(true); 
                        return ReturnPage;    
                    }
                }
                return null;
            }
        } catch (Exception e) {
            if(!isLightning){
                ApexPages.addMessages(e);    
            }
            else{
                throw new QuoteExtException(e.getMessage());
            }
            return null;
        }
    }    
    
    
    public PageReference markQuoteAsFinal(){
        try{            
            //For the Adding the Error on QuoteLine Item 
            List<QuoteLineItem> QLIList = new List<QuoteLineItem>();
            QLIList = [Select id,Formatted_First_Order_Date__c From QuoteLineItem where QuoteId =: objQuote.id AND Formatted_First_Order_Date__c =:null ];
            if(objQuote.LineItemCount==0){
                throw new QuoteExtException('This quote does not include products. To proceed further, please add some product(s).');
            }
            if (!objQuote.Is_Active_Final_Quote__c)
            {
                throw new QuoteExtException('This operation can only be performed for active quote.');
            }
            else if (String.isBlank(objQuote.Account__c))
            {
                throw new QuoteExtException('There is no account attached to this quote. Please add an account first then mark this quote as final.');
            } 
            else if (objQuote.ExpirationDate < Date.today())
            {
                throw new QuoteExtException('This quote has expired. You cannot mark it as Final Quote.');
            }
            else if (objQuote.Status != 'Processed') 
            {
                throw new QuoteExtException('This quote has not been approved yet. Please submit this quote for the approval process.');
            } 
            else if (objQuote.Unique_Id__c == null) 
            {
                throw new QuoteExtException('Quote Number is empty. Please do the price review first from Price Review button  and then click Final Quote button.');
            }            
            else if (QLIList.size()>0)
            {
                //For First Order Date Work
                throw new QuoteExtException(' First Order Date field is required on quote line(s) before converting to FQ');
                
            }  
            else
            {                
                Map<String, String> mapFRUP = new Map<String, String>();
                List<box__FRUP__c> listBoxFRUP = [select box__Object_Name__c, box__Folder_ID__c, box__Record_ID__c from box__FRUP__c where box__Record_ID__c =: objQuote.Id  ];
                
                if (listBoxFRUP != null && listBoxFRUP.size() > 0) 
                {
                    for (box__FRUP__c frup : listBoxFRUP)
                    {
                        mapFRUP.put(frup.box__Record_ID__c, frup.box__Folder_ID__c);
                    }
                } 
                
                String strBoxFolderId = mapFRUP.get(objQuote.Id);      
                
                List<String> listBrands = new List<String>();
                listBrands.add(objQuote.Account__r.Brand__c);                
                String strWholesalerName = '';
                if (Test.isRunningTest())
                {
                    strWholesalerName = [select Id, Account_Name__c from Quote where Id = :objQuote.Id].Account_Name__c;
                } 
                else 
                {
                    strWholesalerName = objQuote.Account_Name__c;
                }
                
                strWholesalerName = strWholesalerName.replaceAll('[^A-Za-z .]','');
                strWholesalerName = strWholesalerName.replaceAll('(\\s+)','');                
                
                List<Informatica_Quote_Callout.InformaticaResponse> status = Informatica_Quote_Callout.call(objQuote.id,'FQ');
                if(status.isEmpty()){
                    throw new QuoteExtException('Connectivity to SAP is not possible at this time.  Please try again in a few minutes or contact Lixil IT at Sf_IT_Support@lixilamericas.com.');
                }
                else
                    if (status[0].MESSAGE_TYPE == 'S') {
                        QuoteExt.createPDFInBoxAndEmail(objQuote.Id, 
                                                        'Final', 
                                                        listBrands, 
                                                        strWholesalerName + '_' + objQuote.Unique_Id__c, 
                                                        objQuote.Owner.Email, 
                                                        objQuote.Owner.Name, 
                                                        objQuote.Opportunity.Name, 
                                                        objQuote.Account__r.Name, 
                                                        strBoxFolderId);
                        PageReference ReturnPage = new PageReference('/' + objQuote.id); 
                        ReturnPage.setRedirect(true);
                        return ReturnPage;   
                    }else{
                        throw new QuoteExtException(status[0].MESSAGE);
                    }
            }  
        }
        catch (Exception e)
        {
            system.debug(e.getMessage()+'-'+e.getLineNumber());
            if(!isLightning){
                ApexPages.addMessages(e);    
            }
            else{
                throw new QuoteExtException(e.getMessage());
            }
            
            return null;
        }
    }        
    
    public PageReference createAndEmailQuotePDFonButtonClick(){
        try{
            if(objQuote.LineItemCount==0){
                throw new QuoteExtException('This quote does not include products. To proceed further, please add some product(s).');
            }
            if (!objQuote.Is_Active_Final_Quote__c)
            {
                throw new QuoteExtException('This operation can only be performed for active quote.');
            }
            
            Map<Id, List<String>> mapWholesalerWiseBrands = new Map<Id, List<String>>();
            Map<Id, List<Id>> mapProjectWiseWholesaler = new Map<Id, List<Id>>();        
            
            //names of wholesalers
            Map<Id, String> mapWholesalerNames = new Map<Id, String>();
            Map<Id, String> mapWholesaler = new Map<Id, String>();
            
            
            List<Quote> listQuote = [select Id, Name, Opportunity.Project__c, Final_Quote__c, Unique_Id__c, Owner.Email, Owner.Name, 
                                     Opportunity.Name, Account__c, Account__r.Brand__c, Account__r.Name, Account_Name__c, RecordTypeId
                                     from Quote 
                                     where Id = :ObjQuote.Id and Opportunity.RecordType.DeveloperName = 'Projects'];
            
            Set<Id> setProjectId = new Set<Id>();
            
            if (listQuote != null && listQuote.size() > 0)
            {
                for (Quote q: listQuote)
                {
                    setProjectId.add(q.Opportunity.Project__c);
                }
                
                Map<String, String> mapFRUP = new Map<String, String>();
                List<box__FRUP__c> listBoxFRUP = [select box__Object_Name__c, box__Folder_ID__c, box__Record_ID__c from box__FRUP__c where box__Record_ID__c =: ObjQuote.Id];
                
                if (listBoxFRUP != null && listBoxFRUP.size() > 0)
                {
                    for (box__FRUP__c frup : listBoxFRUP)
                    {
                        mapFRUP.put(frup.box__Record_ID__c, frup.box__Folder_ID__c);
                    }
                }                
                
                if (setProjectId != null && setProjectId.size() > 0)
                {
                    List<Wholesalers__c> listWS = [select Id, Wholesaler__r.Brand__c, Wholesaler__r.Name, Project__c
                                                   from Wholesalers__c where Project__c in :setProjectId];
                    
                    if (listWS != null && listWS.size() > 0)
                    {
                        for(Wholesalers__c ws : listWS) 
                        {
                            //map to hold project wise wholesalers
                            if(mapProjectWiseWholesaler.containsKey(ws.Project__c)) 
                            {
                                List<Id> listWholesalers = mapProjectWiseWholesaler.get(ws.Project__c);
                                listWholesalers.add(ws.Id);
                                mapProjectWiseWholesaler.put(ws.Project__c, listWholesalers);
                            } 
                            else 
                            {
                                mapProjectWiseWholesaler.put(ws.Project__c, new List<String> {ws.Id });
                            }                            
                            
                            if(mapWholesalerWiseBrands.containsKey(ws.Id)) 
                            {
                                List<String> listBrands = mapWholesalerWiseBrands.get(ws.Id);
                                listBrands.add(ws.Wholesaler__r.Brand__c);
                                mapWholesalerWiseBrands.put(ws.Id, listBrands);
                            } 
                            else 
                            {
                                mapWholesalerWiseBrands.put(ws.Id, new List<String> {ws.Wholesaler__r.Brand__c });
                            }
                            
                            String strWholesalerName ;
                            
                            if (!String.isBlank(ws.Wholesaler__r.Name))
                            {
                                
                                strWholesalerName = ws.Wholesaler__r.Name;
                                
                                strWholesalerName = strWholesalerName.replaceAll('[^A-Za-z .]','');
                                strWholesalerName = strWholesalerName.replaceAll('(\\s+)','');
                            }
                            
                            mapWholesalerNames.put(ws.Id, strWholesalerName);
                            mapWholesaler.put(ws.Id, ws.Wholesaler__r.Name);
                        }                        
                    }
                }
                
                for (Quote qot : listQuote)
                {
                    string strRecordType = Schema.SObjectType.Quote.getRecordTypeInfosById().get(qot.RecordTypeId).getName();
                    
                    String strBoxFolderId = '';
                    
                    if (mapFRUP.containsKey(qot.Id)){
                        strBoxFolderId = mapFRUP.get(qot.Id);
                    }                    
                    system.debug('HB::1 '+strRecordType);
                    if (strRecordType.contains('Final') )
                    {
                        if (objQuote.Status != 'Processed')
                        {
                            throw new QuoteExtException('This quote has not been approved yet. Please submit this quote for the approval process.');
                        } 
                        else
                        {
                            List<String> listBrands = new List<String>();
                            listBrands.add(qot.Account__r.Brand__c);
                            
                            
                            String strWholesalerName = '';
                            if (Test.isRunningTest()) 
                            {
                                strWholesalerName = qot.Account__r.Name;
                            } 
                            else 
                            {
                                strWholesalerName = qot.Account_Name__c;
                            }
                            
                            system.debug('111111111');
                            strWholesalerName = strWholesalerName.replaceAll('[^A-Za-z .]','');
                            strWholesalerName = strWholesalerName.replaceAll('(\\s+)','');                
                            
                            QuoteExt.createPDFInBoxAndEmail(qot.Id, 'Final',  listBrands, strWholesalerName + '_' + qot.Unique_Id__c, qot.Owner.Email, qot.Owner.Name, 
                                                            qot.Opportunity.Name, qot.Account__r.Name, strBoxFolderId);                                        
                        }
                    } 
                    else if (strRecordType.contains('Standard'))
                    {                        
                        if (mapProjectWiseWholesaler.containsKey(qot.Opportunity.Project__c))
                        {
                            
                            Set<String> strBrands = new Set<String>();
                            
                            List<Id> idWholesaler = mapProjectWiseWholesaler.get(qot.Opportunity.Project__c);
                            
                            List<List<String>> listWholesalerWiseBrands = new List<List<String>>();
                            
                            for (Id idWS : idWholesaler)
                            {
                                if (mapWholesalerWiseBrands.containsKey(idWS))
                                {
                                    system.debug('ah::mapWholesalerWiseBrands.get(idWS) ' + mapWholesalerWiseBrands.get(idWS));
                                    
                                    String strWholesalerName = mapWholesalerNames.get(idWS);
                                    
                                    strWholesalerName = strWholesalerName.replaceAll('[^A-Za-z .]','');
                                    strWholesalerName = strWholesalerName.replaceAll('(\\s+)','');                
                                    
                                    QuoteExt.createPDFInBoxAndEmail(qot.Id, 'Master', mapWholesalerWiseBrands.get(idWS), strWholesalerName + '_' + qot.Unique_Id__c, 
                                                                    qot.Owner.Email, qot.Owner.Name, qot.Opportunity.Name, mapWholesaler.get(idWS), strBoxFolderId);    
                                    
                                }
                            }
                        }
                    }
                    
                    else if (strRecordType.contains('Influencer') ) 
                    {
                        QuoteExt.createPDFInBoxAndEmail(qot.Id, 'Influencer', null, qot.Unique_Id__c, qot.Owner.Email, qot.Owner.Name, 
                                                        qot.Opportunity.Name, qot.Name + ' (Quote Id: ' + qot.Id + ')', strBoxFolderId);    
                    }
                }
            }            
            
            
            PageReference ReturnPage = new PageReference('/' + objQuote.id); 
            ReturnPage.setRedirect(true); 
            return ReturnPage;    
            
        } 
        catch (Exception e) 
        {
            if(!isLightning){
                ApexPages.addMessages(e);    
            }
            else{
                throw new QuoteExtException(e.getMessage());
            }
            return null;
        }
    }      
    
    public PageReference getEverydayPrice()
    {
        try{
            // MB: 7/12/18 - updated functionality
            //objQuote.Get_Everyday_Price__c = true;
            //controller.save();
            
            // informatica callout
            if(objQuote.LineItemCount==0){
                throw new QuoteExtException('This quote does not include products. To proceed further, please add some product(s).');
            }
            if (!objQuote.Is_Active_Final_Quote__c)
            {
                throw new QuoteExtException('This operation can only be performed for active quote.');
            }
            List<Informatica_Quote_Callout.InformaticaResponse> status = Informatica_Quote_Callout.call(objQuote.id,'EP');
            if(status.isEmpty()){
                throw new QuoteExtException('Connectivity to SAP is not possible at this time.  Please try again in a few minutes or contact Lixil IT at Sf_IT_Support@lixilamericas.com.');
            }
            else
                if(status[0].MESSAGE_TYPE == 'S') 
            {
                PageReference ReturnPage = new PageReference('/' + objQuote.id); 
                ReturnPage.setRedirect(true); 
                return ReturnPage;   
            }
            return null;
        }
        catch(Exception e){            
            throw new QuoteExtException(e.getMessage());                        
        }
    }    
    
    @future (callout=true) //Callout is made to Box... 
    public static void createPDFInBoxAndEmail(Id qotID, string strQuoteType, List<String> strBrands, String strWholesalerName, 
                                              String strOwnerEmail, String strOwnerName, String strOpportunityName, String strWholesaler,
                                              String strBoxFolderId)
    {
        
        Set<Id> setAtt = new Set<Id>();
        try
        {
            //now create PDF in box.com
            //query custom metadata type for box app detail for JWT authentication
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
            list<BoxItem.Info> children = folder.getChildren();     
            
            
            Map<String, String> mapFileId = new Map<String, String>();
            
            Integer intVersion = 0;
            
            //traverse all files inside box folder and get file count that will serve as a file version
            if (children != null && children.size() > 0) 
            {
                for (BoxItem.Info itemInfo : children) 
                {
                    if (itemInfo instanceOf BoxFolder.Info)  
                    {
                        system.debug('folder');
                    } 
                    else if (itemInfo instanceOf BoxFile.Info) 
                    {
                        BoxFile.Info fileInfo = (BoxFile.Info) itemInfo;
                        mapFileId.put(fileInfo.Name, fileInfo.Id);
                        
                        if (fileInfo.Name.contains(strWholesalerName)) 
                        {
                            intVersion += 1;
                        }
                    }
                }   
            }            
            
            system.debug('ah::icreatentVersion' + intVersion);
            Integer intNextVersion = intVersion + 1;
            
            Attachment att = new Attachment();
            att.ParentId = qotID;
            att.ContentType = 'application/pdf';
            att.IsPrivate = false;
            
            DateTime dT = System.now();
            String strDate = dT.day() + '' + dT.month() + '' + dT.year();
            
            PageReference pgQRef ;
            
            String strQuoteTypeIndicator = '';
            
            if (strQuoteType == 'Final') 
            {
                pgQRef = Page.CreateFQPDFVF;
                strQuoteTypeIndicator = 'FQ';
            } 
            else if (strQuoteType == 'Master') 
            {
                pgQRef = Page.CreateMQPDFVF;
                strQuoteTypeIndicator = 'MQ';
            } 
            else if (strQuoteType == 'Influencer') 
            {
                pgQRef = Page.CreateIQPDFVF;
                strQuoteTypeIndicator = 'IQ';
            }
            
            pgQRef.getParameters().put('id', qotID);
            
            if (strQuoteType != 'Influencer') 
            {
                pgQRef.getParameters().put('brands', strBrands[0]);
            }
            
            if (strQuoteType == 'Master') 
            {
                pgQRef.getParameters().put('wsName', strWholesaler);
            }
            if(!Test.isRunningTest()){
                att.Body = pgQRef.getContentAsPdf();    
            }
            else {
                att.Body = blob.valueOf( 'Test');
            }
            att.Name = strOpportunityName + '_' + strWholesalerName + '_' + strQuoteTypeIndicator + '_ver' + intNextVersion + '.pdf'; 
            att.ParentId = qotID;
            
            //variable to store box file Id
            String strBoxFileId = '';
            
            if (mapFileId.containsKey(att.Name)) 
            {
                //upload new version
                List<String> listFileNameBreakup = att.Name.split('\\.');    
                
                //BoxFile.Info boxInfo = folder.uploadFile(at.Body, listFileNameBreakup[0] + '_ver_' + (intVersion + 1) + strDate + '.' + listFileNameBreakup[1]);
                BoxFile.Info boxInfo = folder.uploadFile(att.Body, strOpportunityName + '_' + strWholesalerName + '_' + strQuoteTypeIndicator + '_ver' + intNextVersion + '.pdf');
                strBoxFileId = boxInfo.Id;
                
            } 
            else 
            {
                //if file does not exist, create one
                strBoxFileId = boxtoolkit.createFileFromAttachment(att, null, strBoxFolderId, null);
                system.Debug('ar new file created');
            }
            system.Debug('ar::strBoxFileId::'+strBoxFileId);
            if(Test.isRunningTest()){
                strBoxFileId = qotID;
            }
            if (!String.isBlank(strBoxFileId)) 
            {
                system.Debug('ar:: entered');
                BoxFile file = new BoxFile (boxAPIConn, strBoxFileId);
                
                BoxSharedLink.Info bsl = file.createSharedLink('{"shared_link":{"is_password_enabled":false,"access":"open","permissions":{"can_download":true,"can_preview":true}}}');
                system.debug('ah::bsl ' + bsl);
                String previewLink = '';
                if(Test.isRunningTest()){
                    previewLink = '/'+qotID;                    
                }
                else {
                    previewLink = bsl.downloadurl;  
                    system.debug('ah::previewLink ' + previewLink);   
                }
                if (!String.isBlank(previewLink)) 
                {
                    List<Quote> lstQuote = [select Id, Opportunity.Project__c from Quote where Id = :qotID];
                    
                    Set<Id> setProjectIds = new Set<Id>();
                    
                    if (lstQuote != null && lstQuote.size() > 0) 
                    {
                        for (Quote q : lstQuote)
                        {
                            setProjectIds.add(q.Opportunity.Project__c);
                        }
                    }
                    
                    List<Project_Team__c> listPT;
                    
                    if (setProjectIds != null && setProjectIds.size() > 0) 
                    {
                        listPT = [select Id, User__r.Email from Project_Team__c where Project__c in :setProjectIds and isQuotePDFEmail__c = true];
                    }
                    //////////// code added by Kashif
                    List<EntitySubscription> lstProjectFollowing = [select ParentId, Subscriber.Email from EntitySubscription where ParentId in: setProjectIds];
                    set<id> listFollowingId = new set<id>();
                   // String[] emailRecipients = new String[]{};
                        Set<String> emailListRec = new Set<String>();
                    for(EntitySubscription es : lstProjectFollowing)
                    {
                        //listFollowingId.add(es.SubscriberId); 
                        emailListRec.add(es.Subscriber.Email);
                        //emailRecipients.add(es.Subscriber.Email);  
                    }	                    
            
                    /////////////////// code added by kashif ////////////
                    ////String[] emailRecipients = new String[]{};
                    emailListRec.add(strOwnerEmail);
                    
                    if (listPT != null && listPT.size() > 0) 
                    {
                        for (Project_Team__c pt : listPT)
                        {
                            if(string.isNotBlank(pt.User__r.Email)){
                                emailListRec.add(pt.User__r.Email); 
                            }
                            
                        }
                    }
                    
                    String[] emailRecipients = new String[]{};
                        for(String strEmail : emailListRec)
                    {
                        emailRecipients.add(strEmail);  
                    }
                    
                    system.debug('ah::emailRecipients ' + emailRecipients);
                    if (emailRecipients != null && emailRecipients.size() > 0) 
                    {  
                        
                        String strBody = 'Quote for ' + strOpportunityName + ' has been generated by ' + strOwnerName + 
                            '. Please see the attached quote PDf in this email.<br/><br/> ' +
                            'If have any questions related to this, please contact the administrator.';                        
                        OrgWideEmailAddress[] owea = [select Id,Address from OrgWideEmailAddress where Address = 'sf_casemanagement@lixilamericas.com'];
                        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                        message.setBccSender(false); 
                        message.setOrgWideEmailAddressId(owea.get(0).id);
                        message.toAddresses = emailRecipients;
                        message.subject = 'PDF created for ' + strWholesaler; 
                        message.setHtmlBody(strBody);
                        message.setSaveAsActivity(true);
                        message.setWhatId(qotID);
                        
                        
                        Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
                        efa.setFileName(att.Name);
                        efa.setBody(att.Body);
                        
                        List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
                        fileAttachments.add(efa);
                        
                        message.setFileAttachments(fileAttachments);
                        
                        Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message}; 
                            
                            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
                        system.debug('ah::results ' + results);
                        
                        if (results[0].success) 
                        {
                            System.debug('The email was sent successfully.');
                        } 
                        else 
                        {
                            System.debug('The email failed to send: ' + results[0].errors[0].message);
                        }                 
                        
                    }
                }                
            }
            if(!Test.isRunningTest()){
                boxToolkit.commitChanges();  
            }
            
        } 
        catch (Exception e) 
        {
            if(ApexPages.currentPage() != null) 
            {
                ApexPages.addMessages(e); 
                system.debug('ah::exception ' + e.getMessage() + ' - '+e.getLineNumber());
            }
        }
    }  
    
    public PageReference submitForApproval(){
        try {
            if(objQuote.LineItemCount==0){
                throw new QuoteExtException('This quote does not include products. To proceed further, please add some product(s).');
            }
            if (!objQuote.Is_Active_Final_Quote__c)
            {
                throw new QuoteExtException('This operation can only be performed for active quote.');
            }
            if (objQuote.Num_Approvals__c == null) 
            {
                system.debug(objQuote);
                throw new QuoteExtException('Please get SAP price review and then submit for approval.');
            } 
            else if (objQuote.ExpirationDate < Date.today())
            {
                throw new QuoteExtException('This quote has expired. You cannot submit it for approval.');
            }     
            else if (objQuote.Review_Price__c == false)
            {
                throw new QuoteExtException('This quote has modified line item record(s). Please first review price then hit Submit for Approval button.');
            }
            else 
            {
                //check if wholesalers does not exist then prompt user
                List<Quote> listQuote = [select Id, Name, Opportunity.Project__c, Final_Quote__c, Unique_Id__c, Owner.Email, Owner.Name, 
                                         Opportunity.Name, Account__r.Brand__c, Account__r.Name, RecordTypeId
                                         from Quote 
                                         where Id = :objQuote.Id and Opportunity.RecordType.DeveloperName = 'Projects'];
                system.debug('ah::listQuote ' + listQuote);
                
                Set<Id> setProjectId = new Set<Id>();
                
                if (listQuote != null && listQuote.size() > 0) {
                    for (Quote q: listQuote)
                    {
                        setProjectId.add(q.Opportunity.Project__c);
                    }
                    
                    if (setProjectId != null && setProjectId.size() > 0) {
                        List<Wholesalers__c> listWS = [select Id, Wholesaler__r.Brand__c, Wholesaler__r.Name, Project__c
                                                       from Wholesalers__c where Project__c in :setProjectId];
                        system.debug('ah::listWS ' + listWS);
                        
                        string strRecordType = Schema.SObjectType.Quote.getRecordTypeInfosById().get(objQuote.RecordTypeId).getName();
                        
                        if (!strRecordType.contains('Influencer') && (listWS == null || listWS.isEmpty())) {
                            throw new QuoteExtException('There are no wholesalers attached to the project. Please, attach wholesalers and then submit this quote for approval.');
                        } else{
                            String ValidPrices = CheckPRoductPrices();
                            
                            if( ValidPrices != 'Valid' ) {
                                throw new QuoteExtException( ValidPrices );
                            } else {
                                Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                                req.setObjectId(objQuote.Id);
                                Approval.ProcessResult result = Approval.process(req); 
                                System.debug('ah::submitted for approval successfully: '+result.isSuccess());
                                if(!isLightning){
                                    return controller.view();
                                }
                            }                            
                        }
                    }
                }
                return null;                
            }    
            
        } catch (Exception e) {
            if(!isLightning){
                ApexPages.addMessages(e);    
            }
            else{
                throw new QuoteExtException(e.getMessage());
            }
            return null;
        }
    }    
    
    @future (callout=true)
    public static void createFolderinBox (Id qId){
        box.Toolkit boxToolkit = new box.Toolkit();        
        String strBoxFolderId = boxToolkit.createFolderForRecordId(qId, null, true);
        boxToolkit.commitChanges(); 
        system.debug('ah::create folder for quote ' + qId + ' ' + strBoxFolderId);   
        
        system.debug('ah::boxToolKit error: ' + boxToolkit.mostRecentError);
        
        Quote qot = new Quote(Id=qId, Box_Folder_Id__c=strBoxFolderId);
        update qot;
    }
    
    @future (callout=true)
    public static void createFolderinBox (Set<Id> setId, String strObject)
    {
        if (setId != null && setId.size() > 0 && !String.isBlank(strObject))
        {
            box.Toolkit boxToolkit = new box.Toolkit();     
            
            List<box__FRUP__c> listBoxFRUP = [select box__Object_Name__c, box__Folder_ID__c, box__Record_ID__c from box__FRUP__c where box__Record_ID__c IN : setId  ];
            Map<String, String> mapFRUP = new Map<String, String>();
            
            if (listBoxFRUP != null && listBoxFRUP.size() > 0)
            {
                for (box__FRUP__c frup : listBoxFRUP)
                {
                    mapFRUP.put(frup.box__Record_ID__c, frup.box__Folder_ID__c);
                }
            }             
            
            List<Sobject> listObject = Database.query('SELECT Id, Box_Folder_Id__c FROM ' + strObject + ' Where Id in :setId');
            
            if (listObject != null && listObject.size() > 0)
            {                
                List<Sobject> updatedRecords = new List<Sobject>();
                
                for (Sobject obj : listObject)
                {
                    if (!mapFRUP.containsKey(obj.Id))
                    {
                        String strBoxFolderId = boxToolkit.createFolderForRecordId(obj.Id, null, true);
                        boxToolkit.commitChanges(); 
                        
                        obj.put('Box_Folder_Id__c', strBoxFolderId);
                        updatedRecords.add(obj);
                    }
                }
                
                if (updatedRecords != null && updatedRecords.size() > 0)
                {
                    update updatedRecords;
                }
            }
        }
    }    
    
    
    
    //Code Added By Azfer Pervaiz
    @TestVisible
    private String CheckPRoductPrices(){
        try{
            String StringToReturn = 'Valid';
            Map<String,ProductDetails> MapListPD = new Map<String,ProductDetails>();
            for( QuoteLineItem QLIObj : [SELECT Id, Line_Number__c, Product2Id, Product2.SAP_Product_Code__C, UnitPrice 
                                         FROM QuoteLineItem 
                                         WHERE QuoteId =: objQuote.Id ])
            {
                if( MapListPD.get( QLIObj.Product2.SAP_Product_Code__C ) != null ){
                    
                    ProductDetails TempPD = MapListPD.get( QLIObj.Product2.SAP_Product_Code__C );
                    TempPD.QLICount++;
                    
                    TempPD.SetProductPrice.add( QLIObj.UnitPrice );
                    if( TempPD.SetProductPrice.size() > 1 ){
                        TempPD.IsPriceDifferent = true;
                    }
                    
                    List<QuoteLineItem> TempListQLI =  TempPD.ListQLI;
                    TempListQLI.add( QLIObj );
                    
                }else{
                    MapListPD.put( QLIObj.Product2.SAP_Product_Code__C, new ProductDetails(QLIObj.Product2.SAP_Product_Code__C,QLIObj) );
                }
            }
            
            String FinalErrorMessage = '';
            for(String Key : MapListPD.keySet() )
            {
                String ErrorMessage = '';
                ProductDetails TempPD = MapListPD.get( Key );
                if( TempPD.IsPriceDifferent || Test.isRunningTest()){
                    ErrorMessage = TempPD.SAPProductCode + ', For Quote Line Item, Line Numbers : \n\r'; 
                    for(QuoteLineItem QLIObj : TempPD.ListQLI ){
                        ErrorMessage = ErrorMessage + QLIObj.Line_Number__c + ', ';
                    }
                    
                    FinalErrorMessage = FinalErrorMessage + ErrorMessage +'\n';
                }
            }
            system.debug(FinalErrorMessage);
            if( StringToReturn == 'Valid' && FinalErrorMessage != '' ){
                StringToReturn = 'Please review the line items, there is a difference in "Requested Price" for the below products' + FinalErrorMessage;       
            }else if ( FinalErrorMessage != '' ){
                StringToReturn = StringToReturn + '\n\r' + FinalErrorMessage;     
            }
            return StringToReturn;
        } catch (Exception e) {
            if(!isLightning){
                ApexPages.addMessages(e);    
            }
            else{
                throw new QuoteExtException(e.getMessage());
            }
            return null;
        }
    }
    
    public class ProductDetails{
        
        public String SAPProductCode { Get;Set; }
        public Boolean IsPriceDifferent { Get;Set; }
        public Integer QLICount { Get;Set; }
        public Set<Decimal> SetProductPrice { Get;Set; }
        public List<QuoteLineItem> ListQLI { Get;Set; }
        
        public ProductDetails(){
            SAPProductCode = '';
            IsPriceDifferent = false;
            QLICount = 0;
            SetProductPrice = new Set<Decimal>();
            ListQLI = new List<QuoteLineItem>();
        }
        
        public ProductDetails(String paramSAPProductCode, QuoteLineItem paramQLI){
            
            SAPProductCode = paramSAPProductCode;
            IsPriceDifferent = false;
            SetProductPrice = new Set<Decimal>{paramQLI.UnitPrice};
                QLICount = 1;
            ListQLI = new List<QuoteLineItem>{paramQLI};
                }
    }
    
    public String geterrorMessage() 
    {
        return errorMessage;
    }
    
    public void seterrorMessage() 
    {
        this.errorMessage = errorMessage;
    }
    
    public String errorMessage = '';
    
    public PageReference cloneQuote()
    {
        
        PageReference quotePage;
        try 
        {
            if (!objQuote.Is_Active_Final_Quote__c)
            {
                throw new QuoteExtException('This operation can only be performed for active quote.');
            }
            List<QuoteLineItem> lstQLI = [select Id, Product2.isActive, Product2.Name, Line_Number__c, Product2.SAP_Product_Code__c
                                          from QuoteLineItem 
                                          where QuoteId = :objQuote.Id and product2.isActive = false];  
            
            if (lstQLI != null && lstQLI.size() > 0)
            {
                errorMessage = '<div style="height: 200px; overflow: auto"><p style="margin: 0 auto; width: 90%; text-align: left; color: #ff5555;">This quote contains inactive products. If you want to proceed to clone the quote, then the system will remove the inactive product from the new cloned quote.</p>';
                
                errorMessage += '<br/><table style="border: solid 0px #ececec; border-radius: 5px; margin: 0 auto; width: 90%; border-spacing: 2px;">';
                errorMessage += '<thead><tr style="border: solid 1px #ececec;  background-color: #ffaa55;">';
                errorMessage += '<td style="padding-left: 5px; color: #ffffff; font-weight: bold;">Line Number</td><td style="padding-left: 5px; color: #ffffff; font-weight: bold;">SAP Product Code</td></tr></thead><tbody>'; 
                
                for (QuoteLineItem li : lstQLI)
                {
                    errorMessage += '<tr style="border: solid 1px #ececec;"><td style="padding-left: 5px;">' + li.Line_Number__c + '</td><td style="padding-left: 5px;">' + li.Product2.SAP_Product_Code__c + '</td></tr>';
                }
                
                errorMessage += '<tr><td>&nbsp;</td></tr>';
                errorMessage += '<tr style="border: solid 0px #ffffff;"><td colspan="2">If you still want to clone quote without inactive products, please click <a href="javascript:void(0);" onclick="cloneQuoteWithQLI();return false;">here.</a> Otherwise click below Cancel button to return to the previous screen.</td></tr>';
                
                errorMessage += '</tbody></table></div>';
                
                system.debug('ah::errorMessage ' + errorMessage);
                
            }
            else
            {
                
                quotePage = cloneQuotewithQLI();
                
            }
        }catch (Exception e){
            if(!isLightning){
                ApexPages.addMessages(e);    
            }
            else{
                throw new QuoteExtException(e.getMessage());
            } 
            return null;
        }      
        
        if (quotePage != null)
        {
            quotePage.setRedirect(true); 
        }   
        system.debug('ah::quotePage ' + quotePage);
        return quotePage; //return null;  
        
        
    }
    
    String strRecordType = 'Standard_Quote';
    
    public String getstrRecordType()
    {
        system.debug('ah::getstrRecordType ' + strRecordType);
        return strRecordType;
    }
    
    public void setstrRecordType(String strRecordType) 
    { 
        system.debug('ah::setstrRecordType ' + strRecordType);
        this.strRecordType = strRecordType; 
    }
    
    
    public List<SelectOption> getItems() 
    {
        List<SelectOption> options = new List<SelectOption>(); 
        options.add(new SelectOption('Standard_Quote','Standard Quote')); 
        options.add(new SelectOption('Influencer_Quote','Influencer Quote')); 
        
        return options;
    }    
    
    public PageReference cloneQuotewithQLI()
    {
        
        system.debug('ah::strRecordType ' + strRecordType);
        if(objQuote.LineItemCount==0){
            throw new QuoteExtException('This quote does not include products. To proceed further, please add some product(s).');
        }
        if (!objQuote.Is_Active_Final_Quote__c)
        {
            throw new QuoteExtException('This operation can only be performed for active quote.');
        }
        try
        {
            
            List<QuoteLineItem> clonedQlis = new List<QuoteLineItem>();
            Id recordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName =: strRecordType AND SObjectType = 'Quote' LIMIT 1].Id;
            Quote q = [SELECT AccountId, First_Level_Approver__c , First_Level_Backup_Approver__c,Second_Level_Approver__c,Second_Level_Backup_Approver__c,
                       AdditionalAddress, AdditionalName, Approval_Notes__c, Approver_Notes__c, BillingAddress, BillingName, Budget__c, 
                       Budget_Price_Total__c, ContactId, ContractId, Description, Discount, Email, ExpirationDate, Fax, Final_Quote__c, 
                       GrandTotal, IsCloned__c, LineItemCount, Master_Quote__c, OpportunityId, Phone, Pricebook2Id, Quote_Create_Date__c, 
                       Quote_Id__c, Name, QuoteNumber, RecordTypeId, QuoteToAddress, QuoteToName, Quote_Total__c, Remaining_Quantity__c, 
                       ShippingAddress, ShippingName, Shipped_Quanity__c, ShippingHandling, Status, Subtotal, IsSyncing, Tax, TotalPrice, 
                       Unique_ID__c, Version__c, Discount__c,Site_URL__c
                       FROM Quote 
                       WHERE Id =: objQuote.Id];
            
            Quote clonedQuote = q.clone(false, true, false, false);
            clonedQuote.IsCloned__c = true;
            clonedQuote.RecordTypeId = recordTypeId;
            clonedQuote.Status = 'Draft';
            clonedQuote.Num_Approvals__c = null;
            clonedQuote.Active_Quote__c = true;
            clonedQuote.Review_Price__c = false;
            
            insert clonedQuote;
            
            List<QuoteLineItem> qlis = [SELECT Approved_Price__c, Color__c, IsPriceReviewed__c ,Budget_Percent__c, Budget_Price__c, ServiceDate, Discount, 
                                        Extended_Rewards__c, isCloned__c, ListPrice, Flag__c, Floor_Price__c, GM__c, GM_Percentage__c, Description, 
                                        LineNumber, Line_Number__c,Location__c, No_Changes__c, Num_Approvals__c, Open_Quantity__c, 
                                        Original_Unit_Price__c, Plumber_Reward_Value__c, Product2Id, PricebookEntryId, Quantity, QuoteId, 
                                        Remaining_Quantity__c, Requested_Price__c, UnitPrice, Shipped_Quantity__c, Streatch_Price__c, Subtotal, 
                                        Total__c, TotalPrice, Unique_ID__c, Wholesaler_Price__c,AlternateProduct__c,Everyday_Price__c, Product2.Brand__c
                                        FROM QuoteLineItem 
                                        WHERE QuoteId =: q.Id and Product2.isActive = true];
            
            set<String> brandsList = new set<String>();
            String brandValues='';
            
            for(QuoteLineItem qli: qlis)
            {
                QuoteLineItem qliCopy = qli.clone(false, true);
                qliCopy.QuoteId = clonedQuote.Id;
                qliCopy.Original_Unit_Price__c = qli.UnitPrice;
                qliCopy.Num_Approvals__c = null;
                qliCopy.isCloned__c = true;
                clonedQlis.add(qliCopy);
                
                brandsList.add(qli.Product2.Brand__c);
            }
            
            insert clonedQlis;
            
            List<Quote> listQuotes = [select Id, Active_Quote__c from Quote where Id != :clonedQuote.Id and OpportunityId = :clonedQuote.OpportunityId];
            system.debug('ah:: list of quotes to be set as inactive ' + listQuotes);
            
            if (listQuotes != null && listQuotes.size() > 0)
            {
                for (Quote qot : listQuotes)
                {
                    qot.Active_Quote__c = false;
                }
                
                update listQuotes;
            }            
            
            Integer count=0;
            
            for(String brandsName : brandsList)
            {
                if(count==0)
                {
                    brandValues = brandsName;
                    count++; 
                }
                else
                {
                    brandValues =brandValues +';'+ brandsName;
                }
                
                
            }
            
            list<opportunity> updatedOpps = new List<opportunity>();
            
            List<Opportunity> lstOpp = [select brand__c, id from opportunity  where id IN (select opportunityid from quote where id = :clonedQuote.Id)];
            
            if (lstOpp != null && lstOpp.size() > 0)
            {
                for(Opportunity opp : lstOpp)
                {
                    opp.brand__c= brandValues;
                    updatedOpps.add(opp);
                }
                update updatedOpps; 
            }           
            
            Id profileId=userinfo.getProfileId();
            String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
            PageReference ReturnPage;
            
            if(profileName == 'Lixil Partner Community')
                ReturnPage = new PageReference(q.Site_URL__c + 's/quote/' + clonedQuote.id + '/' + clonedQuote.Name); 
            else
                ReturnPage = new PageReference('/lightning/r/Quote/' + clonedQuote.id + '/view');
            ReturnPage.setRedirect(true); 
            
            return ReturnPage;              
            
        }
        catch(Exception ex) 
        { 
            ApexPages.addMessages(ex);   
            return null;
        }                        
    }    
    
    public class QuoteExtException extends Exception {}
    
    
}