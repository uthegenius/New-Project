@IsTest
public class ConfirmationModalCtrl_Test {
    
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
            Case aCase = UtilityTest.CreateMultipleCase( acc1.Id, 
                                                    Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Defect_Return').getRecordTypeId(),
                                                    1,
                                                    True)[0];
            test.stopTest();
        }
    }
    
    @isTest static void testDSS(){
        test.startTest();
        Case aCase = [select Id from Case limit 1];         
        RequestStatus Status = new RequestStatus();
        Status = ConfirmationModalCtrl.callAction(aCase.Id,'DSS');
        test.stopTest();
    }
    
    @isTest static void testOrder(){
        test.startTest();
        Order aOrder = [select Id from Order limit 1];         
            RequestStatus Status = new RequestStatus();
            Status = ConfirmationModalCtrl.callAction(aOrder.Id,'SSS');
            Status = ConfirmationModalCtrl.callAction(aOrder.Id,'OSS');
            Status = ConfirmationModalCtrl.callAction(aOrder.Id,'GSD');
        test.stopTest();
    }
    @isTest static void testQuote(){
        
        Quote quote1 = [select Id from Quote limit 1];         
            RequestStatus Status = new RequestStatus();            
        	test.startTest();
            Status = ConfirmationModalCtrl.callAction(quote1.Id,'PR');
            Status = ConfirmationModalCtrl.callAction(quote1.Id,'SA');
            Status = ConfirmationModalCtrl.callAction(quote1.Id,'STS');
  			test.stopTest();
        
    }
    
    @isTest static void testQuote2(){
        
        Quote quote1 = [select Id from Quote limit 1];         
        test.startTest();    
        RequestStatus Status = new RequestStatus();            
            Status = ConfirmationModalCtrl.callAction(quote1.Id,'RPR');
            Status = ConfirmationModalCtrl.callAction(quote1.Id,'FQ');
        	
            
  			test.stopTest();
        
    }    
     
}