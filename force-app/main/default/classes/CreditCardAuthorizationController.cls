/************************
Author:         Abid Raza
Created Date:   03/Oct/2018 
Purpose:        Controller class to send Request to card connect for Credit Card Authorization.
************************/

public class CreditCardAuthorizationController 
{ 
    @AuraEnabled 
	public static Order InitCtrl(String paramOrderRecordId)
    {
        Order ord;
        if(!string.IsBlank(paramOrderRecordId))
        {
            ord = [Select Id,Name,Card_Number__c,Card_Type__c,Card_Holder__c,CVV__c,Order_Amount__c,
                   Merchant_ID__c,isOrder_Simulator__c,Count_of_0_Price_Lines__c,
                   BillingStreet,BillingCity,BillingState,BillingPostalCode,BillingCountry
                   from Order where Id =: paramOrderRecordId limit 1];
        	ord.Card_Holder__c = '';
            ord.Card_Type__c = '';
        }	
		return ord;
	}
    
    @AuraEnabled 
	public static string GetMerchantCurrency(String MerchantId)
    {
        string MerchantCurrency = '';
        if(!string.IsBlank(MerchantId))
        {
            List<CardConnect_Merchant_Information__mdt> Lstcmi = [Select Merchant_Currency__c,Merchant_ID__c from CardConnect_Merchant_Information__mdt];
            
            for(CardConnect_Merchant_Information__mdt cmi: Lstcmi)
            {
                if(cmi.Merchant_ID__c == MerchantId)
                {
                    MerchantCurrency = cmi.Merchant_Currency__c;
                }
            }
        }
        return MerchantCurrency;
	}
    
