/**
 * ─────────────────────────────────────────────────────────────────────────────────────────────────
 * TITLE: QBUnsubscribeTest
 * DESCRIPTION: This is a test class of QBUnsubscribe
 * @author         Amrit
 * @version        1.0
 * @created        30/05/2025
 * ─────────────────────────────────────────────────────────────────────────────────────────────────
 */
@isTest
public class QBUnsubscribeTest {

    @TestSetup
    static void createTestData() {
        Lead l = new Lead(
            FirstName = 'Rasmus',
            LastName = 'Mencke',
            Company = 'Salesforce',
            Email = 'rmencke@salesforce.com',
            QB_Marketing_Opt_Out__c = false
        );
        insert l;

        Contact c = new Contact(
            FirstName = 'Rasmus',
            LastName = 'Mencke',
            Email = 'rmencke@salesforce.com',
            QB_Marketing_Opt_Out__c = false
        );
        insert c;
    }

    static testMethod void testUnsubscribe() {
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();

        email.subject = 'test unsubscribe test';
        env.fromAddress = 'rmencke@salesforce.com';

        Test.startTest();
        QBUnsubscribe unsubscribeObj = new QBUnsubscribe();
        unsubscribeObj.handleInboundEmail(email, env);
        Test.stopTest();

        List<Lead> leads = [SELECT QB_Marketing_Opt_Out__c FROM Lead WHERE Email = 'rmencke@salesforce.com'];
        List<Contact> contacts = [SELECT QB_Marketing_Opt_Out__c FROM Contact WHERE Email = 'rmencke@salesforce.com'];

        System.assertEquals(true, leads[0].QB_Marketing_Opt_Out__c, 'Lead should be opted out');
        System.assertEquals(true, contacts[0].QB_Marketing_Opt_Out__c, 'Contact should be opted out');
    }

    static testMethod void testUnsubscribe2() {
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();

        email.subject = 'test'; 
        env.fromAddress = 'rmencke@salesforce.com';

        Test.startTest();
        QBUnsubscribe unsubscribeObj = new QBUnsubscribe();
        unsubscribeObj.handleInboundEmail(email, env);
        Test.stopTest();

        List<Lead> leads = [SELECT QB_Marketing_Opt_Out__c FROM Lead WHERE Email = 'rmencke@salesforce.com'];
        List<Contact> contacts = [SELECT QB_Marketing_Opt_Out__c FROM Contact WHERE Email = 'rmencke@salesforce.com'];

        System.assertEquals(false, leads[0].QB_Marketing_Opt_Out__c, 'Lead should NOT be opted out');
        System.assertEquals(false, contacts[0].QB_Marketing_Opt_Out__c, 'Contact should NOT be opted out');
    }
}