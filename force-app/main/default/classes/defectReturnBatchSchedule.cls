/************************
Author:         Hanif Babar
Created Date:   15/Aug/2018 
Purpose:        defectReturnBatchSchedule

************************MODIFICATION HISTORY**************************************
Added on             Added By               Description
**********************************************************************************
15/Aug/2018           Hanif Babar          Initial Development 
***********************************************************************************/
global class defectReturnBatchSchedule implements Database.Batchable<sObject>,Schedulable{
    private id caseRecordTypeId;
    private id queueid;
    global void execute(SchedulableContext sc)        
    {
        defectReturnBatchSchedule t = new defectReturnBatchSchedule();
        Database.executeBatch(t);  
    }
    global defectReturnBatchSchedule(){
        caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Defect_Return').getRecordTypeId();
        List<Group> queueidList  = [select Id, Name, DeveloperName from Group where Type = 'Queue' and DeveloperName='Grohe_Goods_Associate' LIMIT 1];        
        if(queueidList.size()>0)
        {
            queueid = queueidList[0].id;
        }
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
        // Get all defect retrun lins whoes defect return case is not created
        string query =   'Select Id,Reference_Number_BP__c,Case__c,Account__c,Requested_By__c '+
                        'From Defect_Return_Form__c '+
                        'Where Case__c = null '+
                   		'and Account__c != null '+ 
                        'and Reference_Number_BP__c !=null order by Reference_Number_BP__c';
        system.debug(query);
        system.debug(Database.query(query));
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        // Prepare multil defect lines for a case entry
        List<AggregateResult> ar =[Select Reference_Number_BP__c, 
                                 	Account__c,
                                    Requested_By__c
                            From Defect_Return_Form__c
                            Where Id  in :scope
                            Group by Reference_Number_BP__c, Account__c, Requested_By__c order by Reference_Number_BP__c];
        
        map<string,Case> mapCase = new map<string,Case>();
        for(AggregateResult element:ar){
            Case aCase = new Case(RecordTypeId = caseRecordTypeId,                                  
                                  AccountId = (Id)element.get('Account__c'), 
                                  Defect_Return_Reference_Number__c = string.valueof(element.get('Reference_Number_BP__c')),
                                  Origin = 'Business Portal',
                                  status = 'Open',
                                  OwnerId = queueid);            
            if (string.isNotBlank(string.valueof(element.get('Requested_By__c')))){
                aCase.ContactId = (Id)element.get('Requested_By__c');
            }
            
            mapCase.put(string.valueof(element.get('Reference_Number_BP__c')), aCase);
        }
        system.debug(mapCase);
        Insert mapCase.values();
        List<Defect_Return_Form__c> lstDRF = (List<Defect_Return_Form__c>)scope;
        for(Defect_Return_Form__c element : lstDRF){
            if(mapCase.containsKey(element.Reference_Number_BP__c)){
                element.put('Case__c',mapCase.get(element.Reference_Number_BP__c).Id); 
            }            
        }
        update lstDRF;
    }
    
    global void finish(Database.BatchableContext BC){
    }
}