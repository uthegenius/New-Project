global class sObjectNoofTouch_BatchSch implements Database.Batchable<sObject>,Schedulable{
    global final String ObjN;
    global final Double NoDays_Limit;
    global sObjectNoofTouch_BatchSch(){
        
    }
    global sObjectNoofTouch_BatchSch(String O, Double P){
        
        ObjN=o;
        NoDays_Limit = P;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        string query = 'Select Id, Is_Last_Touch_Limit_Hit__c,LastTransActivity__c From '+ObjN+
                   ' where Is_Last_Touch_Limit_Hit__c=False and Days_Since_Last_Touch__c > :NoDays_Limit';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        map<id,datetime> mapAccountTeamLMD = new map<id,datetime>();
        if(ObjN.toUpperCase()=='ACCOUNT'){
            List<AggregateResult> lstAR = [Select AccountId,Min(LastModifiedDate) LMD 
                                           From AccountTeamMember                                            
                                          Where AccountId = :scope
                                          Group By AccountId];
            if (!lstAR.isEmpty()){
                for(AggregateResult ar:lstAr){
                    mapAccountTeamLMD.put(string.valueOf(ar.get('AccountId')),
                                          datetime.valueOf(ar.get('LMD')));
                }
                for(sobject s : scope){
                    DateTime dt = mapAccountTeamLMD.get(s.Id);
                    if(datetime.valueOf(s.get('LastTransActivity__c'))<dt ){
                        s.put('LastTransActivity__c',dt); 
                    }
                    
                }
            }
        }
        
        for(sobject s : scope){
            s.put('Is_Last_Touch_Limit_Hit__c',True); 
        }
        database.update(scope,false);
    }
    
    global void finish(Database.BatchableContext BC){
    }
    global static void scheduleJob(){
        sObjectNoofTouch_BatchSch obj = new sObjectNoofTouch_BatchSch();
        String sch = '0 15 12 1/1 * ? *';
        String jobID = System.schedule('Object Lead,Account,Opp No. Days since last touch', sch, obj);
    }
    global void execute(SchedulableContext ctx) {
        sObjectNoofTouch_BatchSch.explicitRun();
    }
    global static void explicitRun(){
        Lixil_Config__c LC = Lixil_Config__c.getInstance();
        Double LTDL = LC.Last_Touch_Days_Limit__c;
        List<String> lstObjectName = new List<String>();
        lstObjectName = LC.Object_for_Last_Touches__c.split(',');
        For(String objName:lstObjectName){
            sObjectNoofTouch_BatchSch obj = new sObjectNoofTouch_BatchSch(objName,LTDL);
          Id batchJobId = Database.executeBatch(obj, 200);
        }
    }
}