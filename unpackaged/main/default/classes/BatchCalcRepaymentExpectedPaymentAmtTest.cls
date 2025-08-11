@IsTest
public with sharing class BatchCalcRepaymentExpectedPaymentAmtTest {

    @IsTest
    public static void testBatchClass() {
     
        Account acc = TestDataFactory.createAccount();
        insert acc;

        cmbls__Repayment__c repayment = TestDataFactory.createRepayment(acc.Id);
        repayment.Expected_Payment_Amount__c = 0.0;
        insert repayment;

        List<cmbls__Amortization_Schedule__c> amortSchs = new List<cmbls__Amortization_Schedule__c>();
        for (Integer i = 0; i < 10; i++) {
            cmbls__Amortization_Schedule__c amortSch = TestDataFactory.createAmortizationSchedule(repayment.Id, i);
            amortSchs.add(amortSch);
        }
        insert amortSchs;

        Test.startTest();
            BatchCalcRepaymentExpectedPaymentAmt batch = new BatchCalcRepaymentExpectedPaymentAmt();
            Database.executeBatch(batch);
        Test.stopTest();

        List<cmbls__Repayment__c> updatedRepayment = [SELECT Id, Expected_Payment_Amount__c
                                                      FROM cmbls__Repayment__c
                                                      WHERE cmbls__Status__c in ('Active','Pause')];  

        system.assertNotEquals(null, updatedRepayment, 'Repayment record is not found');
        system.Assert.areEqual(updatedRepayment[0].Expected_Payment_Amount__c, 45, 'Expected_Payment_Amount__c calculation is not correct');

    }

    @IsTest
    public static void testBatchClassInvocable() {
     
        Account acc = TestDataFactory.createAccount();
        insert acc;

        cmbls__Repayment__c repayment = TestDataFactory.createRepayment(acc.Id);
        repayment.Expected_Payment_Amount__c = 0.0;
        insert repayment;

        List<cmbls__Amortization_Schedule__c> amortSchs = new List<cmbls__Amortization_Schedule__c>();
        for (Integer i = 0; i < 10; i++) {
            cmbls__Amortization_Schedule__c amortSch = TestDataFactory.createAmortizationSchedule(repayment.Id, i);
            amortSchs.add(amortSch);
        }
        insert amortSchs;
        
        List<Id> repayments = new List<Id>();
        repayments.add(repayment.Id);
        
        Test.startTest();
            BatchCalcRepaymentExpectedPaymentAmt.calculateExpectedPaymentAmount(repayments);
        Test.stopTest();

        List<cmbls__Repayment__c> updatedRepayment = [SELECT Id, Expected_Payment_Amount__c
                                                      FROM cmbls__Repayment__c
                                                      WHERE cmbls__Status__c in ('Active','Pause')];  

        system.assertNotEquals(null, updatedRepayment, 'Repayment record is not found');
        system.Assert.areEqual(updatedRepayment[0].Expected_Payment_Amount__c, 45, 'Expected_Payment_Amount__c calculation is not correct');

    }
}