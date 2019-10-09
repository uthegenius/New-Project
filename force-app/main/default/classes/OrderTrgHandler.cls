/*-------------------------------------------------------------------------------------------------
Author:             
Date:               
Version:            1.0
Description:        Order Trigger Handler
----------------------------------------------------------------------------------------------------*/
/************************MODIFICATION HISTORY*************************************

***********************************************************************************/

public class OrderTrgHandler {
    public void onBeforeInsert(List<Order> newObjects, Map<Id, Order> newMap){  
        List<Order> ListOrderToUpdate = new List<Order>();
        List<Order> ListOoderToPopulatePONumber = new List<Order>();
        
        Set<String> SetRecordTypeName = new Set<String>();
        Set<String> SetOrderType = new Set<String>();
        Set<String> SetOwner = new Set<String>();
        for(Order OrderObj : newObjects ){
            if( OrderObj.Order_Type__c != null && OrderObj.Record_Type_Developer_Name__c != null){
                
                OrderObj.Expected_Delivery_Date__c = Date.Today();
                
                ListOrderToUpdate.add(OrderObj);
                SetRecordTypeName.add(OrderObj.Record_Type_Developer_Name__c);
                SetOrderType.add(OrderObj.Order_Type__c);
                SetOwner.add(OrderObj.OwnerId);
            }
            
            if( String.isNotBlank(OrderObj.Case__c) && String.isBlank(OrderObj.PoNumber)){
                ListOoderToPopulatePONumber.add( OrderObj );
            }
        }
        
        if( ListOrderToUpdate.size() > 0 ){
            PopulateOrderDefault(ListOrderToUpdate, SetRecordTypeName, SetOrderType,SetOwner);
        }
        
        if( ListOoderToPopulatePONumber.size() > 0 ){
            PopulatePONumber( ListOoderToPopulatePONumber );
        }
    }

    public void onAfterInsert(List<Order> newObjects){
        //Get QuoteIds from inserted orders
        List<string> quoteIds = new List<string>();
        for(Order order : newObjects){
            quoteIds.add(order.QuoteId);
        }
        
        List<Id> quotes = new List<Id>(new Map<Id, Quote>([SELECT Id FROM Quote WHERE Id IN:quoteIds AND Active_Quote__c=true]).keySet());
        
        if(quotes.size() > 0){
            List<Opportunity> opportunities = [SELECT Id, StageName FROM Opportunity WHERE FinalQuote__c IN:quotes];
            for(Opportunity opp : opportunities){
                opp.StageName = 'Closed Won';
            }
            update opportunities;
    System.debug('In Order Trigger After Insert');
    System.debug(opportunities);
        }

    }
    
    public void onBeforeUpdate(List<Order> oldObjects, List<Order> newObjects, Map<Id, Order> oldMap, Map<Id, Order> newMap){   
        
        List<Order> ListOrderToUpdate = new List<Order>();
        List<Order> ListOoderToPopulatePONumber = new List<Order>();
        
        Set<String> SetRecordTypeName = new Set<String>();
        Set<String> SetOrderType = new Set<String>();
        Set<String> SetOwner = new Set<String>();
        
        Order OlderOrderObj;
        for(Order OrderObj : newObjects ){
            OlderOrderObj = oldMap.get( OrderObj.Id );
            if( OrderObj.Order_Type__c != null && OrderObj.Record_Type_Developer_Name__c != null && OrderObj.Net_Amount__c != null && (
                OrderObj.Order_Type__c != OlderOrderObj.Order_Type__c || 
                OrderObj.isOrderAmountApproved__c==False||
                OrderObj.Standard_Cost__c != OlderOrderObj.Standard_Cost__c || // Add by hanif to run if Custom Order Amount field changed.
                OrderObj.Record_Type_Developer_Name__c != OlderOrderObj.Record_Type_Developer_Name__c ||
                OrderObj.Net_Amount__c != OlderOrderObj.Net_Amount__c ) ){
                    
                    ListOrderToUpdate.add(OrderObj);
                    SetRecordTypeName.add(OrderObj.Record_Type_Developer_Name__c);
                    SetOrderType.add(OrderObj.Order_Type__c);
                    SetOwner.add(OrderObj.OwnerId);
                }
            
            if( String.isNotBlank(OrderObj.Case__c) && String.isBlank(OrderObj.PoNumber) &&
               ( OrderObj.Case__c != OlderOrderObj.Case__c || OrderObj.CaseContactLastName__c != OlderOrderObj.CaseContactLastName__c || 
                OrderObj.CaseContactFirstName__c != OlderOrderObj.CaseContactFirstName__c || OrderObj.CaseNumber__c != OlderOrderObj.CaseNumber__c ) ){
                    
                    ListOoderToPopulatePONumber.add( OrderObj );
                }
        }
        
        if( ListOrderToUpdate.size() > 0 ){
            PopulateOrderDefault(ListOrderToUpdate, SetRecordTypeName, SetOrderType,SetOwner);
        }
        
        if( ListOoderToPopulatePONumber.size() > 0 ){
            PopulatePONumber( ListOoderToPopulatePONumber );
        }
    }
    
