@IsTest
public class CheckBoxFolder_Controller_Test {
    @TestSetup static void createTestSetupData(){
        Id StdPriceBookId = UtilityTest.getStandardPBId();
        Project__c proj = UtilityTest.createProject();
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        System.runAs ( thisUser ) {
            Project_Team__c projTeamMember1 = UtilityTest.createProjectTeam(proj.Id);            
            Account acc1 = UtilityTest.createCustomerAccount();            
            acc1.Brand__c = 'American Standard;Grohe;FIAT';
            update acc1;
            Wholesalers__c ws1 = UtilityTest.createWholesaler(acc1.Id, proj.Id);
            
            Opportunity OppProj = UtilityTest.createProjectOpportunity(proj.Id);            
            Quote quote1 = UtilityTest.createStandardQuote(StdPriceBookId, acc1.Id, OppProj);
            Product2 ASProd = UtilityTest.createAmericanStandardProduct(StdPriceBookId);
            QuoteLineItem qli1 = UtilityTest.createQLI(StdPriceBookId,quote1,ASProd);
            
            test.startTest();
            Order ord1 = UtilityTest.CreateOrder(acc1.Id,quote1.Id,StdPriceBookId);
            OrderItem orditem1 = UtilityTest.CreateOrderItem(quote1.Id,qli1.Id,ASProd.Id,ord1.Id);
            quote1.Unique_id__c = '0507525556';
            quote1.Num_Approvals__c = 0;
            quote1.Status = 'Processed';
            quote1.Review_Price__c = True;
            update quote1;
            
            test.stopTest();
        }
    }
    
    @isTest static void test_Box_FRUP()
    {
        test.startTest();
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        System.runAs ( thisUser ) {
            Quote qot = [select Id, Num_Approvals__c,recordtypeid,Status,Integration_Process_In_Progress__c from Quote limit 1];        
            box__FRUP__c frup = createBoxFolder('Test Obj Name',qot.id);
            CheckBoxFolder_Controller.isBoxFolderExits(qot.id);
            CheckBoxFolder_Controller.checkQuote(qot.id);             
            qot.Integration_Process_In_Progress__c =true;
            update qot;
            CheckBoxFolder_Controller.checkQuote(qot.Id); 
        }
        
        test.stopTest();
    }
    
    public static box__FRUP__c createBoxFolder(String strObjectName, Id objId){
        box__FRUP__c frup = new box__FRUP__c();
        frup.box__Object_Name__c = strObjectName;
        frup.box__Folder_ID__c = '12345';
        frup.box__Record_ID__c  = objId;
        insert frup;
        return frup;
    }
    
    /*
    public static Account createAgencyAccount(){
        Account acct = new Account();
        acct.Name = 'Test Agency Account';
        acct.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Agency').getRecordTypeId();
        acct.Brand__c = 'American Standard;DXV';
        acct.Account_Subtype__c = 'Sold to; Shipt to';
        insert acct;
        return acct;
    }
    
    public static Project__c createProject(){        
        
        Project__c prj = new Project__c();
        prj.Name = 'Test Project';
        prj.Project_Type__c = 'Ship';
        prj.City__c = 'Atlanta';
        prj.State__c = 'GA';
        prj.Postal_Code__c = '30301';
        prj.Country__c = 'US';
        prj.Stage__c = 'Open';
        
        prj.Project_Region__c = 'Southeast';
        
        insert prj;
        return prj;
    }
    public static Opportunity createProjectOpportunity(Id projectId){
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opporutnity';
        opp.StageName = 'Initiation';
        opp.CloseDate = Date.today().AddMonths(1);
        opp.Project__c = projectId;
        opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Projects').getRecordTypeId();
        //opp.FinalQuote__c.
        insert opp;
        return opp;
    }
    
    public static Quote createQuote( Opportunity oppt)
    {
        Quote qot = new Quote();
        qot.Name = 'Test Quote';
        qot.OpportunityId =oppt.id;
        qot.Status = 'Draft';
        qot.RecordTypeId = Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName().get('Standard_Quote').getRecordTypeId();
        qot.ExpirationDate = Date.today().AddMonths(1);
        //qot.Account__c = acctId;
        //Id stdPriceBookId = Test.getStandardPricebookId();
        //qot.Pricebook2Id = spbId;
        insert qot;
        return qot;
    }
    */
}