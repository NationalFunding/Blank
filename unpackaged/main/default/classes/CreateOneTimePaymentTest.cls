/**
 * CreateOneTimePaymentTest class
 * @author CloudMyBiz (r)
 * @date 3/24/2022
 * @description
 * @group 
 */

@IsTest
private class CreateOneTimePaymentTest{
    
    @TestSetup static void setupMethod(){
        Account acc = TestDataFactory.createAccount();
        insert acc;
    
        cmbls__Repayment__c repayment = TestDataFactory.createRepayment(acc.Id);
        insert repayment;
    }
    
    @IsTest
    static void mainInvocableMethod(){
        cmbls__Repayment__c repayment = [SELECT Id FROM cmbls__Repayment__c];
        delete [SELECT Id FROM cmbls__Payment__c];
        CreateOneTimePayment.CreateRequest mainRequest = new CreateOneTimePayment.CreateRequest();
        mainRequest.repaymentId = repayment.Id;
        mainRequest.effectiveDate = System.today().addDays(15);
        mainRequest.transactionAmount = 2000;
        mainRequest.subType = 'Adjustment';
        mainRequest.achProcessor = 'ACH.com';
        mainRequest.notes = 'Test Notes';
        
        Test.startTest();
        CreateOneTimePayment.CreateResult[] results = CreateOneTimePayment.mainInvocableMethod(new CreateOneTimePayment.CreateRequest[]{mainRequest});
        System.assertEquals(1, results.size());
        System.assertEquals(true, results[0].success);
        Test.stopTest();
        
        cmbls__Payment__c record = [SELECT Id, cmbls__Repayment__c, RecordTypeId, cmbls__Effective_Date__c, cmbls__Transaction_Type__c, cmbls__Transaction_Amount__c, cmbls__Sub_Type__c, cmbls__Payment_Method__c, cmbls__ACH_Processor__c, cmbls__Notes__c FROM cmbls__Payment__c WHERE cmbls__Repayment__c = :repayment.Id];
        System.assertEquals(record.Id, results[0].output);
        System.assertEquals(mainRequest.repaymentId, record.cmbls__Repayment__c);
        System.assertEquals(mainRequest.effectiveDate, record.cmbls__Effective_Date__c);
        System.assertEquals(mainRequest.transactionAmount, record.cmbls__Transaction_Amount__c);
        System.assertEquals(mainRequest.subType, record.cmbls__Sub_Type__c);
        System.assertEquals(mainRequest.achProcessor, record.cmbls__ACH_Processor__c);
        System.assertEquals(mainRequest.notes, record.cmbls__Notes__c);
    
        System.assertEquals(PaymentUtils.PAYMENT_RECORD_TYPE_DEBIT_ID, record.RecordTypeId);
        System.assertEquals(PaymentUtils.PAYMENT_TRANSACTION_TYPE_PAYMENT, record.cmbls__Transaction_Type__c);
        System.assertEquals(PaymentUtils.PAYMENT_METHOD_ACH, record.cmbls__Payment_Method__c);
    }
    
    @IsTest
    static void mainInvocableMethodError(){
        cmbls__Repayment__c repayment = [SELECT Id FROM cmbls__Repayment__c];
        delete [SELECT Id FROM cmbls__Payment__c];
        CreateOneTimePayment.CreateRequest mainRequest = new CreateOneTimePayment.CreateRequest();
        mainRequest.repaymentId = repayment.Id;
        
        Test.startTest();
        CreateOneTimePayment.CreateResult[] results = CreateOneTimePayment.mainInvocableMethod(new CreateOneTimePayment.CreateRequest[]{mainRequest});
        System.assertEquals(1, results.size());
        System.assertEquals(false, results[0].success);
        System.assert(results[0].output.contains('REQUIRED_FIELD_MISSING'));
        Test.stopTest();
        
        System.assertEquals(0, [SELECT COUNT() FROM cmbls__Payment__c WHERE cmbls__Repayment__c = :repayment.Id]);
    }
    
    @IsTest
    static void mainInvocableMethodNoProcessor(){
        cmbls__Repayment__c repayment = [SELECT Id, cmbls__ACH_Processor__c FROM cmbls__Repayment__c];
        delete [SELECT Id FROM cmbls__Payment__c];
        CreateOneTimePayment.CreateRequest mainRequest = new CreateOneTimePayment.CreateRequest();
        mainRequest.repaymentId = repayment.Id;
        mainRequest.effectiveDate = System.today().addDays(15);
        mainRequest.transactionAmount = 2000;
        mainRequest.subType = 'Adjustment';
        mainRequest.notes = 'Test Notes';
        
        Test.startTest();
        CreateOneTimePayment.CreateResult[] results = CreateOneTimePayment.mainInvocableMethod(new CreateOneTimePayment.CreateRequest[]{mainRequest});
        System.assertEquals(1, results.size());
        System.assertEquals(true, results[0].success);
        Test.stopTest();
        
        cmbls__Payment__c record = [SELECT Id, cmbls__Repayment__c, RecordTypeId, cmbls__Effective_Date__c, cmbls__Transaction_Type__c, cmbls__Transaction_Amount__c, cmbls__Sub_Type__c, cmbls__Payment_Method__c, cmbls__ACH_Processor__c, cmbls__Notes__c FROM cmbls__Payment__c WHERE cmbls__Repayment__c = :repayment.Id];
        System.assertEquals(record.Id, results[0].output);
        System.assertEquals(mainRequest.repaymentId, record.cmbls__Repayment__c);
        System.assertEquals(mainRequest.effectiveDate, record.cmbls__Effective_Date__c);
        System.assertEquals(mainRequest.transactionAmount, record.cmbls__Transaction_Amount__c);
        System.assertEquals(mainRequest.subType, record.cmbls__Sub_Type__c);
        System.assertEquals(repayment.cmbls__ACH_Processor__c, record.cmbls__ACH_Processor__c);
        System.assertEquals(mainRequest.notes, record.cmbls__Notes__c);
        
        System.assertEquals(PaymentUtils.PAYMENT_RECORD_TYPE_DEBIT_ID, record.RecordTypeId);
        System.assertEquals(PaymentUtils.PAYMENT_TRANSACTION_TYPE_PAYMENT, record.cmbls__Transaction_Type__c);
        System.assertEquals(PaymentUtils.PAYMENT_METHOD_ACH, record.cmbls__Payment_Method__c);
    }
}