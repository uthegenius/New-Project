/*
* Change log: 
*   Changed by: Tectonic (MB) on 6/12/18    - LSCIP-68 - QLI consolidation.
*/
trigger QuoteTrg on Quote (after insert, after update, before insert, before Update, before delete) 
{

     // Return if trigger is inactive from custom meta data type
    Trigger_Active_Inactive_Flag__mdt objTrgActive = [Select Flag__c from Trigger_Active_Inactive_Flag__mdt where MasterLabel = 'QuoteTrg'];
    
    if(!objTrgActive.Flag__c ) return;
    
    // Abid Raza - 19/7/2018 - Day3 IssueLog(#62) - GM__c and GM_Per__c values to put in 2 new fields Requested_GM__c & Requested_GM_Per__c respectively.
    if (Trigger.isBefore && Trigger.isUpdate)
    {
        for (Quote q : Trigger.New)    
        {
            if(q.GM__c != Trigger.OldMap.get(q.Id).GM__c)
                q.Requested_GM__c = q.GM__c;
            
            if(q.GM_Per__c != Trigger.OldMap.get(q.Id).GM_Per__c)
                q.Requested_GM_Per__c  = q.GM_Per__c;
            
            //if(string.isNotBlank(q.Unique_id__c)){}
                      
        }
    }
    
    // Abid Raza - 23/7/2018 - Day3 IssueLog(#38) - Except Admin profiles users, no user can delete quote.
    if (Trigger.isBefore && Trigger.isDelete)
    {
        Id profileId=userinfo.getProfileId();
        String profileName=[Select Name from Profile where Id=:profileId].Name;
        List<Lixil_Configuration__mdt> LixilSetting_QuoteDelete = [Select Enable_Callouts_From_Trigger_to_Box__c 
                                   from Lixil_Configuration__mdt 
                                   where DeveloperName = 'Allow_Quote_QLI_Deletion_to_Admin'
                                   and Enable_Callouts_From_Trigger_to_Box__c = True];
        
        for (Quote q : Trigger.Old)
        {
            if ((profileName != 'System Administrator' && 
                profileName != 'Lixil System Administrator' && 
                profileName != 'Integration System Administrator') && 
                q.Final_Quote__c ) 
            {
                q.addError('Quote cannot be deleted. Please contact your Salesforce administrator.');
            }
            else if (profileName.contains('System Administrator') && 
                q.Final_Quote__c &&
                    !LixilSetting_QuoteDelete.isEmpty()) 
            {
                q.addError('The final quote can not be deleted. If you have an exceptional case to remove a quote, please contact your Salesforce administrator.');
            }
        }
    }
    
    Set<Id> setQuotetoTrackOpp = new Set<Id>();
    
    if (Trigger.isAfter && Trigger.isInsert)
    {
        Set<id> boxIds = new Set<id>();
        for(Quote quo:Trigger.new)
        {
            boxIds.add(quo.id);
        }
        Set<Id> setOppId = new Set<Id>();
        Set<Id> setRTId = new Set<Id>();
        Set<Id> setQuoteId = new Set<Id>();
        
        Lixil_Configuration__mdt lcm = [select Enable_Callouts_From_Trigger_to_Box__c 
                                        from Lixil_Configuration__mdt
                                       where DeveloperName = 'Enable_Callouts_From_Apex_Trigger_to_Box'];
        
        Map<String, String> mapFRUP = new Map<String, String>();
        
        if (lcm.Enable_Callouts_From_Trigger_to_Box__c == true)
        {
            //create quote record's folder in box.com
            Box_App_Detail__mdt bad = [select  Id, User_Id__c,  Enterprise_Id__c,  Public_Key__c,  Private_Key__c, Client_Id__c,  Client_Secret__c 
                                       from Box_App_Detail__mdt];
            
            String userId = bad.User_Id__c;
            String enterpriseId = bad.Enterprise_Id__c;
            String publicKeyId = bad.Public_Key__c;
            String privateKey = bad.Private_Key__c;
            String clientId = bad.Client_Id__c;
            String clientSecret = bad.Client_Secret__c;  
            List<box__FRUP__c> listBoxFRUP = new List<box__FRUP__c>();
   
            if(boxIds!=null && boxIds.size()>0)
            {
                           
                listBoxFRUP = [select box__Object_Name__c, box__Folder_ID__c, box__Record_ID__c from box__FRUP__c where box__Record_ID__c IN : boxIds  ];

            }
            
            if (listBoxFRUP != null && listBoxFRUP.size() > 0)
            {
                for (box__FRUP__c frup : listBoxFRUP)
                {
                    mapFRUP.put(frup.box__Record_ID__c, frup.box__Folder_ID__c);
                }
            }        
        }
        Set<Id> setQotIDs = new Set<Id>();
        
        for (Quote q : Trigger.New)    
        {
            setOppId.add(q.OpportunityId); 
            setRTId.add(q.RecordTypeId);               
            
            if (q.Mark_Opportunity_as_Shipped__c)
            {
                setQuotetoTrackOpp.add(q.Id);
            }
            
            setQuoteId.add(q.Id);
            
            
            if (lcm.Enable_Callouts_From_Trigger_to_Box__c == true && !Test.isRunningTest())
            {
                //if folder for this record does not exist in box.com, then create it
                if (!mapFRUP.containsKey(q.Id))
                {
                    //QuoteExt.createFolderinBox(q.Id);
                    setQotIDs.add(q.Id);
                }            
            }
        }
        
        if (setQotIDs != null && setQotIDs.size() > 0)
        {
            BoxIntegrationUtil.createFolderinBox (setQotIDs, 'Quote');
        }
        
        Map<String, String> mapVersion = new Map<String, String>();
        
        //Map to store Account Number 
        Map<Id, String> mapAccountNumber = new Map<Id, String>();
        
        if (setOppId != null && setOppId.size() > 0)
        {
            if ( setRTId != null && setRTId.size() > 0)
            {
                List<AggregateResult> aggResult = [select OpportunityId, RecordTypeId, MAX(VersionNumber__c) MaxVersion from Quote  where OpportunityId in :setOppId and RecordTypeId in :setRTId group by OpportunityId, RecordTypeId];
                
                if (aggResult != null && aggResult.size() > 0)
                {
                    for (AggregateResult ar : aggResult)
                    {
                        mapVersion.put(ar.get('OpportunityId') + '-' + ar.get('RecordTypeId'), String.valueOf(ar.get('MaxVersion')));
                    }
                }
            }
        }
        
        
        List<Quote> listQuote = new List<Quote>();
        ////////// code added by kashif --  assing owner to project team on update ///////////////
        List<Project_Team__c> projTeamList = new  List<Project_Team__c>();
        set<id> projectIdSet = new set<id>();
        Map<id,id> projownerIdMap = new Map<id,id>();
        List<String> ProjectId_UserId = new List<String>();
        Map<String,String> ProjectId_UserIdMap = new Map<String,String>();
        
        for (Quote qt : Trigger.New)
        {
            if (mapVersion.containsKey(qt.OpportunityId + '-' + qt.RecordTypeId))
            {
                String strMaxVersionNum = mapVersion.get(qt.OpportunityId + '-' + qt.RecordTypeId);
                
                if (strMaxVersionNum != null)
                {
                    Integer intMaxVer = Integer.valueOf(strMaxVersionNum) + 1;
    
                    Quote q = new Quote(Id=qt.Id, Version__c=String.valueOf(intMaxVer));
                    
                    /*unique Id generation logic changed on 25th May 2018 on ticket LCSIP-97 that's why following piece of code is commented out
                    if (mapAccountNumber.containsKey(qt.OpportunityId))
                    {
                        q.Unique_ID__c = mapAccountNumber.get(qt.OpportunityId) + '-' + qt.QuoteNumber;
                    }
                    */
                    listQuote.add(q);
                }
                else
                {
                    Quote q = new Quote(Id=qt.Id, Version__c='1');
                    system.debug('ah::in else ');
                    /*unique Id generation logic changed on 25th May 2018 on ticket LCSIP-97 that's why following piece of code is commented out
                    /*
                    if (mapAccountNumber.containsKey(qt.OpportunityId))
                    {
                        q.Unique_ID__c = mapAccountNumber.get(qt.OpportunityId) + '-' + qt.QuoteNumber;
                    }       
                    */
                    listQuote.add(q);
                }
            }
            
            if(string.isnotblank(qt.ProjectId__c)){
                 Project_Team__c prjtm = new Project_Team__c(Project__c = qt.ProjectId__c,User__c = qt.OwnerId, isQuotePDFEmail__c = true, Role__c=qt.Project_Team_Member_Role__c,
                                                        ProjectId_UserId__c= qt.ProjectId__c+'-'+qt.OwnerId);	
        	 projTeamList.add(prjtm);
             ProjectId_UserId.add(qt.ProjectId__c+'-'+qt.OwnerId);  
            }
            
        }
        

        if (listQuote != null && listQuote.size() > 0) 
        {
            update listQuote;
        }
        if(projTeamList.size() > 0)
        {
            List<Project_Team__c> checkExistingList = [ select id,ProjectId_UserId__c from Project_Team__c where  ProjectId_UserId__c in:ProjectId_UserId];
            if(checkExistingList.size() > 0)
            {
                Integer index = 0, index2=-1;
                 for(Project_Team__c ptc : checkExistingList   )
                 {
                     index = 0;
                     for(Project_Team__c pt : projTeamList )
                     {
                        if(ptc.ProjectId_UserId__c == pt.ProjectId_UserId__c )
                        {
                            index2 = index; 
                        }
                         else{
                             index++;
                         }
                     }
                        if(index2 != -1)
                        {
                            projTeamList.remove(index2);
                            index2 = -1;
                        }
                          
                 }
            }
            
                if(projTeamList.size() > 0 )
                {
                    upsert projTeamList;
                }   
 		} 
        ////////// code added by kashif /////////////// 
     }        
    
    
    
    
    if (Trigger.isBefore && Trigger.isUpdate)
    {
        Set<Id> setQuoteCreateAndEmailPDF = new Set<Id>();
        Boolean isFinalQuote = false;
        Set<Id> boxIds = new Set<Id>();
        
        Lixil_Configuration__mdt lcm = [select Enable_Callouts_From_Trigger_to_Box__c 
                                        from Lixil_Configuration__mdt
                                       where DeveloperName = 'Enable_Callouts_From_Apex_Trigger_to_Box'];
        
        for (Quote q : Trigger.New)
        {
            
            boxIds.add(q.id);
            if (Trigger.oldMap.get(q.Id).Status != Trigger.newMap.get(q.Id).Status && Trigger.newMap.get(q.Id).Status == Label.Approved_Quote_Status ) 
            {
                string strRecordType = Schema.SObjectType.Quote.getRecordTypeInfosById().get(q.RecordTypeId).getName();
                
                if (strRecordType == 'Standard Quote')
                {
                    q.RecordTypeId = Schema.SObjectType.Quote.getRecordTypeInfosByName().get('Locked Standard Quote').getRecordTypeId();
                }
                else if (strRecordType == 'Influencer Quote')
                {
                    q.RecordTypeId = Schema.SObjectType.Quote.getRecordTypeInfosByName().get('Locked Influencer Quote').getRecordTypeId();
                }
            }
            
            
            system.debug('ah::Trigger.oldMap.get(q.Id).Status' + Trigger.oldMap.get(q.Id).Status);
            system.debug('ah::Trigger.newMap.get(q.Id).Status' + Trigger.newMap.get(q.Id).Status);
            system.debug('ah::Trigger.oldMap.get(q.Id).Create_PDF__c' + Trigger.oldMap.get(q.Id).Create_PDF__c);
            system.debug('ah::Trigger.newMap.get(q.Id).Create_PDF__c' + Trigger.newMap.get(q.Id).Create_PDF__c);

            //If Enable Callouts From Trigger to Box field is true in Lixil Configuration custom metadata type then allow callouts to Box.com
            if (lcm.Enable_Callouts_From_Trigger_to_Box__c == true)
            {
                if (Trigger.oldMap.get(q.Id).Status != Trigger.newMap.get(q.Id).Status && Trigger.newMap.get(q.Id).Status == Label.Approved_Quote_Status 
                    ) 
                {
                    isFinalQuote = Trigger.newMap.get(q.Id).Final_Quote__c ;

					system.debug('ah::final quote.... ' + Trigger.newMap.get(q.Id).Final_Quote__c);
                    system.debug('ah::final quote.... ' + isFinalQuote);
                    
                    //PageReference pgRef = QuoteExt.createQuotePDF(q.Id, q.Final_Quote__c);
                    setQuoteCreateAndEmailPDF.add(q.Id);
                     
                    system.debug('ah::populating set for pdf generation');
                }         
            }       
        }
        
        ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        //before update
        ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        Map<Id, List<String>> mapWholesalerWiseBrands = new Map<Id, List<String>>();
        Map<Id, List<Id>> mapProjectWiseWholesaler = new Map<Id, List<Id>>();        
        
        //names of wholesalers
        Map<Id, String> mapWholesalerNames = new Map<Id, String>();
        Map<Id, String> mapWholesaler = new Map<Id, String>();
        
        if (setQuoteCreateAndEmailPDF != null && setQuoteCreateAndEmailPDF.size() > 0)
        {
            List<Quote> listQuote = [select Id, Name, Opportunity.Project__c, Final_Quote__c, Unique_Id__c, Owner.Email, Owner.Name, 
                                     Opportunity.Name, Account__r.Brand__c, Account__r.Name, RecordTypeId, Account_Name__c
                                     from Quote 
                                     where Id in :setQuoteCreateAndEmailPDF and Opportunity.RecordType.DeveloperName = 'Projects'];
            system.debug('ah::listQuote ' + listQuote);
         
            Set<Id> setProjectId = new Set<Id>();
                        
            if (listQuote != null && listQuote.size() > 0)
            {
                for (Quote q: listQuote)
                {
                    setProjectId.add(q.Opportunity.Project__c);
                }
                
                Map<String, String> mapFRUP = new Map<String, String>();
                List<box__FRUP__c> listBoxFRUP =  new List<box__FRUP__c>();
                if(boxIds!=null && boxIds.size()>0)
                {
                     listBoxFRUP= [select box__Object_Name__c, box__Folder_ID__c, box__Record_ID__c from box__FRUP__c where box__Record_ID__c IN :boxIds] ;
                
                }
                
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
                    
                    if (mapFRUP.containsKey(qot.Id))
                    {
                        strBoxFolderId = mapFRUP.get(qot.Id);
                        system.debug('ah::folder id ' + qot.Id + ' ' + strBoxFolderId);
                    }                    
                    
                    if (strRecordType.contains('Final') && isFinalQuote == true)
                    {

                            List<String> listBrands = new List<String>();
                            listBrands.add(qot.Account__r.Brand__c);
                            
                            system.debug('ah::qot.Account__c ' + qot.Account__c);
                            system.debug('ah::qot.Account__r.Brand__c ' + qot.Account__r.Brand__c);
                            system.debug('ah::listBrands ' + listBrands);
                                        
                            String strWholesalerName = qot.Account_Name__c;
                            
                            strWholesalerName = strWholesalerName.replaceAll('[^A-Za-z .]','');
                            strWholesalerName = strWholesalerName.replaceAll('(\\s+)','');                
                            
                            system.debug('ah::strWholesalerName...... ' + strWholesalerName);                            
                            
                            QuoteExt.createPDFInBoxAndEmail(qot.Id, 
                                                            'Final', 
                                                            listBrands, 
                                                            strWholesalerName + '_' + qot.Unique_Id__c, 
                                                            qot.Owner.Email, 
                                                            qot.Owner.Name, 
                                                            qot.Opportunity.Name, 
                                                            qot.Account__r.Name, 
                                                            strBoxFolderId);                                        
                            
                    }
                    else if (strRecordType.contains('Standard'))
                    {                        
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
                                    
                                    strWholesalerName = strWholesalerName.replaceAll('[^A-Za-z .]','');
                                    strWholesalerName = strWholesalerName.replaceAll('(\\s+)','');                
                                    
                                    system.debug('ah::strWholesalerName...... ' + strWholesalerName);                                          
                                    
                                    QuoteExt.createPDFInBoxAndEmail(qot.Id, 
                                                                    'Master', 
                                                                    mapWholesalerWiseBrands.get(idWS), 
                                                                    strWholesalerName + '_' + qot.Unique_Id__c, 
                                                                    qot.Owner.Email, 
                                                                    qot.Owner.Name, 
                                                                    qot.Opportunity.Name, 
                                                                    mapWholesaler.get(idWS), 
                                                                    strBoxFolderId);    
                                }
                            }
                        }
                    }
                    
                    else if (strRecordType.contains('Influencer'))
                    {
                        QuoteExt.createPDFInBoxAndEmail(qot.Id, 
                                                        'Influencer', 
                                                        null, 
                                                        qot.Unique_Id__c, 
                                                        qot.Owner.Email, 
                                                        qot.Owner.Name, 
                                                        qot.Opportunity.Name, 
                                                        qot.Name + ' (Quote Id: ' + qot.Id + ')', 
                                                        strBoxFolderId);    
                    }
                }
            }            
        }        
    }
    
    if (Trigger.isAfter && Trigger.isUpdate)
    {
        
        Set<Id> setQuote = new Set<Id>();
        Set<Id> setRejectedQuoteOppIds= new Set<Id>();
        //Set<Id> setIntApproval = new Set<Id>();
        
        Map<Id, Decimal> mapQuoteBudgetPercent = new Map<Id, Decimal>();
        Map<Id, Decimal> mapQuoteDiscountPercent = new Map<Id, Decimal>();
        List<Quote> finalQuotes = new List<Quote>();
        List<Quote> updatedQuotes = new List<Quote>();
        
        //Set<Id> setQuoteCreateAndEmailPDF = new Set<Id>();
        
        set<id> qouteId = new set<id>();
        Set<Id> setOppIds = new Set<Id>();        
      	Decimal Budget_Price_Calulate_dec;
        
        for(Quote q : Trigger.New)
        {
          if ( (Trigger.oldMap.get(q.id).Budget__c != Trigger.newMap.get(q.Id).Budget__c && Trigger.newMap.get(q.Id).Budget__c != null) || 
               (Trigger.oldMap.get(q.id).Discount__c!= Trigger.newMap.get(q.Id).Discount__c) 
             )
          {
              setQuote.add(q.Id);
              if (q.Discount__c != null) { mapQuoteDiscountPercent.put(q.Id, q.Discount__c); updatedQuotes.add(new Quote(Id=q.Id, Discount__c=null)); }
              if (q.Budget__c > 0) { mapQuoteBudgetPercent.put(q.Id, q.Budget__c); }
          }
            
          // Tectonic (MB) - LSCIP-68 - Consolidate QuoteLineItems when Quote is converted from MQ to FQ (Final) stage
          // Changed by Hanif SF Case No 00090249 Issue in Quote consolidation, Move to Quote Ext before informatica process
          if( trigger.oldMap.get(q.Id).Consolidation__c == false && trigger.newMap.get(q.Id).Consolidation__c == true ) 
          {
              finalQuotes.add(q);
              QuoteLineItemTrgHandler qliHandler = new QuoteLineItemTrgHandler();
              qliHandler.consolidateQLI(finalQuotes);
          }
            
          system.debug('ah::Trigger.oldMap' + Trigger.oldMap.get(q.Id).Num_Approvals__c);
          system.debug('ah::Trigger.newMap' + Trigger.newMap.get(q.Id).Num_Approvals__c);
  
          if (Trigger.oldMap.get(q.Id).Mark_Opportunity_as_Shipped__c != Trigger.newMap.get(q.Id).Mark_Opportunity_as_Shipped__c && Trigger.newMap.get(q.Id).Mark_Opportunity_as_Shipped__c == true)
          { 
              setQuotetoTrackOpp.add(q.Id);
              system.debug('ah::q.Mark_Opportunity_as_Shipped__c ' + q.Mark_Opportunity_as_Shipped__c);
          }
          
          if(trigger.oldMap.get(q.Id).Status != 'Rejected' && trigger.newMap.get(q.Id).Status == 'Rejected' ) 
          {
              setRejectedQuoteOppIds.add(q.OpportunityId);
          }             

           if(Trigger.oldMap.get(q.Id).Active_Quote__c != Trigger.newMap.get(q.Id).Active_Quote__c && Trigger.newMap.get(q.Id).Active_Quote__c ==true )
           {
               qouteId.add(q.id);  
               setOppIds.add(q.OpportunityId);
           }  
			
           map<Id,Id> mapAccountId = new map<Id,Id>();
            system.debug('hb::'+q.Account__c+' '+Trigger.OldMap.get(q.Id).Account__c);
            if((string.isNotBlank(q.Account__c) && Trigger.OldMap.get(q.Id).Account__c == null) || q.Account__c != Trigger.OldMap.get(q.Id).Account__c){
                mapAccountId.Put(q.Id,q.Account__c);                
            }
            system.debug('hb'+mapAccountId);
            QuoteTrgHandler.PopulateWholeSalerAgency(mapAccountId);
        }

        String brandValues='';
        Set<String> brandsList = new Set<String>();
        
        if (qouteId != null && qouteId.size() > 0)
        {
            List<Quote> listQuotes = [select Id, Active_Quote__c from Quote where Id not in :qouteId and OpportunityId = :setOppIds and Active_Quote__c=true];
            system.debug('ah:: list of quotes to be set as inactive ' + listQuotes);
            
            if (listQuotes != null && listQuotes.size() > 0)
            {
                for (Quote qot : listQuotes)
                {
                    qot.Active_Quote__c = false;
                }
                
                update listQuotes;
            }
            
            List<QuoteLineItem> listQLI = [select Product2.Brand__c from QuoteLineItem where QuoteId in :qouteId];
            
            for(QuoteLineItem qli : listQLI)
            {
                System.debug(qli.Product2.Brand__c);
                
                brandsList.add(qli.Product2.Brand__c);
                
                
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
        }
        
        System.debug('Brand Values fetched from Line items: '+brandValues );
        
        list<opportunity> updatedOpps = new List<opportunity>();
        
        if (setOppIds != null && setOppIds.size() > 0)
        {
            List<opportunity> listOpp = [select brand__c, id from opportunity  where id in :setOppIds];
            
            if (listOpp != null && listOpp.size() > 0)
            {
                for(Opportunity opp : listOpp)
                {
                    opp.brand__c= brandValues;
                    updatedOpps.add(opp);
                }
                
                update updatedOpps; 
            }
        }       
        
        if (updatedQuotes.size() > 0) { update updatedQuotes; }
        
        // Abid Raza 19/7/2018 - Send Email to project team on Quote Rejection and mark opportunity stage as Invalid.
         system.Debug('SetOfOpportunityIds::'+setRejectedQuoteOppIds);
         set<String> emailAddressesList = new set<String>();
         Set<Id> setProjectIds= new Set<Id>();
         Map<Id,Set<string>> MapProjectTeamEmails = new Map<Id,Set<string>>();
         List<Messaging.SingleEmailMessage> ListOfEmailsSent = new List<Messaging.SingleEmailMessage>();
         
        List<Opportunity> opportunities;
        
        if (setRejectedQuoteOppIds != null && setRejectedQuoteOppIds.size() > 0)
        {
        	opportunities = [Select Id,Name,StageName,RecordType.DeveloperName,CloseDate,Project__c 
                              from Opportunity where Id in:setRejectedQuoteOppIds and RecordTypeDeveloperName__c = 'Projects'];
        }
         system.Debug('ListOfOpportunities::'+opportunities);    

         if(opportunities != null && opportunities.Size() > 0)
         {
            for(Opportunity opp: opportunities)
            {
                opp.StageName = 'Invalid';
                setProjectIds.add(opp.Project__c);
            }
            
            if(setProjectIds.size() > 0)
            {
                for(Project_Team__c projTeam : [SELECT id,User__c, User__r.Email,Project__c,Role__c FROM Project_Team__c
                                                WHERE Project__c in: setProjectIds])
                {
                    for(Opportunity opp: opportunities)
                    {
                      if(opp.Project__c == projTeam.Project__c)
                      {
                        if(MapProjectTeamEmails.containsKey(opp.Id))
                        {
                            MapProjectTeamEmails.get(opp.Id).add(projTeam.User__r.Email);
                        }
                        else
                        { 
                            MapProjectTeamEmails.put(opp.Id, new set<string> { projTeam.User__r.Email });
                        }
                      }
                    }
                }
            }
            
             for(Quote q : Trigger.New)
             {
                 if(trigger.oldMap.get(q.Id).Status != 'Rejected' && trigger.newMap.get(q.Id).Status == 'Rejected' ) 
                 {
                      Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                      mail.setToAddresses(new List<string>(MapProjectTeamEmails.get(q.OpportunityId)));
                      mail.setSubject(q.Name + ' Rejected');
                      mail.setHtmlBody('<html><body> ' + System.URL.getSalesforceBaseURL().ToExternalForm() + '/' + q.Id + ' has been reject. Please click the link of quote to view the information. </body></html>');
                      System.debug('Mail::'+mail);
                      ListOfEmailsSent.add(mail);
                 }
             }
             
             Update opportunities;
             if(ListOfEmailsSent.Size() > 0)
                 Messaging.sendEmail(ListOfEmailsSent);
         }
      
        system.debug('ah::mapQuoteBudgetPercent ' + mapQuoteBudgetPercent);
        
        if (setQuote != null && setQuote.size() > 0)
        {
            List<QuoteLineItem> listQLI = [select Id, ListPrice, Requested_Price__c, QuoteId, Everyday_Price__c, Approved_Price__c, Quote.Discount__c from QuoteLineItem where QuoteId in :setQuote];
            system.debug('ah::listQLI ' + listQLI);
            
            if (listQLI != null && listQLI.size() > 0)
            {
                List<QuoteLineItem> listQLItoUpdate = new List<QuoteLineItem>();
                
                for (QuoteLineItem qli : listQLI)
                { 
                   
                    if (mapQuoteDiscountPercent.containsKey(qli.QuoteId))
                    {
                        if (qli.Everyday_Price__c != null && qli.Everyday_Price__c > 0){
                            qli.UnitPrice = qli.Everyday_Price__c  - ((qli.Everyday_Price__c * mapQuoteDiscountPercent.get(qli.QuoteId)) / 100);
                        }
                    } 
                    
                    if (mapQuoteBudgetPercent.containsKey(qli.QuoteId))
                    {
                        if (qli.Approved_Price__c != null && qli.Approved_Price__c > 0){
                            qli.Budget_Percent__c = mapQuoteBudgetPercent.get(qli.QuoteId);
                            Budget_Price_Calulate_dec = qli.Approved_Price__c + ((qli.Approved_Price__c * mapQuoteBudgetPercent.get(qli.QuoteId)) / 100);
                            qli.Budget_Price__c = Budget_Price_Calulate_dec.setScale(2);
                            
                            System.debug('badar::'+ qli.Approved_Price__c + ((qli.Approved_Price__c * mapQuoteBudgetPercent.get(qli.QuoteId)) / 100));
                        }
                    }
                    listQLItoUpdate.add(qli);
                }
                
                if (listQLItoUpdate != null && listQLItoUpdate.size() > 0)
                {
                    update listQLItoUpdate;
                    system.debug('ah::listQLItoUpdate ' + listQLItoUpdate);
                }
            }
        }

    }
    
    if (setQuotetoTrackOpp != null && setQuotetoTrackOpp.size() > 0)
    {
        
        system.debug('ah::setQuotetoTrackOpp ' + setQuotetoTrackOpp);
        
        //feedback item 43 restoring old functionality 19th July 2018 1-11 am      
        List<Quote> listQuotetoOpp = [select Id, OpportunityId, Mark_Opportunity_as_Shipped__c, QLI_Count__c, QLI_with_Shipped_Quantity_Count__c 
                                      from Quote where Id in :setQuotetoTrackOpp and Mark_Opportunity_as_Shipped__c = true];
        
        system.debug('ah::listQuotetoOpp ' + listQuotetoOpp);
        
        Set<Id> setOppId = new Set<Id>();
        
        if (listQuotetoOpp != null && listQuotetoOpp.size() > 0)
        {
            for (Quote qot : listQuotetoOpp)
            {
                setOppId.add(qot.OpportunityId);
            }
        }
        
        List<opportunity> listOpptoUpdate = new List<Opportunity>();
        
        if (setOppId != null && setOppId.size() > 0)
        {
            List<Opportunity> listOpp = [select Id, StageName, RecordType.DeveloperName from opportunity where Id in :setOppId ];
            system.debug('ah::listOpp ' + listOpp);
            
            if (listOpp != null && listOpp.size() > 0)
            {
                for (Opportunity opp : listOpp)
                {
                    if (opp.RecordType.DeveloperName == 'Display' && opp.StageName != 'Confirming Display')
                    {
                        opp.StageName = 'Confirming Display';
                        listOpptoUpdate.add(opp);                        
                    }
                    else if(opp.RecordType.DeveloperName == 'Initiative' && opp.StageName != 'Closed Won')
                    {
                        opp.StageName = 'Closed Won';
                        listOpptoUpdate.add(opp);                        
                    }
                }
            }
        }
        
        if (listOpptoUpdate != null && listOpptoUpdate.size() > 0)
        {
            update listOpptoUpdate;
            system.debug('ah::listOpptoUpdate ' + listOpptoUpdate);
        }
                
    } 
    
    if( trigger.isBefore){
        QuoteTrgHandler QuoteTrgHandlerObj = QuoteTrgHandler.getInstance();
        if( trigger.isBefore && trigger.isInsert ){
            QuoteTrgHandlerObj.onBeforeInsert(Trigger.new, Trigger.newMap);
        }else if(trigger.isBefore && trigger.isUpdate){
            QuoteTrgHandlerObj.onBeforeUpdate(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
        }
    }
}