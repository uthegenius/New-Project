public class LiveChatTranscript_Helper {
    public static Map<Id,String> getChatButtonNamWithCaseId(List<LiveChatTranscript> paramLCT){
        map<id,string> CaseChatButtonName = new map<id,string>();
        map<id,id> CaseIdChatButtonId = new map<id,id>();
        for(LiveChatTranscript element:paramLCT){
            if(string.isNotBlank(element.CaseId) && string.isNotBlank(element.LiveChatButtonId)){
                CaseIdChatButtonId.put(element.CaseId,element.LiveChatButtonId);
            }
            
        }
        
        if(!CaseIdChatButtonId.isEmpty()){
            List<LiveChatButton> lstChatButton = [select MasterLabel from LiveChatButton where id = :CaseIdChatButtonId.values()];
            for( LiveChatButton element:lstChatButton ){
                for(String Key:CaseIdChatButtonId.KeySet()){
                    Id ChatId = CaseIdChatButtonId.get(Key);
                    if(element.Id== ChatId){
                        CaseChatButtonName.put(Key,element.MasterLabel);
                    }
                }
            }
        }
        
        return caseChatButtonName;
    }
}