public class CheckBoxFolder_Controller {
    @AuraEnabled 
    public static boolean isBoxFolderExits(String paramQuoteRecordId){
        List<box__FRUP__c> lstboxRec = [select Id 
                                        from box__FRUP__c where box__Record_ID__c = : paramQuoteRecordId ];
        
        system.debug('HB:: '+lstboxRec);
        return lstboxRec.isEmpty();
    }
    
    @AuraEnabled 
    public static wrapperQuoteMessage checkQuote(String paramQuoteRecordId){
        wrapperQuoteMessage result = new wrapperQuoteMessage();
        result.Message='';
        Quote qQuote = [select Id,Active_Quote__c,Version__c,OpportunityId,Opportunity.FinalQuote__c,Opportunity.FinalQuote__r.Version__c,Account__c,Sold_To_SAP_Account__c, 
                        Final_Quote__c, Opportunity.Project__c,Integration_Process_In_Progress__c ,RecordType.Name,Status,Num_Approvals__c
                        from Quote  where Id = : paramQuoteRecordId ];
        List<Wholesalers__c> lstWholeSaler = [Select Id from Wholesalers__c where Project__c =:qQuote.Opportunity.Project__c];
        CheckBoxFolder_Controller obj = new CheckBoxFolder_Controller();
        
        
        If(!qQuote.Final_Quote__c && string.isNotBlank(qQuote.Opportunity.FinalQuote__r.Version__c)){
            result.ActiveQuote = new Quote(Id=qQuote.Opportunity.FinalQuote__c,
                                          Version__c=qQuote.Opportunity.FinalQuote__r.Version__c);
            result.Message += '\n- There is already a FQ exits for this opportunity. It is highly recommended that the FQ version {1} be used.';
        }
        
        If(!qQuote.Active_Quote__c && string.isBlank(qQuote.Opportunity.FinalQuote__r.Version__c)){
            result.ActiveQuote = [Select Id,Version__c From Quote where OpportunityId = :qQuote.OpportunityId and Active_Quote__c = True Limit 1];
            result.Message += '\n- This is not an active version of the quote. It is highly recommended that the active version {1} be used.';
        }
        if(qQuote.Final_Quote__c && (string.isBlank(qQuote.Account__c) ||
                                     string.isBlank(qQuote.Sold_To_SAP_Account__c)) 
          ){
              result.Message += '\n- There is an issue in Ship to account / Sold to account in this Quote. Please re-enter Account before you submit it to SAP.';
          }     
        if(qQuote.Integration_Process_In_Progress__c){
            result.Message += '\n- The price review/FQ process is still in progress.';
        }
        
        if(qQuote.Status=='Draft' && qQuote.Num_Approvals__c == null && qQuote.Final_Quote__c){
            result.Message += '\n- In a FQ, you\'ve added new SKU. Therefore, before submitting to SAP, it is necessary to do the price review and approval again.';
        }
        
        if(lstWholeSaler.isEmpty() && !qQuote.RecordType.Name.contains('Influe') ){
            result.Message += '\n- There is no wholesaler defined in the project. To process the quote smoothly, please define the wholesaler.';
        }
        if(string.isNotBlank(result.Message)){
            result.Message = 'The issues in this quote are below. Please resolve all to transmit successfully to SAP.'+result.Message;
        }
        return result;
    }
    public class wrapperQuoteMessage{
        @AuraEnabled Quote ActiveQuote {get;set;}
        @AuraEnabled String Message {get;set;}
        public wrapperQuoteMessage(){
            ActiveQuote = new Quote();
            Message = '';
        }
    }
}