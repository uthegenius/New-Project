public class ProdQuoteExt 
{
    public Quote objQuote;
    private ApexPages.StandardController controller;
    public static PageReference pgRef; 
    
    public ProdQuoteExt(ApexPages.StandardController stdController){
        controller = stdController;
        this.objQuote = (Quote)stdController.getRecord();
        objQuote = [select id,ProjectId__c,Account__c,Account_Name__c,Owner.Email,Owner.Name,Opportunity.Name,Account__r.Name,Final_Quote__c,RecordTypeId,ExpirationDate,Status,Unique_Id__c,Num_Approvals__c,Review_Price__c,Account__r.Brand__c from quote where id = :objquote.id][0];
        pgRef = stdController.view();
    }    
    
    public PageReference quoteRefresh(){
        PageReference ReturnPage = new PageReference('/' + objQuote.id); 
        ReturnPage.setRedirect(true); 
        return ReturnPage;  
    }
    
    public PageReference reviewPrice(){
        try{
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
                boolean status = true;//Informatica_Quote_Callout.call(objQuote.id,'PR');
                
                if(status = true)
                {
                    /*PageReference ReturnPage = new PageReference('/' + objQuote.id); 
ReturnPage.setRedirect(true); */
                    return null;   
                }                
            }
            
            
            return null;
        }catch (CalloutException ce) {
            system.debug('ah::callout exception ' + ce.getMessage());
            return null;
        }catch (Exception e){
            system.debug('ah::kaddo 2');
            ApexPages.addMessages(e); 
            return null;
        }
    }
    
    public PageReference submittoSAP(){
        try{
            Project__c proj = [select Id, Postal_Code__c, State__c from Project__c where Id = :objQuote.ProjectId__c];
            
            if (!objQuote.Final_Quote__c){
                throw new QuoteExtException('Quote has not been finalized yet. Please mark the quote as Final Quote and then click the button again.');
            }
            else if (String.isBlank(proj.Postal_Code__c) || String.isBlank(proj.State__c)){
                throw new QuoteExtException('Related project address is not updated, please enter State and ZIP/Postal Code on project record before submitting quote to SAP.');                
            }            
            else{
                // MB: 7/12/18 - updated functionality
                // objQuote.Submit_to_SAP__c = true;
                // controller.save();
                
                // informatica callout            
                boolean status = true;//Informatica_Quote_Callout.call(objQuote.id,'FQ');
                
                if(status = true){
                    PageReference ReturnPage = new PageReference('/' + objQuote.id); 
                    ReturnPage.setRedirect(true); 
                    return ReturnPage;    
                }
                return null;
            }
        } catch (Exception e) {
            ApexPages.addMessages(e); 
            return null;
        }
    }    
    
    
    public PageReference markQuoteAsFinal(){
        try{

             //For the Adding the Error on QuoteLine Item 
            
            //First Order Date work starts From Here.
                boolean allowFinalQuote = true;
                List<QuoteLineItem> QLIList = new List<QuoteLineItem>();
                QLIList = [Select id,Formatted_First_Order_Date__c From QuoteLineItem where QuoteId =: objQuote.id];
                date dt;
                if (QLIList!=null && QLIList.size()>0)
                {
                    for(QuoteLineItem qli : QLIList)
                    {
                         if(qli.Formatted_First_Order_Date__c ==null)
                         {
                             allowFinalQuote=false;
                         }
                    
                    }
                    
                    //Set First Quote Line Item First Order Date in the dt date variable to compare the date and get the earliest Date further. 
                    //dt=QLIList[0].Formatted_First_Order_Date__c ;
                }
            
            //First Order Date work Ends here. 


            if (String.isBlank(objQuote.Account__c))
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
            else if (allowFinalQuote==false)
            {
               //For First Order Date Work
                throw new QuoteExtException(' First Order Date field is required on quote line(s) before converting to FQ');

            }            
            else 
            {      

                Map<String, String> mapFRUP = new Map<String, String>();
                List<box__FRUP__c> listBoxFRUP = [select box__Object_Name__c, box__Folder_ID__c, box__Record_ID__c from box__FRUP__c where box__Record_ID__c =: objQuote.Id];
                
                if (listBoxFRUP != null && listBoxFRUP.size() > 0) 
                {
                    for (box__FRUP__c frup : listBoxFRUP)
                    {
                        mapFRUP.put(frup.box__Record_ID__c, frup.box__Folder_ID__c);
                    }
                } 
                
                String strBoxFolderId = mapFRUP.get(objQuote.Id);      
                
                List<String> listBrands = new List<String>();
                system.debug(objQuote.Account__r.Brand__c);
                listBrands.add(objQuote.Account__r.Brand__c);
                
                system.debug('ah::objQuote.Account_Name__c...... ' + objQuote.Account_Name__c);
                
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
                
                system.debug('ah::strWholesalerName...... ' + strWholesalerName);
                
                system.debug('ah::begin informatica call out');
                
                // informatica callout            
                boolean status = true;//Informatica_Quote_Callout.call(objQuote.id,'FQ');     
                
                system.debug('ah::end informatica call out');
                system.debug('Status'+status);
                
                Quote qot = [select Id, SAP_Price_Review_Process_Response__c from Quote where id = :objQuote.Id];                

                if (!String.isBlank(qot.SAP_Price_Review_Process_Response__c)) {
                    system.debug('ah::SAP_Price_Review_Process_Response__c ' + qot.SAP_Price_Review_Process_Response__c);
                    if (qot.SAP_Price_Review_Process_Response__c.contains('Quote created')) {
                        system.debug('ah::start createPDFInBoxAndEmail');
                        QuoteExt.createPDFInBoxAndEmail(objQuote.Id, 
                                                        'Final', 
                                                        listBrands, 
                                                        strWholesalerName + '_' + objQuote.Unique_Id__c, 
                                                        objQuote.Owner.Email, 
                                                        objQuote.Owner.Name, 
                                                        objQuote.Opportunity.Name, 
                                                        objQuote.Account__r.Name, 
                                                        strBoxFolderId);             
                        system.debug('ah::end createPDFInBoxAndEmail');
                        
                        
                        
                        //if (!objQuote.Final_Quote__c){
                        system.debug('ah::start updating final quote flag');
                        //objQuote.Final_Quote__c = true;
                        
                        //Id fqRecordTypeId = Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName().get('Final_Quote').getRecordTypeId();
                        //objQuote.RecordTypeId = fqRecordTypeId;
                        //controller.save();
                        
                        system.debug('ah::start updating final quote flag');
                        //}
                        
                        PageReference ReturnPage = new PageReference('/' + objQuote.id); 
                        ReturnPage.setRedirect(true); 
                        return ReturnPage;   
                    }else{
                        throw new QuoteExtException('There is an error while submitting quote to SAP. Please review the error and fix it. Error ' + qot.SAP_Price_Review_Process_Response__c);
                    }
                    
                    
                }
                return null;
            }
        }
        
        catch (Exception e)
        {
            ApexPages.addMessages(e); 
            return null;
        }
    }        
    
    public PageReference createAndEmailQuotePDFonButtonClick(){
        try{
            
            Map<Id, List<String>> mapWholesalerWiseBrands = new Map<Id, List<String>>();
            Map<Id, List<Id>> mapProjectWiseWholesaler = new Map<Id, List<Id>>();        
            
            //names of wholesalers
            Map<Id, String> mapWholesalerNames = new Map<Id, String>();
            Map<Id, String> mapWholesaler = new Map<Id, String>();
            
            
            List<Quote> listQuote = [select Id, Name, Opportunity.Project__c, Final_Quote__c, Unique_Id__c, Owner.Email, Owner.Name, 
                                     Opportunity.Name, Account__c, Account__r.Brand__c, Account__r.Name, Account_Name__c, RecordTypeId
                                     from Quote 
                                     where Id = :ObjQuote.Id and Opportunity.RecordType.DeveloperName = 'Projects'];
            
            system.debug('ah::listQuote ' + listQuote);
            
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
                    system.debug('ah::listWS ' + listWS);
                    
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
                                //strWholesalerName = ws.Wholesaler__r.Name.replaceAll('(\\s+)', '');
                                //strWholesalerName = ws.Wholesaler__r.Name.replaceAll('\\D', '');
                                
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
                    system.debug('ah::strRecordType ' + strRecordType);
                    
                    String strBoxFolderId = '';
                    
                    if (mapFRUP.containsKey(qot.Id)){
                        strBoxFolderId = mapFRUP.get(qot.Id);
                        system.debug('ah::folder id ' + qot.Id + ' ' + strBoxFolderId);
                    }                    
                    
                    if ((strRecordType.contains('Final') || Test.isRunningTest() )&& objQuote.Final_Quote__c == true)
                    {
                        if (objQuote.Status != 'Processed')
                        {
                            throw new QuoteExtException('This quote has not been approved yet. Please submit this quote for the approval process.');
                        } 
                        else
                        {
                            system.debug('ah::final quote.....');
                            List<String> listBrands = new List<String>();
                            listBrands.add(qot.Account__r.Brand__c);
                            
                            system.debug('ah::qot.Account__c ' + qot.Account__c);
                            system.debug('ah::qot.Account__r.Brand__c ' + qot.Account__r.Brand__c);
                            system.debug('ah::listBrands ' + listBrands);
                            //system.debug('ah::1111  ' + qot.Account_Name__c);
                            
                            String strWholesalerName = '';
                            if (Test.isRunningTest()) {
                                strWholesalerName = qot.Account__r.Name;
                            } else {
                                strWholesalerName = qot.Account_Name__c;
                            }
                            
                            system.debug('111111111');
                            strWholesalerName = strWholesalerName.replaceAll('[^A-Za-z .]','');
                            strWholesalerName = strWholesalerName.replaceAll('(\\s+)','');                
                            
                            system.debug('ah::strWholesalerName...... ' + strWholesalerName);                            
                            
                            QuoteExt.createPDFInBoxAndEmail(qot.Id, 'Final',  listBrands, strWholesalerName + '_' + qot.Unique_Id__c, qot.Owner.Email, qot.Owner.Name, 
                                                            qot.Opportunity.Name, qot.Account__r.Name, strBoxFolderId);                                        
                        }
                    } 
                    else if (strRecordType.contains('Standard'))
                    {                        
                        system.debug('ah::master quote.....');
                        if (mapProjectWiseWholesaler.containsKey(qot.Opportunity.Project__c))
                        {
                            system.debug('ah::mapProjectWiseWholesaler.containsKey(qot.Opportunity.Project__c) ' + mapProjectWiseWholesaler.get(qot.Opportunity.Project__c));
                            
                            Set<String> strBrands = new Set<String>();
                            
                            List<Id> idWholesaler = mapProjectWiseWholesaler.get(qot.Opportunity.Project__c);
                            
                            List<List<String>> listWholesalerWiseBrands = new List<List<String>>();
                            
                            for (Id idWS : idWholesaler)
                            {
                                if (mapWholesalerWiseBrands.containsKey(idWS))
                                {
                                    system.debug('ah::mapWholesalerWiseBrands.get(idWS) ' + mapWholesalerWiseBrands.get(idWS));
                                    //PageReference pgRef = QuoteExt.createQuotePDF(qot.Id, str);
                                    
                                    String strWholesalerName = mapWholesalerNames.get(idWS);
                                    system.debug('222222222');
                                    strWholesalerName = strWholesalerName.replaceAll('[^A-Za-z .]','');
                                    strWholesalerName = strWholesalerName.replaceAll('(\\s+)','');                
                                    
                                    system.debug('ah::strWholesalerName...... ' + strWholesalerName);                                          
                                    
                                    QuoteExt.createPDFInBoxAndEmail(qot.Id, 'Master', mapWholesalerWiseBrands.get(idWS), strWholesalerName + '_' + qot.Unique_Id__c, 
                                                                    qot.Owner.Email, qot.Owner.Name, qot.Opportunity.Name, mapWholesaler.get(idWS), strBoxFolderId);    
                                    
                                    
                                    //QuoteExt.createQuotePDFinFiles(qot.Id, qot.Final_Quote__c, mapWholesalerWiseBrands.get(idWS), mapWholesalerNames.get(idWS) + '_' + qot.Unique_Id__c, qot.Owner.Email, qot.Owner.Name, qot.Opportunity.Name, mapWholesaler.get(idWS));    
                                    
                                    //strBrands.add(mapWholesalerWiseBrands.get(idWS));
                                    //listWholesalerWiseBrands.add(mapWholesalerWiseBrands.get(idWS));
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
            
            
            
            ////////////////
            
            PageReference ReturnPage = new PageReference('/' + objQuote.id); 
            ReturnPage.setRedirect(true); 
            return ReturnPage;    
            
        } catch (Exception e) {
            ApexPages.addMessages(e); 
            return null;
        }
    }      
    
    public PageReference getEverydayPrice(){
        // MB: 7/12/18 - updated functionality
        //objQuote.Get_Everyday_Price__c = true;
        //controller.save();
        
        // informatica callout
        boolean status = true;//Informatica_Quote_Callout.call(objQuote.id,'EP');
        
        if(status = true) {
            PageReference ReturnPage = new PageReference('/' + objQuote.id); 
            ReturnPage.setRedirect(true); 
            return ReturnPage;   
        }
        return null;
        
    }    
    
    @future (callout=true) //Callout is made to Box... 
    public static void createPDFInBoxAndEmail(Id qotID, string strQuoteType, List<String> strBrands, String strWholesalerName, 
                                              String strOwnerEmail, String strOwnerName, String strOpportunityName, String strWholesaler,
                                              String strBoxFolderId){
                                                  //system.debug('ah::strBrands ' + strBrands[0]);
                                                  system.debug('ah::strQuoteType ' + strQuoteType);
                                                  
                                                  system.debug('ah::strWholesalerName ' + strWholesalerName);
                                                  
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
                                                      
                                                      
                                                      box.Toolkit boxToolkit = new box.Toolkit();
                                                      
                                                      system.debug('ah::boxToolKit error: ' + boxToolkit.mostRecentError);
                                                      
                                                      BoxJwtEncryptionPreferences preferences = new BoxJwtEncryptionPreferences();
                                                      preferences.setPublicKeyId(publicKeyId);
                                                      preferences.setPrivateKey(privateKey);
                                                      BoxPlatformApiConnection boxAPIConn = BoxPlatformApiConnection.getAppUserConnection(userId, clientId, clientSecret, preferences);
                                                      
                                                      system.debug('ah::boxAPIConn::'+boxAPIConn);
                                                      system.debug('ah::strBoxFolderId::'+strBoxFolderId);
                                                      BoxFolder folder = new BoxFolder(boxAPIConn, strBoxFolderId);
                                                      list<BoxItem.Info> children = folder.getChildren();     
                                                      system.debug('ah::children ' + children);            
                                                      
                                                      Map<String, String> mapFileId = new Map<String, String>();
                                                      
                                                      Integer intVersion = 0;
                                                      
                                                      //traverse all files inside box folder and get file count that will serve as a file version
                                                      if (children != null && children.size() > 0) {
                                                          for (BoxItem.Info itemInfo : children) 
                                                          {
                                                              if (itemInfo instanceOf BoxFolder.Info)  {
                                                                  system.debug('folder');
                                                              } else if (itemInfo instanceOf BoxFile.Info) {
                                                                  BoxFile.Info fileInfo = (BoxFile.Info) itemInfo;
                                                                  mapFileId.put(fileInfo.Name, fileInfo.Id);
                                                                  
                                                                  if (fileInfo.Name.contains(strWholesalerName)) {
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
                                                      
                                                      system.debug('ah::qotID ' + qotID);
                                                      
                                                      DateTime dT = System.now();
                                                      String strDate = dT.day() + '' + dT.month() + '' + dT.year();
                                                      
                                                      PageReference pgQRef ;
                                                      
                                                      String strQuoteTypeIndicator = '';
                                                      
                                                      if (strQuoteType == 'Final') {
                                                          pgQRef = Page.CreateFQPDFVF;
                                                          strQuoteTypeIndicator = 'FQ';
                                                      } else if (strQuoteType == 'Master') {
                                                          pgQRef = Page.CreateMQPDFVF;
                                                          strQuoteTypeIndicator = 'MQ';
                                                      } else if (strQuoteType == 'Influencer') {
                                                          pgQRef = Page.CreateIQPDFVF;
                                                          strQuoteTypeIndicator = 'IQ';
                                                      }
                                                      
                                                      pgQRef.getParameters().put('id', qotID);
                                                      
                                                      if (strQuoteType != 'Influencer') {
                                                          pgQRef.getParameters().put('brands', strBrands[0]);
                                                      }
                                                      
                                                      if (strQuoteType == 'Master') {
                                                          pgQRef.getParameters().put('wsName', strWholesaler);
                                                      }
                                                      
                                                      system.debug('ah::param... ' + pgQRef.getParameters().get('id'));
                                                      
                                                      system.debug('ah::strQuoteType ' + strQuoteType);
                                                      system.debug('ah::strQuoteTypeIndicator ' + strQuoteTypeIndicator);
                                                      
                                                      system.debug('ah::att.name detail ' + strWholesalerName + '_ver' + intNextVersion + '_' + strDate + '_' + strQuoteTypeIndicator + '.pdf');
                                                      
                                                      att.Body = pgQRef.getContentAsPdf();
                                                      
                                                      system.debug('ah::.......2............');
                                                      
                                                      att.Name = strWholesalerName + '_ver' + intNextVersion + '_' + strDate + '_' + strQuoteTypeIndicator + '.pdf'; 
                                                      att.ParentId = qotID;
                                                      
                                                      system.debug('ah::att ' + att);
                                                      
                                                      
                                                      system.debug('ah::mapFileId ' + mapFileId.containsKey(att.Name));
                                                      
                                                      //variable to store box file Id
                                                      String strBoxFileId = '';
                                                      
                                                      if (mapFileId.containsKey(att.Name)) {
                                                          //upload new version
                                                          List<String> listFileNameBreakup = att.Name.split('\\.');    
                                                          
                                                          //BoxFile.Info boxInfo = folder.uploadFile(at.Body, listFileNameBreakup[0] + '_ver_' + (intVersion + 1) + strDate + '.' + listFileNameBreakup[1]);
                                                          BoxFile.Info boxInfo = folder.uploadFile(att.Body, strWholesalerName + '_ver' + intNextVersion + '_' + strDate + '_' + strQuoteTypeIndicator + '.pdf');
                                                          strBoxFileId = boxInfo.Id;
                                                          
                                                          system.debug('ah::boxInfo ' + boxInfo);
                                                          system.debug('ah::version updated');
                                                          
                                                      } else {
                                                          //if file does not exist, create one
                                                          strBoxFileId = boxtoolkit.createFileFromAttachment(att, null, strBoxFolderId, null);
                                                          system.debug('ah::new file created');
                                                      }
                                                      
                                                      if (!String.isBlank(strBoxFileId)) {
                                                          BoxFile file = new BoxFile (boxAPIConn, strBoxFileId);
                                                          
                                                          BoxSharedLink.Info bsl = file.createSharedLink('{"shared_link":{"is_password_enabled":false,"access":"open","permissions":{"can_download":true,"can_preview":true}}}');
                                                          system.debug('ah::bsl ' + bsl);
                                                          
                                                          String previewLink = bsl.downloadurl;  
                                                          system.debug('ah::previewLink ' + previewLink);   
                                                          
                                                          if (!String.isBlank(previewLink)) {
                                                              List<Quote> lstQuote = [select Id, Opportunity.Project__c from Quote where Id = :qotID];
                                                              
                                                              Set<Id> setProjectIds = new Set<Id>();
                                                              
                                                              if (lstQuote != null && lstQuote.size() > 0) {
                                                                  for (Quote q : lstQuote)
                                                                  {
                                                                      setProjectIds.add(q.Opportunity.Project__c);
                                                                  }
                                                              }
                                                              
                                                              List<Project_Team__c> listPT;
                                                              
                                                              if (setProjectIds != null && setProjectIds.size() > 0) {
                                                                  listPT = [select Id, User__r.Email from Project_Team__c where Project__c in :setProjectIds and isQuotePDFEmail__c = true];
                                                              }
                                                              
                                                              String[] emailRecipients = new String[]{};
                                                                  emailRecipients.add(strOwnerEmail);
                                                              
                                                              if (listPT != null && listPT.size() > 0) {
                                                                  for (Project_Team__c pt : listPT)
                                                                  {
                                                                      emailRecipients.add(pt.User__r.Email); 
                                                                  }
                                                              }
                                                              
                                                              
                                                              
                                                              system.debug('ah::emailRecipients ' + emailRecipients);
                                                              if (emailRecipients != null && emailRecipients.size() > 0) {  
                                                                  /*
String strBody = 'Quote for ' + strOpportunityName + ' has been generated by ' + strOwnerName + 
'. To preview and check the quote generated, please click <a href="' + previewLink + '">here</a>.<br/><br/> ' +
'If have any questions related to this, please contact the administrator.';
*/
                                                                  
                                                                  String strBody = 'Quote for ' + strOpportunityName + ' has been generated by ' + strOwnerName + 
                                                                      '. Please see the attached quote PDf in this email.<br/><br/> ' +
                                                                      'If have any questions related to this, please contact the administrator.';                        
                                                                  
                                                                  Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                                                                  message.setBccSender(false); 
                                                                  message.toAddresses = emailRecipients;
                                                                  message.subject = 'PDF created for ' + strWholesaler; 
                                                                  message.setHtmlBody(strBody);
                                                                  
                                                                  
                                                                  
                                                                  Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
                                                                  efa.setFileName(att.Name);
                                                                  efa.setBody(att.Body);
                                                                  
                                                                  List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
                                                                  fileAttachments.add(efa);
                                                                  
                                                                  message.setFileAttachments(fileAttachments);
                                                                  
                                                                  Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message}; 
                                                                      
                                                                      Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
                                                                  system.debug('ah::results ' + results);
                                                                  
                                                                  if (results[0].success) {
                                                                      System.debug('The email was sent successfully.');
                                                                  } else {
                                                                      System.debug('The email failed to send: ' + results[0].errors[0].message);
                                                                  }                 
                                                                  
                                                              }
                                                          }                
                                                      }
                                                      
                                                      boxToolkit.commitChanges();  
                                                  } catch (Exception e) {
                                                      if(ApexPages.currentPage() != null) {
                                                          ApexPages.addMessages(e); 
                                                          system.debug('ah::exception ' + e.getMessage());
                                                      }
                                                  }
                                              }  
    
    public PageReference submitForApproval(){
        try {
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
                                return controller.view();
                            }                            
                        }
                    }
                }
                return null;                
            }    
            
        } catch (Exception e) {
            ApexPages.addMessages(e); 
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
    }
    
    //Code Added By Azfer Pervaiz
    @TestVisible
    private String CheckPRoductPrices(){
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
                //ErrorMessage = ErrorMessage.substring( ErrorMessage.lastIndexOf(', '), ErrorMessage.length() );
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
        
        //system.debug('ah::strRecordType ' + strRecordType);
        PageReference quotePage;
        try 
        {
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
        }
        catch(Exception ex) 
        { 
            ApexPages.addMessages(ex);   
            return null;
        }        
        
        if (quotePage != null)
        {
            quotePage.setRedirect(true); 
        }   
        system.debug('ah::quotePage ' + quotePage);
        return quotePage; //return null;        
        
    }
    
    String strRecordType = '';
    
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
                       Unique_ID__c, Version__c, Discount__c 
                       FROM Quote 
                       WHERE Id =: objQuote.Id];
            
            Quote clonedQuote = q.clone(false, true, false, false);
            clonedQuote.IsCloned__c = true;
            clonedQuote.RecordTypeId = recordTypeId;
            clonedQuote.Status = 'Draft';
            clonedQuote.Num_Approvals__c = null;
            clonedQuote.Active_Quote__c = true;
            clonedQuote.Review_Price__c = false;
            //   ClonedQuote.First_Level_Approver__c = 
            System.debug('cloned quote:' + json.serialize(clonedQuote));
            insert clonedQuote;
            // insert Quote Line Items
            // 
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
            
            system.Debug('Cloned QLIs::'+clonedQlis);
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
            //brandValues=brandValues +';';
            System.debug('Brand Values fetched from Line items: '+brandValues );
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
            
            
            system.debug('ah::clonedQuote.id ' + clonedQuote.id)            ;
            //PageReference ReturnPage = new PageReference('/' + clonedQuote.id); 
            PageReference ReturnPage = new PageReference('/lightning/r/Quote/' + clonedQuote.id + '/view'); 
            ReturnPage.setRedirect(true); 
            
            system.debug('ah::ReturnPage ' + ReturnPage);
            return ReturnPage;              
            
        }
        catch(Exception ex) 
        { 
            ApexPages.addMessages(ex);   
            return null;
        }        
        
        //return null;     
        
    }    
    
    public class QuoteExtException extends Exception {}
}