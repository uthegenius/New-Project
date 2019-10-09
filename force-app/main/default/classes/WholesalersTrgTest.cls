@isTest
public class WholesalersTrgTest {
	
    @isTest
    public static void addWholeselerToProject()
    {
    	Project__c p1 = new Project__c(Name='Test Project1', Project_Type__c='Education');
        Project__c p2 = new Project__c(Name='Test Project1', Project_Type__c='Education');
        insert p1;
        insert p2;
        Account acct1 = UtilityTest.createCustomerAccount();            
            acct1.Brand__c = 'American Standard;Grohe;FIAT';
            update acct1;
        Account acct2 = UtilityTest.createCustomerAccount();            
            acct1.Brand__c = 'American Standard;Grohe;FIAT';
            update acct2;
        
        Wholesalers__c wls1 =new Wholesalers__c(Project__c=p1.id,Wholesaler__c=acct1.id);
        Wholesalers__c wls2 =new Wholesalers__c(Project__c=p2.id,Wholesaler__c=acct2.id);
        Test.startTest();
        List<Wholesalers__c> wlss = new List<Wholesalers__c>();
        wlss.add(wls1);
        wlss.add(wls2);
        insert wlss;
        Project__c prj1 = [select brand__c from Project__c where id=:p1.id ];
       // System.assertEquals('Grohe', prj1.Brand__c);
        Project__c prj2 = [select brand__c from Project__c where id=:p2.id ];
        //System.assertEquals('DXV', prj2.Brand__c);
        Test.stopTest(); 
    }
}