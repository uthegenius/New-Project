trigger UpdateAccountLastOwner on Account (after update) {
    set<id> setAccountid = new set<id>();
    set<id> setAcctOldOwnerID = new set<id>();
    List<Account> acctList = new List<Account>();
    List<User> users= new List<User>();
    String oldemail;
    id oldownerid;
    if(Trigger.isUpdate && Trigger.isAfter )
    {
        for(Account acct : Trigger.New)
        {
            if(Trigger.newMap.get(acct.id).ownerid !=Trigger.oldMap.get(acct.id).ownerid)
            {
                setAccountid.add(acct.id);
                setAcctOldOwnerID.add(Trigger.oldMap.get(acct.id).ownerid);
                oldownerid = Trigger.oldMap.get(acct.id).ownerid;
            }
        }
        System.debug('KA:: '+oldownerid);
        users= [select email, name from User where id=:oldownerid];
        if(users.size()>0)
        {
            for(User u: users)
            {
                  oldemail=u.email;  
            }
        }
        for(Account acct : [Select Owner.Email,id, Name, ownerid , Last_Owner_Email__c from Account where id=:setAccountid])
        {
            acct.Last_Owner_Email__c=oldemail;   
            acctList.add(acct);
        }
        update acctList; 
    }
}