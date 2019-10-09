/************************
Author:         Azfer Pervaiz
Created Date:   25/June/2018 
Purpose:        AddProductOpportunityCtrl is the controller class for the AddProductOpportunity lighting component.

************************MODIFICATION HISTORY**************************************
Added on             Added By               Description
**********************************************************************************
25/June/2018          Azfer Pervaiz          Initial Development 
***********************************************************************************/
public class AddProductOpportunityCtrl {
    public static Integer MaxOpportunityLineItem = 0;
        
    /*public static Boolean IsAgencyUser = false;
    public static Set<String> SetAgencyBrand = new Set<String>();
    public static Set<String> SetWholeSalerBrand = new Set<String>();
    public static Integer CountWholeSaler = 0;*/

    @AuraEnabled 
    public static List<OpportunityProductWrapper> InitCtrl(String paramOpportunityRecordId){
        List<OpportunityProductWrapper> ListOpportunityProduct = new List<OpportunityProductWrapper>();
        
        AggregateResult[] groupedResults = [SELECT MAX(Line_Number__c) MaxSrNo FROM OpportunityLineItem WHERE OpportunityId =: paramOpportunityRecordId ]; 
        if( groupedResults[0].get('MaxSrNo') != null ){
            MaxOpportunityLineItem = Integer.valueOf( groupedResults[0].get('MaxSrNo') ) ;
        }else{
            MaxOpportunityLineItem = 0;
        }

        Integer SerionNo = MaxOpportunityLineItem;
        for( Integer i = 0; i < 10; i++ ){
            if( MaxOpportunityLineItem == 0 ){
                SerionNo = 10;
            }else if ( SerionNo < 10 ){
                SerionNo = MaxOpportunityLineItem + 1;
                SerionNo *= 10; 
            }else{
                SerionNo += 10; 
            }
            MaxOpportunityLineItem++;
            ListOpportunityProduct.add( new OpportunityProductWrapper( SerionNo ) );
        }
        return ListOpportunityProduct;
    }

    @AuraEnabled 
    public static List<OpportunityProductWrapper> AddProductCtrl( String paramListOpportunityProductWrapper){
        List<OpportunityProductWrapper> ListToReturn = new List<OpportunityProductWrapper>();
        ListToReturn = (List<AddProductOpportunityCtrl.OpportunityProductWrapper>)JSON.deserialize(paramListOpportunityProductWrapper,List<AddProductOpportunityCtrl.OpportunityProductWrapper>.Class); 
        
        MaxOpportunityLineItem = ListToReturn[ ListToReturn.size() - 1].Serial;

        Integer SerionNo = MaxOpportunityLineItem;
        for( Integer i = 0; i < 10; i++ ){
            if( MaxOpportunityLineItem == 0 ){
                SerionNo = 10;
            }else if ( SerionNo < 100 ){
                SerionNo = MaxOpportunityLineItem + 1;
                SerionNo *= 10; 
            }else{
                SerionNo += 10; 
            }
            MaxOpportunityLineItem++;
            ListToReturn.add( new OpportunityProductWrapper( SerionNo ) );
        }
        return ListToReturn; 
    }

