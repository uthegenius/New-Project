/************************
Author:         Azfer Pervaiz
Created Date:   18/July/2018 
Purpose:        Asset Trg.

************************MODIFICATION HISTORY**************************************
Added on             Added By               Description
**********************************************************************************
18/July/2018          Azfer Pervaiz          Initial Development 
***********************************************************************************/
trigger AssetTrg on Asset (before insert, before Update, after insert,after update) {
    
	Trigger_Active_Inactive_Flag__mdt objTrgActive = [Select Flag__c from Trigger_Active_Inactive_Flag__mdt where MasterLabel = 'AssetTrg'];
    
    if(!objTrgActive.Flag__c )
        return ;

    AssetTrgHandler AssetTrgHandlerObj = new AssetTrgHandler();

    if( Trigger.isInsert && Trigger.isBefore ){
        AssetTrgHandlerObj.OnBeforeInsert(Trigger.new, Trigger.newMap);
    }else if( Trigger.isUpdate && Trigger.isBefore ){
        AssetTrgHandlerObj.onBeforeUpdate(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);            
    }
    else if( Trigger.isInsert && Trigger.isAfter ){
        AssetTrgHandlerObj.onAfterInsert(Trigger.new, Trigger.newMap);            
    }
    else if( Trigger.isUpdate && Trigger.isAfter ){
        AssetTrgHandlerObj.onAfterUpdate(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);            
    } 
}