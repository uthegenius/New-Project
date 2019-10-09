trigger SendEmailOwnerChange on Account (after update) {
  
  List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
  List<ID>ownerids=new List<ID>();
  
  List<String> sendTo = new List<String>();
  List<User>users=new List<User>();
  List<String> accountName = new List<String>();
  
  for (Account myacc : Trigger.new) {
  
    Account oldcon = Trigger.oldMap.get(myacc.Id);
    if (myacc.ownerid != oldcon.ownerid ) {
    
       ownerids.add(myacc.ownerid) ;  
       ownerids.add(oldcon.ownerid) ;
       accountName.add(myacc.Name);
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

      mail.setSubject('Owner change');
      String body = 'Dear User ';
        body+='<br><br>The account <b> '+accountName.get(0)+'</b> owner has been changed.';
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