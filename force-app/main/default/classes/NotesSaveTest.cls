@IsTest
public class NotesSaveTest {
    @TestSetup static void createTestSetupData()
    {
        Account acc = UtilityTest.createDealerAccount();
    }
    @isTest static void testCreateNotes()
    {
        Account acc = [Select Id from Account limit 1];
        ContentNote cn = new ContentNote();
        cn.Title = 'This is Title of the Note!';
        cn.Content = Blob.valueOf('This is the body content of the Note, be careful with HTML characters here, and use escapeXML to help format your content body strings!');
        insert cn;
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = cn.Id;
        cdl.LinkedEntityId = acc.Id;
        cdl.Visibility ='AllUsers';
        cdl.ShareType ='I';
        Insert cdl;
    }
    
    
}