    private void PopulateOrderDefault(List<Order> paramListOrderToUpdate, Set<String> paramSetRecordTypeName, Set<String> paramSetOrderType,Set<String> paramSetOwner){
        Set<String> UserCallCenter = new Set<String>();
        Set<String> UserCountry = new Set<String>();
        map<string,User> mapOwner = new map<string,User>([SELECT Id,Region__c, Call_Center__C FROM User WHERE Id = :paramSetOwner ]);
        
        for(User UserObj:mapOwner.values())
        {
            if(string.isNotBlank(UserObj.Region__c)){
                UserCountry.add(UserObj.Region__c);
            }
            
            if(string.isNotBlank(UserObj.Call_Center__C)){
                UserCallCenter.add(UserObj.Call_Center__C);
            }
        }
        
        String Key;
        map<string,CurrencyType> mapCurrency = new map<string,CurrencyType>();
        for(CurrencyType rec:[SELECT ISOCode, ConversionRate FROM CurrencyType WHERE IsActive=TRUE])
        {
            mapCurrency.put(rec.ISOCode, rec);
        }
        system.debug(paramSetRecordTypeName);        
        system.debug(paramSetOrderType);        
        system.debug(UserCallCenter);
        system.debug(UserCountry);
        SYSTEM.debug([SELECT Call_Center__c, Country_Code__c, 
                      Order_Record_Type__c, Order_Sub_Type__c, Order_Type__c
                      FROM Order_Cost_Center_Setup__c
                      WHERE Order_Record_Type__c IN : paramSetRecordTypeName
                      AND Order_Type__c IN : paramSetOrderType
                      AND Call_Center__c IN :UserCallCenter
                      AND Country_Code__c IN :UserCountry
                     ]);
        Map<String,Order_Cost_Center_Setup__c> MapOrderCostCenterSetup = new Map<String,Order_Cost_Center_Setup__c>();
        for( Order_Cost_Center_Setup__c OrderCostCenterSetupObj : [	SELECT Id, Approver_1__c, Approver_1_Max_Amount__c, Approver_1_Min_Amount__c,
                                                                   Approver_2__c, Approver_2_Max_Amount__c, Approver_2_Min_Amount__c,
                                                                   Approver_3__c, Approver_3_Max_Amount__c, Approver_3_Min_Amount__c,
                                                                   Call_Center__c, Country_Code__c,  Cost_Center_Sold_to__c, Credit_Card_Authorization__c, 
                                                                   Customer_Material_Number__c, Distribution_Channel__c, Division__c, Order_Record_Type__c, 
                                                                   Order_Sub_Type__c, Order_Type__c, Reason_Code__c, Sales_Organization__c, Ship_to__c,CurrencyISOCode,
                                                                   ZZASBOI2__c,Merchant_ID__c
                                                                   FROM Order_Cost_Center_Setup__c
                                                                   WHERE Order_Record_Type__c IN : paramSetRecordTypeName
                                                                   AND Order_Type__c IN : paramSetOrderType
                                                                   AND Call_Center__c IN :UserCallCenter
                                                                   AND Country_Code__c IN :UserCountry ] )
        {
            Key = OrderCostCenterSetupObj.Call_Center__c+'-'+OrderCostCenterSetupObj.Country_Code__c+'-'+OrderCostCenterSetupObj.Order_Record_Type__c+'-'+OrderCostCenterSetupObj.Order_Type__c;
            MapOrderCostCenterSetup.put( Key.toLowerCase(), OrderCostCenterSetupObj );
        }
        system.debug(MapOrderCostCenterSetup);
        for( Order OrderObj : paramListOrderToUpdate ){			
            Key = string.valueOf(mapOwner.get(OrderObj.OwnerId).Call_Center__C) +'-'+
                string.valueOf(mapOwner.get(OrderObj.OwnerId).Region__c) +'-'+
                OrderObj.Record_Type_Developer_Name__c+'-'+OrderObj.Order_Type__c;			
            Order_Cost_Center_Setup__c OrderCostCenterSetupObj;
            if( MapOrderCostCenterSetup.get( Key.toLowerCase() ) != null ){
                OrderCostCenterSetupObj = MapOrderCostCenterSetup.get( Key.toLowerCase() );				
                //OrderObj.Sold_to_Party__c =  OrderCostCenterSetupObj.Cost_Center_Sold_to__c;
                OrderObj.AccountId =  OrderCostCenterSetupObj.Cost_Center_Sold_to__c;
                OrderObj.Credit_Card_Authorization__c =  OrderCostCenterSetupObj.Credit_Card_Authorization__c;
                OrderObj.Customer_Material_Number__C =  OrderCostCenterSetupObj.Customer_Material_Number__c;
                OrderObj.Distribution_Channel__c =  OrderCostCenterSetupObj.Distribution_Channel__c;
                OrderObj.Division__c =  OrderCostCenterSetupObj.Division__c;
                OrderObj.Order_Sub_Type__c =  OrderCostCenterSetupObj.Order_Sub_Type__c;
                OrderObj.xReason_Code__c =  OrderCostCenterSetupObj.Reason_Code__c;
                OrderObj.Sales_Organization__c =  OrderCostCenterSetupObj.Sales_Organization__c;
                OrderObj.Ship_to_Party__c =  OrderCostCenterSetupObj.Ship_to__c;
                OrderObj.Approver__c  = null;
                OrderObj.Merchant_ID__c = OrderCostCenterSetupObj.Merchant_ID__c;
                OrderObj.ZZASBOI2__c = OrderCostCenterSetupObj.ZZASBOI2__c;
                Double conversionRate = 1;
                if (
                    OrderCostCenterSetupObj.CurrencyISOCode != OrderObj.CurrencyISOCode &&
                    mapCurrency.containsKey(OrderObj.CurrencyISOCode)){
                        conversionRate = Double.valueOf(mapCurrency.get(OrderObj.CurrencyISOCode).ConversionRate);
                    }
                
                if( OrderCostCenterSetupObj.Approver_1_Min_Amount__c != null && OrderCostCenterSetupObj.Approver_1_Max_Amount__c != null && 
                   OrderObj.Standard_Cost__c<(OrderCostCenterSetupObj.Approver_1_Min_Amount__c/conversionRate)){
                       OrderObj.isOrderAmountApproved__c = OrderObj.isOrder_Simulator__c;
                   }
                else if( OrderCostCenterSetupObj.Approver_1_Min_Amount__c != null && OrderCostCenterSetupObj.Approver_1_Max_Amount__c != null && 
                        (OrderCostCenterSetupObj.Approver_1_Min_Amount__c/conversionRate) <= OrderObj.Standard_Cost__c && OrderObj.Standard_Cost__c < (OrderCostCenterSetupObj.Approver_1_Max_Amount__c/conversionRate) ){
                            OrderObj.isOrderAmountApproved__c = False;
                            OrderObj.Approver__c = OrderCostCenterSetupObj.Approver_1__c;
                            
                        }else if( OrderCostCenterSetupObj.Approver_2_Min_Amount__c != null && OrderCostCenterSetupObj.Approver_2_Max_Amount__c != null && 
                                 (OrderCostCenterSetupObj.Approver_2_Min_Amount__c/conversionRate) <= OrderObj.Standard_Cost__c && OrderObj.Standard_Cost__c < (OrderCostCenterSetupObj.Approver_2_Max_Amount__c/conversionRate) ){
                                     OrderObj.isOrderAmountApproved__c = False;
                                     OrderObj.Approver__c = OrderCostCenterSetupObj.Approver_2__c;
                                     
                                 }else if( OrderCostCenterSetupObj.Approver_3_Min_Amount__c != null && OrderCostCenterSetupObj.Approver_3_Max_Amount__c != null && 
                                          (OrderCostCenterSetupObj.Approver_3_Min_Amount__c/conversionRate) <= OrderObj.Standard_Cost__c && OrderObj.Standard_Cost__c < (OrderCostCenterSetupObj.Approver_3_Max_Amount__c/conversionRate) ){
                                              OrderObj.isOrderAmountApproved__c = False;
                                              OrderObj.Approver__c = OrderCostCenterSetupObj.Approver_3__c;
                                          } 
            }
        }
    }
    
