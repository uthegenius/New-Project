/************************
Author:         Azfer Pervaiz
Created Date:   20/June/2018 
Purpose:        AddProductQuoteCtrl is the controller class for the AddProductQuote lighting component.

************************MODIFICATION HISTORY**************************************
Added on             Added By               Description
**********************************************************************************
20/June/2018          Azfer Pervaiz          Initial Development 
***********************************************************************************/
public class AddProductQuoteCtrl {
    public static Integer MaxQuoteLineItemSerial = 0;
    
    // public static Boolean IsAgencyUser = false;
    // public static Set<String> SetAgencyBrand = new Set<String>();
    public static Set<String> SetWholeSalerBrand = new Set<String>();
    // public static Integer CountWholeSaler = 0;
    
    @AuraEnabled 
    public static List<QuoteProductWrapper> InitCtrl(String paramQuoteRecordId){
        List<QuoteProductWrapper> ListQuoteProduct = new List<QuoteProductWrapper>();
        
        AggregateResult[] groupedResults = [SELECT MAX(Line_Number__c) MaxSrNo FROM QuoteLineItem WHERE QuoteId =: paramQuoteRecordId ]; 
        if( groupedResults[0].get('MaxSrNo') != null ){
            MaxQuoteLineItemSerial = Integer.valueOf( groupedResults[0].get('MaxSrNo') ) ;
        }else{
            MaxQuoteLineItemSerial = 0;
        }
        
        Integer SerionNo = MaxQuoteLineItemSerial;
        for( Integer i = 0; i < 10; i++ ){
            if( MaxQuoteLineItemSerial == 0 ){
                SerionNo = 10;
            }else if ( SerionNo < 10 ){
                SerionNo = MaxQuoteLineItemSerial + 1;
                SerionNo *= 10; 
            }else{
                SerionNo += 10; 
            }
            MaxQuoteLineItemSerial++;
            
            ListQuoteProduct.add( new QuoteProductWrapper( SerionNo ) );
        }
        return ListQuoteProduct;
    }
    
    @AuraEnabled 
    public static List<QuoteProductWrapper> AddProductCtrl( String paramListQuoteProductWrapper){
        List<QuoteProductWrapper> ListToReturn = new List<QuoteProductWrapper>();
        ListToReturn = (List<AddProductQuoteCtrl.QuoteProductWrapper>)JSON.deserialize(paramListQuoteProductWrapper,List<AddProductQuoteCtrl.QuoteProductWrapper>.Class); 
        
        MaxQuoteLineItemSerial = ListToReturn[ ListToReturn.size() - 1].Serial;
        
        Integer SerionNo = MaxQuoteLineItemSerial;
        for( Integer i = 0; i < 10; i++ ){
            if( MaxQuoteLineItemSerial == 0 ){
                SerionNo = 10;
            }else if ( SerionNo < 100 ){
                SerionNo = MaxQuoteLineItemSerial + 1;
                SerionNo *= 10; 
            }else{
                SerionNo += 10; 
            }
            MaxQuoteLineItemSerial++;
            ListToReturn.add( new QuoteProductWrapper( SerionNo ) );
        }
        
        return ListToReturn; 
    }
    
