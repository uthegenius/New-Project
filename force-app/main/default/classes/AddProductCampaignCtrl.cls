/************************
Author:         Azfer Pervaiz
Created Date:   25/June/2018 
Purpose:        AddProductCampaignCtrl is the controller class for the AddProductCampaign lighting component.

************************MODIFICATION HISTORY**************************************
Added on             Added By               Description
**********************************************************************************
25/June/2018          Azfer Pervaiz          Initial Development 
***********************************************************************************/
public class AddProductCampaignCtrl {
    public static Integer MaxCampaignProduct = 0;
    @AuraEnabled 
    public static List<CampaignProductWrapper> InitCtrl(String paramCampaignRecordId){
        List<CampaignProductWrapper> ListCampaignProduct = new List<CampaignProductWrapper>();

        AggregateResult[] groupedResults = [SELECT MAX(Line_Number__c) MaxSrNo FROM Campaign_Products__c WHERE Campaign__c =: paramCampaignRecordId ]; 
        if( groupedResults[0].get('MaxSrNo') != null ){
            MaxCampaignProduct = Integer.valueOf( groupedResults[0].get('MaxSrNo') ) ;
        }else{
            MaxCampaignProduct = 0;
        }
        
        Integer SerionNo = MaxCampaignProduct;
        for( Integer i = 0; i < 10; i++ ){
            if( MaxCampaignProduct == 0 ){
                SerionNo = 10;
            }else if ( SerionNo < 10 ){
                SerionNo = MaxCampaignProduct + 1;
                SerionNo *= 10; 
            }else{
                SerionNo += 10; 
            }
            MaxCampaignProduct++;
            ListCampaignProduct.add( new CampaignProductWrapper( SerionNo ) );
        }        
        return ListCampaignProduct;
    }

    @AuraEnabled 
    public static List<CampaignProductWrapper> AddProductCtrl( String paramListCampaignProductWrapper){
        List<CampaignProductWrapper> ListToReturn = new List<CampaignProductWrapper>();
        ListToReturn = (List<AddProductCampaignCtrl.CampaignProductWrapper>)JSON.deserialize(paramListCampaignProductWrapper,List<AddProductCampaignCtrl.CampaignProductWrapper>.Class); 
        
        MaxCampaignProduct = ListToReturn[ ListToReturn.size() - 1].Serial;
        
        Integer SerionNo = MaxCampaignProduct;
        for( Integer i = 0; i < 10; i++ ){
            if( MaxCampaignProduct == 0 ){
                SerionNo = 10;
            }else if ( SerionNo < 100 ){
                SerionNo = MaxCampaignProduct + 1;
                SerionNo *= 10; 
            }else{
                SerionNo += 10; 
            }
            MaxCampaignProduct++;
            ListToReturn.add( new CampaignProductWrapper( SerionNo ) );
        }  
        return ListToReturn; 
    }

