/************************
Author:         Azfer Pervaiz
Created Date:   05/July/2018 
Purpose:        This class is the Utility Test class which will be used for Test classes.

************************MODIFICATION HISTORY**************************************
Added on             Added By               Description
**********************************************************************************
05/July/2018           Azfer Pervaiz          Initial Development 
***********************************************************************************/
@isTest
public class UtilityTest {
  
    public static void CreateAgencyZipCodeAssignment(){
        List<Agency_Zip_Code_Assignment__c> ListAgencyZipCodeAssignment = new List<Agency_Zip_Code_Assignment__c>();
        Map<String,Account> MapAgencyAccount = CreateAccountList();
        
        ListAgencyZipCodeAssignment.add( new Agency_Zip_Code_Assignment__c(
            ASRep__c = MapAgencyAccount.get('ASRep').Id,
            DXVRep__c = MapAgencyAccount.get('DXVRep').Id,
            FiatRep__c = MapAgencyAccount.get('FiatRep').Id,
            GroheRep__c = MapAgencyAccount.get('GroheRep').Id,
            County__c = 'TestCounty',
            PrimaryCity__c = 'TestPrimaryCity',
            Region__c = 'Midwest',
            SecondaryCities__c = 'TestSecondaryCities',
            StateCode__c = 'IL',
            Type__c = 'UNIQUE',
            ZipCode__c = '220065' ));
        ListAgencyZipCodeAssignment.add( new Agency_Zip_Code_Assignment__c(
            ASRep__c = MapAgencyAccount.get('ASRep').Id,
            DXVRep__c = MapAgencyAccount.get('DXVRep').Id,
            FiatRep__c = MapAgencyAccount.get('FiatRep').Id,
            GroheRep__c = MapAgencyAccount.get('GroheRep').Id,
            County__c = 'TestCounty',
            PrimaryCity__c = 'TestPrimaryCity',
            Region__c = 'Midwest',
            SecondaryCities__c = 'TestSecondaryCities',
            StateCode__c = 'AK',
            Type__c = 'UNIQUE',
            ZipCode__c = '220067' ));

        ListAgencyZipCodeAssignment.add( new Agency_Zip_Code_Assignment__c(
            ASRep__c = MapAgencyAccount.get('ASRep').Id,
            DXVRep__c = MapAgencyAccount.get('DXVRep').Id,
            FiatRep__c = MapAgencyAccount.get('FiatRep').Id,
            GroheRep__c = MapAgencyAccount.get('GroheRep').Id,
            County__c = 'TestCounty',
            PrimaryCity__c = 'TestPrimaryCity',
            Region__c = 'Southeast',
            SecondaryCities__c = 'TestSecondaryCities',
            StateCode__c = 'AK',
            Type__c = 'UNIQUE',
            ZipCode__c = '30301' ));

        insert ListAgencyZipCodeAssignment;

    }
    
    public static void CreateProjectTeamSetup(){
        List<ProjectTeam__c> ListProjectTeamSetup = new List<ProjectTeam__c>();
        ListProjectTeamSetup.add( new ProjectTeam__c (
            AmountOver__c = 00.00,
            ParentAccount__c = null,
            ProjectType__c = null,
            Region__c = 'Southeast',
            Requestor__c = UserInfo.getUserId(),
            RequestorRole__c = 'Agency',
            RequestorType__c = 'Non Agency',
            TeamMember__c = UserInfo.getUserId(),
            TeamRole__c = 'Projects Director'
            ) );

        ListProjectTeamSetup.add( new ProjectTeam__c (
            AmountOver__c = 00.00,
            ParentAccount__c = null,
            ProjectType__c = null,
            Region__c = 'Southeast',
            RequestorType__c = 'Generic',
            TeamMember__c = UserInfo.getUserId(),
            TeamRole__c = 'Projects Director'
            ) );

        ListProjectTeamSetup.add( new ProjectTeam__c (
            AmountOver__c = 00.00,
            ParentAccount__c = null,
            ProjectType__c = null,
            Region__c = 'Southeast',
            Requestor__c = UserInfo.getUserId(),
            RequestorRole__c = 'Agency',
            RequestorType__c = 'Non Agency',
            TeamMember__c = UserInfo.getUserId(),
            TeamRole__c = 'VP of Channel Sales'
            ) );

        ListProjectTeamSetup.add( new ProjectTeam__c (
            AmountOver__c = 00.00,
            ParentAccount__c = null,
            ProjectType__c = null,
            Region__c = 'Southeast',
            RequestorType__c = 'Generic',
            TeamMember__c = UserInfo.getUserId(),
            TeamRole__c = 'VP of Channel Sales'
            ) );

        insert ListProjectTeamSetup;
    }

