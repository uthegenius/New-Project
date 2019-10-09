@isTest
public class ProjectTrgTest 
{
    @isTest static void testCreateProjWithApprovers()
    {
        
        Agency__c agn1 = UtilityTest.CreateAgency();
        UtilityTest.CreateAgencyZipCodeAssignment();
        Account acct = UtilityTest.createCustomerAccount();
        Project__c prj = UtilityTest.createProjectWithApprovers();
        System.debug('KA:: prj owner Test Class'+ prj.id+'-'+prj.OwnerId);
        Project_Team__c pt = UtilityTest.createProjectTeam(prj.Id);
        UtilityTest.CreateProjectTeamSetup();
        UtilityTest.CreateProjectTeamApproverSetup();
        Wholesalers__c ws = UtilityTest.createWholesaler(acct.Id, prj.Id);
        Test.startTest();
        Opportunity opp = UtilityTest.createProjectOpportunity(prj.Id);

        Id spbId = UtilityTest.getStandardPBId();
        Product2 prod = UtilityTest.createAmericanStandardProduct(spbId);
        Quote qot = UtilityTest.createStandardQuote(spbId, acct, opp);
        QuoteLineItem qli = UtilityTest.createQLI(spbId, qot,prod);
        Test.stopTest();
    }
    
    @isTest static void testCreateProjWith2ndApprovers()
    {
        Test.startTest();
        Account acct = UtilityTest.createCustomerAccount();

        User approver2 = UtilityTest.createUser();
       
        Project__c prj = new Project__c();
        prj.Name = 'Test Project';
        prj.Project_Type__c = 'Ship';
        prj.City__c = 'Atlanta';
        prj.State__c = 'GA';
        prj.Postal_Code__c = '30301';
        prj.Country__c = 'US';
        prj.Stage__c = 'Open';
        prj.Project_Region__c = 'Southeast';
        prj.second_Level_Approver__c = approver2.Id;
       
        insert prj;        
        UtilityTest.CreateProjectTeamSetup();
        UtilityTest.CreateProjectTeamApproverSetup();
        Project_Team__c pt = UtilityTest.createProjectTeam(prj.Id);
        Wholesalers__c ws = UtilityTest.createWholesaler(acct.Id, prj.Id);     
        Opportunity opp = UtilityTest.createProjectOpportunity(prj.Id);

        Id spbId = UtilityTest.getStandardPBId();
        Product2 prod = UtilityTest.createAmericanStandardProduct(spbId);
        Quote qot = UtilityTest.createStandardQuote(spbId, acct, opp);
        QuoteLineItem qli = UtilityTest.createQLI(spbId, qot,prod);
        Test.stopTest();
    }  
    
    @isTest static void testCreateProjWith3rdApprovers()
    {
        Test.startTest();
        Account acct = UtilityTest.createCustomerAccount();
        
        User approver3 = UtilityTest.createUser();
       
        Project__c prj = new Project__c();
        prj.Name = 'Test Project';
        prj.Project_Type__c = 'Ship';
        prj.City__c = 'Atlanta';
        prj.State__c = 'GA';
        prj.Postal_Code__c = '30301';
        prj.Country__c = 'US';
        prj.Stage__c = 'Open';
        prj.Project_Region__c = 'Southeast';
        prj.Third_Level_Approver__c = approver3.Id;
       
        insert prj;        
        
        Project_Team__c pt = UtilityTest.createProjectTeam(prj.Id);
        UtilityTest.CreateProjectTeamSetup();
        UtilityTest.CreateProjectTeamApproverSetup();
        Wholesalers__c ws = UtilityTest.createWholesaler(acct.Id, prj.Id);
        Opportunity opp = UtilityTest.createProjectOpportunity(prj.Id);

        Id spbId = UtilityTest.getStandardPBId();
        Product2 prod = UtilityTest.createAmericanStandardProduct(spbId);
        Quote qot = UtilityTest.createStandardQuote(spbId, acct, opp);
        QuoteLineItem qli = UtilityTest.createQLI(spbId, qot,prod);
        Test.stopTest();
    }    
    
    @isTest public static void testUpdateApprover()
    {
        Test.startTest();
        Account acct = UtilityTest.createCustomerAccount();
        Project__c prj = UtilityTest.createProject();

        Project_Team__c pt = UtilityTest.createProjectTeam(prj.Id);
        Wholesalers__c ws = UtilityTest.createWholesaler(acct.Id, prj.Id);
        Opportunity opp = UtilityTest.createProjectOpportunity(prj.Id);

        Id spbId = UtilityTest.getStandardPBId();
        Product2 prod = UtilityTest.createAmericanStandardProduct(spbId);
        //Quote qot = UtilityTest.createStandardQuote(spbId, acct, opp);
        //QuoteLineItem qli = UtilityTest.createQLI(spbId, qot,prod);   
        
        User approver1 = UtilityTest.createUser();
        prj.First_Level_Approver__c = approver1.Id;        
        
        User approver2 = UtilityTest.createUser();
        prj.Second_Level_Approver__c = approver2.Id;
        
        User approver3 = UtilityTest.createUser();
        prj.Third_Level_Approver__c = approver3.Id;        
		User owner1 = UtilityTest.createUser(); 
        prj.OwnerId=owner1.id;
        update prj;
        
        User owner2 = UtilityTest.createUser(); 
        prj.OwnerId=owner2.id;
        update prj;
         
        prj.OwnerId=owner1.id;
        update prj;
         
        //UtilityTest.CreateProjectTeamSetup();
        //UtilityTest.CreateProjectTeamApproverSetup();
        Test.stopTest();
    }


    @IsTest public static void ProjectTrgHandler_TestInsert(){
        Test.startTest();
        UtilityTest.CreateAgencyZipCodeAssignment();
        UtilityTest.CreateProjectTeamSetup();
        UtilityTest.CreateProjectTeamApproverSetup();
        
        
        Project__c ProjectObj = UtilityTest.createProject2();
        
        Test.stopTest();
    }

    @IsTest public static void ProjectTrgHandler_Testupdate(){
        Test.startTest();
        UtilityTest.CreateAgencyZipCodeAssignment();
        UtilityTest.CreateProjectTeamSetup();
        UtilityTest.CreateProjectTeamApproverSetup();
        Project__c ProjectObj = UtilityTest.createProject2();
        
        ProjectObj.Postal_Code__c = null;
        //User us =UtilityTest.createUser();
       // ProjectObj.OwnerId=us.id;
        update ProjectObj;
        
        Test.stopTest();
    }

    @IsTest public static void ProjectTrgHandler_Testupdate2(){
        Test.startTest();
        UtilityTest.CreateAgencyZipCodeAssignment();
        UtilityTest.CreateProjectTeamSetup();
        UtilityTest.CreateProjectTeamApproverSetup();
        Project__c ProjectObj = UtilityTest.createProject2();        
        ProjectObj.Postal_Code__c = '220065';
        ProjectObj.ReassignProjectTeam__c = true;
        ProjectObj.Total_Project_Value__c = 00.00;
        update ProjectObj;        
        Test.stopTest();
    }
}