public class CampaignExt 
{
    public Campaign objCampaign;
    private ApexPages.StandardController controller;
    
    final String const_REGIONAL_SHOWROOM_MANAGER = 'Regional Showroom Manager';
    final String const_GENERAL_MANAGER = 'General Manager';
    
    public CampaignExt(ApexPages.StandardController stdController)
    {
        controller = stdController;
        this.objCampaign = (Campaign)stdController.getRecord();
    }    
    
    @future (callout=true) 
    public static void setCollaboration(String strBoxFolderId)
    {
        
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
        try{
            list<BoxUser.Info> allUsers = BoxUser.getAllEnterpriseUsers(boxAPIConn);
            
            system.debug('ah::strBoxFolderId........ ' + strBoxFolderId);
            if (allUsers != null && allUsers.size() > 0)
            {
                for (BoxUser.Info bui : allUsers)
                {
                    BoxCollaborator buser = new BoxUser(boxAPIConn, bui.Id);
                    BoxFolder bfolder = new BoxFolder(boxAPIConn, strBoxFolderId);
                    bfolder.collaborate(buser, BoxCollaboration.Role.EDITOR);
                    
                }
            }
                    
        boxToolkit.commitChanges(); 
        }
        catch(Exception e){
            system.debug(e.getMessage());
        }
    }    
    
