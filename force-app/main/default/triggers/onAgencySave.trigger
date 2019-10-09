trigger onAgencySave on Agency__c (after insert, after update) {
    Set<Id> SetAccountId = new Set<Id>();
    for(Agency__c rec:Trigger.New){
        if(String.isNotBlank(rec.Account__c)){
            SetAccountId.add(rec.Account__c);
        }
    }
    if(!SetAccountId.isEmpty()){
        map<id,Account> mapAccount = new map<id,Account>();
        List<Agency__c> lstAgency = [Select Account__c,Agency_Account__r.Name From Agency__c Where Account__c = :SetAccountId];
        system.debug(lstAgency);
        
        if(!lstAgency.isEmpty()){
            for(Agency__c rec:lstAgency){
                if(string.isNotBlank(rec.Agency_Account__r.Name)){
                    Account anAccount = new Account();
                    if(mapAccount.containsKey(rec.Account__c)){
                        anAccount = mapAccount.get(rec.Account__c);
                    }
                    else{
                        anAccount.Id = rec.Account__c;
                    }
                    String Wholesaler_csv = '';
                    Wholesaler_csv = anAccount.Wholesaler_CSV__c;
                    if(string.isnotblank(Wholesaler_csv)){
                        Wholesaler_csv = ','+Wholesaler_csv+',';
                        if(!Wholesaler_csv.contains(','+rec.Agency_Account__r.Name+',')){
                            Wholesaler_csv = Wholesaler_csv+rec.Agency_Account__r.Name;
                        }                        
                    }
                    else{
                        Wholesaler_csv = rec.Agency_Account__r.Name;
                    }
                    Wholesaler_csv = Wholesaler_csv.mid(0, 255);
                    anAccount.Wholesaler_CSV__c = Wholesaler_csv.removeStart(',').removeEnd(',');                    
                    if(string.isnotblank(anAccount.Wholesaler_CSV__c)){
                        mapAccount.put(rec.Account__c,anAccount);
                    }
                    
                }               
            }
        }
        system.debug(mapAccount);
        if(!mapAccount.isEmpty()){
            update mapAccount.values();
        }
    }
    
}