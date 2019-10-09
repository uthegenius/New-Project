trigger UpdateLastOwner on Opportunity (before update) {
    set<id> setOpportunityid = new set<id>();
    set<id> setOppOldOwnerID = new set<id>();
    List<Opportunity> oppList = new List<opportunity>();
    List<User> users= new List<User>();
    String oldemail;
    id oldownerid;
    if(Trigger.isUpdate && Trigger.isAfter )
    {
        for(Opportunity opp : Trigger.New)
        {
            if(Trigger.newMap.get(opp.id).ownerid !=Trigger.oldMap.get(opp.id).ownerid)
            {
                setOpportunityid.add(opp.id);
                setOppOldOwnerID.add(Trigger.oldMap.get(opp.id).ownerid);
                oldownerid = Trigger.oldMap.get(opp.id).ownerid;
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
        for(Opportunity opp : [Select Owner.Email,id, Name, ownerid , Last_Owner_Email__c from Opportunity where id=:setOpportunityid])
        {
            opp.Last_Owner_Email__c=oldemail;   
            oppList.add(opp);
        }
        update oppList; 
    }
}