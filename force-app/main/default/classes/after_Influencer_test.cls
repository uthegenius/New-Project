@IsTest
public class after_Influencer_test {
    @IsTest(SeeAllData=true)
    private static void testTrigger()
    {        
        Influencers__c a = [Select Id from Influencers__c where Infuencer_Account__r.Recordtype.name = 'Influencer' limit 1];
        update a;
    }
}