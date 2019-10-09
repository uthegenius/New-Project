trigger AttachmentTrg on Attachment (after insert) 
    {
        
        List<Id> listAttachmentId = new List<Id>();
        List<Id> listCaseId = new List<Id>();
        
            List<Id> listEmAttachmentId = new List<Id>();
           List<Id> ListEmId = new List<Id>();
           Set<string> stt = new Set<String>();
        
        for (attachment att : Trigger.New)
        {
            if (att.parentId.getSObjectType() == Case.sObjectType||att.parentId.getSObjectType() == Asset.sObjectType  )
            {
                
                listAttachmentId.add(att.Id);
                listCaseId.add(att.ParentId);
                
            }
            
            
               if ( att.parentId.getSObjectType() == EmailMessage.sObjectType )
            {
                
                listEmAttachmentId.add(att.Id);
                ListEmId.add(att.ParentId);
                stt.add(att.ParentId);
                
            }
            
        }
        
        
        
        if (listAttachmentId != null && listAttachmentId.size() > 0)
        {
            system.debug('ah::listAttachmentId ' + listAttachmentId);
            system.debug('ah::listCaseId ' + listCaseId);
            BoxConnectUtil.moveAttachmenttoBox(listAttachmentId, listCaseId);
        }
        
        
      
        
    }