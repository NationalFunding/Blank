/**
 * ─────────────────────────────────────────────────────────────────────────────────────────────────
 * TITLE: NFUnsubscribeTest
 * DESCRIPTION: This is a test class of NFUnsubscribe
 * @author         Amrit
 * @version        1.0
 * @created        30/05/2025
 * ─────────────────────────────────────────────────────────────────────────────────────────────────
 */
@isTest
public class NFUnsubscribeTest {

    @TestSetup
    static void createTestData() {
        Lead l = new Lead(
            FirstName = 'Rasmus',
            LastName = 'Mencke',
            Company = 'Salesforce',
            Email = 'rmencke@salesforce.com',
            Marketing_Opt_Out__c = false
        );
        insert l;

        Contact c = new Contact(
            FirstName = 'Rasmus',
            LastName = 'Mencke',
            Email = 'rmencke@salesforce.com',
            Marketing_Opt_Out__c = false
        );
        insert c;
    }

    static testMethod void testUnsubscribe() {
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();

        email.subject = 'test unsubscribe test';
        env.fromAddress = 'rmencke@salesforce.com';

        Test.startTest();
        NFUnsubscribe unsubscribeObj = new NFUnsubscribe();
        unsubscribeObj.handleInboundEmail(email, env);
        Test.stopTest();

        // Validate that Marketing_Opt_Out__c was updated to true
        Lead l = [SELECT Marketing_Opt_Out__c FROM Lead WHERE Email = 'rmencke@salesforce.com' LIMIT 1];
        Contact c = [SELECT Marketing_Opt_Out__c FROM Contact WHERE Email = 'rmencke@salesforce.com' LIMIT 1];

        System.assertEquals(true, l.Marketing_Opt_Out__c, 'Lead should be opted out');
        System.assertEquals(true, c.Marketing_Opt_Out__c, 'Contact should be opted out');
    }

    static testMethod void testUnsubscribe2() {
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();

        email.subject = 'test'; 
        env.fromAddress = 'rmencke@salesforce.com';

        Test.startTest();
        NFUnsubscribe unsubscribeObj = new NFUnsubscribe();
        unsubscribeObj.handleInboundEmail(email, env);
        Test.stopTest();

        // Validate that Marketing_Opt_Out__c is still false
        Lead l = [SELECT Marketing_Opt_Out__c FROM Lead WHERE Email = 'rmencke@salesforce.com' LIMIT 1];
        Contact c = [SELECT Marketing_Opt_Out__c FROM Contact WHERE Email = 'rmencke@salesforce.com' LIMIT 1];

        System.assertEquals(false, l.Marketing_Opt_Out__c, 'Lead should not be opted out');
        System.assertEquals(false, c.Marketing_Opt_Out__c, 'Contact should not be opted out');
    }
}