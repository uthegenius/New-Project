public class QLIListClass {
    
    @AuraEnabled
    public static QuoteLineItem[] getAssociatedQLI(string quoteId)
    {
        
        id qtid = (id)quoteId;
        QuoteLineItem[] qlis = [SELECT ID,Product2.Name,product2id ,quoteid, Quote.Name ,Quantity ,UnitPrice, ListPrice,Line_Number__c,LineNumber FROM QuoteLineItem WHERE quoteid = :qtid order by LineNumber asc ];
        System.debug('KA:: qlis Size '+ qlis.size());
        System.debug('KA:: quoteId'+ quoteId );
        return qlis;
        
    }
    @AuraEnabled
    public static String getQuoteName(string quoteId)
    {
        
        id qtid = (id)quoteId;
        String quoteName = [SELECT Name from Quote WHERE id = :qtid LIMIT 1].Name;
        System.debug('KA:: quoteName ' + quoteName);
        
        return quoteName;
        
    }
    
    @AuraEnabled
    public static RequestStatus massDeleteQLI(List<String> delIDs){
        RequestStatus result = new RequestStatus();
        List<QuoteLineItem> lstOfDeleteQuoteLineItem =  new List<QuoteLineItem>();
        for(String st: delIDs){
            QuoteLineItem qli = new QuoteLineItem();
            qli.Id = st ;
            lstOfDeleteQuoteLineItem.add(qli);  
        }
        
        List<database.DeleteResult> dr = Database.Delete(lstOfDeleteQuoteLineItem,false);
        Integer i = 0;
        for(database.deleteresult d:dr){
            i++;
            if(!d.isSuccess()){   
                List<database.Error> e = d.getErrors(); 
                for(database.Error err:e){
                    result.ErrorMessage += i+' '+err.getMessage()+'\n';
                }                
            }
        }
        if(string.isNotBlank(result.ErrorMessage)){
            result.IsSuccessfull = false;
        }
        else{
            result.IsSuccessfull = True;
            result.SuccessMessage ='Records deleted successfully.';
        }            
        return result;
    }
}