    public static void CreateProjectTeamApproverSetup(){
        List<ProjectTeamApprover__c> ListProjectTeamApproverSetup = new List<ProjectTeamApprover__c>();
        ListProjectTeamApproverSetup.add( new ProjectTeamApprover__c (
            X1stLevelApprover__c = UserInfo.getUserId(),
            X1stLevelApproverTeamRole__c ='Pricing Approver',
            X2ndLevelApprover__c = UserInfo.getUserId(),
            X2ndLevelApproverTeamRole__c ='Pricing Approver',
            X3rdLevelApprover__c = UserInfo.getUserId(),
            X3rdLevelApproverTeamRole__c ='Pricing Approver',
            Region__c = 'Southeast',
            Requestor__c = UserInfo.getUserId(),
            RequestorRole__c = 'Agency',
            RequestorType__c = 'Non Agency'
            ) );

        ListProjectTeamApproverSetup.add( new ProjectTeamApprover__c (
            X1stLevelApprover__c = UserInfo.getUserId(),
            X1stLevelApproverTeamRole__c ='Sales Support Specialist',
            X2ndLevelApprover__c = UserInfo.getUserId(),
            X2ndLevelApproverTeamRole__c ='Sales Support Specialist',
            X3rdLevelApprover__c = UserInfo.getUserId(),
            X3rdLevelApproverTeamRole__c ='Sales Support Specialist',
            Region__c = 'Southeast',
            Requestor__c = UserInfo.getUserId(),
            RequestorRole__c = 'Agency',
            RequestorType__c = 'Non Agency'
            ) );

        ListProjectTeamApproverSetup.add( new ProjectTeamApprover__c (
            X1stLevelApprover__c = UserInfo.getUserId(),
            X1stLevelApproverTeamRole__c ='Pricing Approver',
            X2ndLevelApprover__c = UserInfo.getUserId(),
            X2ndLevelApproverTeamRole__c ='Pricing Approver',
            X3rdLevelApprover__c = UserInfo.getUserId(),
            X3rdLevelApproverTeamRole__c ='Pricing Approver',
            Region__c = 'Southeast',
            RequestorType__c = 'Generic'
            ) );

        ListProjectTeamApproverSetup.add( new ProjectTeamApprover__c (
            X1stLevelApprover__c = UserInfo.getUserId(),
            X1stLevelApproverTeamRole__c ='Sales Support Specialist',
            X2ndLevelApprover__c = UserInfo.getUserId(),
            X2ndLevelApproverTeamRole__c ='Sales Support Specialist',
            X3rdLevelApprover__c = UserInfo.getUserId(),
            X3rdLevelApproverTeamRole__c ='Sales Support Specialist',
            Region__c = 'Southeast',
            RequestorType__c = 'Generic'
            ) );

        insert ListProjectTeamApproverSetup;
    }

    public static void CreateTeamAssignmentRule(){
        List<Team_Assignment_Rule__c> ListTeamAssignmentRule = new List<Team_Assignment_Rule__c>();
        
        ListTeamAssignmentRule.add(new Team_Assignment_Rule__c( 
            Account__c = CreateAccount('TestAccount',True).Id,
            Assignment_Type__c = 'Agency',
            RecordTypeId = Schema.SObjectType.Team_Assignment_Rule__c.getRecordTypeInfosByName().get('Account Team').getRecordTypeId(),
            Region__c = 'Midwest',
            Role__c = 'Regional Showroom Manager',
            SubChannel__c = 'Showroom',
            Team_Member__c = UserInfo.getUserId(),
            User__c = UserInfo.getUserId()
        ));
        ListTeamAssignmentRule.add(new Team_Assignment_Rule__c( 
            Assignment_Type__c = 'Influencer',
            RecordTypeId = Schema.SObjectType.Team_Assignment_Rule__c.getRecordTypeInfosByName().get('Account Team').getRecordTypeId(),
            Region__c = 'Midwest',
            Role__c = 'National Account Manager',
            SubChannel__c = 'Showroom',
            Team_Member__c = UserInfo.getUserId(),
            User__c = UserInfo.getUserId()
        ));
        ListTeamAssignmentRule.add(new Team_Assignment_Rule__c( 
            Account__c = CreateAccount('TestAccount',True).Id,
            Assignment_Type__c = 'Influencer',
            RecordTypeId = Schema.SObjectType.Team_Assignment_Rule__c.getRecordTypeInfosByName().get('Account Team').getRecordTypeId(),
            Region__c = 'Midwest',
            Role__c = 'Regional Showroom Manager',
            SubChannel__c = 'Showroom',
            Team_Member__c = UserInfo.getUserId(),
            User__c = UserInfo.getUserId()
        ));
        ListTeamAssignmentRule.add(new Team_Assignment_Rule__c( 
            Account__c = CreateAccount('TestAccount',True).Id,
            Assignment_Type__c = 'Dealer',
            RecordTypeId = Schema.SObjectType.Team_Assignment_Rule__c.getRecordTypeInfosByName().get('Account Team').getRecordTypeId(),
            Region__c = 'Midwest',
            Role__c = 'Regional Showroom Manager',
            SubChannel__c = 'Showroom',
            Team_Member__c = UserInfo.getUserId(),
            User__c = UserInfo.getUserId()
        ));
        ListTeamAssignmentRule.add(new Team_Assignment_Rule__c( 
            Account__c = CreateAccount('TestAccount',True).Id,
            Assignment_Type__c = 'Customer',
            RecordTypeId = Schema.SObjectType.Team_Assignment_Rule__c.getRecordTypeInfosByName().get('Account Team').getRecordTypeId(),
            Region__c = 'Midwest',
            Role__c = 'Regional Showroom Manager',
            SubChannel__c = 'Showroom',
            Team_Member__c = UserInfo.getUserId(),
            User__c = UserInfo.getUserId()
        ));

        //For Opportuntiy Team Assignment.
        ListTeamAssignmentRule.add(new Team_Assignment_Rule__c( 
            Assignment_Type__c = 'Showroom/Display',
            RecordTypeId = Schema.SObjectType.Team_Assignment_Rule__c.getRecordTypeInfosByName().get('Opportunity').getRecordTypeId(),
            Region__c = 'Midwest',
            Role__c = 'Regional Showroom Manager',
            Team_Member__c = UserInfo.getUserId(),
            User__c = UserInfo.getUserId()
        ));
        ListTeamAssignmentRule.add(new Team_Assignment_Rule__c( 
            Assignment_Type__c = 'Initiative',
            RecordTypeId = Schema.SObjectType.Team_Assignment_Rule__c.getRecordTypeInfosByName().get('Opportunity').getRecordTypeId(),
            Region__c = 'Midwest',
            Role__c = 'Regional Showroom Manager',
            Team_Member__c = UserInfo.getUserId(),
            User__c = UserInfo.getUserId()
        ));

        insert ListTeamAssignmentRule;
    }