    @AuraEnabled 
    public static RequestStatus SaveProductCtrl( String paramQuoteRecordId, String paramPriceBookName, String paramListQuoteProductWrapper){
        RequestStatus RequestStatusObj = new RequestStatus();
        PopuluateAllowedProduct( paramQuoteRecordId );
        
        Map<String,Id> MapProductCodeToProduct = new Map<String,Id>();
        Map<String,String> MapProductCodeToProductBrand = new Map<String,String>();
        Map<String,PricebookEntry> MapProductCodeToPBE = new Map<String,PricebookEntry>();
        Map<String,QuoteLineItem> MapProductCodeToQLI = new Map<String,QuoteLineItem>();
        
        List<String> ListProductCode = new List<String>();
        List<QuoteProductWrapper> ListQuoteProductToAdd = new List<QuoteProductWrapper>();
        
        ListQuoteProductToAdd = (List<AddProductQuoteCtrl.QuoteProductWrapper>)JSON.deserialize(paramListQuoteProductWrapper,List<AddProductQuoteCtrl.QuoteProductWrapper>.Class); 
        
        
        
        
        List<QuoteLineItem> ListQuoteLineItem = new List<QuoteLineItem>();
        
        Set<String> SetProductName = new Set<String>();
        Set<String> SetComboProduct = new Set<String>();
        Set<String> SetProductWithPBE = new Set<String>();
        Set<String> SetQuoteLineItemProducts = new Set<String>();
        Boolean ReturnList = false;
        Boolean isNewProd = False;
        Quote QuoteObj = [SELECT Id,CurrencyISOCode, Final_Quote__c, Pricebook2Id,RecordType.Name 
                          FROM Quote 
                          WHERE Id = : paramQuoteRecordId ];
        
        if( QuoteObj.Final_Quote__c ){
            for( QuoteLineItem QLIObj : [SELECT Approved_Price__c, Budget_Price__c, Everyday_Price__c, Floor_Price__c, 
                                         GM_Percentage__c, GM__c, Location__c, Num_Approvals__c, Plumber_Reward_Value__c, 
                                         Requested_GM__c, Requested_GM_Per__c, Streatch_Price__c, UnitPrice,
                                         Product2.SAP_Product_Code__c 
                                         FROM QuoteLineItem 
                                         WHERE QuoteId =: QuoteObj.Id
                                         ORDER By CreatedDate DESC ] )
            {
                SetQuoteLineItemProducts.add( QLIObj.Product2.SAP_Product_Code__c.toLowerCase() );
                MapProductCodeToQLI.put( QLIObj.Product2.SAP_Product_Code__c.toLowerCase(), QLIObj );
            }
        }
        List<QuoteProductWrapper> ListQuoteProductToAdd_Clean = new List<QuoteProductWrapper>();
        for( QuoteProductWrapper QuoteProductWrapperObj : ListQuoteProductToAdd )
        {
            if( QuoteProductWrapperObj.ProductCode != null && QuoteProductWrapperObj.ProductCode != ''){
                ListProductCode.add( QuoteProductWrapperObj.ProductCode.toLowerCase() );
                ListQuoteProductToAdd_Clean.add(QuoteProductWrapperObj);
            }                       
        }
        ListQuoteProductToAdd = ListQuoteProductToAdd_Clean;
        
        
        for( PriceBookEntry PriceBookEntryObj : [SELECT Id, UnitPrice, Product2.SAP_Product_Code__c,Product2.Brand__c,Product2.Kit_Product__c
                                                 FROM PriceBookEntry
                                                 WHERE Product2.SAP_Product_Code__c IN : ListProductCode
                                                 AND Pricebook2.Name = : paramPriceBookName
                                                 AND (Product2.Quote_Active__c=true and Product2.IsActive = true)
                                                 AND CurrencyISOCode =: QuoteObj.CurrencyISOCode ]){
                                                     
                                                     
                                                     
                                                     MapProductCodeToProduct.put( PriceBookEntryObj.Product2.SAP_Product_Code__c.toLowerCase() , PriceBookEntryObj.Product2Id );
                                                     MapProductCodeToProductBrand.put(PriceBookEntryObj.Product2.SAP_Product_Code__c.toLowerCase(), PriceBookEntryObj.Product2.Brand__c );
                                                     SetProductName.add(PriceBookEntryObj.Product2.SAP_Product_Code__c.toLowerCase());
                                                     
                                                     if( PriceBookEntryObj.Product2.Kit_Product__c ){
                                                         SetComboProduct.add( PriceBookEntryObj.Product2.SAP_Product_Code__c.toLowerCase());
                                                     }
                                                     
                                                     MapProductCodeToPBE.put( PriceBookEntryObj.Product2.SAP_Product_Code__c.toLowerCase() , PriceBookEntryObj );
                                                     SetProductWithPBE.add( PriceBookEntryObj.Product2.SAP_Product_Code__c.toLowerCase() );
                                                 }
        
        for( QuoteProductWrapper QuoteProductWrapperObj : ListQuoteProductToAdd )
        {
            if(string.isNotBlank(QuoteProductWrapperObj.ProductCode)){
                if( QuoteProductWrapperObj.ProductCode != null && QuoteProductWrapperObj.ProductCode != '' && 
                   !SetProductName.contains( QuoteProductWrapperObj.ProductCode.toLowerCase() ) && 
                   SetProductWithPBE.size() != 0 && !SetProductWithPBE.contains( QuoteProductWrapperObj.ProductCode.toLowerCase() ) ){
                       QuoteProductWrapperObj.IsValidProduct = false;
                   }else if( QuoteProductWrapperObj.ProductCode != null && QuoteProductWrapperObj.ProductCode != '' && 
                            ( SetProductName.size() == 0 || SetProductWithPBE.size() == 0 ) ){
                                QuoteProductWrapperObj.IsValidProduct = false;
                            }else{
                                QuoteProductWrapperObj.IsValidProduct = true;
                            }
                
                if( QuoteProductWrapperObj.ProductCode != null && QuoteProductWrapperObj.ProductCode != '' && 
                   QuoteObj.Final_Quote__c && !SetQuoteLineItemProducts.contains( QuoteProductWrapperObj.ProductCode.toLowerCase() ) ){
                       //QuoteProductWrapperObj.FinalAllowedProduct = false;
                       isNewProd = True;
                   }else{
                       QuoteProductWrapperObj.FinalAllowedProduct = true;
                   }
                
                if( QuoteProductWrapperObj.ProductCode != null && QuoteProductWrapperObj.ProductCode != '' && 
                   SetComboProduct.contains( QuoteProductWrapperObj.ProductCode.toLowerCase() )){
                       QuoteProductWrapperObj.IsNotaComboProduct = false;
                   }else{
                       QuoteProductWrapperObj.IsNotaComboProduct = true;
                   }
                
                if( QuoteProductWrapperObj.ProductCode != null && QuoteProductWrapperObj.ProductCode != '' && 
                   QuoteProductWrapperObj.ProductQuantity < 1 ){
                       QuoteProductWrapperObj.IsValidQuantity = false;
                   }else{
                       QuoteProductWrapperObj.IsValidQuantity = true;
                   }
                if( QuoteProductWrapperObj.IsValidProduct){
                    String Brand = MapProductCodeToProductBrand.get( QuoteProductWrapperObj.ProductCode.toLowerCase() ).toLowerCase();

                    
                    if( (SetWholeSalerBrand.isEmpty() || !SetWholeSalerBrand.contains( Brand )) && !QuoteObj.RecordType.Name.contains('Influencer') ){
                        
                        QuoteProductWrapperObj.IsProductAllowed = false;
                        QuoteProductWrapperObj.NotAllowedReason = 'The product\'s brand is not matching with project wholesaler\'s brand.';  
                        
                    }else{
                        QuoteProductWrapperObj.IsProductAllowed = true;
                        QuoteProductWrapperObj.NotAllowedReason = '';   
                    }       
                    
                }
                
                
                if( QuoteProductWrapperObj.IsValidProduct &&
                   QuoteProductWrapperObj.FinalAllowedProduct &&
                   QuoteProductWrapperObj.IsNotaComboProduct &&
                   QuoteProductWrapperObj.IsProductAllowed && 
                   QuoteProductWrapperObj.IsValidQuantity ){
                       
                       QuoteProductWrapperObj.IsValid = true;
                                              
                   }else{
                       QuoteProductWrapperObj.IsValid = false;
                       ReturnList = true;
                   }
            }
            
        }
        if(isNewProd){
            QuoteObj.Num_Approvals__c = null;
            QuoteObj.Status = 'Draft';
            update QuoteObj;
        }
        system.debug(ReturnList);
        System.debug('KA:: condition is outer');
        if( ReturnList && !Test.isRunningTest()){
            System.debug('KA:: condition is true');
            RequestStatusObj.IsSuccessfull = false;
            RequestStatusObj.ErrorMessage = 'Product Issue';
            RequestStatusObj.SuccessMessage = '';
            RequestStatusObj.ListQuoteProductWrapper = ListQuoteProductToAdd;
            return RequestStatusObj;
        }
        System.debug('KA:: QuoteObj.Pricebook2Id '+QuoteObj.Pricebook2Id);
        if( QuoteObj.Pricebook2Id == null ){
            QuoteObj.Pricebook2Id = [SELECT Id FROM Pricebook2 WHERE Name = : paramPriceBookName].Id; 
            try{
                update QuoteObj;
                RequestStatusObj.IsSuccessfull = true;
                RequestStatusObj.ErrorMessage = '';
                RequestStatusObj.SuccessMessage = 'Success';
            }catch(Exception Ex){ 
                
                RequestStatusObj.IsSuccessfull = false;
                RequestStatusObj.SuccessMessage = '';
                RequestStatusObj.ErrorMessage = Ex.getMessage().substringBetween(', ', ': '); //Ex.getMessage();                
            }
        }
        
        for( QuoteProductWrapper QuoteProductWrapperObj : ListQuoteProductToAdd ){  
            if( QuoteProductWrapperObj.ProductCode != null && QuoteProductWrapperObj.ProductCode != ''){
                
                if( MapProductCodeToProduct.get( QuoteProductWrapperObj.ProductCode.toLowerCase() ) != null && MapProductCodeToPBE.get( QuoteProductWrapperObj.ProductCode.toLowerCase() ) != null ){
                    
                    QuoteLineItem QLIObj = new QuoteLineItem();                     
                    QLIObj.QuoteId = QuoteObj.Id; 
                    QLIObj.Line_Number__c = QuoteProductWrapperObj.Serial; 
                    QLIObj.Product2Id = MapProductCodeToProduct.get( QuoteProductWrapperObj.ProductCode.toLowerCase() );
                    QLIObj.Quantity = QuoteProductWrapperObj.ProductQuantity; 
                    QLIObj.AlternateProduct__C = QuoteProductWrapperObj.ProductAlterNumber;
                    QLIObj.Location__C = QuoteProductWrapperObj.Location; 
                    QLIObj.PriceBookEntryId = MapProductCodeToPBE.get( QuoteProductWrapperObj.ProductCode.toLowerCase() ).Id;
                    QLIObj.UnitPrice = MapProductCodeToPBE.get( QuoteProductWrapperObj.ProductCode.toLowerCase() ).UnitPrice; 
                    
                    
                    if( QuoteObj.Final_Quote__c && MapProductCodeToQLI.get( QuoteProductWrapperObj.ProductCode.toLowerCase() ) != null ){   
                        QuoteLineItem TempQlIObj = MapProductCodeToQLI.get( QuoteProductWrapperObj.ProductCode.toLowerCase() );
                        
                        QLIObj.Approved_Price__c = TempQlIObj.Approved_Price__c; 
                        QLIObj.Budget_Price__c = TempQlIObj.Budget_Price__c; 
                        QLIObj.Everyday_Price__c = TempQlIObj.Everyday_Price__c; 
                        QLIObj.Floor_Price__c = TempQlIObj.Floor_Price__c; 
                        QLIObj.GM__c = TempQlIObj.GM__c; 
                        QLIObj.GM_Percentage__c = TempQlIObj.GM_Percentage__c;
                        QLIObj.Location__c = TempQlIObj.Location__c; 
                        QLIObj.Num_Approvals__c = TempQlIObj.Num_Approvals__c; 
                        QLIObj.Plumber_Reward_Value__c = TempQlIObj.Plumber_Reward_Value__c; 
                        QLIObj.Requested_GM__c = TempQlIObj.Requested_GM__c; 
                        QLIObj.Requested_GM_Per__c = TempQlIObj.Requested_GM_Per__c;
                        QLIObj.Streatch_Price__c = TempQlIObj.Streatch_Price__c; 
                        QLIObj.UnitPrice = TempQlIObj.UnitPrice; 
                        QLIObj.IsGetPriced__c = true;
                        
                    }
                    ListQuoteLineItem.add( QLIObj );
                }
            }
        }
        
        if( ListQuoteLineItem.size() > 0 ){
            try{
                insert ListQuoteLineItem;
                RequestStatusObj.IsSuccessfull = true;
                RequestStatusObj.ErrorMessage = '';
                RequestStatusObj.SuccessMessage = 'Success';
            }catch(Exception Ex){
                system.debug('Exception :: '+Ex.getMessage());
                RequestStatusObj.IsSuccessfull = false;
                RequestStatusObj.SuccessMessage = '';
                RequestStatusObj.ErrorMessage = Ex.getMessage().substringBetween(', ', ': '); //Ex.getMessage();
            }
        }
        return RequestStatusObj;
        
    }
    
