global class MarkOpportunityClosedLostSch implements Schedulable {
global void execute(SchedulableContext ct) {

Date todaysDate = Date.Today();
/* this is a query that should get only the objects where ExpirationDate < Today */
List<Id> quotes = new List<Id>(new Map<Id, Quote>([SELECT Id FROM Quote WHERE ExpirationDate <:todaysDate AND Final_Quote__c = true]).keySet());
System.debug('In MarkOpportunityClosedLostSch');
System.debug(quotes);
MarkOpportunityClosedLostBatch batch = new MarkOpportunityClosedLostBatch(quotes);
database.executebatch(batch,200);

/* update object's status */
}//end execute

}//end MarkOpportunityClosedLostSch