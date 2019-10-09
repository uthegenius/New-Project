@isTest
public class QLIListClassTest {

    @isTest static void massQLIDelete()
    {
        Account acct = UtilityTest.createCustomerAccount();
        //Account acct2 = UtilityTest.createCustomerAccount();
        Project__c prj = UtilityTest.createProject();

        User approver1 = UtilityTest.createUser();
        prj.First_Level_Approver__c = approver1.Id;        
        
        User approver2 = UtilityTest.createUser();
        prj.Second_Level_Approver__c = approver2.Id;
        
        User approver3 = UtilityTest.createUser();
        prj.Third_Level_Approver__c = approver3.Id;        
        
        update prj;

        Project_Team__c pt = UtilityTest.createProjectTeam(prj.Id);
        Wholesalers__c ws = UtilityTest.createWholesaler(acct.Id, prj.Id);
        Test.startTest();
        Opportunity opp = UtilityTest.createProjectOpportunity(prj.Id);
        Id spbId = UtilityTest.getStandardPBId();
        Product2 prod = UtilityTest.createAmericanStandardProduct(spbId);
        Quote qot = UtilityTest.createStandardQuote(spbId, acct, opp);
        QuoteLineItem qli = UtilityTest.createQLI(spbId, qot,prod);
        
		QLIListClass.getAssociatedQLI(qot.id+'');
        List<string> listQuoteID = new List<string>();
        listQuoteID.add(qli.id+'');
        QLIListClass.getQuoteName(qot.id+'');
        QLIListClass.massDeleteQLI(listQuoteID);
    }
}