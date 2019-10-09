trigger DelegatedProcess on Quote (after update) {
    
    set<id> setQuoteId = new set<id>();
    set<id> setProcInstID = new Set<id>();
    set<id> setUserId = new set<id>();
    Integer approvelLevel, approvelStep;
    boolean isProcess = false;
    System.debug('Delegated Approval Called');
    if(Trigger.isUpdate && Trigger.isAfter)
    {
        for(Quote qtt : Trigger.New)
        {
            
            if(qtt.Delegated_Status__c ==true )
            {
                setQuoteId.add(qtt.id);
                approvelLevel = Integer.valueOf(qtt.Num_Approvals__c);
                approvelStep = Integer.valueOf(qtt.Approval_Step__c);
                System.debug('KA:: Aproval Level: '+ approvelLevel); 
                System.debug('KA:: Aproval Step: '+ qtt.Approval_Step__c);
                System.debug('KA:: Aproval Step: '+ approvelStep);
                isProcess = qtt.Delegated_Status__c;    
            }
        }
        System.debug('KA::IsProcee Status: ' + isProcess);
        System.debug('KA:: Set Quote Status: ' + setQuoteId);
        
        System.debug('setQuoteId: ' + setQuoteId);
        if(isProcess==true)
        {
            
            //List<ProcessInstance> ProcessInstanceList = [ SELECT id, TargetObjectId,   Status FROM ProcessInstance where TargetObjectId =:setQuoteId  and status='Pending'];
            List<ProcessInstance> ProcessInstanceList = [ SELECT id, TargetObjectId,   Status FROM ProcessInstance where TargetObjectId =:setQuoteId];
            
            System.debug('KA:: Process Inst List SIze : ' + ProcessInstanceList.size());
            for(ProcessInstance procInst : ProcessInstanceList)
            {
                setProcInstID.add(procInst.id);
                
            }
            System.debug('KA:: Process Inst ID : ' + setProcInstID);
            List<ProcessInstanceStep> procInstStep = [select id, stepStatus, ActorID, ProcessInstanceId From ProcessInstanceStep where ProcessInstanceid=:setProcInstID and StepStatus='Started'];
            for(ProcessInstanceStep procStep: procInstStep)
            {
                setUserId.add(procStep.ActorID);   
            }
            System.debug('KA:: Actual User ID : ' + setUserId);
            ID delegatedUserID ;
            List<User> userList =[select DelegatedApproverId from User where ID=:setUserId];
            for(user usr : userList)
            {
              delegatedUserID = usr.DelegatedApproverId ;  
            }
            System.debug('KA:: Delegated User ID : ' + delegatedUserID);
            List<Quote> updatedPosList = new List<Quote>();
            for(Quote positionLst : [Select id, name, Delegated_Owner__c from Quote where id=:setQuoteId])
            {
                positionLst.Delegated_Owner__c = delegatedUserID;
                positionLst.Delegated_Process__c = 'Delegated';
                updatedPosList.add(positionLst);
            }
            System.debug('KA:: Delegated User ID: '+ delegatedUserID);
            //update updatedPosList;
            
        }
            /*List<sObject> listPIWI = [Select id from ProcessInstanceWorkitem];
            System.debug(listPIWI.size());
            for(ProcessInstanceWorkitem procInsWItm : [Select id from ProcessInstanceWorkitem])
            {
                System.debug('In Loop');
                System.debug('Actor ID: '+ procInsWItm.id);    
            } 
            System.debug('Out Loop');
            //List<ProcessInstanceWorkitem> ProcessInstanceWorkitemList =[SELECT ActorId FROM ProcessInstanceWorkitem where ProcessInstanceId=:ProcessInstanceList.get(0).id];
            //ID actorIDD = ProcessInstanceWorkitemList.get(0).ActorId;
            //System.debug('Actor ID: '+ actorIDD);    
            //
            List<Quote> updatedPosList = new List<Quote>();
            for(Quote positionLst : [Select id, name, Delegated_Owner__c from Quote where id=:setQuoteId])
            {
                positionLst.Delegated_Owner__c = DelegatedUserId;
                positionLst.Delegated_Process__c = 'Delegated';
                updatedPosList.add(positionLst);
            }
            update updatedPosList;
            isProcess= false;
        } */
        
    }
}