    @AuraEnabled        
    public static List<String> getPickListValuesIntoList(String objectType, String selectedField)
    {
        List<String> pickListValuesList = new List<String>();
        Schema.SObjectType convertToObj = Schema.getGlobalDescribe().get(objectType);
        Schema.DescribeSObjectResult res = convertToObj.getDescribe();
        Schema.DescribeFieldResult fieldResult = res.fields.getMap().get(selectedField).getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry pickListVal : ple)
        {
            pickListValuesList.add(pickListVal.getLabel());
        }     
        return pickListValuesList;
    }
    
	@AuraEnabled 
    public static string RequestCardAuthorization(Order OrderRecord1,string MerchantCurrency, string ExpiryDate)
    {
       string ResultStatus = '';
        try
        {
            SYSTEM.debug(OrderRecord1);
            SYSTEM.debug(MerchantCurrency);
            SYSTEM.debug(ExpiryDate);
            JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject();     
            gen.writeStringField('merchid', OrderRecord1.Merchant_ID__c);
            gen.writeStringField('accttype', OrderRecord1.Card_Type__c);
            gen.writeStringField('orderid', OrderRecord1.Id);
            gen.writeStringField('account', OrderRecord1.Card_Number__c); 
            gen.writeStringField('address', OrderRecord1.BillingStreet);             
            gen.writeStringField('city', OrderRecord1.BillingCity); 
            gen.writeStringField('region', OrderRecord1.BillingState); 
            gen.writeStringField('country', OrderRecord1.BillingCountry); 
            gen.writeStringField('postal', OrderRecord1.BillingPostalCode); 
            gen.writeStringField('expiry', ExpiryDate);
            gen.writeStringField('amount', String.valueOf(OrderRecord1.Order_Amount__c));
            gen.writeStringField('currency', MerchantCurrency);
            gen.writeStringField('name', OrderRecord1.Card_Holder__c);
            gen.writeStringField('cvv2', String.valueOf(OrderRecord1.CVV__c));
            gen.writeEndObject();   
            String jsonS = gen.getAsString();
            
            System.debug('jsonMaterials'+jsonS);
            ResultStatus = SendRequest(jsonS,OrderRecord1,MerchantCurrency,ExpiryDate);
        }
        catch(Exception ex) 
        { 
            throw new AuraHandledException('Error: '+ 'Something went wrong. Retry or contact your salesforce administrator.' + ex.getMessage() +' - '+ ex.getLineNumber());   
        }
        return ResultStatus;
    }
    
    public static string SendRequest(string jsonS,Order OrderRec, string MerchantCurrency,string ExpiryDate)
    {
        string status = 'B';
        if(!string.isBlank(jsonS))
        {   
            HttpRequest req = new HttpRequest();
            req.setEndpoint('callout:CardConnectAuthorization');
            req.setHeader('Content-Type', 'application/json; charset=utf-8');
            req.setMethod('PUT');
            req.setbody(jsonS);
            
            Http http = new Http();
            HTTPResponse response = http.send(req);
            system.debug('response::'+response);
            string responsebody = response.getBody();
            
            if(!string.isBlank(responsebody))
            {
                CardConnectResponse ccr = (CardConnectResponse) JSON.deserialize(responsebody, CardConnectResponse.class);
               
                // First, Clearing all data on order record to save new response.
                Order OrderRecord = [Select Id,Name,Card_Number__c,Card_Type__c,Card_Holder__c,CVV__c,Order_Amount__c,Valid_to__c,Merchant_ID__c,Authorization_Code__c,Authorization_Ref_No__c,Authorization_Time__c,REACT__c,RCAVR__c,RCAVZ__c,RCRSP__c,Authorization_Status__c,Authorization_Date__c,Merchant_Currency__c,Authorization_Token__c from Order where Id =: OrderRec.Id];
                OrderRecord.Authorization_Code__c = '';
                OrderRecord.Authorization_Status__c = '';
                OrderRecord.Authorization_Token__c = '';
                OrderRecord.Card_Type__c = null;
                OrderRecord.Card_Holder__c = '';
                OrderRecord.Valid_to__c = null;
                OrderRecord.Authorization_Ref_No__c = '';
                OrderRecord.Authorization_Time__c = null;
                OrderRecord.REACT__c = '';
                OrderRecord.RCAVR__c = '';
                OrderRecord.RCAVZ__c = '';
                OrderRecord.RCRSP__c = '';
                OrderRecord.Authorization_Date__c = null;
                OrderRecord.Merchant_Currency__c = null;
                OrderRecord.Authorized_Amount__c = null;
                Update OrderRecord;
                
                // Now, Saving New response on Order.
                //string ExpDate = ExpiryDate.right(2) + '-' + ExpiryDate.left(2);
                //Date ExDate = date.valueOf('20'+ ExpDate + '-01 00:00:00');
                OrderRecord.Authorization_Code__c = ccr.authcode;
                OrderRecord.Authorization_Status__c = ccr.resptext;
                OrderRecord.Authorization_Token__c = ccr.token;
                OrderRecord.Card_Type__c = OrderRec.Card_Type__c;
                OrderRecord.Card_Holder__c = OrderRec.Card_Holder__c;
                OrderRecord.Valid_to__c = ExpiryDate;
                OrderRecord.Authorization_Ref_No__c = ccr.retref;
                OrderRecord.Authorization_Time__c = DateTime.now().time();
                OrderRecord.REACT__c = ccr.respstat;
                OrderRecord.RCAVR__c = ccr.avsresp;
                OrderRecord.RCAVZ__c = ccr.respproc;
                OrderRecord.RCRSP__c = ccr.respcode;
                OrderRecord.Authorization_Date__c = Date.today();
                OrderRecord.Merchant_Currency__c = MerchantCurrency;
                OrderRecord.Authorized_Amount__c = OrderRec.Order_Amount__c;
                Update OrderRecord;
                status = ccr.respstat;
            }
        }
        return status;
    }
    
    public class CardConnectResponse
    {
        public string respstat {get;set;}
        public string authcode {get;set;}
        public string token {get;set;}
        public string resptext {get;set;}
        public string commcard {get;set;}
        public string cvvresp {get;set;}
        public string avsresp {get;set;}
        public string respcode {get;set;}
        public string entrymode {get;set;}
        public string respproc {get;set;}
        public string bintype {get;set;}
        public string retref {get;set;}
    }  
}