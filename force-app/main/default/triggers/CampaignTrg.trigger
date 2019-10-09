trigger CampaignTrg on Campaign (after update, after  insert) 
{
    final String const_REGIONAL_SHOWROOM_MANAGER = 'Regional Showroom Manager';
    final String const_GENERAL_MANAGER = 'General Manager';
    
    If (Trigger.isAfter && Trigger.isUpdate)
    {
        //execute campaign when campaign status is changed to In Progress
        
        //List to hold unique opp records
        List<Opportunity> listDedupOpp = new List<Opportunity>();
        
        try 
        {
            Set<Id> setCampaignId = new Set<Id>();
            
            for (Campaign campaignId : Trigger.New)
            {
                if(Trigger.oldMap.get(campaignId.Id).Status != Trigger.newMap.get(campaignId.Id).Status && Trigger.newMap.get(campaignId.Id).Status == 'In Progress')
                {
                    setCampaignId.add(campaignId.Id);
                    system.debug('ah::campaignId.Id ' + campaignId.Id);
                }
            }        
            
            system.debug('ah::setCampaignId ' + setCampaignId);
            if (setCampaignId != null && setCampaignId.size() > 0)
            {
                List<CampaignMember> listCM = [select Id, ContactID, Campaign.Name, Campaign.EndDate, Contact.AccountId, Campaign.Campaign_Products_Camp_Price_Rollup_c__c, 
                                               Contact.Account.General_Manager__c, Contact.Account.Regional_Showroom_manager__c, Campaign.OwnerId 
                                               from CampaignMember 
                                               where CampaignId in :setCampaignId and Contact.AccountId != null];
                
                system.debug('ah::listCM ' + listCM);
                Map<String, Id> mapOppRecordType = new Map<String, Id>();
                Map<Id, List<CampaignMember>> mapCM = new Map<Id, List<CampaignMember>>();
                Set<Id> setAcctId = new Set<Id>();
                
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
                    
                    for(CampaignMember cm : listCM)
                    {
                        if(mapCM.containsKey(cm.CampaignId)) 
                        {
                            List<CampaignMember> cMem = mapCM.get(cm.CampaignId);
                            cMem.add(cm);
                            mapCM.put(cm.CampaignId, cMem);
                        } 
                        else 
                        {
                            mapCM.put(cm.CampaignId, new List<CampaignMember> { cm });
                        }
                        
                        setAcctId.add(cm.Contact.AccountId);
                    }
                    
                    List<Opportunity> listOpp = new List<Opportunity>();
                    List<Quote> listQuote = new List<Quote>();
                    List<QuoteLineItem> listQLI = new List<QuoteLineItem>();
                    
                	
           
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
                    
                    for (Campaign cam : Trigger.New)
                    {
                        String campaignRecordTypeName = Schema.Sobjecttype.Campaign.getRecordTypeInfosById ().get(cam.RecordTypeId).getName();
                        
                        if (mapOppRecordType.containsKey(campaignRecordTypeName) && mapCM.containsKey(cam.Id))
                        {
                            List<CampaignMember> lCM = mapCM.get(cam.Id);
                            
                            if (lCM != null && lCM.size() > 0)
                            {
                                for (CampaignMember cm : lCM)
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
                                        Opportunity opp = new Opportunity(OwnerId=idOppOwner, StageName=strStageName, Name=cm.Campaign.Name, 
                                                                          RecordTypeId=mapOppRecordType.get(campaignRecordTypeName), CloseDate=cm.Campaign.EndDate, 
                                                                          Start_Date__c=System.today(), AccountId=cm.Contact.AccountId, 
                                                                          Amount=cm.Campaign.Campaign_Products_Camp_Price_Rollup_c__c, CampaignId=cm.CampaignId);
                                        listOpp.add(opp);
                                    }
                                }
                            }
                        }
                    }
                    
                    if (listOpp != null && listOpp.size() > 0)
                    {
                        system.debug('ah::listOpp ' + listOpp);
                        
                        Set<Opportunity> setOpp = new Set<Opportunity>();
                        setOpp.addAll(listOpp);
                        
                        
                        listDedupOpp.addAll(setOpp);
                        system.debug('ah::listDedupOpp ' + listDedupOpp);
                        insert listDedupOpp;
                    }            
                    List<Campaign_Products__c> listCP = new List<Campaign_Products__c>();
                    List<String> ListProductId = new List<String>();

                    for( Campaign_Products__c  CampaignProductsObj :   [select  Campaign__c,  Product__c, Product__r.Name, List_Price__c,  Quantity__c,  Product_Description__c,  Campaign_Price__c 
                                                         from Campaign_Products__c
                                                         where Campaign__c = :setCampaignId])
                    {
                        listCP.add( CampaignProductsObj );
                        ListProductId.add(CampaignProductsObj.Product__c);
                    }
                    
                    Map<String, ID> mapPBE = new Map<String, Id>();
                    
                    List<PriceBookEntry> listPBE = [select Id, Name from PriceBookEntry where Product2Id In : ListProductId];
                    
                    if (listPBE != null && listPBE.size() > 0)
                    {
                        for (PriceBookEntry pbe : listPBE)
                        {
                           mapPBE.put(pbe.Name, pbe.Id) ;
                        }
                    }
                    
                    //get standard price book
                    Id stdPriceBookId;
                    
                    if(!Test.isRunningTest())   
                    {
                        //Pricebook2 stdPriceBook = [select id, name from Pricebook2 where isStandard = true limit 1];
                        stdPriceBookId = [select id from Pricebook2 where isStandard = true limit 1].Id;
                    }
                    else
                    {
                        stdPriceBookId = Test.getStandardPricebookId();
                    }
                    
                    if (listCP != null && listCP.size() > 0)
                    {
                        for (Opportunity opp : [select Id, Name, OwnerId, Campaign_Unique_Code__c, Account.Account_Number__c, Account.SAP_Account_Number__c from Opportunity where Id in :listDedupOpp])
                        {
                            Quote qot = new Quote();
                            qot.OpportunityId = opp.Id;
                            qot.Name = opp.Name;
                            qot.RecordTypeId = Schema.Sobjecttype.Quote.getRecordTypeInfosByName().get('Standard Quote').getRecordTypeId();
                            qot.Pricebook2Id = stdPriceBookId;
                            
                            /*Updated By M. Asif 8/6/2018 qot.Unique_Id__c Assignment
                            qot.Unique_Id__c = opp.Account.Account_Number__c +'-'+ opp.Campaign_Unique_Code__c;                        	
                        	*/
                        	qot.Unique_Id__c = opp.Account.SAP_Account_Number__c +'-'+ opp.Campaign_Unique_Code__c;
                        	
                            qot.Status = 'Processed';
                            listQuote.add(qot);
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
                                    //change on ZP's feedback on 29 May 2018
                                    qli.UnitPrice = cp.List_Price__c;
                                    //qli.UnitPrice = cp.Campaign_Price__c;
                                    qli.Requested_Price__c = cp.Campaign_Price__c;
                                    qli.Approved_Price__c = cp.Campaign_Price__c;
                                    qli.Quantity = cp.Quantity__c;
                                    qli.Product2Id = cp.Product__c;
                                    qli.PricebookEntryId = mapPBE.get(cp.Product__r.Name);
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
        }
        
        catch (Exception e)
        {
            for (Campaign c : Trigger.New)
            {
                c.addError(e);
            }
        }
    }
    
    if (Trigger.isAfter && Trigger.isInsert)
    {
        Set<Id> setCampIDs = new Set<Id>();
        
        for (Campaign camp : Trigger.New)
        {
        	setCampIDs.add(camp.Id);
        }
        
        if (setCampIDs != null && setCampIDs.size() > 0)
        {
            BoxIntegrationUtil.createFolderinBox (setCampIDs, 'Campaign');
        }
            
    }    
}