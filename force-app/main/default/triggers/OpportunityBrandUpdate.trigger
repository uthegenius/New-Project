trigger OpportunityBrandUpdate on QuoteLineItem (after update) {

    set<id> setProduct2Id= new set<id>();
    set<String> brandsList = new set<string>();
    
    if (Trigger.isUpdate)
    {
      for (QuoteLineItem qli : Trigger.New)
      {
         setProduct2Id.add(qli.Product2Id);
         
      }            
    }
    
    
    
}