    private void PopulatePONumber( List<Order> paramListOoderToPopulatePONumber ){
        map<string, Order> mapOrders = new map<string, Order>();
        for( Order OrderObj : paramListOoderToPopulatePONumber )
        {
            Integer CaseNumber = Integer.valueOf(OrderObj.CaseNumber__c);
            String PONumber = String.valueOf(CaseNumber) +'-'+OrderObj.CaseContactLastName__c+'-'+OrderObj.CaseContactFirstName__c;
            OrderObj.PoNumber = PONumber; 
            mapOrders.put(OrderObj.Case__c,OrderObj);
        }
        
        if( !mapOrders.isEmpty()  ){
            List<Order> lstOrder = [Select Id, Name, PoNumber,OrderNumber,Case__c,Case__r.CaseNumber from Order where Case__c in :mapOrders.KeySet()];
        
        map<string,order> existingPO = new map<string,order>();
        for(Order Element:lstOrder){
            existingPO.put(Element.Case__c,Element);
        }
        
        for(String Key:mapOrders.KeySet()){
            if(existingPO.containsKey(Key)){
                Order anOrder = mapOrders.get(Key);
                Order existingOrder =  existingPO.get(Key);
                
                anOrder.addError('There is already order '+existingOrder.OrderNumber+' against case '+existingOrder.Case__r.CaseNumber+'. Only one order per case is permitted.');
            }
        }
        }
        
        
    }
}