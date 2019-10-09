trigger EmailOppOwnerChange on Opportunity  (after update) {
    
    List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
    List<ID>ownerids=new List<ID>();
    Id setOpportunityId;
    set<id> setAccntId = new set<id>();
    List<String> sendTo = new List<String>();
    List<String> sendToNewOwner = new List<String>();
    List<String> sendToOldOwner = new List<String>();
    List<User>users=new List<User>();
    List<String> optName = new List<String>();
    String AccountName;
    for (Opportunity  oppt : Trigger.new) {
        
        Opportunity oldcon = Trigger.oldMap.get(oppt.Id);
        if (oppt.ownerid != oldcon.ownerid ) {
            ownerids.add(oppt.ownerid) ;  
            ownerids.add(oldcon.ownerid) ;
            optName.add(oppt.Name);
            setOpportunityId= oppt.id;  
            setAccntId.add(oppt.AccountId);
            //AccountName = oppt.Account.Name;
        }
    }
   // System.debug('KA:: '+ AccountName);
   // String AccountName;
    for(Account acc : [select name from account where id=:setAccntId])
    {
       AccountName = acc.Name; 
    }
   
    if(ownerids.size()>0 ){
        String newOwnerName='';
        String oldOwnerName='';
        String body='';
        users=[select name,id,email from user where id in:ownerids];
        system.debug('-------------users------'+users);
        if(users.size()>0){
            for(User u:users){
                sendTo.add(u.Email);
                if(u.id==ownerids.get(0))
                {
                    newOwnerName = u.Name;
                    sendToNewOwner.add(u.Email);
                    body='*** OPPORTUNITY ASSIGNMENT NOTIFICATION *** <br><br>';
                    body+='The following opportunity has been assigned to you.<br> ';
                    body+='Account: <b>'+AccountName+'</b><br> ';
                    body+='Opportunity Name: <b>'+optName.get(0)+'</b><br>';
                    body+='Click on the link to access the opportunity directly: <a href=https://lwta--full.lightning.force.com/'+setOpportunityId+'> https://lwta--full.lightning.force.com/'+setOpportunityId+'</a>';
                    mails.add(creatEmail(sendToNewOwner, body));
                    
                }
                if(u.id==ownerids.get(1))
                {
                    oldOwnerName = u.Name;
                    sendTooldOwner.add(u.Email);
                    body='*** OPPORTUNITY ASSIGNMENT NOTIFICATION *** <br><br>';

                    body+='The following opportunity owner has been changed.<br> ';
                    body+='Account: <b>'+AccountName+'</b><br> ';
                    body+='Opportunity Name: <b>'+optName.get(0)+'</b><br>';
                    body+='<br>New Owner: <b>'+newOwnerName+'</b><br>';
                    body+='Click on the link to access the opportunity directly: <a href=https://lwta--full.lightning.force.com/'+setOpportunityId+'> https://lwta--full.lightning.force.com/'+setOpportunityId+'</a>';
                    mails.add(creatEmail(sendTooldOwner, body));
                }
            }
            try{
                Messaging.sendEmail(mails);
            }
            catch(Exception e){
                system.debug('-------------exception------'+e);                
            }            
        }        
    }
    Messaging.SingleEmailMessage creatEmail(List<string>sendTo, String body)
    {
         Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            //mail.setReplyTo('ramanisetti@gmail.com');
            mail.setSenderDisplayName('Lixil Admin');
            
            mail.setSubject('Opportunity Owner change');
           
            mail.setToAddresses(sendTo);
            mail.setHtmlBody(body);
            return mail;
    }
    
}