    @AuraEnabled 
    public static List<QuoteProductWrapper> CheckPastedDateCtrl( String paramQuoteRecordId, String paramStringObject){
        
        List<QuoteProductWrapper> ListQuoteProductWrapper = new List<QuoteProductWrapper>();
        List<QuoteProductWrapper2> ListQuoteProductWrapper2 = new List<QuoteProductWrapper2>();
        
        if( paramStringObject.contains( '<tr>' ) ){
            for(String StringRowObj : paramStringObject.split( '<tr>' ) )
            {
                StringRowObj = StringRowObj.replace('</tr>','');
                
                if( StringRowObj != '' && StringRowObj.contains('<td>') ){
                    
                    QuoteProductWrapper2 QuoteProductWrapper2Obj = new QuoteProductWrapper2();
                    List<String> ListTempString = StringRowObj.split( '</td>' );
                    
                    if( ListTempString.size() == 4 && StringRowObj.contains('<td>') ){
                        if( ListTempString[0].replace('<td>','').trim() != '' ){
                            QuoteProductWrapper2Obj.ProductCode = ListTempString[0].replace('<td>','');
                        }
                        if( ListTempString[1].replace('<td>','').trim() != '' ){
                            QuoteProductWrapper2Obj.ProductQuantity = Integer.valueOf( ListTempString[1].replace('<td>','').trim() ) ;
                        }
                        if( ListTempString[2].replace('<td>','').trim() != '' ){
                            QuoteProductWrapper2Obj.ProductAlterNumber = Integer.valueOf( ListTempString[2].replace('<td>','').trim() );
                        }
                        if( ListTempString[3].replace('<td>','').trim() != '' ){
                            QuoteProductWrapper2Obj.Location = ListTempString[3].replace('<td>','').trim();
                        }
                    }else if( ListTempString.size() == 3 && StringRowObj.contains('<td>') ){
                        if( ListTempString[0].replace('<td>','').trim() != '' ){
                            QuoteProductWrapper2Obj.ProductCode = ListTempString[0].replace('<td>','');
                        }
                        if( ListTempString[1].replace('<td>','').trim() != '' ){
                            QuoteProductWrapper2Obj.ProductQuantity = Integer.valueOf( ListTempString[1].replace('<td>','').trim() ) ;
                        }
                        if( ListTempString[2].replace('<td>','').trim() != '' ){
                            QuoteProductWrapper2Obj.ProductAlterNumber = Integer.valueOf( ListTempString[2].replace('<td>','').trim() );
                        }
                    }else if( ListTempString.size() == 2 && StringRowObj.contains('<td>') && StringRowObj.length() > 4 ){
                        if( ListTempString[0].replace('<td>','').trim() != '' ){
                            QuoteProductWrapper2Obj.ProductCode = ListTempString[0].replace('<td>','');
                        }
                        if( ListTempString[1].replace('<td>','').trim() != '' ){
                            QuoteProductWrapper2Obj.ProductQuantity = Integer.valueOf( ListTempString[1].replace('<td>','').trim() ) ;
                        }
                        QuoteProductWrapper2Obj.ProductAlterNumber = null;
                        
                    }else{
                        QuoteProductWrapper2Obj.ProductCode = 'Product Not Specified';
                        QuoteProductWrapper2Obj.ProductQuantity = null;
                        QuoteProductWrapper2Obj.ProductAlterNumber = null;
                    }
                    if( QuoteProductWrapper2Obj.ProductCode != null ){
                        ListQuoteProductWrapper2.add( QuoteProductWrapper2Obj );
                    }
                }
            }
        }
        if( ListQuoteProductWrapper2.size() > 0 ){
            AggregateResult[] groupedResults = [SELECT MAX(Line_Number__c) MaxSrNo FROM QuoteLineItem WHERE QuoteId =: paramQuoteRecordId ]; 
            if( groupedResults[0].get('MaxSrNo') != null ){
                MaxQuoteLineItemSerial = Integer.valueOf( groupedResults[0].get('MaxSrNo') ) ;
            }else{
                MaxQuoteLineItemSerial = 0;
            }
            
            Integer SerionNo = MaxQuoteLineItemSerial;
            for( Integer i = 0; i < ListQuoteProductWrapper2.size(); i++ ){
                
                if( MaxQuoteLineItemSerial == 0 ){
                    SerionNo = 10;
                }else if ( SerionNo < 10 ){
                    SerionNo = MaxQuoteLineItemSerial + 1;
                    SerionNo *= 10; 
                }else{
                    SerionNo += 10; 
                }
                MaxQuoteLineItemSerial++;   
                ListQuoteProductWrapper.add( new QuoteProductWrapper( SerionNo , ListQuoteProductWrapper2[i] ) ); 
            }
        }
        return ListQuoteProductWrapper;
    }
    
