/************************
Author:         Azfer Pervaiz
Created Date:   28/Aug/2018 
Purpose:        AddProductOrderCtrl is the controller class for the AddProductOrder lighting component.

************************MODIFICATION HISTORY**************************************
Added on             Added By               Description
**********************************************************************************
28/Aug/2018          Azfer Pervaiz          Initial Development 
***********************************************************************************/
with sharing public class AddProductOrderCtrl {
    public static Integer MaxOrderItemSerial = 0;
    
    public static Boolean IsAgencyUser = false;
    public static Set<String> SetAgencyBrand = new Set<String>();
    public static Set<String> SetWholeSalerBrand = new Set<String>();
    public static Integer CountWholeSaler = 0;
    
    @AuraEnabled 
    public static List<OrderItemWrapper> InitCtrl(String paramOrderRecordId){
        List<OrderItemWrapper> ListOrderItem = new List<OrderItemWrapper>();
        
        AggregateResult[] groupedResults = [SELECT MAX(Line_Number__c) MaxSrNo FROM OrderItem WHERE OrderId =: paramOrderRecordId ]; 
        if( groupedResults[0].get('MaxSrNo') != null ){
            MaxOrderItemSerial = Integer.valueOf( groupedResults[0].get('MaxSrNo') ) ;
        }else{
            MaxOrderItemSerial = 0;
        }
        
        Integer SerionNo = MaxOrderItemSerial;
        for( Integer i = 0; i < 10; i++ ){
            if( MaxOrderItemSerial == 0 ){
                SerionNo = 10;
            }else if ( SerionNo < 10 ){
                SerionNo = MaxOrderItemSerial + 1;
                SerionNo *= 10;	
            }else{
                SerionNo += 10;	
            }
            MaxOrderItemSerial++;
            
            ListOrderItem.add( new OrderItemWrapper( SerionNo ) );
        }
        return ListOrderItem;
    }
    
    @AuraEnabled 
    public static List<OrderItemWrapper> AddProductCtrl( String paramListOrderItemWrapper){
        List<OrderItemWrapper> ListToReturn = new List<OrderItemWrapper>();
        ListToReturn = (List<AddProductOrderCtrl.OrderItemWrapper>)JSON.deserialize(paramListOrderItemWrapper,List<AddProductOrderCtrl.OrderItemWrapper>.Class); 
        
        MaxOrderItemSerial = ListToReturn[ ListToReturn.size() - 1].Serial;
        
        Integer SerionNo = MaxOrderItemSerial;
        for( Integer i = 0; i < 10; i++ ){
            if( MaxOrderItemSerial == 0 ){
                SerionNo = 10;
            }else if ( SerionNo < 100 ){
                SerionNo = MaxOrderItemSerial + 1;
                SerionNo *= 10;	
            }else{
                SerionNo += 10;	
            }
            MaxOrderItemSerial++;
            ListToReturn.add( new OrderItemWrapper( SerionNo ) );
        }
        
        return ListToReturn; 
    }
    
    @AuraEnabled 
    public static RequestStatus SaveProductCtrl( String paramOrderRecordId, String paramPriceBookName, String paramListOrderItemWrapper){
        RequestStatus RequestStatusObj = new RequestStatus();
        
        Map<String,Id> MapProductCodeToProduct = new Map<String,Id>();
        Map<String,String> MapProductCodeToProductBrand = new Map<String,String>();
        Map<String,PricebookEntry> MapProductCodeToPBE = new Map<String,PricebookEntry>();
        
        List<String> ListProductCode = new List<String>();
        List<OrderItemWrapper> ListOrderItemToAdd = new List<OrderItemWrapper>();
        
        ListOrderItemToAdd = (List<AddProductOrderCtrl.OrderItemWrapper>)JSON.deserialize(paramListOrderItemWrapper,List<AddProductOrderCtrl.OrderItemWrapper>.Class); 
        
        List<OrderItem> ListOrderItem = new List<OrderItem>();
        
        Set<String> SetProductName = new Set<String>();
        Set<String> SetProductWithPBE = new Set<String>();
        
        Boolean ReturnList = false;
        
        Order OrderObj = [SELECT Id,CurrencyISOCode, Pricebook2Id  
                          FROM Order 
                          WHERE Id = : paramOrderRecordId ];
        
        for( OrderItemWrapper OrderItemWrapperObj : ListOrderItemToAdd )
        {
            if( OrderItemWrapperObj.ProductCode != null && OrderItemWrapperObj.ProductCode != ''){
                ListProductCode.add( OrderItemWrapperObj.ProductCode.toUpperCase() );
            }
            system.debug(OrderItemWrapperObj);
        }
        
        for( Product2 ProductObj : [SELECT Id, Brand__c, ProductCode, SAP_Product_Code_Upper__c 
                                    FROM Product2
                                    WHERE SAP_Product_Code_Upper__c IN : ListProductCode
                                    AND IsActive = true]){
                                        MapProductCodeToProduct.put( ProductObj.SAP_Product_Code_Upper__c , ProductObj.Id );
                                        MapProductCodeToProductBrand.put( ProductObj.SAP_Product_Code_Upper__c , ProductObj.Brand__c );
                                        SetProductName.add( ProductObj.SAP_Product_Code_Upper__c );
                                    }
        Id stPriceBook= ReturnPriceBookId();
            system.debug(stPriceBook);
            system.debug(OrderObj.CurrencyISOCode);
            system.debug(json.serialize( [SELECT Pricebook2.Name, Product2.SAP_Product_Code_Upper__c,Pricebook2Id,Product2.IsActive,CurrencyISOCode
                                          FROM PriceBookEntry
                                          WHERE Product2.SAP_Product_Code_Upper__c IN : ListProductCode 
                                          AND Product2.IsActive = true
                                          AND Pricebook2Id= :stPriceBook
                                          AND CurrencyISOCode =: OrderObj.CurrencyISOCode ]));
        
        for( PriceBookEntry PriceBookEntryObj : [SELECT Id, UnitPrice, Product2.SAP_Product_Code_Upper__c 
                                                 FROM PriceBookEntry
                                                 WHERE Product2.SAP_Product_Code_Upper__c IN : ListProductCode
                                                 AND Pricebook2Id= :stPriceBook
                                                 AND Product2.IsActive = true
                                                 AND CurrencyISOCode =: OrderObj.CurrencyISOCode ])
        {
                                                     MapProductCodeToPBE.put( PriceBookEntryObj.Product2.SAP_Product_Code_Upper__c , PriceBookEntryObj );
                                                     SetProductWithPBE.add( PriceBookEntryObj.Product2.SAP_Product_Code_Upper__c );
        }
       
        for( OrderItemWrapper OrderItemWrapperObj : ListOrderItemToAdd )
        {
            
            if( OrderItemWrapperObj.ProductCode != null && OrderItemWrapperObj.ProductCode != '' && 
               !SetProductName.contains( OrderItemWrapperObj.ProductCode.toUpperCase() ) && 
               SetProductWithPBE.size() != 0 && !SetProductWithPBE.contains( OrderItemWrapperObj.ProductCode.toUpperCase() ) ){
                   OrderItemWrapperObj.IsValidProduct = false;
               }else if( OrderItemWrapperObj.ProductCode != null && OrderItemWrapperObj.ProductCode != '' && 
                        ( SetProductName.size() == 0 || SetProductWithPBE.size() == 0 ) ){
                            OrderItemWrapperObj.IsValidProduct = false;
                        }else{
                            OrderItemWrapperObj.IsValidProduct = true;
                        }
            
            if( OrderItemWrapperObj.ProductCode != null && OrderItemWrapperObj.ProductCode != '' && 
               OrderItemWrapperObj.ProductQuantity < 1 ){
                   OrderItemWrapperObj.IsValidQuantity = false;
               }else{
                   OrderItemWrapperObj.IsValidQuantity = true;
               }
            
            if( OrderItemWrapperObj.ProductCode != null && OrderItemWrapperObj.ProductCode != '' && MapProductCodeToProductBrand.get( OrderItemWrapperObj.ProductCode.toUpperCase() ) != null ){
                
                String Brand = MapProductCodeToProductBrand.get( OrderItemWrapperObj.ProductCode.toUpperCase() ).toLowerCase();
                
                if( IsAgencyUser && SetAgencyBrand.size() > 0 && !SetAgencyBrand.contains( Brand ) && CountWholeSaler == 0 ){
                    
                    OrderItemWrapperObj.IsProductAllowed = false;
                    OrderItemWrapperObj.NotAllowedReason = 'Brand not allowed defiend on agency.';           
                    
                }else if( IsAgencyUser && SetAgencyBrand.size() > 0 && !SetAgencyBrand.contains( Brand ) && 
                         CountWholeSaler > 0 && SetWholeSalerBrand.size() > 0 && !SetWholeSalerBrand.contains( Brand ) ){
                             
                             OrderItemWrapperObj.IsProductAllowed = false;
                             OrderItemWrapperObj.NotAllowedReason = 'Brand not allowed to agency/Wholesaler.';  
                             
                         }else if( !IsAgencyUser && CountWholeSaler > 0 && SetWholeSalerBrand.size() > 0 && 
                                  !SetWholeSalerBrand.contains( Brand ) ){
                                      
                                      OrderItemWrapperObj.IsProductAllowed = false;
                                      OrderItemWrapperObj.NotAllowedReason = 'Brand not allowed defined on Wholesaler.';  
                                      
                                  }else{
                                      OrderItemWrapperObj.IsProductAllowed = true;
                                      OrderItemWrapperObj.NotAllowedReason = '';   
                                  }
                
            }else{
                OrderItemWrapperObj.IsProductAllowed = true;
                OrderItemWrapperObj.NotAllowedReason = '';   
            }
            
            if( OrderItemWrapperObj.IsValidProduct && 
               OrderItemWrapperObj.IsProductAllowed && 
               OrderItemWrapperObj.IsValidQuantity ){
                   
                   OrderItemWrapperObj.IsValid = true;
                   
               }else{
                   OrderItemWrapperObj.IsValid = false;
                   ReturnList = true;
               }
        }
        
        if( ReturnList ){
            RequestStatusObj.IsSuccessfull = false;
            RequestStatusObj.ErrorMessage = 'Product Issue';
            RequestStatusObj.SuccessMessage = '';
            RequestStatusObj.ListOrderItemWrapper = ListOrderItemToAdd;
            return RequestStatusObj;
        }
        
        if( OrderObj.Pricebook2Id == null ){
            OrderObj.Pricebook2Id = [SELECT Id FROM Pricebook2 WHERE Name = : paramPriceBookName].Id; 
            try{
                update OrderObj;
                RequestStatusObj.IsSuccessfull = true;
                RequestStatusObj.ErrorMessage = '';
                RequestStatusObj.SuccessMessage = 'Success';
            }catch(Exception Ex){ 
                system.debug('Exception :: '+Ex.getMessage());
                RequestStatusObj.IsSuccessfull = false;
                RequestStatusObj.SuccessMessage = '';
                RequestStatusObj.ErrorMessage = Ex.getMessage();
            }
        }
        
        for( OrderItemWrapper OrderItemWrapperObj : ListOrderItemToAdd ){
            if( OrderItemWrapperObj.ProductCode != null && OrderItemWrapperObj.ProductCode != ''){
                
                if( MapProductCodeToProduct.get( OrderItemWrapperObj.ProductCode.toUpperCase() ) != null && MapProductCodeToPBE.get( OrderItemWrapperObj.ProductCode.toUpperCase() ) != null ){
                    
                    ListOrderItem.add( new OrderItem( OrderId = paramOrderRecordId, Line_Number__c = OrderItemWrapperObj.Serial, PoItemNumber__C = OrderItemWrapperObj.Serial, 
                                                     Product2Id = MapProductCodeToProduct.get( OrderItemWrapperObj.ProductCode.toUpperCase() ),
                                                     Quantity = OrderItemWrapperObj.ProductQuantity, /*AlternateNumber__C = OrderItemWrapperObj.AlternateNumber,*/
                                                     PriceBookEntryId = MapProductCodeToPBE.get( OrderItemWrapperObj.ProductCode.toUpperCase() ).Id,
                                                     UnitPrice = MapProductCodeToPBE.get( OrderItemWrapperObj.ProductCode.toUpperCase() ).UnitPrice ) );  
                }
            }
        }
        
        if( ListOrderItem.size() > 0 ){
            try{
                insert ListOrderItem;
                RequestStatusObj.IsSuccessfull = True;
                RequestStatusObj.ErrorMessage = '';
                RequestStatusObj.SuccessMessage = 'Success';
            }
            catch(DmlException Ex){
                system.debug('Exception :: '+Ex.getMessage());
                RequestStatusObj.IsSuccessfull = false;
                RequestStatusObj.SuccessMessage = '';
                RequestStatusObj.ErrorMessage = Ex.getDmlMessage(0);
            }            
            catch(Exception Ex){
                system.debug('Exception :: '+Ex.getMessage());
                RequestStatusObj.IsSuccessfull = false;
                RequestStatusObj.SuccessMessage = '';
                RequestStatusObj.ErrorMessage = Ex.getMessage();
            }
        }
        return RequestStatusObj;
        
    }
    
    @AuraEnabled
    public static RequestStatus UpdateOrderSimulator(String paramOrderRecordId){
        Informatica_Order_Callout.InformaticaResponse status = new Informatica_Order_Callout.InformaticaResponse();
        RequestStatus result = new RequestStatus();
        status.MESSAGE_TYPE = 'E';
        status = Informatica_Order_Callout.callOrderSimulator(paramOrderRecordId)[0];
        if(status.MESSAGE_TYPE=='S'){
            result.IsSuccessfull = True;
            result.SuccessMessage = status.MESSAGE;
        }
        else{
            result.IsSuccessfull = FALSE;
            result.ErrorMessage = status.MESSAGE;
        }
        system.debug(result);
        return result;
    }
 	private static Id ReturnPriceBookId(){
        if(!Test.isRunningTest())   
        {
            return [SELECT Id FROM PriceBook2 WHERE IsStandard = true].Id;
        }
        else
        {
            return Test.getStandardPricebookId();
        }
    }   
    @AuraEnabled 
    public static List<OrderItemWrapper> CheckPastedDateCtrl( String paramOrderRecordId, String paramStringObject){
        
        List<OrderItemWrapper> ListOrderItemWrapper = new List<OrderItemWrapper>();
        List<OrderItemWrapper2> ListOrderItemWrapper2 = new List<OrderItemWrapper2>();
        
        if( paramStringObject.contains( '<tr>' ) ){
            for(String StringRowObj : paramStringObject.split( '<tr>' ) )
            {
                StringRowObj = StringRowObj.replace('</tr>','');
                
                if( StringRowObj != '' && StringRowObj.contains('<td>') ){
                    
                    OrderItemWrapper2 OrderItemWrapper2Obj = new OrderItemWrapper2();
                    List<String> ListTempString = StringRowObj.split( '</td>' );
                    
                    /*if( ListTempString.size() == 3 && StringRowObj.contains('<td>') ){
if( ListTempString[0].replace('<td>','').trim() != '' ){
OrderItemWrapper2Obj.ProductCode = ListTempString[0].replace('<td>','');
}
if( ListTempString[1].replace('<td>','').trim() != '' ){
OrderItemWrapper2Obj.ProductQuantity = Integer.valueOf( ListTempString[1].replace('<td>','').trim() ) ;
}
if( ListTempString[2].replace('<td>','').trim() != '' ){
OrderItemWrapper2Obj.AlternateNumber = Integer.valueOf( ListTempString[2].replace('<td>','').trim() );
}
}else*/ if( ListTempString.size() == 2 && StringRowObj.contains('<td>') && StringRowObj.length() > 4 ){
    if( ListTempString[0].replace('<td>','').trim() != '' ){
        OrderItemWrapper2Obj.ProductCode = ListTempString[0].replace('<td>','');
    }
    if( ListTempString[1].replace('<td>','').trim() != '' ){
        OrderItemWrapper2Obj.ProductQuantity = Integer.valueOf( ListTempString[1].replace('<td>','').trim() ) ;
    }
    //OrderItemWrapper2Obj.AlternateNumber = null;
    
}else{
    OrderItemWrapper2Obj.ProductCode = 'Product Not Specified';
    OrderItemWrapper2Obj.ProductQuantity = null;
    //OrderItemWrapper2Obj.AlternateNumber = null;
}
                    if( OrderItemWrapper2Obj.ProductCode != null ){
                        ListOrderItemWrapper2.add( OrderItemWrapper2Obj );
                    }
                }
            }
        }
        if( ListOrderItemWrapper2.size() > 0 ){
            AggregateResult[] groupedResults = [SELECT MAX(Line_Number__c) MaxSrNo FROM OrderItem WHERE OrderId =: paramOrderRecordId ]; 
            if( groupedResults[0].get('MaxSrNo') != null ){
                MaxOrderItemSerial = Integer.valueOf( groupedResults[0].get('MaxSrNo') ) ;
            }else{
                MaxOrderItemSerial = 0;
            }
            
            Integer SerionNo = MaxOrderItemSerial;
            for( Integer i = 0; i < ListOrderItemWrapper2.size(); i++ ){
                
                if( MaxOrderItemSerial == 0 ){
                    SerionNo = 10;
                }else if ( SerionNo < 10 ){
                    SerionNo = MaxOrderItemSerial + 1;
                    SerionNo *= 10;	
                }else{
                    SerionNo += 10;	
                }
                MaxOrderItemSerial++;	
                ListOrderItemWrapper.add( new OrderItemWrapper( SerionNo , ListOrderItemWrapper2[i] ) ); 
            }
        }
        return ListOrderItemWrapper;
    }
    
    
    public class OrderItemWrapper{
        
        @AuraEnabled public Integer Serial { Get;Set; }
        @AuraEnabled public String ProductCode { Get;Set; }
        @AuraEnabled public Integer ProductQuantity { Get;Set; }
        //@AuraEnabled public Integer AlternateNumber { Get;Set; }
        @AuraEnabled public Boolean IsValid { Get;Set; }
        @AuraEnabled public Boolean IsValidProduct { Get;Set; }
        @AuraEnabled public Boolean IsValidQuantity { Get;Set; }
        @AuraEnabled public Boolean IsProductAllowed { Get;Set; }
        @AuraEnabled public String NotAllowedReason { Get;Set; }
        
        public OrderItemWrapper(){}
        
        public OrderItemWrapper(Integer paramSerial){
            Serial = paramSerial;
            ProductCode = null;
            ProductQuantity = 0;
            //AlternateNumber = null;
            IsValid = true;
            IsValidProduct = true;
            IsValidQuantity = true;
            IsProductAllowed = true;
            NotAllowedReason = '';
        }
        
        public OrderItemWrapper(Integer paramSerial, OrderItemWrapper2 paramOrderItemWrapper2 ){
            Serial = paramSerial;
            ProductCode = paramOrderItemWrapper2.ProductCode;
            ProductQuantity = paramOrderItemWrapper2.ProductQuantity;
            //AlternateNumber = paramOrderItemWrapper2.AlternateNumber;
            IsValid = true;
            IsValidProduct = true;
            IsValidQuantity = true;
            IsProductAllowed = true;
            NotAllowedReason = '';
        }
        
    }
    
    private Class OrderItemWrapper2{
        private String ProductCode { Get;Set; }
        private Integer ProductQuantity { Get;Set; }
        private Integer AlternateNumber { Get;Set; }
        
        public OrderItemWrapper2(){
            ProductCode = null;
            ProductQuantity = 0;
            //AlternateNumber = null;
        }
    }
}