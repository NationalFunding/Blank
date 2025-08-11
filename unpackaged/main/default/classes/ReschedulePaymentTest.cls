/**
 * ReschedulePaymentTest class
 * @author CloudMyBiz (r)
 * @date 3/24/2022
 * @description
 * @group 
 */

@IsTest
private class ReschedulePaymentTest{
    
    @TestSetup static void setupMethod(){
        Test.startTest();
        Account acc = TestDataFactory.createAccount();
        insert acc;
    
        cmbls__Repayment__c repayment = TestDataFactory.createRepayment(acc.Id);
        insert repayment;
    
        delete [SELECT Id FROM cmbls__Payment__c];
    
        insert new cmbls__Payment__c(
            cmbls__Repayment__c = repayment.Id,
            RecordTypeId = PaymentUtils.PAYMENT_RECORD_TYPE_CREDIT_ID,
            cmbls__Effective_Date__c = System.today().addDays(1),
            cmbls__Transaction_Type__c = PaymentUtils.PAYMENT_TRANSACTION_TYPE_PAYMENT,
            cmbls__Sub_Type__c = 'Adjustment',
            cmbls__Transaction_Amount__c = 4000,
            cmbls__Status__c = PaymentUtils.PAYMENT_STATUS_SCHEDULED,
            cmbls__Payment_Method__c = PaymentUtils.PAYMENT_METHOD_ACH,
            cmbls__ACH_Processor__c = 'ACH.com'
        );
        Test.stopTest();
    }

    @IsTest
    static void mainInvocableMethod(){
        cmbls__Repayment__c repayment = [SELECT Id, (SELECT Id FROM cmbls__Payments__r LIMIT 1) FROM cmbls__Repayment__c];
        ReschedulePayment.RescheduleRequest mainRequest = new ReschedulePayment.RescheduleRequest();
        mainRequest.paymentId = repayment.cmbls__Payments__r[0].Id;
        mainRequest.effectiveDate = System.today().addDays(10);
        mainRequest.notes = 'Test Notes';
    
        Test.startTest();
        ReschedulePayment.RescheduleResult[] results = ReschedulePayment.mainInvocableMethod(new ReschedulePayment.RescheduleRequest[]{mainRequest});
        System.assertEquals(1, results.size());
        System.assertEquals(true, results[0].success);
        Test.stopTest();
        
        cmbls__Payment__c newPayment = [SELECT Id, cmbls__Status__c, cmbls__Effective_Date__c, cmbls__Notes__c, cmbls__Repayment__c, Payment__c FROM cmbls__Payment__c WHERE Id != :repayment.cmbls__Payments__r[0].Id];
        System.assertEquals(PaymentUtils.PAYMENT_STATUS_SCHEDULED, newPayment.cmbls__Status__c);
        System.assertEquals(mainRequest.notes, newPayment.cmbls__Notes__c);
        System.assertEquals(repayment.Id, newPayment.cmbls__Repayment__c);
        System.assertEquals(mainRequest.effectiveDate, newPayment.cmbls__Effective_Date__c);
        System.assertEquals(repayment.cmbls__Payments__r[0].Id, newPayment.Payment__c);
        
        cmbls__Payment__c oldPayment = [SELECT Id, cmbls__Status__c, cmbls__Notes__c FROM cmbls__Payment__c WHERE Id = :repayment.cmbls__Payments__r[0].Id];
        System.assertEquals(PaymentUtils.PAYMENT_STATUS_CANCELED, oldPayment.cmbls__Status__c);
        System.assertEquals(mainRequest.notes, oldPayment.cmbls__Notes__c);
        
        String successMessage = String.format(ReschedulePayment.SUCCESS_MESSAGE, new String[]{oldPayment.Id, newPayment.Id});
        System.assertEquals(successMessage, results[0].output);
    }
    
    @IsTest
    static void mainInvocableMethodError(){
        cmbls__Repayment__c repayment = [SELECT Id, (SELECT Id FROM cmbls__Payments__r LIMIT 1) FROM cmbls__Repayment__c];
        ReschedulePayment.RescheduleRequest mainRequest = new ReschedulePayment.RescheduleRequest();
        mainRequest.paymentId = repayment.cmbls__Payments__r[0].Id;
        mainRequest.effectiveDate = System.today().addDays(10);
        mainRequest.notes = 'Test Notes';
        
        update new cmbls__Payment__c(Id = repayment.cmbls__Payments__r[0].Id, cmbls__Status__c = PaymentUtils.PAYMENT_STATUS_CANCELED);
    
        Test.startTest();
        ReschedulePayment.RescheduleResult[] results = ReschedulePayment.mainInvocableMethod(new ReschedulePayment.RescheduleRequest[]{mainRequest});
        System.assertEquals(1, results.size());
        System.assertEquals(false, results[0].success);
        Test.stopTest();
        
        System.assertEquals(1, [SELECT COUNT() FROM cmbls__Payment__c WHERE cmbls__Repayment__c = :repayment.Id]);
        cmbls__Payment__c oldPayment = [SELECT Id, cmbls__Status__c, Name, cmbls__Notes__c FROM cmbls__Payment__c WHERE Id = :repayment.cmbls__Payments__r[0].Id];
        System.assertEquals(PaymentUtils.PAYMENT_STATUS_CANCELED, oldPayment.cmbls__Status__c);
        System.assertEquals(null, oldPayment.cmbls__Notes__c);
    
        String outputMessage = String.format(ReschedulePayment.NOT_SCHEDULED_ERROR_MESSAGE, new String[]{oldPayment.Name, oldPayment.cmbls__Status__c});
        System.assertEquals(String.format(ReschedulePayment.ERROR_MESSAGE, new String[]{outputMessage}), results[0].output);
    }
}