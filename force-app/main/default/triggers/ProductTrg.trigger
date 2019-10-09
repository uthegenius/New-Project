trigger ProductTrg on Product2 (after Update, before insert, after insert) 
{
    if(trigger.IsAfter && Trigger.IsUpdate)
    {    
        set<Id> SetProductIds = new set<Id>();
        
        for(Product2 prod: Trigger.New)
        {
            if(prod.Discontinue_date__c != null && prod.Discontinue_date__c >= Date.Today() && prod.Discontinue_date__c != Trigger.OldMap.get(prod.Id).Discontinue_date__c)
            {
                SetProductIds.add(prod.Id);
            }
        }
        
        system.Debug('SetProductIds::'+SetProductIds);
        
        if(SetProductIds.size() > 0)
        {
            Database.executeBatch(new ProductDiscontinuationEmailBatch(SetProductIds));
        }
    }
    ProductTrgHandler ProductTrgHandlerObj = new ProductTrgHandler(); 
    if(trigger.isBefore && trigger.isInsert){
        ProductTrgHandlerObj.OnBeforeInsert( Trigger.new, Trigger.newMap );
    }else if(trigger.isAfter && trigger.isInsert){
        ProductTrgHandlerObj.OnAfterInsert( Trigger.new, Trigger.newMap );
    }
}