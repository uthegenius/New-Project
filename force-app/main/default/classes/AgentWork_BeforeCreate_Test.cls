@IsTest
public class AgentWork_BeforeCreate_Test {
    
    static String mdmTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Technical Support').getRecordTypeId();
    
    @isTest
    private static void agentHandlerTest(){
        Case caseRec = new Case();
        caseRec.RecordTypeId = mdmTypeId;
        caseRec.Subject = 'testCase';
        caseRec.Description = 'TTB0333333';
        caseRec.OwnerId =  UserInfo.getUserId(); 
        caseRec.Status = 'Open';
        
        insert caseRec;
        ID SChannelId= [SELECT Id FROM ServiceChannel Limit 1].Id;
        User user1 = new User();
        user1.id = UserInfo.getUserId();
        System.runAs(user1){              
            AgentWork awork = new AgentWork();
            awork.UserId = UserInfo.getUserId(); 
            awork.ServiceChannelId = SChannelId;
            awork.WorkItemId = caseRec.Id;			
            insert awork;
            update awork;
        }
    }
}