    public static Map<String,Account> CreateAccountList(){
		Id PRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Agency').getRecordTypeId();
        Map<String,Account> MapToReturn = new Map<String,Account>();
        List<Account> ListAccount = new List<Account>{ 
            new Account( Name = 'ASRep', RecordTypeId = PRecordTypeId ), new Account( Name = 'DXVRep',RecordTypeId = PRecordTypeId ), 
            new Account( Name = 'FiatRep',RecordTypeId = PRecordTypeId ), new Account( Name = 'GroheRep',RecordTypeId = PRecordTypeId ) };
        insert ListAccount;
        for( Account AccountObj : ListAccount )
        {
            MapToReturn.put( AccountObj.Name,AccountObj );
        }
        return MapToReturn;
    }

    public static Account CreateAccount(String paramAccountName, Boolean paramIsnertAccount){

        Account AccountObjToReturn = new Account(Name = paramAccountName,
                                                 Account_SubType__c = 'Sold To; Ship To',
                                                 ShippingCity = 'NY',
                                                 ShippingStreet = '22 A',
                                                 ShippingState = 'IL',
                                                 ShippingPostalCode = '220065',
                                                 ShippingCountry = 'US');
        if( paramIsnertAccount ){
            insert AccountObjToReturn;
        }
        return AccountObjToReturn;
    } 

    public static Opportunity CreateOpportunity(Id paramAccountId){
        Project__c proj = UtilityTest.createProject();
        
        Opportunity OpportunityObj = new Opportunity(AccountId = paramAccountId);
        OpportunityObj.Name = 'Test Name :: '+paramAccountId;
        OpportunityObj.StageName = 'Closed Won';
        OpportunityObj.CloseDate = Date.today().AddMonths(1);
        OpportunityObj.Project__c = proj.Id;
        insert OpportunityObj;

        return OpportunityObj; 
    }
    
    public static Opportunity CreateDisplayOpportunity(Id paramAccountId){
        Project__c proj = UtilityTest.createProject();
        
        Opportunity OpportunityObj = new Opportunity(AccountId = paramAccountId);
        OpportunityObj.Name = 'Test Opportunity :: '+paramAccountId;
        OpportunityObj.StageName = 'Initiation';
        OpportunityObj.CloseDate = Date.today().AddMonths(1);
        OpportunityObj.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Display').getRecordTypeId();
        OpportunityObj.Project__c = proj.Id;

        insert OpportunityObj;

        return OpportunityObj; 
    }
    
    public static Opportunity CreateInitiativeOpportunity(Id paramAccountId){
        Project__c proj = UtilityTest.createProject();
        Opportunity OpportunityObj = new Opportunity(AccountId = paramAccountId);
        OpportunityObj.Name = 'Test Opportunity :: '+paramAccountId;
        OpportunityObj.StageName = 'Initiative Proposal';
        OpportunityObj.CloseDate = Date.today().AddMonths(1);
        OpportunityObj.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Initiative').getRecordTypeId();
        OpportunityObj.Project__c = proj.Id;
        insert OpportunityObj;

        return OpportunityObj; 
    }
    
