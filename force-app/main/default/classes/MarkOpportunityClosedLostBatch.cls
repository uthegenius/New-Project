global class MarkOpportunityClosedLostBatch implements Database.Batchable<sObject>
{
    private List<Id> strParameter;

    public MarkOpportunityClosedLostBatch(List<Id> strParam) {
        strParameter = strParam;
    }
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        System.debug('Quote Ids'+strParameter);
        String query = 'SELECT Id, StageName FROM Opportunity WHERE FinalQuote__c IN:strParameter AND Has_Order__c=false';
        return Database.getQueryLocator(query);
    }
 
    global void execute(Database.BatchableContext BC, List<Opportunity> opportunities)
    {
        System.debug('Opportunities: '+opportunities);
         for(Opportunity opportunity : opportunities)
         {
            opportunity.StageName = 'Closed Lost';
             opportunity.Lost_Reason__c = 'Automatic';
         }
        update opportunities;
    }  
    global void finish(Database.BatchableContext BC)
    {
    }
}