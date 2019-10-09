trigger CopyItemBrandstoOppt on Quote (after update) 
{
    set<id> listQLIids = new set<id>();
    set<String> brandsList = new set<String>();
    set<id> qouteId = new set<id>();
    Set<Id> setOppIds = new Set<Id>();
    
    String brandValues='';
    if(trigger.isUpdate)
    {
        for(Quote qt : Trigger.New)
        {
            if(Trigger.oldMap.get(qt.Id).Active_Quote__c ==false && Trigger.oldMap.get(qt.Id).Active_Quote__c ==true )
            {
                qouteId.add(qt.id);  
                setOppIds.add(qt.OpportunityId);
            }
        }
        
        if (qouteId != null && qouteId.size() > 0)
        {
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
        /* 
for(QuoteLineItem qLItm : [select id, name, brand__c opportunityid, quote.id from QuoteLineItem where  quote.id IN:qouteId])
{
System.debug(qLItm.id +' '+qLItm.brand__c); 
}*/
    }
}