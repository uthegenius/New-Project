/*
* Created by: Tectonic (MB) on 5/27/18
* Description: (LSCIP-129) - System should be able to validate if wholesaler can be added to the project opportunity based on opportunity/quote line items. 
* Updated by       Updated on      Reason 
*/

trigger QuoteLineItemTrg on QuoteLineItem (before insert, after insert, after update, before delete, after delete, before update) 
{
    // Return if trigger is inactive from custom meta data type
    Trigger_Active_Inactive_Flag__mdt objTrgActive = [Select Flag__c from Trigger_Active_Inactive_Flag__mdt where MasterLabel = 'QuoteLineItemTrg'];
    
    If(!objTrgActive.Flag__c ) return ;
    
    Map<Id, String> mapQuoteRecordType;
    Map<Id, Boolean> mapQuoteVR = new Map<Id, Boolean>();
    Map<Id, Id> QuoteIdtoQLI= new Map<Id, Id>();
    Map<string,Id> mapBrandAgency = new Map<String,Id>();
    Map<string,List<String>> mapBrandWholeSaler = new Map<String,List<String>>();
    Map<Id,Influencers__c> mapInconsitentInfluencer = new Map<Id,Influencers__c>();
    
    if (Trigger.isBefore && (Trigger.isDelete || Trigger.isUpdate)){
        Set<Id> setQuoteId = new Set<Id>();
        Set<Id> setProjectId = new Set<Id>();
        if (Trigger.isDelete){
            Id profileId=userinfo.getProfileId();
            String profileName=[Select Name from Profile where Id=:profileId].Name;
            List<Lixil_Configuration__mdt> LixilSetting_QuoteDelete = [Select Enable_Callouts_From_Trigger_to_Box__c 
                                                                       from Lixil_Configuration__mdt 
                                                                       where DeveloperName = 'Allow_Quote_QLI_Deletion_to_Admin'
                                                                       and Enable_Callouts_From_Trigger_to_Box__c = True];
            for (QuoteLineItem qli : Trigger.Old)
            {
                
                if ((profileName != 'System Administrator' && 
                     profileName != 'Lixil System Administrator' && 
                     profileName != 'Integration System Administrator') && 
                    qli.Final_Quote__c ) 
                {
                    qli.addError('Quote cannot be deleted. Please contact your Salesforce administrator.');
                }
                else if (profileName.contains('System Administrator') && 
                         qli.Final_Quote__c &&
                         !LixilSetting_QuoteDelete.isEmpty()) 
                {
                    qli.addError('The final quote line can not be deleted. If you have an exceptional case to remove a quote line, please contact your Salesforce administrator.');
                }
                
                setQuoteId.add(qli.QuoteId);
            }
        }
        else if (Trigger.isUpdate){
            for (QuoteLineItem qli : Trigger.New)
            {
                setQuoteId.add(qli.QuoteId);
                setProjectId.add(qli.Project_Id__c);      
            }            
        }
        
        List<Quote> lstQot;
        List<Project_Agency__c> lstProject_Agency = new List<Project_Agency__c>();      
        List<Wholesalers__c> lstWholesaler = new List<Wholesalers__c>();
        if (setQuoteId != null && setQuoteId.size() > 0)
        {
            lstQot = [select Id,RecordType.DeveloperName,Consolidation__c from Quote where Id in : setQuoteId];
        }
        if (!setProjectId.isEmpty()){
            lstProject_Agency = [Select Id,Type__c,Project__c from Project_Agency__c where Project__c = :setProjectId];
            lstWholesaler = [Select Id,Wholesaler__r.Brand__c,Wholesaler__r.Name,Project__c 
                             from Wholesalers__c 
                             where Project__c = :setProjectId];
            for(Influencers__c element:[Select id,name,Project__r.Name,Project__c
                                        from Influencers__c 
                                        where Inconsistent_Contact_Account__c = true 
                                        and Project__c = :setProjectId]){
                                            mapInconsitentInfluencer.put(element.Project__c,element);
                                        }
            for(Project_Agency__c element:lstProject_Agency){
                if(string.isNotBlank(element.Type__c)){
                    if (element.Type__c == 'AS'){
                        mapBrandAgency.put(element.Project__c+'American Standard',element.Id);
                    }
                    else{
                        mapBrandAgency.put(element.Project__c+element.Type__c,element.Id);
                    }
                }
            }
            for(Wholesalers__c element:lstWholesaler){
                if(string.isNotBlank(element.Wholesaler__r.Brand__c)){
                    for(String key:element.Wholesaler__r.Brand__c.split(';')){
                        key=element.Project__c+key;
                        List<String> oldVal = new List<String>();
                        if(mapBrandWholeSaler.containsKey(key)){
                            oldVal = mapBrandWholeSaler.get(key);
                        }
                        oldVal.add(element.Wholesaler__r.Name);
                        mapBrandWholeSaler.put(Key,oldVal);
                    }
                }                    
            }
            
        }
        mapQuoteRecordType = new Map<Id, String>();
        mapQuoteVR = new Map<Id, Boolean>();
        
        if (lstQot != null && lstQot.size() > 0)
        {
            for (Quote q : lstQot)
            {
                mapQuoteRecordType.put(q.Id, q.RecordType.DeveloperName);
                mapQuoteVR.put(q.Id, q.Consolidation__c);
                
            }
            
        }  
        
    }
    
    if (Trigger.isAfter && (Trigger.isDelete || Trigger.isUpdate)){
        Set<Id> setQuoteId = new Set<Id>();
        Set<Id> setOppId = new Set<Id>();
        
        Map<Id, Id> QuoteIdtoQLI= new Map<Id, Id>();
        
        if (Trigger.isDelete)        
        {
            for (QuoteLineItem qli : Trigger.Old)
            {
                setQuoteId.add(qli.QuoteId);
                QuoteIdtoQLI.put(qli.QuoteId,qli.id);
            }
        }
        else if (Trigger.isUpdate)
        {
            
            for (QuoteLineItem qli : Trigger.New)
            {
                setQuoteId.add(qli.QuoteId);
                QuoteIdtoQLI.put(qli.QuoteId,qli.id);
                
            }  
        }
        
        List<Quote> lstQot;
        Map<Id,Id> mapquotetoOpp  = new Map<id,id>();
        if (setQuoteId != null && setQuoteId.size() > 0)
        {
            lstQot = [select Id,First_Order_Date__c,OpportunityId from Quote where Id in : setQuoteId];
            
        }
        
        Map<id,Quote> mapQuoteIdtoQuote = new Map<id,Quote>();
        List<QuoteLineItem>  minDOBRecord = new List<QuoteLineItem>();
        List<AggregateResult> arrResult  = new List<AggregateResult>();
        if (lstQot != null && lstQot.size() > 0)
        {
            for (Quote q : lstQot)
            {
                mapQuoteIdtoQuote.put(q.id,q);
                mapquotetoOpp.put(q.id,q.OpportunityId);
            }
            
            arrResult = [Select QuoteId,MIN(First_Order_Date_Farmula__c) dt,Quote.OpportunityId OppId  From QuoteLineItem where QuoteId IN: lstQot and First_Order_Date_Farmula__c!=null Group By QuoteId,Quote.OpportunityId ];
            
        }
        
        List<Quote> quoteList =  new List<Quote>();
        List<Opportunity> OppList = new List<Opportunity>();
        if(arrResult!= null && arrResult.size()>0)
        {
            for(AggregateResult qli:arrResult)
            {                    
                quoteList.add(new Quote(id = string.valueof(qli.get('QuoteId')),
                                        First_Order_Date__c = Date.valueof(qli.get('dt'))));
                OppList.add(new Opportunity(id = string.valueof(qli.get('OppId')),
                                            First_Order_Date__c = Date.valueof(qli.get('dt'))));
            }
        }
        if (!quoteList.isEmpty())
        {
            try{
                update quoteList;
            }
            Catch(Exception e)
            {
                system.debug('Exception'+e);
            }
        }
        if (!OppList.isEmpty())
        {
            try{
                update OppList;
            }
            Catch(Exception e)
            {
                system.debug('Exception'+e);
            }   
        }        
    }
    
    // Abid Raza - 19/7/2018 - Day3 IssueLog(#63) - GM $ and GM % values to put in 2 new fields Requested GM $ & Requested GM % respectively.
    if (Trigger.isBefore && Trigger.isUpdate){
        List<qli_fields__c> listQF;
        if (!Test.isRunningTest() && Trigger.oldMap != Trigger.newMap)
        {
            listQF = [select name, api_name__c from qli_fields__c];
        }
        
        for (QuoteLineItem qli : Trigger.New)    
        { 
            if(mapBrandAgency.containsKey(qli.Project_Id__c+qli.QLI_Brand__c)){
                qli.Project_Agency__c = mapBrandAgency.get(qli.Project_Id__c+qli.QLI_Brand__c);
            }
            if(mapBrandWholeSaler.containsKey(qli.Project_Id__c+qli.QLI_Brand__c)){
                
                qli.Wholesalers__c = string.join(mapBrandWholeSaler.get(qli.Project_Id__c+qli.QLI_Brand__c),', ') ;
            }
            
            if(mapInconsitentInfluencer.containsKey(qli.Project_Id__c)){                
                qli.addError('The project '+mapInconsitentInfluencer.get(qli.Project_Id__c).Project__r.Name+' defines inconsistent influencer records. Please edit the influencer record '+ mapInconsitentInfluencer.get(qli.Project_Id__c).Name +' and correct account and contact information.');
            }
            if (mapQuoteRecordType.containsKey(qli.QuoteId) && (mapQuoteRecordType.get(qli.QuoteId)  == 'Locked_Standard_Quote' || mapQuoteRecordType.get(qli.QuoteId)  == 'Locked_Influencer_Quote') && !mapQuoteVR.get(qli.QuoteId) )
            {
                if (listQF != null && listQF.size() > 0)
                {
                    for (qli_fields__c qf : listQF)
                    {
                        if (trigger.oldMap.get(qli.Id).get(qf.Api_Name__c) != trigger.newMap.get(qli.Id).get(qf.Api_Name__c)) 
                        {
                            qli.addError('Quote line item cannot be modified. Please contact your Salesforce administrator. '+qf.Api_Name__c);
                        }
                    }
                }
            }
            else
            {
                if(qli.GM__c != Trigger.OldMap.get(qli.Id).GM__c)
                {
                    qli.Requested_GM__c = qli.GM__c;
                }
                
                if(qli.GM_Percentage__c != Trigger.OldMap.get(qli.Id).GM_Percentage__c)
                {
                    qli.Requested_GM_Per__c  = qli.GM_Percentage__c;
                }
                
                if(qli.Product2Id != null)
                {
                    if(qli.Product2Id != Trigger.OldMap.get(qli.Id).Product2Id)
                    {
                        qli.SAP_ProductCode__c = qli.Product2.SAP_Product_Code__c;
                    }
                }
                else
                {
                    qli.SAP_ProductCode__c = '';
                }
            }
            
        }
        
        
    }
    
    if (Trigger.isBefore && Trigger.isDelete){
        Id profileId=userinfo.getProfileId();
        String profileName=[Select Name from Profile where Id=:profileId].Name;
        
        
        for (QuoteLineItem qli : Trigger.Old) 
        {
            
            if ( profileName != 'System Administrator' && profileName != 'Lixil System Administrator' && profileName != 'Integration System Administrator' 
                && (mapQuoteRecordType.containsKey(qli.QuoteId) 
                    && mapQuoteRecordType.get(qli.QuoteId) != 'Influencer_Quote' && mapQuoteRecordType.get(qli.QuoteId) != 'Standard_Quote'))
            {
                qli.addError('Quote line item cannot be deleted. Please contact your Salesforce administrator.');
            }
        }
    }
    
    if (Trigger.isBefore && Trigger.isInsert){
        //Change by Andrew- Deployemnt Testing Issue Sheet - Issue No 23
        set<id> setQliId = new set<id>();
        
        for (QuoteLineItem qli : Trigger.New)    
        {
            if(qli.Product2Id != null)
            {
                qli.SAP_ProductCode__c = qli.Product2.SAP_Product_Code__c;
            }
        }
        
        QuoteLineItemTrgHandler qliHandler = new QuoteLineItemTrgHandler();
        
    }
    
    if (Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate || Trigger.isDelete)){    
        Set<Id> setQuoteId = new Set<Id>();
        Set<Id> setQuoteLineId = new Set<Id>();
        Set<Id> setUpdateReviewPrice = new Set<Id>();
        
        set<String> brandsList = new set<String>();
        Set<Id> setQuoteLineIdAfterDelete = new Set<Id>();
        Set<Id> setQuoteIdAfterDelete = new Set<Id>();
        
        if (!Trigger.isDelete)
        {
            for (QuoteLineItem qli : Trigger.New)
            {
                if (Trigger.isInsert) 
                {    
                    setQuoteId.add(qli.QuoteId);
                    setQuoteLineId.add(qli.Id);
                } 
                else if (Trigger.isUpdate)  
                {
                    if (Trigger.oldMap.get(qli.Id).Everyday_Price__c != Trigger.newMap.get(qli.Id).Everyday_Price__c) 
                    {
                        setQuoteId.add(qli.QuoteId);
                        setQuoteLineId.add(qli.Id);
                    }
                    
                    if (!Userinfo.getName().contains('Integration') && Trigger.oldMap.get(qli.Id).UnitPrice != Trigger.newMap.get(qli.Id).UnitPrice) 
                    {
                        setUpdateReviewPrice.add(qli.QuoteId);
                    }
                }   
            }  
        }
        
        if (Trigger.isDelete) 
        { 
            for (QuoteLineItem qli : Trigger.Old)
            {
                setQuoteLineIdAfterDelete.add(qli.Id);
                setQuoteIdAfterDelete.add(qli.QuoteId);
            }
        }
        
        if (setUpdateReviewPrice != null && setUpdateReviewPrice.size() > 0)
        {
            List<Quote> lstQuotePR = [select Id, Review_Price__c from Quote where Id in :setUpdateReviewPrice];
            
            if (lstQuotePR != null && lstQuotePR.size() > 0)
            {
                for (Quote q : lstQuotePR)
                {
                    q.Review_Price__c = false;
                }
                
                update lstQuotePR;
            }
        }
        
        
        Map<Id, Decimal> mapQuoteBudgetPercent = new Map<Id, Decimal>();
        Map<Id, Decimal> mapQuoteDiscountPercent = new Map<Id, Decimal>();
        Map<Id, String> mapAccountNumber = new Map<Id, String>();
        /*
List<Quote> finalQuotes = [SELECT Id FROM Quote WHERE Id IN: setQuoteId AND Final_Quote__c = true];
if(finalQuotes.size() > 0 ) 
{
QuoteLineItemTrgHandler qliHandler = new QuoteLineItemTrgHandler();
qliHandler.consolidateQLI(finalQuotes); 
}
*/
        if (setQuoteId != null && setQuoteId.size() > 0)
        {
            List<Quote> listQuote = [select Id, Budget__c, Discount__c, Opportunity.Account.Account_Number__c, RecordType.DeveloperName from Quote where id in :setQuoteId];
            
            if (listQuote != null && listQuote.size() > 0)
            {
                for (Quote q : listQuote)
                {
                    if (q.Budget__c != null && q.RecordType.DeveloperName == 'Influencer_Quote')
                    {
                        mapQuoteBudgetPercent.put(q.Id, q.Budget__c);
                    }
                    
                    //if (q.Discount__c > 0) { mapQuoteDiscountPercent.put(q.Id, q.Discount__c); }
                    
                    mapAccountNumber.put(q.Id, q.Opportunity.Account.Account_Number__c);
                }
            }
        }
        
        List<QuoteLineItem> listQLItoUpdate = new List<QuoteLineItem>();
        
        Boolean isRecordChanged = false;
        
        if (Trigger.isInsert)
        {
            if (setQuoteId != null && setQuoteId.size() > 0 ) 
            {
                map<Id,Id> mapAccountId = new map<Id,Id>();
                for (QuoteLineItem qli : [select Id, Product2.Brand__c, Quote.Active_Quote__c,Quote.Account__c,QuoteId from QuoteLineItem where QuoteId in :setQuoteId ])
                {
                    if (qli.Quote.Active_Quote__c == true)
                    {
                        brandsList.add(qli.Product2.Brand__c);
                    }                
                    if(string.isNotBlank(qli.Quote.Account__c)){
                        mapAccountId.Put(qli.QuoteId,qli.Quote.Account__c);    
                    }
                }    
                if(!mapAccountId.isEmpty()){
                    QuoteTrgHandler.PopulateWholeSalerAgency(mapAccountId);
                }
            }
        }
        
        if (setQuoteLineId != null && setQuoteLineId.size() > 0)
        {
            for (QuoteLineItem qli : [select Id, UnitPrice, ListPrice, Everyday_Price__c, QuoteId, LineNumber, Quote.Opportunity.RecordType.Name, Product2.ProductCode, Unique_ID__c, IsCloned__c, Quote.Discount__c, Approved_Price__c, Product2.Brand__c, Quote.Active_Quote__c from QuoteLineItem where Id in :setQuoteLineId ])
            {
                
                isRecordChanged = false;
                
                if (!qli.isCloned__c){
                    
                    if (qli.Everyday_Price__c != null && qli.Everyday_Price__c > 0 ) {
                        qli.UnitPrice = qli.Everyday_Price__c;
                        isRecordChanged = true;
                    }
                    
                    if (mapQuoteBudgetPercent.containsKey(qli.QuoteId))
                    {
                        if (qli.Approved_Price__c != null && qli.Approved_Price__c > 0){
                            qli.Budget_Percent__c = mapQuoteBudgetPercent.get(qli.QuoteId);
                            qli.Budget_Price__c = qli.Approved_Price__c + ((qli.Approved_Price__c * mapQuoteBudgetPercent.get(qli.QuoteId)) / 100);
                            isRecordChanged = true;
                        }
                    }
                }
                
                if (mapAccountNumber.containsKey(qli.QuoteId) && qli.Quote.Opportunity.RecordType.Name != 'Projects')
                {            
                    qli.Unique_ID__c = mapAccountNumber.get(qli.QuoteId) + '-' + qli.LineNumber + '-' + qli.Product2.ProductCode;
                    isRecordChanged = true;
                }
                
                if (isRecordChanged)
                {
                    listQLItoUpdate.add(qli); 
                }
                
                
            }
        }
        
        
        if (setQuoteIdAfterDelete != null && setQuoteIdAfterDelete.size() > 0)
        {
            for (QuoteLineItem qli : [select Id, Product2.Brand__c from QuoteLineItem where QuoteId in :setQuoteIdAfterDelete and Quote.Active_Quote__c = true ])
            {
                brandsList.add(qli.Product2.Brand__c);
            }
            
        }
        
        if (listQLItoUpdate != null && listQLItoUpdate.size() > 0)
        {
            update listQLItoUpdate;            
        }        
        
        if (Trigger.isInsert || Trigger.isDelete)
        {
            Integer count=0;
            String brandValues='';
            
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
            
            List<Opportunity> lstOpp;
            
            system.debug('ah::setQuoteId ' + setQuoteId);
            system.debug('ah::setQuoteIdAfterDelete ' + setQuoteIdAfterDelete);
            
            if ((setQuoteId != null && setQuoteId.size() > 0)  || (setQuoteIdAfterDelete != null && setQuoteIdAfterDelete.size() > 0))
            {
                lstOpp = [select brand__c, id from opportunity  where id IN (select opportunityid from quote where id IN :setQuoteId or Id in :setQuoteIdAfterDelete)];
            }
            
            if (lstOpp != null && lstOpp.size() > 0)
            {
                for(Opportunity opp : lstOpp)
                {
                    opp.brand__c= brandValues;
                    updatedOpps.add(opp);
                }
                update updatedOpps; 
            }            
        }
        
    }
    
    
}