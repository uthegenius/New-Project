trigger OrderTrg on Order (before insert, before update, after insert, after update) 
{
     // Return if trigger is inactive from custom meta data type
    Trigger_Active_Inactive_Flag__mdt objTrgActive = [Select Flag__c from Trigger_Active_Inactive_Flag__mdt where MasterLabel = 'OrderTrg'];
    if(!objTrgActive.Flag__c ) return ;
    
    OrderTrgHandler handler = new OrderTrgHandler();
    
    // Before Insert
    if(Trigger.isInsert && Trigger.isBefore)
    {
        handler.OnBeforeInsert(Trigger.new, Trigger.newMap);
    }
    
    // Before Update
    else if(Trigger.isUpdate && Trigger.isBefore)
    {
        handler.OnBeforeUpdate(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
    }
    
    // After Insert
    else if(Trigger.isInsert && Trigger.isAfter)
    {
        et4ae5.triggerUtility.automate('Order');
    }
    
    // After Update
    else if(Trigger.isUpdate && Trigger.isAfter)
    {
        et4ae5.triggerUtility.automate('Order');
    }
    
}