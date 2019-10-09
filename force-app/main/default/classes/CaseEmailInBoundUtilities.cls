global  class CaseEmailInBoundUtilities  implements Messaging.InboundEmailHandler{
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.inboundEmail email,Messaging.InboundEnvelope env)
    {
        // Create an InboundEmailResult object for returning the result of the Apex Email Service
        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
        try 
        {
            
            String emailBody=email.plainTextBody;
            
            if(string.isNotBlank(emailBody)){
                
                String cFirstName = emailBody.substringBetween('First Name: ', 'Last Name');                
                String cLastName = emailBody.substringBetween('Last Name: ', 'Email');
                String cEmail = emailBody.substringBetween('Email: ', 'Product SKU');
                Contact aContact = new Contact();
                aContact.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Consumer').getRecordTypeId();
                aContact.FirstName = cFirstName;
                aContact.LastName = cLastName;
                aContact.BP_External_Id__c = cEmail;
                aContact.Email = cEmail;
                Account__c ac = Account__c.getInstance();
                aContact.AccountId = ac.Account_id__c;
                Database.upsert(aContact,contact.BP_External_Id__c,false);
                
                Case aCase = new Case();
                aCase.Subject = Email.subject;
                aCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Customer_Success').getRecordTypeId();
                aCase.Description=emailBody;
                aCase.Contact=new contact (BP_External_Id__c = cEmail);
                aCase.Origin='Web';
                
                Database.insert(aCase,false);
            }
            
        }
        catch (Exception e) 
        {
            System.debug('Exception : ' + e);
        }
        result.success = true;
        return result;
    }
}