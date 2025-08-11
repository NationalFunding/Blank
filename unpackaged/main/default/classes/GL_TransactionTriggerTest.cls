@IsTest
public with sharing class GL_TransactionTriggerTest {

    @TestSetup
    static void setupMethod(){
        insert new Accounting_Period__c(
            Month__c = '9',
            Year__c = '2022',
            Status__c = 'Closed'
        );
    }
    
    @IsTest
    public static void testTrigger() {
        cmbls__GL_Transaction__c trans = new cmbls__GL_Transaction__c(
            cmbls__Date__c = Date.today().addYears(-10)
        );
        Test.startTest();
        insert trans;
        Test.stopTest();
    
        trans = [SELECT Id, Earliest_Post_Date__c FROM cmbls__GL_Transaction__c WHERE Id = :trans.Id];
        Accounting_Period__c closedPeriods = [SELECT Id, Date__c FROM Accounting_Period__c WHERE Status__c = 'Closed' ORDER BY Date__c DESC LIMIT 1];
        System.assertEquals(closedPeriods.Date__c.addMonths(1).toStartOfMonth(), trans.Earliest_Post_Date__c);
    }
}