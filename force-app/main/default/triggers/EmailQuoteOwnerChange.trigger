trigger EmailQuoteOwnerChange on Quote  (after update) {
  
  List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
  List<ID>ownerids=new List<ID>();
  
  List<String> sendTo = new List<String>();
  List<User>users=new List<User>();
  List<String> quoteName = new List<String>();
  
  for (Quote  qt : Trigger.new) {
  
    Quote oldcon = Trigger.oldMap.get(qt.Id);
    if (qt.ownerid != oldcon.ownerid ) {
    
       ownerids.add(qt.ownerid) ;  
       ownerids.add(oldcon.ownerid) ;
       quoteName.add(qt.Name);
    }
    }
    
    if(ownerids.size()>0 ){
      String newOwnerName='';
    users=[select name,id,email from user where id in:ownerids];
    system.debug('-------------users------'+users);
    if(users.size()>0){
     for(User u:users){
      sendTo.add(u.Email);
      if(u.id==ownerids.get(0))
      {
          newOwnerName = u.Name;
      }
    }
    
     Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
     //mail.setReplyTo('ramanisetti@gmail.com');
      mail.setSenderDisplayName('Email alert');

      mail.setSubject('Quote Owner change');
      String body = 'Dear User ';
        body+='<br><br>The Quote <b> '+quoteName.get(0)+'</b> owner has been changed.';
        body+='The new owner is <b>'+newOwnerName+' </b>';
        body+='<br>Thanks, <br>Lixil Admin';
      mail.setToAddresses(sendTo);
      mail.setHtmlBody(body);
      //EmailTemplate tmplId = [SELECT Id FROM EmailTemplate WHERE Name='Owner Change Notification Current Owner' LIMIT 1];
      //mail.setTemplateId(tmplId.id);
      mails.add(mail);
      try{
      Messaging.sendEmail(mails);
      }
      catch(Exception e){
      system.debug('-------------exception------'+e);
       
      }
    
    }
    
    }
  
}