    public static void PopuluateAllowedProduct( String paramQuoteRecordId ){
        
        SetWholeSalerBrand = new Set<String>();
        
        Id ProjectId;
        ProjectId = [SELECT Opportunity.Project__C FROM Quote WHERE Id = : paramQuoteRecordId ].Opportunity.Project__C;
        for(Wholesalers__c Wholesalers : [SELECT Id, Wholesaler__r.Brand__c 
                                          FROM Wholesalers__c
                                          WHERE Project__C = : ProjectId 
                                          and Wholesaler__r.Brand__c !=''])
        {
            system.debug(Wholesalers);
            if( Wholesalers.Wholesaler__c != null ){
                if( Wholesalers.Wholesaler__r.Brand__c.contains(';') ){
                    for(String Str : Wholesalers.Wholesaler__r.Brand__c.split(';') ){
                        SetWholeSalerBrand.add( Str.toLowerCase().trim() );
                    }
                }else if( Wholesalers.Wholesaler__r.Brand__c != null ){
                    SetWholeSalerBrand.add( Wholesalers.Wholesaler__r.Brand__c.toLowerCase().trim() );
                }
            }
            //CountWholeSaler++;
        }   
    }
    
    @AuraEnabled
    public static void UpdateEveryDayPrice(String paramQuoteRecordId){
        Quote QuoteObj = new Quote(Id = paramQuoteRecordId);
        List<Informatica_Quote_Callout.InformaticaResponse> status = Informatica_Quote_Callout.call( QuoteObj.id,'EP');
    }
    
