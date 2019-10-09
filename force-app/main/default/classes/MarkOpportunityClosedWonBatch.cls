global class MarkOpportunityClosedWonBatch implements Database.Batchable<sObject>
{
    private List<Id> strParameter;

    public MarkOpportunityClosedWonBatch(List<Id> strParam) {
        strParameter = strParam;
    }
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        System.debug('Quote Ids'+strParameter);
        String query = 'SELECT Id, StageName FROM Opportunity WHERE FinalQuote__c IN:strParameter AND Has_Order__c=true';
        return Database.getQueryLocator(query);
    }
 
    global void execute(Database.BatchableContext BC, List<Opportunity> opportunities)
    {
        System.debug('Opportunities: '+opportunities);
         for(Opportunity opportunity : opportunities)
         {
            opportunity.StageName = 'Closed Won';
             opportunity.Won_Reason__c = 'Automatic';
         }
        update opportunities;
    }  
    global void finish(Database.BatchableContext BC)
    {
    }
}