    public PageReference executeCampaign()
    {
        //List to hold unique opp records
        List<Opportunity> listDedupOpp = new List<Opportunity>();
        
        try
        {
            List<CampaignMember> listCM = [select Id, ContactID, Campaign.Name, Campaign.EndDate, Contact.AccountId, Campaign.Campaign_Products_Camp_Price_Rollup_c__c, 
                                           Campaign.Reason_Code__c, Campaign.Sales_Deal__c, Campaign.CurrencyIsoCode, 
                                           Contact.Account.General_Manager__c, Contact.Account.Regional_Showroom_manager__c, Campaign.OwnerId
                                           from CampaignMember 
                                           where CampaignId = :objCampaign.Id and Contact.AccountId != null];
            
            Map<String, Id> mapOppRecordType = new Map<String, Id>();
            
            
            
            if (listCM != null && listCM.size() > 0)
            {
                List<RecordType> listRT =[select Id, DeveloperName from RecordType where SObjectType = 'Opportunity'];
                
                if (listRT != null && listRT.size() > 0)
                {
                    for (RecordType rt : listRT)
                    {
                        mapOppRecordType.put(rt.DeveloperName, rt.Id);
                    }
                }
                
                String campaignRecordTypeName = Schema.Sobjecttype.Campaign.getRecordTypeInfosById ().get(objCampaign.RecordTypeId).getName();
                
                List<Opportunity> listOpp = new List<Opportunity>();
                List<Quote> listQuote = new List<Quote>();
                List<QuoteLineItem> listQLI = new List<QuoteLineItem>();
                
                //set of Accounts
                Set<Id> setAcctId = new Set<Id>();
                Set<Id> setCampaignId = new Set<Id>();
                
                for (CampaignMember cm : listCM)
                {
                    setAcctId.add(cm.Contact.AccountId);
                    setCampaignId.add(cm.Id);
                }
                
                //Account team map
                Map<String, Id> mapAT = new Map<String, Id>();
                
                if (setAcctId != null && setAcctId.size()> 0)
                {
                    List<AccountTeamMember> listATM = [select Id, AccountId, TeamMemberRole, UserId from AccountTeamMember where AccountId in :setAcctId];
                    
                    if (listATM != null && listATM.size() > 0)
                    {
                        for (AccountTeamMember atm : listATM)
                        {
                            mapAT.put(atm.AccountId + '-' + atm.TeamMemberRole, atm.UserId);
                        }
                    }
                }
                
                //map that will used to restrict duplicate opportunity creation
                Map<String, Id> mapExistingOpp = new Map<String, Id>();
                
                List<Opportunity> listExistingOpp = [select Id, Name, AccountId from Opportunity where AccountId in :setAcctId];
                
                if (listExistingOpp != null && listExistingOpp.size() > 0)
                {
                    for (Opportunity op : listExistingOpp)
                    {
                        mapExistingOpp.put(op.Name + '-' + op.AccountId, op.Id);
                    }
                }                
                
                //Map to store record's corresponding folder Id in box.com
                Map<String, String> mapFRUP = new Map<String, String>();
                
                //file map of record Id and corresponding folder ID in box.com
                if (setCampaignId != null && setCampaignId.size() > 0)
                {
                    for (box__FRUP__c frup : [select box__Object_Name__c, box__Folder_ID__c, box__Record_ID__c from box__FRUP__c where box__Record_ID__c in :setCampaignId])
                    {
                        mapFRUP.put(frup.box__Record_ID__c, frup.box__Folder_ID__c);
                    }
                }                
                
                box.Toolkit boxToolkit = new box.Toolkit();
                
                String strBoxFolderId = '';
                String strCampMarketingMaterialFolder = '';
                
                if (!mapFRUP.containsKey(objCampaign.Id))
                {
                    strBoxFolderId = boxToolkit.createFolderForRecordId(objCampaign.Id, null, true);
                    boxToolkit.commitChanges(); 
                    
                    strCampMarketingMaterialFolder = 'https://app.box.com/folder/' + strBoxFolderId;
                }
                else
                {
                    strBoxFolderId = mapFRUP.get(objCampaign.Id);
                    strCampMarketingMaterialFolder = 'https://app.box.com/folder/' + strBoxFolderId;
                }                  
                
                if (!Test.isRunningTest())
                {
                    CampaignExt.setCollaboration(strBoxFolderId);
                }
                
                if (mapOppRecordType.containsKey(campaignRecordTypeName))
                {
                    for (CampaignMember cm : listCM)
                    {
                        Id idOppOwner;
                        String strStageName = '';
                        
                        if (campaignRecordTypeName == 'Display')
                        {
                            strStageName = 'Display Proposal';
                            if (mapAT.containsKey(cm.Contact.AccountId + '-' + const_REGIONAL_SHOWROOM_MANAGER))
                            {
                                idOppOwner = mapAT.get(cm.Contact.AccountId + '-' + const_REGIONAL_SHOWROOM_MANAGER);
                            }
                            else
                            {
                                idOppOwner = cm.Campaign.OwnerId;
                            }
                        }
                        else if (campaignRecordTypeName == 'Initiative')
                        {
                            strStageName = 'Initiative Proposal';
                            
                            if (mapAT.containsKey(cm.Contact.AccountId + '-' + const_GENERAL_MANAGER))
                            {
                                idOppOwner = mapAT.get(cm.Contact.AccountId + '-' + const_GENERAL_MANAGER);    
                            }
                            else 
                            {
                                idOppOwner = cm.Campaign.OwnerId;
                            }
                        }  
                        else
                        {
                            idOppOwner = cm.Campaign.OwnerId;
                        }
                        
                        
                        
                        //if opportunity already exists, don't create duplicate one
                        if (!mapExistingOpp.containsKey(cm.Campaign.Name + '-' + cm.Contact.AccountId))
                        {                        
                            //implement opportunity creation logic as per LSCIP-83
                            Opportunity opp = new Opportunity(OwnerId=idOppOwner,Responsible__c = idOppOwner, StageName=strStageName, Name=cm.Campaign.Name, RecordTypeId=mapOppRecordType.get(campaignRecordTypeName), 
                                                              CloseDate=cm.Campaign.EndDate, Start_Date__c=System.today(), AccountId=cm.Contact.AccountId, 
                                                              Amount=cm.Campaign.Campaign_Products_Camp_Price_Rollup_c__c, CampaignId=cm.CampaignId, 
                                                              Marketing_Material__c=strCampMarketingMaterialFolder,
                                                              CurrencyIsoCode = cm.Campaign.CurrencyIsoCode);
                            listOpp.add(opp);
                        }
                        
                    }
                    
                    if (listOpp != null && listOpp.size() > 0)
                    {
                        Set<Opportunity> setOpp = new Set<Opportunity>();
                        setOpp.addAll(listOpp);
                        
                        
                        listDedupOpp.addAll(setOpp);
                        
                        insert listDedupOpp;
                    }
                    
                }
                
                List<Campaign_Products__c> listCP = new List<Campaign_Products__c>();
                List<String> ListProductId = new List<String>();
                
                List<Campaign_Products__c> lstCProd = [select  Campaign__c,  Product__c, Product__r.Name, List_Price__c,  Quantity__c,  Product_Description__c,  Campaign_Price__c, Line_Number__c, CurrencyIsoCode  
                                                       from Campaign_Products__c
                                                       where Campaign__c = :objCampaign.Id];
                
                if (lstCProd != null && lstCProd.size() > 0) 
                {
                    for( Campaign_Products__c  CampaignProductsObj :  lstCProd)
                    {
                        listCP.add( CampaignProductsObj );
                        ListProductId.add(CampaignProductsObj.Product__c);
                    }
                }
                
                Map<String, ID> mapPBE = new Map<String, Id>();
                
                List<PriceBookEntry> listPBE = [select Id, Name from PriceBookEntry WHERE CurrencyIsoCode =: objCampaign.CurrencyIsoCode AND Product2Id IN : ListProductId];
                
                if (listPBE != null && listPBE.size() > 0)
                {
                    for (PriceBookEntry pbe : listPBE)
                    {
                        mapPBE.put(pbe.Name, pbe.Id) ;
                    }
                }
                Id stdPriceBookId;
                
                if(!Test.isRunningTest())   
                {
                    stdPriceBookId = [select id from Pricebook2 where isStandard = true limit 1].Id;
                }
                else
                {
                    stdPriceBookId = Test.getStandardPricebookId();
                }
                
                if (listCP != null && listCP.size() > 0)
                {
                    List<Opportunity> lOpp = [select Id, Name, OwnerId, CurrencyIsoCode, Campaign_Unique_Code__c, Account.Account_Number__c, Account.SAP_Account_Number__c 
                                              from Opportunity where Id in :listDedupOpp];
                    
                    if (lOpp != null && lOpp.size() > 0)
                    {
                        for (Opportunity opp : lOpp)
                        {
                            Quote qot = new Quote();
                            qot.OpportunityId = opp.Id;
                            qot.Name = opp.Name;
                            qot.OwnerId = opp.OwnerId;
                            
                            if (campaignRecordTypeName == 'Display')
                            {
                                qot.RecordTypeId = Schema.Sobjecttype.Quote.getRecordTypeInfosByName().get('Display Quote').getRecordTypeId();    
                            }
                            else if (campaignRecordTypeName == 'Initiative')
                            {
                                qot.RecordTypeId = Schema.Sobjecttype.Quote.getRecordTypeInfosByName().get('Initiative Quote').getRecordTypeId();    
                            }
                            qot.Pricebook2Id = stdPriceBookId;
                            
                            /*Updated By M. Asif 8/6/2018 qot.Unique_Id__c Assignment
qot.Unique_Id__c = opp.Account.Account_Number__c +'-'+ opp.Campaign_Unique_Code__c;
*/
                            qot.Unique_Id__c = opp.Account.SAP_Account_Number__c +'-'+ opp.Campaign_Unique_Code__c;
                            qot.CurrencyIsoCode = opp.CurrencyIsoCode;
                            qot.Status = 'Processed';
                            listQuote.add(qot);
                        }
                    }
                    
                    if (listQuote != null && listQuote.size() > 0)
                    {                
                        system.debug('ah::listQuote ' + listQuote);
                        insert listQuote;
                        
                        for (Quote q : listQuote)
                        {
                            for (Campaign_Products__c cp : listCP)
                            {
                                QuoteLineItem qli = new QuoteLineItem();
                                qli.QuoteId = q.Id;
                                qli.UnitPrice = cp.Campaign_Price__c;
                                qli.Approved_Price__c = cp.Campaign_Price__c;
                                qli.Quantity = cp.Quantity__c;
                                qli.Product2Id = cp.Product__c;
                                qli.PricebookEntryId = mapPBE.get(cp.Product__r.Name);
                                qli.Line_Number__c = cp.Line_Number__c;
                                listQLI.add(qli);
                            }   
                        }
                        
                        if (listQLI != null && listQLI.size() > 0)
                        {   
                            system.debug('ah::listQLI ' + listQLI);
                            insert listQLI;                        
                        }                    
                    }
                    
                }
            }
        }
        
        catch (Exception e)
        {
            ApexPages.addMessages(e); 
            system.debug('ah::exception ' + e.getMessage());
            
            if (listDedupOpp != null && listDedupOpp.size() > 0)
            {
                System.debug('listDedupOpp::'+listDedupOpp);
                delete listDedupOpp;
            }
            
            return null; 
        }
        update new Campaign(Id= objCampaign.id,Campaign_Execution_Date_Time__c = system.now(),
                           campaign_executed__c = True);
        PageReference ReturnPage = new PageReference('/' + objCampaign.id); 
        ReturnPage.setRedirect(true); 
        return ReturnPage;
    }
    
}