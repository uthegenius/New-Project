@isTest
public class SFSupportDSR_ControllerTest {
    
    
    @isTest
    public static void SFSupportDSRTest()
    {
        Account acct = new Account(Name='Test Account');
        insert acct;
        
        Contact con = new Contact(LastName='Test', accountid=acct.id);
        insert con;
        recordtype RecordTypeIdContact = [select id from recordtype where developername='Salesforce_Cases' LIMIT 1];
        System.debug('KA::'+ RecordTypeIdContact.id);
        Case cas = new Case(Subject='Test Case', Status='Open', Type='Installation',Origin='Web',Contact=con,recordtypeid=RecordTypeIdContact.id);
        insert cas;
        CaseComment cc = new CaseComment(CommentBody='Test Comment Body' , ParentId=cas.id);
        insert cc;
        
        
        EmailMessage em2;
        em2 = UtilityTest.createEmailMessage(cas.id, 'Test','<html>Html</html>','test@lixilamericas.com', false);
        em2.RelatedToId=cas.id;
        em2.status = '3';
        em2.Incoming = false;
        insert em2;
        system.debug([select status from emailmessage limit 1]);
        Test.StartTest();
        SFSupportDSR_Controller  SFSupDSR = new SFSupportDSR_Controller();
        SFSupDSR.DSRDate = Date.Today();
        
        SFSupDSR.fetchDSR();
        Test.StopTest();   
        
    }
    
}