trigger SendEmailNotification on Account (after update) {
    
    set<id> setAccountId = new set<id>();
    List<id> setOwnerId = new List<id>();
    List<String> setAcctName = new List<String>();
    LIST<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
    
    if( Trigger.isAfter && Trigger.isUpdate)
    {
        for(Account acct: Trigger.New)
        {
            if(Trigger.oldMap.get(acct.id).ownerID != Trigger.NewMap.get(acct.id).ownerID )
            {
                setAccountId.add(acct.id);
                setOwnerId.add(acct.OwnerId);
                setAcctName.add(acct.Name);
            }
        } 
        User usr = [select email, lastName from user where id=:setOwnerId LIMIT 1];
        list<String> reciverEmail = new list<String>();
        reciverEmail.add(usr.email);
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(reciverEmail);
        mail.setReplyTo('kashif.ali@gettectonic.com');
        mail.setSenderDisplayName('Test Apex Email Sender');
        mail.setSubject('Test Apex Email Notification');
        String body='Dear '+usr.LastName +','+
            'You are now owner of account id'+setAccountId;
        
        emails.add(mail);
        Messaging.sendEmail(emails);
    }
}