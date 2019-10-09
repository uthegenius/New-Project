public class FollowRecordsByOwner {
    
    @InvocableMethod
    public static void passPerm(List<id> recordId)
    {
        /*List<List <sObject>> searchList = [FIND 'id' IN ALL FIELDS Returning Project__c(Id, ownerid
		where id in: recordId),
		Quote(Id, ownerid where id in: recordId)]; */
        Map<id,id> recordsMap  =new Map<id,id>();
        List<Project__c> projList = [select id, ownerid from project__c where id IN:recordId];
        if(projList.size() > 0)
        {
            for(Project__c prj : projList)
            {
             	recordsMap.put(prj.id,prj.OwnerId);    		    
            }   
        }
        
        List<Quote> qtList = [select id, ownerid from quote where id IN:recordId];
        if(qtList.size() > 0)
        {
//for(Quote qt : qtList)
            //{
            // 	recordsMap.put(qt.id,qt.OwnerId);    		    
           // }   
        }
        if(recordsMap.size() > 0)
        {
         	followRecords(recordsMap);   
        }
    }
    
    public static void followRecords(Map<id,id> dataToFollow)
    {
        List<EntitySubscription> entSubList = new List<EntitySubscription>();
        List<EntitySubscription> entExists = [select parentid,SubscriberId from EntitySubscription where parentid=:dataToFollow.keyset()];
        if (entExists.size() > 0)
        {
            for(Id key : dataToFollow.keySet())
            {
                for(EntitySubscription en :entExists )
                {
                    if(en.parentid == key && en.SubscriberId==dataToFollow.get(key))
                    {
                        dataToFollow.remove(key);
                    }   
                }
                
            }
        }
        if(dataToFollow.size() > 0)
        {
            for(Id key : dataToFollow.keySet())
            {
                if(dataToFollow.get(key) == UserInfo.getUserId())
                {
                    EntitySubscription es = new EntitySubscription(
                        ParentId=key,
                        SubscriberId =dataToFollow.get(key)   
                    );
                    entSubList.add(es);    
                }
                System.debug(key+' - '+ dataToFollow.get(key));   
            }
            if(entSubList.size()  > 0)
            {
                try{
                    insert entSubList;  
                }catch(DmlException ex)
                {
                    System.debug('DML Exception: '+ ex.getMessage());
                }
                
            }
        }
    }   
}