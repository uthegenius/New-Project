trigger LiveChatTranscript_Trg on LiveChatTranscript (after insert, after update) {
    if((Trigger.isInsert||Trigger.isUpdate) && Trigger.isAfter){
        map<id,string> caseChatButtonName = new map<id,string>();
        caseChatButtonName = LiveChatTranscript_Helper.getChatButtonNamWithCaseId(Trigger.New);
        List<Case> lstCase = new List<Case>();
        for(Id Key:caseChatButtonName.keyset()){
            system.debug(Key);
            lstCase.add( new case(Id=Key,
                                  Queue_Name_WR__c = caseChatButtonName.get(Key))
                       );
        }
        if(!lstCase.isEmpty()){
            Update lstCase;
        }
    }
}