@isTest
public class BoxIntegrationUtilTest 
{
    @TestSetup static void createTestSetupData()
    {
        Account acct = UtilityTest.createCustomerAccount();
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
		opp.AccountId = acct.Id;
        update opp;
        
        Id spbId = UtilityTest.getStandardPBId();
        Product2 prod = UtilityTest.createAmericanStandardProduct(spbId);
        Quote qot = UtilityTest.createStandardQuote(spbId, acct, opp);
        QuoteLineItem qli = UtilityTest.createQLI(spbId, qot,prod);
        Test.stopTest();  
    }
    
	@isTest static void testMQLI()
    {
        Test.startTest();
        Quote qot = [select Id, RecordTypeId, Final_Quote__c, Opportunity.Account.brand__c from Quote limit 1];
        
        ApexPages.StandardController sc = new ApexPages.StandardController(qot);
        
        PageReference pageRef = Page.CreateMQPDFVF;
        pageRef.getParameters().put('id', String.valueOf(qot.Id));
        pageRef.getParameters().put('brands', 'American Standard;DXV');
        Test.setCurrentPage(pageRef);
        
        BoxIntegrationUtil biu = new BoxIntegrationUtil(sc);
        //qe.reviewPrice();
        BoxIntegrationUtil.createFolderinBox(qot.Id);

        Test.stopTest();        
    }
    
	@isTest static void testFQLI()
    {
        Test.startTest();
        Quote qot = [select Id, RecordTypeId, Final_Quote__c from Quote limit 1];
        qot.Final_Quote__c = true;
        update qot;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(qot);
        
        PageReference pageRef = Page.CreateFQPDFVF;
        pageRef.getParameters().put('id', String.valueOf(qot.Id));
        pageRef.getParameters().put('brands', 'American Standard;DXV;FIAT');
        Test.setCurrentPage(pageRef);
        
        BoxIntegrationUtil biu = new BoxIntegrationUtil(sc);

        Test.stopTest();        
    }    
    
	@isTest static void testIQLI()
    {
        Test.startTest();
        
        Account acct = [select id from Account limit 1];
        Opportunity opp = [select id from Opportunity limit 1];
        
        Id spbId = Test.getStandardPricebookId();
        
        Quote qot = UtilityTest.createInfluencerQuote(spbId, acct.id, opp);
        
        Product2 prod = [select Id from Product2 limit 1];
        
        QuoteLineItem qli = UtilityTest.createQLI(spbId, qot, prod);
        
        qot.Final_Quote__c = true;
        update qot;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(qot);
        
        PageReference pageRef = Page.CreateIQPDFVF;
        pageRef.getParameters().put('id', String.valueOf(qot.Id));
        pageRef.getParameters().put('brands', 'American Standard;DXV;FIAT');
        Test.setCurrentPage(pageRef);
        
        BoxIntegrationUtil biu = new BoxIntegrationUtil(sc);
		biu.getFQLineItems();
        
        Test.stopTest();        
    }    
}