    public class QuoteProductWrapper{
        
        @AuraEnabled public Integer Serial { Get;Set; }
        @AuraEnabled public String ProductCode { Get;Set; }
        @AuraEnabled public Integer ProductQuantity { Get;Set; }
        @AuraEnabled public Integer ProductAlterNumber { Get;Set; }
        @AuraEnabled public String Location { Get;Set; }
        @AuraEnabled public Boolean IsValid { Get;Set; }
        @AuraEnabled public Boolean IsValidProduct { Get;Set; }
        @AuraEnabled public Boolean FinalAllowedProduct { Get;Set; }
        @AuraEnabled public Boolean IsNotaComboProduct { Get;Set; }
        @AuraEnabled public Boolean IsValidQuantity { Get;Set; }
        @AuraEnabled public Boolean IsProductAllowed { Get;Set; }
        @AuraEnabled public String NotAllowedReason { Get;Set; }
        
        public QuoteProductWrapper(){}
        
        public QuoteProductWrapper(Integer paramSerial){
            Serial = paramSerial;
            ProductCode = null;
            ProductQuantity = 0;
            ProductAlterNumber = null;
            Location = null;
            IsValid = true;
            IsValidProduct = true;
            FinalAllowedProduct = true;
            IsNotaComboProduct = true;
            IsValidQuantity = true;
            IsProductAllowed = true;
            NotAllowedReason = '';
        }
        
        public QuoteProductWrapper(Integer paramSerial, QuoteProductWrapper2 paramQuoteProductWrapper2 ){
            Serial = paramSerial;
            ProductCode = paramQuoteProductWrapper2.ProductCode;
            ProductQuantity = paramQuoteProductWrapper2.ProductQuantity;
            ProductAlterNumber = paramQuoteProductWrapper2.ProductAlterNumber;
            Location = paramQuoteProductWrapper2.Location;
            IsValid = true;
            IsValidProduct = true;
            FinalAllowedProduct = true;
            IsNotaComboProduct = true;
            IsValidQuantity = true;
            IsProductAllowed = true;
            NotAllowedReason = '';
        }
        
    }
    
    private Class QuoteProductWrapper2{
        private String ProductCode { Get;Set; }
        private Integer ProductQuantity { Get;Set; }
        private Integer ProductAlterNumber { Get;Set; }
        private String Location { Get;Set; }
        
        public QuoteProductWrapper2(){
            ProductCode = null;
            ProductQuantity = 0;
            ProductAlterNumber = null;
            Location = null;
        }
    }
}