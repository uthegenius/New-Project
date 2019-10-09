/*
* Created by: Tectonic (MB) on 5/24/18
* Description: (LSCIP-81) - (AM-4) - System should be able to add display order coming via integration without opportunity in asset manager
* Updated by        Updated on      Reason 
*/
trigger OrderLineItemTrg on OrderItem (after insert, after update,before insert) {
    // check to avoid recursion
    //if(AvoidRecursion.isFirstRun())
    //{
    Set<String> setWithQuantity = new Set<String>();
    Set<String> setWithShippedQuantity = new Set<String>();
    Set<String> setOrderSAPId = new Set<String>();
    Set<String> setQuoteID = new Set<String>();
    Set<Id> setQuoteLineItemID = new Set<Id>();
    Set<Id> SetCancelledOrderItemQuoteIds = new Set<Id>();
    Set<Id> SetOpportunityIds = new Set<Id>();
    
    
    if (Trigger.isAfter && (Trigger.isUpdate || Trigger.isInsert) )   
    {
        //ticket 87
        Set<Id> setOrderItemId = new Set<Id>();
        
        for (OrderItem oi : Trigger.New)
        {
            if (Trigger.isInsert)
            {
                setOrderItemId.add(oi.Id);
                if (oi.Quote_Line_Item__c != null) { setQuoteLineItemID.add(oi.Quote_Line_Item__c); } 
            }
            
            if (Trigger.isUpdate)
            {
                if (Trigger.oldMap.get(oi.Id).Open_Quantity__c != Trigger.newMap.get(oi.Id).Open_Quantity__c || 
                    Trigger.oldMap.get(oi.Id).Shipped_Quantities__c != Trigger.newMap.get(oi.Id).Shipped_Quantities__c || 
                    Trigger.oldMap.get(oi.Id).Quantity != Trigger.newMap.get(oi.Id).Quantity || 
                    Trigger.oldMap.get(oi.Id).Remaining_Quantity__c != Trigger.newMap.get(oi.Id).Remaining_Quantity__c
                   )
                {
                    setOrderItemId.add(oi.Id);
                    if (oi.Quote_Line_Item__c != null) { setQuoteLineItemID.add(oi.Quote_Line_Item__c); } 
                }
                
                //[AR]-Get Cancelled Order Item quote Ids
                if(oi.Line_Status__c == 'Cancelled' && Trigger.oldMap.get(oi.Id).Line_Status__c != Trigger.newMap.get(oi.Id).Line_Status__c)
                    SetCancelledOrderItemQuoteIds.add(oi.Quote__c);
                
            }
        }
        
        // [AR]- Cancel Task if Order Line item is cancelled.
        if(SetCancelledOrderItemQuoteIds.size() > 0)
        {
            List<Task> ListOfTasks = new List<Task>();
            List<Opportunity> ListOpps = new List<Opportunity>([Select Id from Opportunity where RecordType.DeveloperName = 'Display' and Id in (Select OpportunityId 
                                                                                                                                                 FROM Quote WHERE Id in: SetCancelledOrderItemQuoteIds)]);
            
            if(ListOpps.Size() > 0)
            {
                for(Opportunity opp:  ListOpps)
                {
                    SetOpportunityIds.add(opp.Id);
                }
            }
            
            if(SetOpportunityIds.size()>0)
            {
                ListOfTasks = [Select Id,Status,WhatId from Task where WhatId in: SetOpportunityIds and Status != 'Cancelled'];
                
                if(ListOfTasks.Size() > 0)
                {
                    for(Task tsk: ListOfTasks)
                    {
                        tsk.Status = 'Cancelled';
                    }
                    Update ListOfTasks;
                }
                
            }
            
        }
        
        List<OrderItem> listOrders;
        
        if (setOrderItemId != null && setOrderItemId.size() > 0)
        {
            listOrders = [select Quote__c, OrderId, Shipped_Quantities__c,Remaining_Quantity__c, quantity, Open_Quantity__c,
                          Order.Order_SAP_ID__c, /*Order.Reason_Code_Unique_ID__c, Order.Sales_Deal_Unique_ID__c,*/ Product2.SAP_Product_Code__c 
                          from OrderItem where Id in :setOrderItemId 
                          and Line_Status__c !='Cancelled'];
        }
        
        if (listOrders != null && listOrders.size() > 0)
        {
            for(OrderItem oli: listOrders)
            {
                if (oli.quantity != null && (oli.Shipped_Quantities__c == null || oli.Shipped_Quantities__c == 0 ) )
                {
                    //setWithQuantity.add(oli.Order.Reason_Code_Unique_ID__c);
                    setWithQuantity.add(oli.Quote__c);
                }
                else if (oli.quantity != null && oli.Shipped_Quantities__c != null)
                {
                    //setWithShippedQuantity.add(oli.Order.Reason_Code_Unique_ID__c);   
                    setWithShippedQuantity.add(oli.Order.Order_SAP_ID__c);    
                } 
                
                if (oli.Order.Order_SAP_ID__c != null)
                {
                    setOrderSAPId.add(oli.Order.Order_SAP_ID__c);
                }
                
                if (oli.Quote__c != null)
                {
                    setQuoteID.add(oli.Quote__c);
                }
                
            }
        }
        
        //Marking Flag true on Quote and QuoteLineItem on OrderItem insertion.
        if(setQuoteID.size()>0 && setQuoteLineItemID.size()>0)
        {
            List<Quote> ListQuotes = [Select Id,Name,IsOrderReceived__c from Quote where Id in:setQuoteID and IsOrderReceived__c =:false];
            List<QuoteLineItem> listQLIs = [select Id,IsOrderItemReceived__c from QuoteLineItem where Id in: setQuoteLineItemID and IsOrderItemReceived__c =:false];
            
            if(ListQuotes != null && ListQuotes.size() > 0)
            {
                for(Quote q:ListQuotes)
                {
                    q.IsOrderReceived__c = true;
                }
                Update ListQuotes;
            }
            
            if(listQLIs != null && listQLIs.size() > 0)
            {   
                for(QuoteLineItem qli:listQLIs)
                {
                    qli.IsOrderItemReceived__c = true;
                }
                Update listQLIs;                 
            }
            
            // [AR]-Get Opportunities against Order Items and Changed Stage to Closed Won.
            Id InitiativeRecordtypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Initiative').getRecordTypeId();
            List<Opportunity> ListOpportunites = [Select Id,Name,StageName from Opportunity where RecordTypeId =: InitiativeRecordtypeId and StageName in ('Initiative Proposal', 'Committed') and Id in (Select OpportunityId FROM Quote WHERE Id in: setQuoteID)];
            
            if(ListOpportunites.size() > 0)
            {
                for(Opportunity opp: ListOpportunites)
                {
                    opp.StageName = 'Closed Won';
                }
                Update ListOpportunites;
            }
            
        }
        
        
        List<Opportunity> listOpptoUpdate = new List<Opportunity>();
        
        //if order comes with order quantity only
        if (setWithQuantity != null && setWithQuantity.size() > 0)
        {
            List<Quote> listOrderWithQuantity = [select Id, OpportunityId
                                                 from Quote
                                                 where Unique_Id__c != null
                                                 and Id in :setWithQuantity and Opportunity.RecordType.DeveloperName = 'Display'];
            Set<Id> setOppForConfirmingDisplay = new Set<Id>();
            
            if (listOrderWithQuantity != null && listOrderWithQuantity.size() > 0)
            {
                for (Quote q : listOrderWithQuantity )
                {
                    setOppForConfirmingDisplay.add(q.OpportunityId);
                }   
            }
            
            //Day 2 feedback item 43, Display ordered should be selected instead of Confirming display when order received. 
            //When shipped at that time move it to confirming display. Removed Shipped as a stage
            //making change on 19th July 2018 1-11 am
            
            //List<Opportunity> listOppCD =  [select Id, StageName from Opportunity where Id in :setOppForConfirmingDisplay and StageName != 'Confirming Display']; 
            List<Opportunity> listOppCD =  [select Id, StageName from Opportunity where Id in :setOppForConfirmingDisplay and StageName != 'Display Order'];    
            system.debug('ah::listOppCD ' + listOppCD);
            if (listOppCD != null && listOppCD.size() > 0)
            {
                for (Opportunity op : listOppCD)
                {
                    op.StageName = 'Display Order'; 
                    listOpptoUpdate.add(op);
                }
            }
        }
        
        //if order comes with shipped quantity 
        if (setWithShippedQuantity != null && setWithShippedQuantity.size() > 0)
        {
            List<Quote> listOrderWithShippedQuantity = [select Id, OpportunityId
                                                        from Quote
                                                        where Unique_Id__c != null
                                                        and Unique_Id__c in :setWithShippedQuantity and Opportunity.RecordType.DeveloperName = 'Display'];
            
            Set<Id> setOppForShipped = new Set<Id>();
            
            if (listOrderWithShippedQuantity != null && listOrderWithShippedQuantity.size() > 0)
            {
                for (Quote q : listOrderWithShippedQuantity )
                {
                    setOppForShipped.add(q.OpportunityId);
                }   
            }
            
        }
        
        if (listOpptoUpdate != null && listOpptoUpdate.size() > 0)        
        {
            update listOpptoUpdate;
        }
        
        //ticket LSCIP-74
        List<QuoteLineItem> listQLI;
        
        if (setQuoteID != null && setQuoteID.size() > 0)
        {
            listQLI = [select Id, Quantity, Remaining_Quantity__c, Shipped_Quantity__c, Recon_Quantity__c,Quote.Unique_Id__c, Open_Quantity__c, Product2.SAP_Product_Code__c 
                       from QuoteLineItem where QuoteId in : setQuoteID and Product2.SAP_Product_Code__c != null];
        }
        
        system.debug('ah::listQLI ' + listQLI);   
        Map<String, QuoteLineItem> mapQLI = new Map<String, QuoteLineItem>();
        
        if (listQLI != null && listQLI.size() > 0)
        {
            for (QuoteLineItem qli : listQLI)
            {
                mapQLI.put(qli.QuoteId + '-' + qli.Product2.SAP_Product_Code__c, qli);
            }
        }
        
        map<Id, QuoteLineItem> mapOfQLIUpdate = new map<Id, QuoteLineItem>();
        QuoteLineItem orderQLI = new QuoteLineItem();
        
        List<orderItem> lstOrders;
        
        lstOrders = [select Order.QuoteId, Quote_Line_Item__c, OrderId, Shipped_Quantities__c,Remaining_Quantity__c, quantity, Open_Quantity__c, 
                     Order.Order_SAP_ID__c, Line_Status__c,Attribute9__c,/*Order.Reason_Code_Unique_ID__c, Order.Sales_Deal_Unique_ID__c,*/ Product2.SAP_Product_Code__c 
                     from OrderItem 
                     where Quote_Line_Item__c  in :setQuoteLineItemID 
                     order by Quote_Line_Item__c, lastmodifiedDate ASC];
        
        if (lstOrders != null && lstOrders.size() > 0)
        {
            system.debug(lstOrders);
            List<QuoteLineItem> listQLItoUpdate = new List<QuoteLineItem>();
            
            for (OrderItem oi : lstOrders)
            {
                orderQLI = new QuoteLineItem();
                orderQLI.Id = oi.Quote_Line_Item__c;
                orderQLI.Open_Quantity__c = 0;
                orderQLI.Shipped_Quantity__c = 0;
                orderQLI.Remaining_Quantity__c = 0;                        
                orderQLI.Recon_Quantity__c = 0;
                if (oi.Line_Status__c !='Cancelled' ){
                    if (mapOfQLIUpdate.containsKey(oi.Quote_Line_Item__c)){
                        orderQLI = mapOfQLIUpdate.get(oi.Quote_Line_Item__c);                    
                        if(oi.Attribute9__c=='I'){
                            orderQLI.Recon_Quantity__c += oi.Quantity == null ? 0 : oi.Quantity;
                        }
                        else{
                            orderQLI.Open_Quantity__c += oi.Quantity == null ? 0 : oi.Quantity;
                            orderQLI.Shipped_Quantity__c += oi.Shipped_Quantities__c == null ? 0 : oi.Shipped_Quantities__c;
                            orderQLI.Remaining_Quantity__c += oi.Remaining_Quantity__c == null ? 0 : oi.Remaining_Quantity__c;
                        }     
                    }
                    else {                        
                        if(oi.Attribute9__c=='I'){                    
                            orderQLI.Recon_Quantity__c = oi.Quantity == null ? 0 : oi.Quantity;
                        }
                        else{                            
                            orderQLI.Open_Quantity__c = oi.Quantity == null ? 0 : oi.Quantity;
                            orderQLI.Shipped_Quantity__c = oi.Shipped_Quantities__c == null ? 0 : oi.Shipped_Quantities__c;
                            orderQLI.Remaining_Quantity__c = oi.Remaining_Quantity__c == null ? 0 : oi.Remaining_Quantity__c;
                            orderQLI.Recon_Quantity__c = 0;
                        }                                                
                    }                    
                }
                mapOfQLIUpdate.put(oi.Quote_Line_Item__c, orderQLI);
                system.debug(oi);
                system.debug(orderQLI);
            } 
            
            listQLItoUpdate.addAll(mapOfQLIUpdate.values());
            if (!listQLItoUpdate.isEmpty())
            {
                update listQLItoUpdate;
            }
        }
    }  
    system.debug(Trigger.New);
    
}