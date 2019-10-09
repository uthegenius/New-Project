trigger FieldServiceTicketTrg on Field_Service_Ticket__c (before update,after insert) {
    
    List<string> csid= new List<string>();
    List<string> fstid= new List<string>();
    if(Trigger.IsBefore && Trigger.IsUpdate)
    {    
        
        for(Field_Service_Ticket__c fst:Trigger.new)
        {   
            if(fst.Approved__c==true&& fst.Approved__c != Trigger.OldMap.get(fst.Id).Approved__c)
            {
                fstid.add(fst.id);
                csid.add(fst.Case_ID__c);
            }
            
        }
        system.debug('ah::fstid ' + fstid);
        system.debug('ah::csid ' + csid);
        if(fstid.size()>0 && csid.size()>0)
        {
            FSTHandler.sendEmail(fstid,csid);
            system.debug('Inserted');
        }
        
    }
    
    if(Trigger.IsAfter && Trigger.IsInsert)
    {
        
        for(Field_Service_Ticket__c fst :Trigger.new)
            
        {
            BoxConnectUtil.createFolderinBox(fst.Id);
        }
        
    }
    
}