    public static OpportunityTeamMember createOpportunityTeam(Id OppId){
        User usr = UtilityTest.createUser();
        
        OpportunityTeamMember otm = new OpportunityTeamMember();
        otm.OpportunityAccessLevel = 'Edit';
        otm.TeamMemberRole = 'General Manager';
        otm.OpportunityId = OppId;
        otm.UserId = usr.Id;
        
        insert otm;
        return otm;
    }
    
    public static User createUser(){
        Profile prof = [Select Id from profile where Name='System Administrator']; 
        
        String orgId=UserInfo.getOrganizationId(); 
        
        String dateString=String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','') ;
        
        Integer RandomId=Integer.valueOf(Math.rint(Math.random()*1000000)); 
        
        String uniqueName=orgId+dateString+RandomId; 
        
        User usr = new User();
        usr.firstname = 'ABC';
        usr.lastName = 'XYZ';
        usr.email = uniqueName + '@test' + orgId + '.org'; 
        usr.Username = uniqueName + '@test' + orgId + '.org';
        usr.EmailEncodingKey = 'ISO-8859-1';
        usr.Alias = uniqueName.substring(18, 23);
        usr.TimeZoneSidKey = 'America/Los_Angeles';
        usr.LocaleSidKey = 'en_US';
        usr.LanguageLocaleKey = 'en_US';
        usr.ProfileId = prof.Id;
        usr.Region__c = 'USA';
        usr.Call_Center__c = 'Tech';
        usr.User_Project_Team_Role__c='Sales Rep';
                
        insert usr;        
        return usr;
    }
    
    public static Account createCustomerAccount(){
        Account acct = new Account();
        acct.Name = 'Test Customer Account';
        acct.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();
        acct.Brand__c = 'American Standard;DXV;Grohe;FIAT';
        acct.Account_SubType__c = 'Sold To; Ship To';
        acct.ShippingCity = 'NY';
        acct.ShippingStreet = '22 A';
        acct.ShippingState = 'IL';
        acct.ShippingPostalCode = '220065';
        acct.ShippingCountry = 'US';
        insert acct;
        return acct;
    }
    
    public static Account createAgencyAccount(){
        Account acct = new Account();
        acct.Name = 'Test Agency Account';
        acct.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Agency').getRecordTypeId();
        acct.Brand__c = 'American Standard;DXV;Grohe;FIAT';
        acct.Account_Subtype__c = 'Sold to; Shipt to';
        insert acct;
        return acct;
    }
    
    public static AccountTeamMember createAccountTeam(Id accId){
        User usr = UtilityTest.createUser();
        
        AccountTeamMember atm = new AccountTeamMember();
        atm.AccountAccessLevel = 'Edit';
        atm.TeamMemberRole = 'Account Manager';
        atm.AccountId = accId;
        atm.UserId = usr.Id;
        
        insert atm;
        return atm;
    }
    
    public static Account createDealerAccount(){
        Account acct = new Account();
        acct.Name = 'Test Customer Account';
        acct.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Dealer').getRecordTypeId();
        acct.Brand__c = 'American Standard;DXV;Grohe;FIAT';
        acct.Account_Subtype__c = 'Sold to; Shipt to';
        insert acct;
        return acct;
    }
    
