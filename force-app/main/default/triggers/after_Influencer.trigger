trigger after_Influencer on Influencers__c (after insert, after update, after delete, after undelete) {
    if(Trigger.isAfter){
        Set<id> ProjectId = new Set<Id>();
        for(Influencers__c rec:trigger.new){
            ProjectId.add(rec.Project__c);
        }
        
        List<Influencers__c> lstInf = [Select Infuencer_Account__r.Name, Project__c from Influencers__c where Project__c = :ProjectId];
        
        map<id,Project__c> Project_inf = new map<id,Project__c>();
        for(Influencers__c rec:lstInf){
            String Inf ='';
            if(Project_inf.containskey(rec.Project__c)){
                Inf = Project_inf.get(rec.Project__c).Project_Influencers__c;
            }             
            Inf = Inf+','+rec.Infuencer_Account__r.Name;
            Inf = Inf.removeStart(',');
            Inf = inf.mid(0, 255);
            Project_inf.put(rec.Project__c,new Project__c(Id=Rec.Project__c,Project_Influencers__c=Inf));
            system.debug(Project_inf);
        }
        system.debug(Project_inf);
        if(!Project_inf.isEmpty()){
            update Project_inf.values();
        }
        
    }
    
    
}