public with sharing class Recent_Cases_Controller {
    @AuraEnabled
    public static List<EmailMessage> getEmails()
    {
        List<EmailMessage> listRetrieved = new List<EmailMessage>();        
        if(Schema.sObjectType.EmailMessage.isAccessible())
        {
            listRetrieved = [SELECT Id, Subject,ParentId,Parent.CaseNumber, Parent.Subject,TextBody
                             FROM EmailMessage
                             Where Parent.OwnerId = :UserInfo.getUserId()
                             and  (Status in( '0','5'))
                             order by Id desc];
        }
        system.debug(listRetrieved.size());
        return listRetrieved;
    }
}