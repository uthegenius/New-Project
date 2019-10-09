@isTest
public class emailMessageTest {
    
    
    
   public static TestMethod void emailMessageTest()
   {
       List<Case> csList3;
       csList3 = UtilityTest.CreateMultipleCase(null,
                                                     Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Technical_Support').getRecordTypeId(),
                                                     2,
                                                     true);
       
     
       EmailMessage em;
       em = UtilityTest.createEmailMessage(csList3[0].id, 'ODMS Team Assignment for Case #: 00005204 Ref Number: '+csList3[0].id+' cc','<html>Html</html>','sf_casemanagement@lixilamericas.com', false);
       em.For_Odms__c=false;
       insert em;
       


    
       List<Case> csList4;
       csList4 = UtilityTest.CreateMultipleCase(null,
                                                     Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Technical_Support').getRecordTypeId(),
                                                     2,
                                                     false);
       
       
       csList4[0].origin='From Reply';
       insert csList4;
       
     
       EmailMessage em5;
       em5 = UtilityTest.createEmailMessage(csList4[0].id, 'ODMS Team Assignment for Case #: 00005204 Ref Number: '+csList3[0].id+' cc','<html>Html</html>','sf_casemanagement@lixilamericas.com', false);
       em5.For_Odms__c=false;
       insert em5;


       
       
       
       //For the Scar Form
       Account ac =UtilityTest.CreateAccount('Test Account',true);
       Contact cc = UtilityTest.CreateContact(ac.id,'Other');
       Scar__c sc = UtilityTest.CreateScar(true,ac.id,cc.id);
       EmailMessage em2;
       em2 = UtilityTest.createEmailMessage(csList3[0].id, 'Test','<html>Html</html>','test@lixilamericas.com', false);
       em2.RelatedToId=sc.id;       
       insert em2;
       
       
       
      EmailMessage em3;
     // em3=UtilityTest.createEmailMessage(csList3[0].id, 'Test Subject', '<html>Test Caes</html>','test@mail.com', true);

       
       
       
   }
    
    
    
    
    
    

}