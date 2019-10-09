/*-------------------------------------------------------------------------------------------------
Author:             
Date:               
Version:            1.0
Description:        
----------------------------------------------------------------------------------------------------*/
/************************MODIFICATION HISTORY*************************************

***********************************************************************************/

public class Order_NewOrderCreationCtrl {
    
    
    //Method that fetches recordtype information via metadata api call
    @AuraEnabled
    public static list<string> fetchRecordTypeValues()
    {
        Map<Id, String > mapOfRecordtype;
        
        List<Schema.RecordTypeInfo> recordtypes = Order.SObjectType.getDescribe().getRecordTypeInfos();    
        //mapOfRecordtype = new Map<Id, String>();
        list<string> result= new list<string>();
        Set<string> recordTypeName = new Set<string>();        
        recordTypeName.add('Warranty_Replacement_Order');
        recordTypeName.add('Good_Will_Order');       
        recordTypeName.add('FOC');
        recordTypeName.add('Credit_Card_Sales');
        for(RecordTypeInfo rt : recordtypes)
        {
            if(rt.getName() != 'Master' && rt.isActive() && rt.isAvailable() &&recordTypeName.contains(rt.getDeveloperName())){
                //mapOfRecordtype.put(rt.getRecordTypeId(), rt.getName());
                result.add(rt.getName());
            }
        }
        
        List<String> finalList = new List<String>();
        for(Integer i = result.size()-1; i>=0;i--)
        {
            finalList.add(result.get(i));
        }
        return finalList;
    }
    
    @AuraEnabled
    public static objWrpClass getRecTypeId(String recordTypeLabel)
    {
        Id recid = Schema.SObjectType.Order.getRecordTypeInfosByName().get(recordTypeLabel).getRecordTypeId();        
        objWrpClass objClassRet = new objWrpClass();
        objClassRet.recTypeId = string.valueOf(recid);
        objClassRet.uiTheme = UserInfo.getUiThemeDisplayed();
        
        List<User> userList = new List<User>();
        Id userId = UserInfo.getUserId();
        userList = [Select id,Call_Center__c,Region__c From User Where id=:userId];
        if(userList[0].Region__c!=null)
        {
            
            objClassRet.userRegion=userList[0].Region__c;
        }
        
        
        if(userList[0].Call_Center__c!=null)
        {
            
            objClassRet.callCenter=userList[0].Call_Center__c;
        }
        
        
        
        
        
        return objClassRet;
    }
    
    
    public class objWrpClass 
    {
        @AuraEnabled public String recTypeId{get;set;}
        @AuraEnabled public String uiTheme{get;set;}
        @AuraEnabled public String userRegion{get;set;}
        @AuraEnabled public String callCenter{get;set;}
    }
}