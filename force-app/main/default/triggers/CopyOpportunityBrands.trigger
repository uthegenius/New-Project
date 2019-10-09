trigger CopyOpportunityBrands on QuoteLineItem (after insert , after delete) {

    set<id> listProdcutIds = new set<id>();
    set<id> listQLIids = new set<id>();
    set<id> setQuoteIdList = new set<id>();
    set<String> brandsList = new set<String>();
    String brandValues='';
    
    if(trigger.isInsert || trigger.isDelete)
    {
        if (Trigger.isInsert)
        {
           for (QuoteLineItem qli : Trigger.New)
           {
                    //listProdcutIds.add(qli.QuoteId);
                    listQLIids.add(qli.id);
                    setQuoteIdList .add(qli.quoteid);
           }   
        }
        
        if (Trigger.isDelete)
        {
           for (QuoteLineItem qli : Trigger.Old)
           {
                    //listProdcutIds.add(qli.QuoteId);
                    listQLIids.add(qli.id);
                    setQuoteIdList .add(qli.quoteid);
           }   
        }        

        
       list<QuoteLineItem> qliList =[select Product2.Brand__c from QuoteLineItem where QuoteId in :setQuoteIdList];
        
       for(QuoteLineItem qli : qliList)
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
       //brandValues=brandValues +';';
       System.debug('Brand Values fetched from Line items: '+brandValues );
       list<opportunity> updatedOpps = new List<opportunity>();
        
       List<Opportunity> lstOpp;
        
       if (setQuoteIdList != null && setQuoteIdList.size() > 0)  
       {
       		lstOpp = [select brand__c, id from opportunity  where id IN (select opportunityid from quote where id IN :setQuoteIdList)];
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
       
       /*for(Quote QuoteList: [select id from Quote where Active_Quote__c=true])
       {
           System.debug(QuoteList.id);
       } */
    }
}