public class DeleteQuoteExt 
{
    @AuraEnabled
    public static string deletedquoteAction(string qid)
    {
        string status = '';
        try
        {
            system.debug('QuoteId');
            if(string.isNotBlank(qid))
            {
            	Quote qt = [Select id From Quote where id =: qid];
                system.debug('Quote ID'+qt.id);
                delete qt;
                status = 'Succeed'; 
            }
            
        }
        catch(Exception e)
        {          
            status = 'Failed';
        }
        return status;
    }
}