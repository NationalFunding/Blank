/**
 * PaymentSelectorTest class
 * @author CloudMyBiz (r)
 * @date 9/7/2022
 * @description
 * @group 
 */

@IsTest
private class PaymentSelectorTest{
    
    @TestSetup static void setupMethod(){
        Test.startTest();
        Account acc = TestDataFactory.createAccount();
        insert acc;
    
        Bank_Account__c bankAccount = TestDataFactory.createBankAccount();
        insert bankAccount;
    
        Opportunity opp = TestDataFactory.createOpportunity(acc.Id);
        insert opp;
    
        cmbls__Repayment__c repayment = TestDataFactory.createRepayment(acc.Id);
        insert repayment;
    
        cmbls__ACH_Batch__c achBatch = TestDataFactory.createACHBatch('Wells Fargo Account', Constant.ACH_BATCH_STATUS_SUCCESS, DateTimeUtils.getNextValidDate(Date.today().addDays(1)));
        insert achBatch;
    
        cmbls__Payment__c[] payments = new cmbls__Payment__c[]{
            TestDataFactory.createPayment(repayment.Id, PaymentUtils.PAYMENT_RECORD_TYPE_CREDIT, PaymentUtils.PAYMENT_STATUS_SCHEDULED, 100, Date.today(), achBatch.cmbls__ACH_Provider_Name__c),
            TestDataFactory.createPayment(repayment.Id, PaymentUtils.PAYMENT_RECORD_TYPE_CREDIT, PaymentUtils.PAYMENT_STATUS_SCHEDULED, 500, Date.today(), achBatch.cmbls__ACH_Provider_Name__c),
            TestDataFactory.createPayment(repayment.Id, PaymentUtils.PAYMENT_RECORD_TYPE_DEBIT, PaymentUtils.PAYMENT_STATUS_PENDING, 1600, Date.today(), achBatch.cmbls__ACH_Provider_Name__c),
            TestDataFactory.createPayment(repayment.Id, PaymentUtils.PAYMENT_RECORD_TYPE_DEBIT, PaymentUtils.PAYMENT_STATUS_PENDING, 1200, Date.today(), achBatch.cmbls__ACH_Provider_Name__c),
            TestDataFactory.createPayment(repayment.Id, PaymentUtils.PAYMENT_RECORD_TYPE_DEBIT, PaymentUtils.PAYMENT_STATUS_SETTLED, 1200, Date.today(), achBatch.cmbls__ACH_Provider_Name__c)
        };
        payments[0]. cmbls__Transaction_Type__c = PaymentUtils.PAYMENT_TRANSACTION_TYPE_PAYMENT;
        payments[1]. cmbls__Transaction_Type__c = PaymentUtils.PAYMENT_TRANSACTION_TYPE_PAYMENT;
        payments[2].cmbls__Interest_Payment_Amt__c = payments[2].cmbls__Transaction_Amount__c;
        payments[3].cmbls__Interest_Payment_Amt__c = payments[3].cmbls__Transaction_Amount__c;
        payments[4].cmbls__Interest_Payment_Amt__c = payments[4].cmbls__Transaction_Amount__c;
        insert payments;
        Test.stopTest();
    }
    
    @IsTest
    static void queries(){
        cmbls__Repayment__c repayment = [SELECT Id FROM cmbls__Repayment__c];
        
        Test.startTest();
        Map<Id, cmbls__Payment__c[]> scheduled = PaymentSelector.getScheduledCreditPaymentsByRepaymentIds(new Set<Id>{repayment.Id});
        System.assertEquals(2, scheduled.get(repayment.Id).size());
        
        cmbls__Payment__c single = PaymentSelector.getPaymentById(scheduled.get(repayment.Id)[0].Id);
        System.assertNotEquals(null, single);
    
        Map<Id, Decimal> sumPending = PaymentSelector.getSumPendingDebitPaymentsByRepayment(new Set<Id>{repayment.Id});
        System.assertEquals(2800, sumPending.get(repayment.Id));
    
        Map<Id, Decimal> sumPendingSettled = PaymentSelector.getSumPendingSettledDebitPaymentsByRepayment(new Set<Id>{repayment.Id});
        System.assertEquals(4000, sumPendingSettled.get(repayment.Id));
    
        Test.stopTest();
    }
}