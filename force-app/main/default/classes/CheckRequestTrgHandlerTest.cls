@isTest
public class CheckRequestTrgHandlerTest {
    
    
    @TestSetup static void createTestSetupData()
    {          
        CheckRequestTrgHandler CSTR = new CheckRequestTrgHandler();
        //insert new CheckRequestPDFRecipient__c(Recipient_Email__c = 'test@mail.com');
        string caseId;
        Account ac = UtilityTest.CreateAccount('Test Account', true);         
        List<Check_Request__c> testList = new List<Check_Request__c>();
        Contact cont = new Contact(FirstName='Test First Name',
                                   LastName='Test Last Name',
                                   Email='test@mail.com',
                                   RecordTypeId=Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Consumer').getRecordTypeId(),
                                   Phone='460157155551',
                                   OtherCity='Test City',
                                   OtherState='Test State',
                                   OtherCountry='Test Country',
                                   OtherPostalCode='Test Postal',
                                   OtherStreet='Test Street',
                                   AccountId=ac.id
                                  );
        
        
        insert cont;
        Case cs;
        if(cont!=null)
        {
            cs = new Case(
                Type='Installation',
                status='Email',
                ContactId=cont.id,
                RecordTypeId=Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Technical_Support').getRecordTypeId()
            );
        }
        
        insert cs;
        caseId = cs.Id+'';
        List<Check_Request__c> csTrg = new List<Check_Request__c>();
        
        Check_Request__c cc; 
        
        for(integer i =0;i<5;i++)   
        {
            cc = new Check_Request__c
                (
                    Case_ID__c =cs.id,
                    Amount__c=500,
                    Name_on_Check__c='Test',
                    Approved__c=false,
                    Date__c = Date.today()
                );
            csTrg.add(cc); 
        }
        if(csTrg.Size() > 0)
        {  
                        
            
            insert csTrg;
            
        }
        
        test.startTest();
        String authResponse2 = BoxTestJsonResponseFactory.AUTH_USER_TOKEN;
        Test.setMock(HttpCalloutMock.class, new BoxTestMockCallout(authResponse2, 'OK', 200)); 
       // List<Check_Request__c> csTrg = [select Approved__c from Check_Request__c limit 100];
        
        for(Check_Request__c cr: csTrg)
        {
           UtilityTest.createBoxFolder('Check_Request__c', cr.Id);
           
        }        
        test.stopTest();  
      
        
         CheckRequestTrgHandler.CreateAndSendPDF('Payment_Us', csTrg[0].id, 'Test CR', '1234', caseId, 'test@mail.com', 'a021k000002Xkm0AAC');
        //CheckRequestTrgHandler.CreateAndSendPDF('Payment_Us', csTrg[0].id, 'Test CR', '1234', CaseId, 'test@mail.com', 'a021k000002Xkm0AAC');
		 //CheckRequestTrgHandler.CreateAndSendPDF('Reimbursement_CA', csTrg[0].id, 'Test CR', '1234', caseId, 'test@mail.com', 'a021k000002Xkm0AAC');  
        
        
        
    }
    
    
    public static TestMethod void test1()
    {   
        test.startTest();
        String authResponse2 = BoxTestJsonResponseFactory.AUTH_USER_TOKEN;
        Test.setMock(HttpCalloutMock.class, new BoxTestMockCallout(authResponse2, 'OK', 200)); 
        List<Check_Request__c> csTrg = [select Approved__c from Check_Request__c limit 100];
        for(Check_Request__c cr: csTrg)
        {
            cr.Approved__c = true;
            
        }                
        Update csTrg;
        test.stopTest();       
    }
    
}