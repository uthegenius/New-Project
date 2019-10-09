/************************
Author:         Azfer Pervaiz
Created Date:   30/May/2018 
Purpose:        This Trigger will be used for automation that will be customized on the account object.

************************MODIFICATION HISTORY**************************************
Added on             Added By         		Description
**********************************************************************************
30/May/2018          Azfer Pervaiz       	Initial Development 
***********************************************************************************/

trigger AccountTrg on Account (before insert, before update, after insert, after update) {
    
	// Return if trigger is inactive from custom meta data type
    Trigger_Active_Inactive_Flag__mdt objTrgActive = [Select Flag__c from Trigger_Active_Inactive_Flag__mdt where MasterLabel = 'AccountTrg'];
    
    if(!objTrgActive.Flag__c )
        return ;
	
	//Trigger automation on before insertion or update
	AccountTrgHelper AccountTrgHelperObj = new AccountTrgHelper();
	
	if( Trigger.isInsert && Trigger.isBefore ){
		
		AccountTrgHelperObj.onBeforeInsert( Trigger.new, Trigger.newMap );		
	
	}else if( Trigger.isInsert && Trigger.isAfter ){
		
		AccountTrgHelperObj.OnAfterInsert( Trigger.new, Trigger.newMap );
	
	}else if( Trigger.isUpdate && Trigger.isBefore ){
		
		AccountTrgHelperObj.onBeforeUpdate( Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap );
	
	}else if( Trigger.isUpdate && Trigger.isAfter ){
		
		AccountTrgHelperObj.onAfterUpdate( Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap );

	}

}