    @AuraEnabled 
    public static RequestStatus SaveProductCtrl( String paramCampaignRecordId, String paramPriceBookName, String paramListCampaignProductWrapper){
        RequestStatus RequestStatusObj = new RequestStatus();
        Map<String,Id> MapProductCodeToProduct = new Map<String,Id>();
        Map<String,PricebookEntry> MapProductCodeToPBE = new Map<String,PricebookEntry>();
        
        List<String> ListProductCode = new List<String>();
        List<CampaignProductWrapper> ListCampaignProductToAdd = new List<CampaignProductWrapper>();
        ListCampaignProductToAdd = (List<AddProductCampaignCtrl.CampaignProductWrapper>)JSON.deserialize(paramListCampaignProductWrapper,List<AddProductCampaignCtrl.CampaignProductWrapper>.Class); 
        
        List<Campaign_Products__c> ListCampaignProduct = new List<Campaign_Products__c>();
        Set<String> SetProductName = new Set<String>();
        Set<String> SetProductWithPBE = new Set<String>();
        Campaign CampaignObj = [SELECT Id, CurrencyIsoCode 
                                FROM Campaign 
                                WHERE Id =: paramCampaignRecordId ];
        Boolean ReturnList = false;

        for( CampaignProductWrapper CampaignProductWrapperObj : ListCampaignProductToAdd )
        {
            if( CampaignProductWrapperObj.ProductCode != null && CampaignProductWrapperObj.ProductCode != ''){
                ListProductCode.add( CampaignProductWrapperObj.ProductCode );
            }
        }

        for( Product2 ProductObj : [SELECT Id, ProductCode, SAP_Product_Code__c 
                                    FROM Product2
                                    WHERE SAP_Product_Code__c IN : ListProductCode
                                    AND IsActive = true]){
            MapProductCodeToProduct.put( ProductObj.SAP_Product_Code__c , ProductObj.Id );
            SetProductName.add( ProductObj.SAP_Product_Code__c );

        }

        for( PriceBookEntry PriceBookEntryObj : [SELECT Id, UnitPrice, Product2.SAP_Product_Code__c 
                                                FROM PriceBookEntry
                                                WHERE Product2.SAP_Product_Code__c IN : ListProductCode
                                                AND Pricebook2.Name = : paramPriceBookName
                                                AND Product2.IsActive = true
                                                AND CurrencyIsoCode =: CampaignObj.CurrencyIsoCode]){
            MapProductCodeToPBE.put( PriceBookEntryObj.Product2.SAP_Product_Code__c , PriceBookEntryObj );
            SetProductWithPBE.add( PriceBookEntryObj.Product2.SAP_Product_Code__c );
        }

        for( CampaignProductWrapper CampaignProductWrapperObj : ListCampaignProductToAdd )
        {
            if( CampaignProductWrapperObj.ProductCode != null && CampaignProductWrapperObj.ProductCode != '' && 
                !SetProductName.contains( CampaignProductWrapperObj.ProductCode ) && 
                SetProductWithPBE.size() != 0 && !SetProductWithPBE.contains( CampaignProductWrapperObj.ProductCode ) ){
                CampaignProductWrapperObj.IsValidProduct = false;
            }else if( CampaignProductWrapperObj.ProductCode != null && CampaignProductWrapperObj.ProductCode != '' && 
                ( SetProductName.size() == 0 || SetProductWithPBE.size() == 0 ) ){
                CampaignProductWrapperObj.IsValidProduct = false;
            }else{
                CampaignProductWrapperObj.IsValidProduct = true;
            }

            if( CampaignProductWrapperObj.ProductCode != null && CampaignProductWrapperObj.ProductCode != '' && 
                CampaignProductWrapperObj.ProductQuantity == 0 ){
                CampaignProductWrapperObj.IsValidQuntity = false;
            }else{
                CampaignProductWrapperObj.IsValidQuntity = true;
            }
            if( CampaignProductWrapperObj.ProductCode != null && CampaignProductWrapperObj.ProductCode != '' &&
                CampaignProductWrapperObj.CampaignPrice == 0.0 ){
                CampaignProductWrapperObj.IsValidPrice = false;
            }else{
                CampaignProductWrapperObj.IsValidPrice = true;
            }

            if( CampaignProductWrapperObj.IsValidProduct && 
                CampaignProductWrapperObj.IsValidQuntity &&
                CampaignProductWrapperObj.IsValidPrice ){

                CampaignProductWrapperObj.IsValid = true;

            }else{
                CampaignProductWrapperObj.IsValid = false;
                ReturnList = true;
            }
        }


        if( ReturnList ){
            RequestStatusObj.IsSuccessfull = false;
            RequestStatusObj.ErrorMessage = 'Product Not Found';
            RequestStatusObj.SuccessMessage = '';
            RequestStatusObj.ListCampaignProductWrapper = ListCampaignProductToAdd;
            return RequestStatusObj;
        }

        for( CampaignProductWrapper CampaignProductWrapperObj : ListCampaignProductToAdd ){
            if( CampaignProductWrapperObj.ProductCode != null && CampaignProductWrapperObj.ProductCode != ''){

                if( MapProductCodeToProduct.get( CampaignProductWrapperObj.ProductCode ) != null && MapProductCodeToPBE.get( CampaignProductWrapperObj.ProductCode ) != null ){

                    ListCampaignProduct.add( new Campaign_Products__c( Campaign__c = paramCampaignRecordId, Line_Number__c = CampaignProductWrapperObj.Serial, 
                                                                    Campaign_Price__c = CampaignProductWrapperObj.CampaignPrice,
                                                                    Product__c = MapProductCodeToProduct.get( CampaignProductWrapperObj.ProductCode ),
                                                                    Quantity__c = CampaignProductWrapperObj.ProductQuantity,
                                                                    CurrencyIsoCode = CampaignObj.CurrencyIsoCode ) );
                }
            }
        }
        if( ListCampaignProduct.size() > 0 ){
            try{
                insert ListCampaignProduct;
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
        return RequestStatusObj;
    }
    
    @AuraEnabled 
    public static List<CampaignProductWrapper> CheckPastedDateCtrl( String paramCampaignRecordId, String paramStringObject){
        List<CampaignProductWrapper> ListCampaignProductWrapper = new List<CampaignProductWrapper>();
        List<CampaignProductWrapper2> ListCampaignProductWrapper2 = new List<CampaignProductWrapper2>();
        
        if( paramStringObject.contains( '<tr>' ) ){
            for(String StringRowObj : paramStringObject.split( '<tr>' ) )
            {
                StringRowObj = StringRowObj.replace('</tr>','');

                if( StringRowObj != '' && StringRowObj.contains('<td>') ){

                    CampaignProductWrapper2 CampaignProductWrapper2Obj = new CampaignProductWrapper2();
                    List<String> ListTempString = StringRowObj.split( '</td>' );
                    
                    if( ListTempString.size() == 3 && StringRowObj.contains('<td>') ){
                        if( ListTempString[0].replace('<td>','').trim() != '' ){
                            CampaignProductWrapper2Obj.ProductCode = ListTempString[0].replace('<td>','');
                        }
                        if( ListTempString[1].replace('<td>','').trim() != '' ){
                            CampaignProductWrapper2Obj.ProductQuantity = Integer.valueOf( ListTempString[1].replace('<td>','').trim() ) ;
                        }
                        if( ListTempString[2].replace('<td>','').trim() != '' ){
                            CampaignProductWrapper2Obj.CampaignPrice = Decimal.valueOf( ListTempString[2].replace('<td>','').trim() );
                        }
                    }else if( ListTempString.size() == 2 && StringRowObj.contains('<td>') && StringRowObj.length() > 4 ){
                        if( ListTempString[0].replace('<td>','').trim() != '' ){
                            CampaignProductWrapper2Obj.ProductCode = ListTempString[0].replace('<td>','');
                        }
                        if( ListTempString[1].replace('<td>','').trim() != '' ){
                            CampaignProductWrapper2Obj.ProductQuantity = Integer.valueOf( ListTempString[1].replace('<td>','').trim() ) ;
                        }
                        CampaignProductWrapper2Obj.CampaignPrice = 0.0;
                    
                    }else{
                        CampaignProductWrapper2Obj.ProductCode = 'Product Not Specified';
                        CampaignProductWrapper2Obj.ProductQuantity = null;
                        CampaignProductWrapper2Obj.CampaignPrice = null;
                    }
                    if( CampaignProductWrapper2Obj.ProductCode != null ){
                        ListCampaignProductWrapper2.add( CampaignProductWrapper2Obj );
                    }
                }
            }
        }
        if( ListCampaignProductWrapper2.size() > 0 ){
            AggregateResult[] groupedResults = [SELECT MAX(Line_Number__c) MaxSrNo FROM Campaign_Products__c WHERE Campaign__c =: paramCampaignRecordId ]; 
            if( groupedResults[0].get('MaxSrNo') != null ){
                MaxCampaignProduct = Integer.valueOf( groupedResults[0].get('MaxSrNo') ) ;
            }else{
                MaxCampaignProduct = 0;
            }
                    
            Integer SerionNo = MaxCampaignProduct;
            for( Integer i = 0; i < ListCampaignProductWrapper2.size(); i++ ){
                if( MaxCampaignProduct == 0 ){
                    SerionNo = 10;
                }else if ( SerionNo < 10 ){
                    SerionNo = MaxCampaignProduct + 1;
                    SerionNo *= 10; 
                }else{
                    SerionNo += 10; 
                }
                MaxCampaignProduct++;   
                ListCampaignProductWrapper.add( new CampaignProductWrapper( SerionNo , ListCampaignProductWrapper2[i] ) ); 
            }

        }
        return ListCampaignProductWrapper;
    }

    public class CampaignProductWrapper{
        
        @AuraEnabled public Integer Serial { Get;Set; }
        @AuraEnabled public String ProductCode { Get;Set; }
        @AuraEnabled public Integer ProductQuantity { Get;Set; }
        @AuraEnabled public Decimal CampaignPrice { Get;Set; }
        @AuraEnabled public Boolean IsValid { Get;Set; }
        @AuraEnabled public Boolean IsValidProduct { Get;Set; }
        @AuraEnabled public Boolean IsValidQuntity { Get;Set; }
        @AuraEnabled public Boolean IsValidPrice { Get;Set; }

        public CampaignProductWrapper(){}
        
        public CampaignProductWrapper(Integer paramSerial){
            Serial = paramSerial;
            ProductCode = '';
            ProductQuantity = 0;
            CampaignPrice = 0.0;
            IsValid = true;
            IsValidProduct = true;
            IsValidQuntity = true;
            IsValidPrice = true;
        }

        public CampaignProductWrapper(Integer paramSerial, CampaignProductWrapper2 paramCampaignProductWrapper2 ){
            Serial = paramSerial;
            ProductCode = paramCampaignProductWrapper2.ProductCode;
            ProductQuantity = paramCampaignProductWrapper2.ProductQuantity;
            CampaignPrice = paramCampaignProductWrapper2.CampaignPrice;
            IsValid = true;
            IsValidProduct = true;
            IsValidQuntity = true;
            IsValidPrice = true;
        }
    }

    private Class CampaignProductWrapper2{
        private String ProductCode { Get;Set; }
        private Integer ProductQuantity { Get;Set; }
        private Decimal CampaignPrice { Get;Set; }

        public CampaignProductWrapper2(){
            ProductCode = '';
            ProductQuantity = 0;
            CampaignPrice = 0.0;
        }
    }
}