    @AuraEnabled
    public static RequestStatus SaveProductCtrl(String paramOpportunityRecordId, String paramPriceBookName, String paramListOpportunityProductWrapper) {
        RequestStatus RequestStatusObj = new RequestStatus();
        //PopuluateAllowedProduct( paramOpportunityRecordId );

        Map <String, Id> MapProductCodeToProduct = new Map <String, Id> ();
        Map<String,String> MapProductCodeToProductBrand = new Map<String,String>();
        Map <String, PricebookEntry> MapProductCodeToPBE = new Map <String, PricebookEntry> ();

        List <String> ListProductCode = new List <String> ();
        List <OpportunityProductWrapper> ListOpportunityProductToAdd = new List <OpportunityProductWrapper> ();
        ListOpportunityProductToAdd = (List <AddProductOpportunityCtrl.OpportunityProductWrapper> ) JSON.deserialize(paramListOpportunityProductWrapper, List <AddProductOpportunityCtrl.OpportunityProductWrapper> .Class);

        List <OpportunityLineItem> ListOpportunityLineItem = new List <OpportunityLineItem> ();

        Set<String> SetProductName = new Set<String>();
        Set<String> SetProductWithPBE = new Set<String>();
        
        Opportunity OpportunityObj = [SELECT Id, CurrencyISOCode, Pricebook2Id 
                                    FROM Opportunity 
                                    WHERE Id = : paramOpportunityRecordId ];
        
        for (OpportunityProductWrapper OpportunityProductWrapperObj: ListOpportunityProductToAdd) {
            if (OpportunityProductWrapperObj.ProductCode != null && OpportunityProductWrapperObj.ProductCode != '') {
                ListProductCode.add(OpportunityProductWrapperObj.ProductCode.toLowerCase());
            }
        }

        for (Product2 ProductObj: [SELECT Id, Brand__C, ProductCode, SAP_Product_Code__c
                                    FROM Product2
                                    WHERE SAP_Product_Code__c IN: ListProductCode
                                    AND IsActive = true]) 
        {
            MapProductCodeToProduct.put(ProductObj.SAP_Product_Code__c.toLowerCase(), ProductObj.Id);
            MapProductCodeToProductBrand.put(ProductObj.SAP_Product_Code__c.toLowerCase(), ProductObj.Brand__C);
            SetProductName.add( ProductObj.SAP_Product_Code__c.toLowerCase() );
        }

        for (PriceBookEntry PriceBookEntryObj: [SELECT Id, UnitPrice, Product2.SAP_Product_Code__c
                                                FROM PriceBookEntry
                                                WHERE Product2.SAP_Product_Code__c IN: ListProductCode
                                                AND Pricebook2.Name =: paramPriceBookName
                                                AND Product2.IsActive = true
                                                AND CurrencyISOCode = : OpportunityObj.CurrencyISOCode ]) 
        {
            MapProductCodeToPBE.put(PriceBookEntryObj.Product2.SAP_Product_Code__c.toLowerCase(), PriceBookEntryObj);
            SetProductWithPBE.add( PriceBookEntryObj.Product2.SAP_Product_Code__c.toLowerCase() );
        }

        Boolean ReturnList = false;

        for( OpportunityProductWrapper OpportunityProductWrapperObj : ListOpportunityProductToAdd )
        {
            if( OpportunityProductWrapperObj.ProductCode != null && OpportunityProductWrapperObj.ProductCode != '' && 
                !SetProductName.contains( OpportunityProductWrapperObj.ProductCode.toLowerCase() ) && 
                SetProductWithPBE.size() > 0 && !SetProductWithPBE.contains( OpportunityProductWrapperObj.ProductCode.toLowerCase() ) ){
                
                OpportunityProductWrapperObj.IsValidProduct = false;
            }else if( OpportunityProductWrapperObj.ProductCode != null && OpportunityProductWrapperObj.ProductCode != '' && 
                ( SetProductName.size() == 0 || SetProductWithPBE.size() == 0 ) ){
            
                OpportunityProductWrapperObj.IsValidProduct = false;
            }else{
                OpportunityProductWrapperObj.IsValidProduct = true;
            }

            if( OpportunityProductWrapperObj.ProductCode != null && OpportunityProductWrapperObj.ProductCode != '' && 
                OpportunityProductWrapperObj.ProductQuantity < 1 ){
            
                OpportunityProductWrapperObj.IsValidQuantity = false;
            }else{
                OpportunityProductWrapperObj.IsValidQuantity = true;
            }
        
            /*if( OpportunityProductWrapperObj.ProductCode != null && OpportunityProductWrapperObj.ProductCode != '' && MapProductCodeToProductBrand.get( OpportunityProductWrapperObj.ProductCode ) != null ){
                
                String Brand = MapProductCodeToProductBrand.get( OpportunityProductWrapperObj.ProductCode ).toLowerCase();

                if( IsAgencyUser && SetAgencyBrand.size() == 0 ){
                    
                    OpportunityProductWrapperObj.IsProductAllowed = false;
                    OpportunityProductWrapperObj.NotAllowedReason = 'Brand not allowed defiend on agency.';           
                
                }else if( IsAgencyUser && SetAgencyBrand.size() > 0 && !SetAgencyBrand.contains( Brand ) && CountWholeSaler == 0 ){
                    
                    OpportunityProductWrapperObj.IsProductAllowed = false;
                    OpportunityProductWrapperObj.NotAllowedReason = 'Brand not allowed defiend on agency.';           
                
                }else if( IsAgencyUser && SetAgencyBrand.size() > 0 && !SetAgencyBrand.contains( Brand ) && 
                    CountWholeSaler > 0 && SetWholeSalerBrand.size() > 0 && !SetWholeSalerBrand.contains( Brand ) ){

                    OpportunityProductWrapperObj.IsProductAllowed = false;
                    OpportunityProductWrapperObj.NotAllowedReason = 'Brand not allowed to agency/Wholesaler.';  
                
                }else if( !IsAgencyUser && CountWholeSaler > 0 && SetWholeSalerBrand.size() > 0 && 
                    !SetWholeSalerBrand.contains( Brand ) ){

                    OpportunityProductWrapperObj.IsProductAllowed = false;
                    OpportunityProductWrapperObj.NotAllowedReason = 'Brand not allowed defined on Wholesaler.';  
                
                }else{
                    OpportunityProductWrapperObj.IsProductAllowed = true;
                    OpportunityProductWrapperObj.NotAllowedReason = '';   
                }
            }else{
                OpportunityProductWrapperObj.IsProductAllowed = true;
                OpportunityProductWrapperObj.NotAllowedReason = '';   
            }*/

            if( OpportunityProductWrapperObj.IsValidProduct && 
                OpportunityProductWrapperObj.IsProductAllowed && 
                OpportunityProductWrapperObj.IsValidQuantity ){

                OpportunityProductWrapperObj.IsValid = true;

            }else{
                OpportunityProductWrapperObj.IsValid = false;
                ReturnList = true;
            }

        }
        if( ReturnList ){
            RequestStatusObj.IsSuccessfull = false;
            RequestStatusObj.ErrorMessage = 'Product Issue';
            RequestStatusObj.SuccessMessage = '';
            RequestStatusObj.ListOpportunityProductWrapper = ListOpportunityProductToAdd;
            return RequestStatusObj;
        }

        if( OpportunityObj.Pricebook2Id == null ){
            OpportunityObj.Pricebook2Id = [SELECT Id FROM Pricebook2 WHERE Name = : paramPriceBookName].Id; 
            try{
                update OpportunityObj;
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

        for (OpportunityProductWrapper OpportunityProductWrapperObj: ListOpportunityProductToAdd) 
        {
            if (OpportunityProductWrapperObj.ProductCode != null && OpportunityProductWrapperObj.ProductCode != '') {

                if (MapProductCodeToProduct.get(OpportunityProductWrapperObj.ProductCode.toLowerCase()) != null && MapProductCodeToPBE.get(OpportunityProductWrapperObj.ProductCode.toLowerCase()) != null) {

                    ListOpportunityLineItem.add(new OpportunityLineItem(OpportunityId = paramOpportunityRecordId, Line_Number__c = OpportunityProductWrapperObj.Serial,
                        Product2Id = MapProductCodeToProduct.get(OpportunityProductWrapperObj.ProductCode.toLowerCase()),
                        Quantity = OpportunityProductWrapperObj.ProductQuantity, AlternateProduct__C = OpportunityProductWrapperObj.ProductAlterNumber,
                        PriceBookEntryId = MapProductCodeToPBE.get(OpportunityProductWrapperObj.ProductCode.toLowerCase()).Id,
                        UnitPrice = MapProductCodeToPBE.get(OpportunityProductWrapperObj.ProductCode.toLowerCase()).UnitPrice));
                }
            }
        }

        if (ListOpportunityLineItem.size() > 0) {
            try {
                insert ListOpportunityLineItem;
                RequestStatusObj.IsSuccessfull = true;
                RequestStatusObj.ErrorMessage = '';
                RequestStatusObj.SuccessMessage = 'Success';
            } catch (Exception Ex) {
                system.debug('Exception :: ' + Ex.getMessage());
                RequestStatusObj.IsSuccessfull = false;
                RequestStatusObj.SuccessMessage = '';
                RequestStatusObj.ErrorMessage = Ex.getMessage();
            }
        }
        return RequestStatusObj;
    }
    
    @AuraEnabled 
    public static List<OpportunityProductWrapper> CheckPastedDateCtrl( String paramOpportunityRecordId, String paramStringObject){
        
        List<OpportunityProductWrapper> ListOpportunityProductWrapper = new List<OpportunityProductWrapper>();
        List<OpportunityProductWrapper2> ListOpportunityProductWrapper2 = new List<OpportunityProductWrapper2>();

        if( paramStringObject.contains( '<tr>' ) ){
            for(String StringRowObj : paramStringObject.split( '<tr>' ) )
            {
                StringRowObj = StringRowObj.replace('</tr>','');

                if( StringRowObj != '' && StringRowObj.contains('<td>') ){

                    OpportunityProductWrapper2 OpportunityProductWrapper2Obj = new OpportunityProductWrapper2();
                    List<String> ListTempString = StringRowObj.split( '</td>' );
                    if( ListTempString.size() == 3 && StringRowObj.contains('<td>') ){
                        if( ListTempString[0].replace('<td>','').trim() != '' ){
                            OpportunityProductWrapper2Obj.ProductCode = ListTempString[0].replace('<td>','');
                        }
                        if( ListTempString[1].replace('<td>','').trim() != '' ){
                            OpportunityProductWrapper2Obj.ProductQuantity = Integer.valueOf( ListTempString[1].replace('<td>','').trim() ) ;
                        }
                        if( ListTempString[2].replace('<td>','').trim() != '' ){
                            OpportunityProductWrapper2Obj.ProductAlterNumber = Integer.valueOf( ListTempString[2].replace('<td>','').trim() );
                        }
                    }else if ( ListTempString.size() == 2 && StringRowObj.contains('<td>') ){
                        if( ListTempString[0].replace('<td>','').trim() != '' ){
                            OpportunityProductWrapper2Obj.ProductCode = ListTempString[0].replace('<td>','');
                        }
                        if( ListTempString[1].replace('<td>','').trim() != '' ){
                            OpportunityProductWrapper2Obj.ProductQuantity = Integer.valueOf( ListTempString[1].replace('<td>','').trim() ) ;
                        }
                        OpportunityProductWrapper2Obj.ProductAlterNumber = null;
                    }
                    ListOpportunityProductWrapper2.add( OpportunityProductWrapper2Obj );
                }
            }
        }
        if( ListOpportunityProductWrapper2.size() > 0 ){
            AggregateResult[] groupedResults = [SELECT MAX(Line_Number__c) MaxSrNo FROM OpportunityLineItem WHERE OpportunityId =: paramOpportunityRecordId ]; 
            if( groupedResults[0].get('MaxSrNo') != null ){
                MaxOpportunityLineItem = Integer.valueOf( groupedResults[0].get('MaxSrNo') ) ;
            }else{
                MaxOpportunityLineItem = 0;
            }
            Integer SerionNo = MaxOpportunityLineItem;
            for( Integer i = 0; i <ListOpportunityProductWrapper2.size(); i++ ){
                if( MaxOpportunityLineItem == 0 ){
                    SerionNo = 10;
                }else if ( SerionNo < 10 ){
                    SerionNo = MaxOpportunityLineItem + 1;
                    SerionNo *= 10; 
                }else{
                    SerionNo += 10; 
                }
                MaxOpportunityLineItem++;   
                ListOpportunityProductWrapper.add( new OpportunityProductWrapper( SerionNo , ListOpportunityProductWrapper2[i] ) ); 
            }
        }
        return ListOpportunityProductWrapper;
    }

   /* public static void PopuluateAllowedProduct( String paramOpportunityRecordId ){
        SetAgencyBrand = new Set<String>();
        SetWholeSalerBrand = new Set<String>();
        CountWholeSaler = 0;
        USer LoggedinUser = [SELECT Id,Agency_Id__c FROM User WHERE Id =: UserInfo.getUserId() ];
        
        if( String.isNotBlank( LoggedinUser.Agency_Id__c ) ){
            IsAgencyUser = true;
        }

        Account AgencyAccount;
        try{
            AgencyAccount = [SELECT Id, Brand__C FROM Account WHERE Id = : LoggedinUser.Agency_Id__c];
        }catch(Exception Ex){
            AgencyAccount = null;
        }
        if( AgencyAccount != null && AgencyAccount.Brand__c != null ){
            if( AgencyAccount.Brand__c.contains(';') ){
                for(String Str : AgencyAccount.Brand__c.split(';') ){
                    SetAgencyBrand.add( Str.toLowerCase().trim() );    
                }
            }else if( AgencyAccount.Brand__c != null ){
                SetAgencyBrand.add( AgencyAccount.Brand__c.toLowerCase().trim() );
            }
        }

        Id ProjectId;
        try{
            ProjectId = [SELECT Project__C FROM Opportunity WHERE Id = : paramOpportunityRecordId ].Project__C;
        }catch(Exception Ex){
            ProjectId = null;
        }
        for(Wholesalers__c Wholesalers : [SELECT Id, Wholesaler__r.Brand__c 
                                            FROM Wholesalers__c
                                            WHERE Project__C = : ProjectId ])
        {
            if( Wholesalers.Wholesaler__c != null ){
                if( Wholesalers.Wholesaler__r.Brand__c.contains(';') ){
                    for(String Str : Wholesalers.Wholesaler__r.Brand__c.split(';') ){
                        SetWholeSalerBrand.add( Str.toLowerCase().trim() );
                    }
                }else if( Wholesalers.Wholesaler__r.Brand__c != null ){
                    SetWholeSalerBrand.add( Wholesalers.Wholesaler__r.Brand__c.trim() );
                }
            }
            CountWholeSaler++;
        }   
    }*/

    public class OpportunityProductWrapper{
        
        @AuraEnabled public Integer Serial { Get;Set; }
        @AuraEnabled public String ProductCode { Get;Set; }
        @AuraEnabled public Integer ProductQuantity { Get;Set; }
        @AuraEnabled public Integer ProductAlterNumber { Get;Set; }
        @AuraEnabled public Boolean IsValid { Get;Set; }
        @AuraEnabled public Boolean IsValidProduct { Get;Set; }
        @AuraEnabled public Boolean IsValidQuantity { Get;Set; }
        @AuraEnabled public Boolean IsProductAllowed { Get;Set; }
        @AuraEnabled public String NotAllowedReason { Get;Set; }

        public OpportunityProductWrapper(){}
        
        public OpportunityProductWrapper(Integer paramSerial){
            Serial = paramSerial;
            ProductCode = '';
            ProductQuantity = 0;
            ProductAlterNumber = null;
            IsValid = true;
            IsValidProduct = true;
            IsValidQuantity = true;
            IsProductAllowed = true;
            NotAllowedReason = '';
        }

        public OpportunityProductWrapper(Integer paramSerial, OpportunityProductWrapper2 paramOpportunityProductWrapper2 ){
            Serial = paramSerial;
            ProductCode = paramOpportunityProductWrapper2.ProductCode;
            ProductQuantity = paramOpportunityProductWrapper2.ProductQuantity;
            ProductAlterNumber = paramOpportunityProductWrapper2.ProductAlterNumber;
            IsValid = true;
            IsValidProduct = true;
            IsValidQuantity = true;
            IsProductAllowed = true;
            NotAllowedReason = '';
        }

    }

    private Class OpportunityProductWrapper2{
        private String ProductCode { Get;Set; }
        private Integer ProductQuantity { Get;Set; }
        private Integer ProductAlterNumber { Get;Set; }

        public OpportunityProductWrapper2(){
            ProductCode = '';
            ProductQuantity = 0;
            ProductAlterNumber = null;
        }
    }
}