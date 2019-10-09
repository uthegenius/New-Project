@isTest 
public class sObjectNoofTouch_BatchSch_Test {
    static testMethod void testMethod1() 
    {
        List<Account> lstAccount= new List<Account>();
        for(Integer i=0 ;i <6;i++)
        {
            Account acc = new Account();
            acc.Name ='Name'+i;
            acc.Is_Last_Touch_Limit_Hit__c = False;
            lstAccount.add(acc);
        }
        
        insert lstAccount;
        UtilityTest.createAccountTeam(lstAccount[0].Id);
        UtilityTest.createAccountTeam(lstAccount[1].Id);
        insert new Lixil_Config__c(Last_Touch_Days_Limit__c=0,Object_for_Last_Touches__c='Account');
        Test.startTest();
        
        sObjectNoofTouch_BatchSch.scheduleJob();
        
        Test.stopTest();
    }
}