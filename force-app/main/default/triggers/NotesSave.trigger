trigger NotesSave on ContentDocument  (after insert, after update, after delete, after undelete) {
    
    // Jira LSCIP-29 (L-8)
    // Track last modify date on parent object ever after delete or undelete
    /*
    if(Trigger.isAfter && Trigger.newMap.keySet() != null){
        Set<Id> parentId = new Set<Id>();
        set<Id> setCDL = Trigger.newMap.keySet();
        for(ContentDocumentLink aCDL:[select LinkedEntityId 
                                      From ContentDocumentLink 
                                      Where ContentDocumentId = :setCDL]){
            if(string.isNotBlank(aCDL.LinkedEntityId)){
                parentId.add(aCDL.LinkedEntityId);
            }             
        }
        CommonObjects_Controller.setLastTransActivity(parentId);
    }
    */
}