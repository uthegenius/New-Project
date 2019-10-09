global class MarkOpportunityCompletedSch implements Schedulable 
{
  global void execute(SchedulableContext sc) 
    {
    List<Opportunity> listOpp = [select Id, Has_Order__c, Campaign.EndDate 
                                     from Opportunity 
                                     where Campaign.EndDate = :Date.today().addDays(-1) and Has_Order__c = true and StageName = 'Closed Won'];
    system.debug(listOpp);  
        
        if (listOpp != null && listOpp.size() > 0)
        {
            List<Opportunity> listOppToUpdate = new List<Opportunity>();
            
            for (Opportunity opp : listOpp)
            {
                opp.StageName = 'Completed';
                listOppToUpdate.add(opp);
            }
            
            update listOppToUpdate;
        }
    }
}