    public static Contact CreateContact(Id Accountid, string RecordTypeName){
        Contact con = new Contact();
        con.firstname = Accountid;
        con.LastName = 'Contact';
        con.AccountId = Accountid;
        if(RecordTypeName =='Consumer')
        {
            con.Asset_Name__c='Test Asset';
            con.Asset_Quantity__c=2.0;
            con.Purchase_Date__c = System.Date.today();
            con.Install_Date__c= System.Date.today();
        }
        con.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(RecordTypeName).getRecordTypeId();
        con.Phone = Accountid;
        con.OtherCity = 'Los Angeles';
        con.OtherCountry  = 'US';
        con.OtherPostalCode  = Accountid;
        con.OtherState  = 'CA';
        con.OtherStreet  = Accountid;
        con.Email = Accountid+'@email.com';       
        insert con;
        return con;
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

    public static Project__c createProject2(){        
        
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
    
        public static Contact CreateConsumerContact(Id Accountid, string RecordTypeName){
            Integer RandomId = Integer.valueOf(Math.rint(Math.random()*1000000));
            
        Contact con = new Contact();
        con.LastName = 'Contact';
        con.AccountId = Accountid;
        con.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(RecordTypeName).getRecordTypeId();
        con.Email='test@mail.com';
        con.OtherCity='Test City';
        con.OtherState='Test State';
        con.OtherCountry='Test Country';
        con.OtherPostalCode='Test PostalCode';
        con.OtherStreet='Test StreetAddress';
		con.BP_External_Id__c = 'con-' + RandomId;

        Database.insert(con,false);
        return con;
    }
    
    
    public static Project__c createProjectWithApprovers(){
      
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
        System.debug('KA:: Project Owner Utility Test: '+UserInfo.getUserId());
        return prj;
    }    
    
	public static Project_Team__c createProjectTeam(Id prjId){
        User usr = UtilityTest.createUser();
        
        Project_Team__c pt = new Project_Team__c();
        //pt.IsApprover__c = ;
        //pt.IsProjectTeam__c = ;
        pt.Project__c = prjId;
        pt.Role__c = 'Sales Support Specialist';
        pt.isQuotePDFEmail__c = true;        
        pt.User__c = usr.Id;
        pt.ProjectId_UserId__c=prjId+'-'+UserInfo.getUserId();
        System.debug('KA::ProjectId_UserId__c Utility Test '+pt.ProjectId_UserId__c );
        insert pt;
        return pt;
    }
    
    public static Wholesalers__c createWholesaler(Id acctId, Id prjId){
        Wholesalers__c ws = new Wholesalers__c();
        ws.Project__c = prjId;
        ws.Wholesaler__c = acctId;
        
        insert ws;
        return ws;
    }
    
    
    
    
    public static Opportunity createProjectOpportunity(Id projectId){
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opporutnity';
        opp.StageName = 'Initiation';
        opp.CloseDate = Date.today().AddMonths(1);
        opp.Project__c = projectId;
        opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Projects').getRecordTypeId();
        
        insert opp;
        return opp;
    }
    
    public static Id getStandardPBId(){
        return Test.getStandardPricebookId();
    }

    public static Pricebook2 CreatePriceBook(String paramPriceBook2Name){
        Pricebook2 Pricebook2Obj = new Pricebook2();
        Pricebook2Obj.Name = paramPriceBook2Name;
        Pricebook2Obj.IsActive = true;
        insert Pricebook2Obj;
        return Pricebook2Obj;
    }
    
    public static Quote createStandardQuote(Id spbId, Account acct, Opportunity opp){
        User usr = UtilityTest.createUser();
        Quote qot = new Quote();
        System.runAs(usr)
        {
            qot.Name = 'Test Quote';
            qot.OpportunityId = opp.Id;
            qot.Status = 'Draft';
            qot.RecordTypeId = Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName().get('Standard_Quote').getRecordTypeId();
            qot.ExpirationDate = Date.today().AddMonths(1);
            qot.Account__c = acct.Id;
            Id stdPriceBookId = Test.getStandardPricebookId();
            qot.Pricebook2Id = spbId;
            
            insert qot;
        }
        return qot;        
    }

    public static Quote createStandardQuote(Id spbId, Id acctId, Opportunity opp){
        User usr = UtilityTest.createUser();
        Quote qot = new Quote();
        System.runAs(usr)
        {
            qot.Name = 'Test Quote';
            qot.OpportunityId = opp.Id;
            qot.Status = 'Draft';
            qot.RecordTypeId = Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName().get('Standard_Quote').getRecordTypeId();
            qot.ExpirationDate = Date.today().AddMonths(1);
            qot.Account__c = acctId;
            Id stdPriceBookId = Test.getStandardPricebookId();
            qot.Pricebook2Id = spbId;
            
            insert qot;
        }
        return qot;        
    }

    public static Quote createInfluencerQuote(Id spbId, Id acctId, Opportunity opp){
        Quote qot = new Quote();
        qot.Name = 'Test Quote';
        qot.OpportunityId = opp.Id;
        qot.Status = 'Draft';
        qot.RecordTypeId = Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName().get('Influencer_Quote').getRecordTypeId();
        qot.ExpirationDate = Date.today().AddMonths(1);
        qot.Account__c = acctId;
        //Id stdPriceBookId = Test.getStandardPricebookId();
        qot.Pricebook2Id = spbId;
        
        insert qot;
        return qot;        
    }
    
	public static Product2 createAmericanStandardProduct(Id spbId){
        Integer RandomId=Integer.valueOf(Math.rint(Math.random()*1000000));
        Product2 prod = new Product2(Name='DXV Test Faucet', IsActive=true, Brand__c='American Standard',SAP_Product_Code__c = 'M970340-'+RandomId, Discontinue_date__c=Date.today()+1);
        insert prod;

 		return prod;      
    }
    
	public static Product2 createGroheProduct(){
        Integer RandomId=Integer.valueOf(Math.rint(Math.random()*1000000));
        Product2 prod1 = new Product2(Name='DXV Test Faucet', Brand__c='Grohe',SAP_Product_Code__c = 'M970343-'+RandomId, Discontinue_date__c=Date.today()+1,IsActive=False);
        insert prod1;

 		return prod1;      
    }    
    
    public static PricebookEntry createPricebookEntry(Id spbId, Product2 prod){
        //Id spbId = Test.getStandardPricebookId();
        
        PricebookEntry pbe = new PricebookEntry (Product2Id=prod.id, Pricebook2ID=spbId, UnitPrice=50, isActive=true);
        insert pbe;  
        
        return pbe;
    }
    
    
    public static Product2 createProduct(Boolean insertParam){
      
        Product2 pr = new Product2(
                Name='Test',
                SAP_Product_Code__c='40664001',
                SAP_Product_Hierarchy__c='1234'

           );
   
         return pr;        
        
    }
    
        public static QuoteLineItem createQLI(Id spbId, Quote qot, Product2 prod){
        Id pbeID = [select Id from PricebookEntry where Product2Id = :prod.Id and CurrencyISOCode = 'USD' limit 1].Id;
        
        Integer RandomId=Integer.valueOf(Math.rint(Math.random()*1000000));
        
    	QuoteLineItem qli = new QuoteLineItem();
        qli.QuoteId = qot.Id;
        qli.UnitPrice = 100;
        qli.Requested_Price__c = 100; 
        qli.Approved_Price__c = 90;
        qli.Quantity = 5;
        qli.Product2Id = prod.Id;
        qli.PricebookEntryId = pbeID;
        qli.Everyday_Price__c = 100;
        qli.Quote_Line_Item_ID__c = String.valueOf(RandomId);
        qli.Formatted_First_Order_Date__c = '12/2050';
		insert qli;        
        return qli;
    }
    
    // Add by Hanif to stop duplication line number add a parameter of line number
    public static QuoteLineItem createQLI(Id spbId, Quote qot, Product2 prod, integer LineNumber){
        Id pbeID = [select Id from PricebookEntry where Product2Id = :prod.Id and CurrencyISOCode = 'USD' limit 1].Id;
        
    	QuoteLineItem qli = new QuoteLineItem();
        qli.QuoteId = qot.Id;
        qli.UnitPrice = 100;
        qli.Requested_Price__c = 100; 
        qli.Approved_Price__c = 90;
        qli.Quantity = 5;
        qli.Product2Id = prod.Id;
        qli.PricebookEntryId = pbeID;
        qli.Everyday_Price__c = 100;
       // qli.Quote_Line_Item_ID__c = String.valueOf(RandomId);
       qli.Line_Number__c = LineNumber;
		insert qli;        
        return qli;
    }
    @Future(callout=true)
    public static void createBoxFolder(String strObjectName, Id objId){
        box__FRUP__c frup = new box__FRUP__c();
        frup.box__Object_Name__c = strObjectName;
        frup.box__Folder_ID__c = '12345';
        frup.box__Record_ID__c  = objId;
        
        insert frup;
       
    }
    
    public static Lead createLead(){
        Lead lea = new Lead();
        lea.FirstName = 'Test';
        lea.LastName = 'Lead';
        lea.City = 'Chicago';
        lea.PostalCode = '08854';
        lea.Company = 'Test Company';
        lea.Country = 'USA';
        lea.Email = 'testlead@test.com';
        lea.NumberOfEmployees = 124;
		lea.Leadsource='Web';
		lea.Rating = 'Warm';        
        insert lea;
		return lea;        
    }
    
    public static Asset CreateAsset(){
        Product2 prod = UtilityTest.createGroheProduct();
        Account acc = UtilityTest.createCustomerAccount();
        
        Asset ast = new Asset();
        ast.Name = 'Test Asset';
        ast.Quantity = 1;
        ast.Sub_Channels__c = 'Project';
        ast.AccountId = acc.Id;
        ast.Product2Id = prod.Id;
          
        ast.PurchaseDate = System.Date.today();
        ast.InstallDate =System.Date.today();
        insert ast;
        return ast;
    }
    
    public static Task CreateTask(Id ObjectId){
     	User usr = UtilityTest.createUser();
        Schema.SObjectType ObjectType = ObjectId.getSobjectType();
        
        Task tsk = new Task();
        if(ObjectId.getSobjectType() == Contact.sObjectType || ObjectId.getSobjectType() == Lead.sObjectType)
        	tsk.WhoId = ObjectId;
        else
            tsk.WhatId = ObjectId;
        tsk.Status = 'Open';
        tsk.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Display').getRecordTypeId();
        tsk.ActivityDate = System.today().AddMonths(1);
        tsk.Subject = 'Test Task';
        tsk.OwnerId = usr.Id;
        
        insert tsk;
        return tsk;
    }
    
    public static Event CreateEvent(Id ObjectId){
     	User usr = UtilityTest.createUser();
        Schema.SObjectType ObjectType = ObjectId.getSobjectType();
        
        Event evt = new Event();
        if(ObjectId.getSobjectType() == Contact.sObjectType || ObjectId.getSobjectType() == Lead.sObjectType)
        	evt.WhoId = ObjectId;
        else
            evt.WhatId = ObjectId;
        evt.Type = 'Call';
        evt.DurationInMinutes = 60;
        //evt.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Display').getRecordTypeId();
        evt.ActivityDateTime = System.today().AddMonths(1);
        evt.Subject = 'Test Task';
        evt.OwnerId = usr.Id;
        
        insert evt;
        return evt;
    }
    
    public static Agency__c CreateAgency(){
        Account acc = UtilityTest.CreateAccount('Test Account1', true);
        Account AgencyAcc =  UtilityTest.createAgencyAccount();
        //Account AgencyAcc2 =  UtilityTest.createAgencyAccount();
        Contact con = UtilityTest.CreateContact(AgencyAcc.Id, 'Agency');
        Contact ShowroomChampion = con;//UtilityTest.CreateContact(AgencyAcc2.Id, 'Agency');
        
        Agency__c agn = new Agency__c();
        agn.Account__c = acc.Id;
        agn.Agency_Account__c = AgencyAcc.Id;
        agn.Contact__c = con.Id;
        agn.Showroom_Champion__c = ShowroomChampion.Id;
        
        insert agn;
        return agn;
    }
    
    public static Order CreateOrder(Id AccountId, Id QuoteId,Id SpbId){   
        Order ord = new Order();
        ord.AccountId = AccountId;
        ord.Status = 'Open';
        ord.EffectiveDate = Date.today();
        ord.QuoteId = QuoteId;
        ord.Pricebook2Id = SpbId;
        ord.RecordTypeId = Schema.SObjectType.Order.getRecordTypeInfosByName().get('Orders').getRecordTypeId();
        insert ord;
        return ord;
        
    }
    public static Order CreateOrder(Id ParamCaseId, Id ParamAccountId, Id paramRecordType,Boolean isInsert){   
        Order ord = new Order();
        ord.AccountId = ParamAccountId;
        ord.Status = 'Open';
        ord.EffectiveDate = Date.today();
        ord.Case__c = ParamCaseId;
        ord.RecordTypeId = paramRecordType;
        ord.Pricebook2Id = Test.getStandardPricebookId();
        if (isInsert) 
        {
            insert ord;
        }
        
        return ord;
        
    }
    public static OrderItem CreateOrderItem(Id QuoteId,Id QuoteLineItemId,Id ProductId,Id OrderId){
        Id pbeID = [select Id from PricebookEntry where Product2Id = :ProductId and CurrencyISOCode = 'USD' limit 1].Id;
        
        OrderItem orditem = new OrderItem();
        orditem.UnitPrice = 200;
        orditem.Open_Quantity__c = 2;
        orditem.Shipped_Quantities__c = 2;
        orditem.Quote__c = QuoteId;
        orditem.Quote_Line_Item__c = QuoteLineItemId;
        orditem.Line_Status__c = 'Open';
        orditem.Product2Id = ProductId;
        orditem.PricebookEntryId = pbeID;
        orditem.OrderId = OrderId;
        orditem.Quantity = 2;
        
        insert orditem;
        return orditem;
    }
    
    public static Campaign createCampaign(String strRecordType){
        Campaign cam = new Campaign();
        cam.Reason_Code__c = 'RC111';
        cam.Sales_Deal__c = 'SD111';
        cam.EndDate = Date.today().AddMonths(1);
        cam.Name = 'Display Campaign';
        cam.RecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get(strRecordType).getRecordTypeId();
        
        insert cam;
        return cam;
    }
    
    public static Campaign_Products__c createCampaignProduct(Id campaignId, Id productId){
		Campaign_Products__c  cp = new Campaign_Products__c();
        cp.Campaign__c = campaignId;
        cp.Campaign_Price__c = 100;
        cp.Line_Number__c = 111;
        cp.Product__c = productId;
        cp.Quantity__c = 1;
        cp.Sales_Price_Depreciated__c = 10;
        cp.List_Price__c = 90;   
    
        insert cp;
        return cp;
    }
    
    public static CampaignMember createCampaignMember(Id campaignId, Id accountId, Id contactId){
        CampaignMember cm = new CampaignMember();
        cm.Account__c = accountId;
        cm.Status = 'Sent';
        cm.CampaignId = campaignId;
        cm.ContactId = contactId;
        cm.CurrencyIsoCode = 'USD';
        
        insert cm;
        return cm;
    }
    
   
    public static EmailMessage createEmailMessage(string ParamParentId,String ParamSubject,String ParamBody,String ParamToAddress,Boolean ParamInsert)
    {
        EmailMessage em  = new EmailMessage(ParentId=ParamParentId,
                                            Subject=ParamSubject,
                                            HtmlBody=ParamBody,
                                            Status='0',
                                            ToAddress=ParamToAddress
                                            
        
        
        );
        
        if(ParamInsert)
        {
            insert em; 
        }
        
        return em;
        
    }
    
    public static Case CreateCase(String ParamAccountId, String ParamRecordTypeId, Boolean paramIsnert){

        Case aCase = new Case(AccountId = ParamAccountId,
                              RecordTypeId = ParamRecordTypeId);
        if( paramIsnert ){
            insert aCase;
        }
        return aCase;
    } 
    
    public static Scar__c createScar(Boolean ParamInsert,id SupplierName, id SupplierContact)
    {
        Scar__c scr = new Scar__c(
            Supplier_Name__c=SupplierName,
            Supplier_Contact__c=SupplierContact
        );
        if(ParamInsert)
        {
            insert scr;
        }
        return scr;
    }
    
    public static SCAR_Team__c CreateScarTeam(Id ScarId)
    {   
        SCAR_Team__c st = new SCAR_Team__c();
        st.Contact_Role__c = 'Team Member';
        st.Email__c = 'team.member@gettectonic.com';
        st.SCAR_Contact_Name__c = 'Team Contact';
        st.SCAR_Form__c = ScarId;
        st.Title__c = 'Developer';
        
        insert st;
        return st;
        
    }
    
    public static List<Case> CreateMultipleCase(String ParamAccountId,String ParamRecordTypeId,Integer ParamNoRecord ,Boolean paramIsnert){
        List<case> csList = new List<Case>();
        for(integer i = 0;i<ParamNoRecord;i++){
            //Created Contact Having First and Last Name                 
            Case cs = CreateCase(ParamAccountId,
                                 ParamRecordTypeId,
                                 False);
            
            cs.Country__c='Canada';
            cs.SuppliedName='Test SS';
            cs.Origin='web';
            cs.SuppliedEmail='test@mail.com';
            cs.Reason='New problem';
            cs.Product_Category__c='Bathroom Furniture';
            cs.Model_SKU__c='40664001';
            cs.Product_Purchase_Date__c=Date.today();
            cs.Street_Address__c='Test Addresses';
            cs.Street_Address2__c='Test Address2';
            cs.City__c='Test';
            cs.State__c='Quebec';
            cs.Postal_Code__c='122';
            cs.Product_Type__c = 'Fittings';
            cs.Product_Sub_Type__c = 'WHL';
            cs.Issue_Type__c = 'Damaged';
            cs.Region__c='USA';
            cs.Team__c='Customer Care';
            cs.Sub_Team__c='Luxury Customer Care';          
            csList.add(cs);
        }
        if( paramIsnert ){
            insert csList;
        }
        return csList;
    }
     
    
    public static Field_Service_Ticket__c createFieldServiceTicket(id ParamfstAgentId,id ParamRecordTypeId,id ParamCaseId,Boolean ParamInsert)
    {
        Field_Service_Ticket__c fst = new Field_Service_Ticket__c();
        fst.Case_ID__c=ParamCaseId;
        fst.Field_Service_Agent__c=ParamfstAgentId;
        fst.RecordTypeId=ParamRecordTypeId;
        
       if(ParamInsert)
       {
           insert fst;
       }
        
        
        return fst;
    }
    
    
    public static Check_Request__c cr(Boolean ParamInsert)
    {
        Check_Request__c cr = new Check_Request__c();
        cr.Check_Number__c='44';
        cr.Approved__c=false;
        cr.Check_Issue_Date__c=Date.today();
        
        if(ParamInsert)
        {
            insert cr;
        }
        return cr;
    }
    
    public static ODMS_Team_Mapping__c createODMSRecord()
    {
        ODMS_Team_Mapping__c odms = new ODMS_Team_Mapping__c();
        odms.Region__c='USA';
        odms.Team__c='Customer Care';
        odms.Sub_Team__c='Luxury Customer Care';
        odms.Email_Addresses__c='test@mail.com;test2@mail.com';
        insert odms;
        return odms;
    }
    Public static  List<Integration_Staging__c> createContactusIntStg ()
    {
        List<Integration_Staging__c> ListofIntgrationStg = new List <Integration_Staging__c>();
        
        for(integer i=0;i<=200;i++)
        {
        
        Integration_Staging__c IntegrationStg = new Integration_Staging__c();
        IntegrationStg.Name='TestIntegrationStg';
        IntegrationStg.Record_Type__c='Contact Us';
        IntegrationStg.Field_17__c='Testfield';
        IntegrationStg.Field_2__c='Test Field 2';
        IntegrationStg.Field_24__c='Test field 24';
        IntegrationStg.Field_1__c='Suggestions/General Inquiries';
        IntegrationStg.Field_5__c='How to view Shipping Status';
        
        ListofIntgrationStg.add(IntegrationStg);
         
        }
      
     return ListofIntgrationStg;
    }
     Public static  List<Integration_Staging__c> createWarrantyIntStg ()
    {
        List<Integration_Staging__c> ListofIntgrationStg = new List <Integration_Staging__c>();
        
        for(integer i=0;i<=200;i++)
        {
        
          Integration_Staging__c IntegrationStg = new Integration_Staging__c();
          IntegrationStg.Name='TestIntegrationStg';
          IntegrationStg.Record_Type__c='Warranty Registration';
          IntegrationStg.Field_17__c='Testfield';
          IntegrationStg.Field_2__c='Test Field 2';
          IntegrationStg.Field_24__c='Test field 24';
          IntegrationStg.Field_47__c='1234';
          IntegrationStg.Field_42__c='Test field 42';
          IntegrationStg.Field_26__c='Test field 26';
        
          ListofIntgrationStg.add(IntegrationStg);
         
        }
      
     return ListofIntgrationStg;
    }
}