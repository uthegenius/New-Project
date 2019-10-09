@isTest
private class CaseEmailInBoundUtilitiesTest {
    @isTest static void testCreateContactFromEmail() {
       Messaging.InboundEmail email = new Messaging.InboundEmail() ;
       Messaging.InboundEnvelope env    = new Messaging.InboundEnvelope();

        email.subject = 'Create Contact';
        email.plainTextBody = 'FromEmail';
        env.fromAddress = 'test@mail.com';

        CaseEmailInBoundUtilities creatC = new CaseEmailInBoundUtilities();
        creatC.handleInboundEmail(email, env );
    }

    }