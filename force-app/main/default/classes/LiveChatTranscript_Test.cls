@isTest(seeAllData = false)
public class LiveChatTranscript_Test {
    static testMethod void getevent(){
		id LiveChatButtonId = [select Id from livechatbutton limit 1].Id;        
        Account anAccount = UtilityTest.createCustomerAccount();               
        id CaseId = UtilityTest.CreateMultipleCase( anAccount.Id, 
                                                    Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Technical_Support').getRecordTypeId(),
                                                    1,
                                                    True)[0].Id;
        
        LiveChatVisitor lcv = new LiveChatVisitor();
        try{
            insert lcv;
        }catch(Exception e){}
        
        LiveChatTranscript lct = new LiveChatTranscript();
        lct.LiveChatVisitorid = lcv.id;
        lct.CaseId = CaseId;
        lct.LiveChatButtonId  = LiveChatButtonId;
        try{
            insert lct;
        }catch(Exception e){}
        system.debug('lct' + lct);
        /*
        insert Live Chat Transcript Event
        */
        LiveChatTranscriptEvent le = new LiveChatTranscriptEvent();
        le.LiveChatTranscriptId = lct.id;
        le.type = 'ChatRequest';
        le.time = system.now();
        try{
            insert le;
        }
        catch(Exception e){}
        try{
            delete le;
        }
        catch(Exception e){}
    }
}