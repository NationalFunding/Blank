/**
 * BatchCheckACHTransactionStatusTest class
 * @author CloudMyBiz (r)
 * @date 08/02/2023
 * @description
 * @group 
 */

@IsTest
private class BatchCheckACHTransactionStatusTest {

    @TestSetup static void setupMethod(){
        Test.startTest();
        Account acc = new Account(Name = 'Test account');
        insert acc;

        List<cmbls__Repayment__c> repayments = new List<cmbls__Repayment__c>();
        cmbls__Repayment__c repayment1 = TestDataFactory.createRepayment(acc.Id);
        repayment1.cmbls__ACH_Processor__c = 'Wells Fargo Account';
        repayment1.Merchant_Number__c = '123456';
        repayments.add(repayment1);
        cmbls__Repayment__c repayment2 = TestDataFactory.createRepayment(acc.Id);
        repayment2.Merchant_Number__c = '123457';
        repayment2.cmbls__ACH_Processor__c = Constant.ACH_PROCESSOR_NF_FUNDING;
        repayments.add(repayment2);
        insert repayments;

        cmbls__ACH_Batch__c achBatch = TestDataFactory.createACHBatch('Wells Fargo Account', Constant.ACH_BATCH_STATUS_SUCCESS, DateTimeUtils.getNextValidDate(Date.today().addDays(1)));
        insert achBatch;

        cmbls__Payment__c payment = TestDataFactory.createPayment(repayment1.Id,'Debit', PaymentUtils.PAYMENT_STATUS_PRE_PENDING, 100.00, Date.today(), 'Wells Fargo Account');
        payment.cmbls__ACH_Batch__c = achBatch.Id;
        payment.cmbls__Transaction_Type__c = PaymentUtils.PAYMENT_TRANSACTION_TYPE_PAYMENT;
        insert payment;

        cmbls__Disbursement_Batch__c disBatch = TestDataFactory.createDisBatch(Constant.ACH_PROCESSOR_NF_FUNDING, 'Pending', DateTimeUtils.getNextValidDate(Date.today().addDays(1)));
        insert disBatch;

        cmbls__Disbursement__c dis = TestDataFactory.createDisbursement('Funding', Constant.STATUS_SCHEDULED, Constant.ACH_PROCESSOR_NF_FUNDING);
        dis.cmbls__Repayment__c = repayment2.Id;
        dis.cmbls__Disbursement_Batch__c = disBatch.Id;
        insert dis;

        WF_Api_Settings__c wellsFargoAPiSettings = TestDataFactory.wfSettings();
        insert wellsFargoAPiSettings;
        Test.stopTest();
    }

    @IsTest
    static void paymentProcessedStatusCheck(){
        cmbls__Payment__c payment = [SELECT Id FROM cmbls__Payment__c WHERE cmbls__Status__c = :PaymentUtils.PAYMENT_STATUS_PRE_PENDING];
        ACH_Transaction_Log__c achLog = TestDataFactory.createACHTransactionLog(payment.Id, Constant.ACH_TRANSACTION_LOG_WF_SENT);
        insert achLog;

        Test.startTest();
        String httpResp = '{"payment_status": "PROCESSED","payee_name": "JE Plumbing Services","payment_date": "20160617","payment_amount": 100.00,"trace_number": "001469807632881"}';
        Test.setMock(HttpCalloutMock.class, new ServiceConnectorMock(200, 'Status', httpResp, new Map<String,String>()));
        new BatchCheckACHTransactionStatus().execute(null);
        Test.stopTest();


        ACH_Transaction_Log__c achTransactionLog = [SELECT Id, Status__c, Response__c, Response_Code__c, ACH_Trace_Number__c FROM ACH_Transaction_Log__c WHERE Payment__c = :payment.Id AND Id !=: achLog.Id];
        System.assertEquals(achTransactionLog.Status__c, Constant.ACH_TRANSACTION_LOG_STATUS_COMPLETED);
        System.assertEquals(achTransactionLog.Response__c, httpResp);
        System.assertEquals(achTransactionLog.Response_Code__c, '200');
        System.assertEquals(achTransactionLog.ACH_Trace_Number__c, '001469807632881');

        Assert.areEqual(1, [SELECT COUNT() FROM ACH_Transaction_Log__c WHERE Status__c =: Constant.ACH_TRANSACTION_LOG_STATUS_PENDING AND Id =: achLog.Id]);
        Assert.areEqual(1, [SELECT COUNT() FROM cmbls__Payment__c WHERE cmbls__Status__c =: PaymentUtils.PAYMENT_STATUS_PRE_PENDING AND Id =: payment.Id]);
    }

    @IsTest
    static void paymentStatusPending(){

        cmbls__Payment__c payment = [SELECT Id FROM cmbls__Payment__c WHERE cmbls__Status__c = :PaymentUtils.PAYMENT_STATUS_PRE_PENDING];
        ACH_Transaction_Log__c achLog = TestDataFactory.createACHTransactionLog(payment.Id, Constant.ACH_TRANSACTION_LOG_WF_SENT);
        insert achLog;

        Test.startTest();
        String httpResp = '{"payment_status": "PENDING","payee_name": "JE Plumbing Services","payment_date": "20160617","payment_amount": 100.00}';
        Test.setMock(HttpCalloutMock.class, new ServiceConnectorMock(200, 'Status', httpResp, new Map<String,String>()));
        new BatchCheckACHTransactionStatus().execute(null);
        Test.stopTest();

        ACH_Transaction_Log__c achTransactionLog = [SELECT Id, Status__c, Response__c, Response_Code__c FROM ACH_Transaction_Log__c WHERE Payment__c = :payment.Id AND Id !=: achLog.Id];
        System.assertEquals(achTransactionLog.Status__c, Constant.ACH_TRANSACTION_LOG_STATUS_COMPLETED);
        System.assertEquals(achTransactionLog.Response__c, httpResp);
        System.assertEquals(achTransactionLog.Response_Code__c, '200');
    
        Assert.isTrue([SELECT COUNT() FROM ACH_Transaction_Log__c WHERE Status__c =: Constant.ACH_TRANSACTION_LOG_WF_SENT AND Id =: achLog.Id] == 1);
        Assert.isTrue([SELECT COUNT() FROM cmbls__Payment__c WHERE cmbls__Status__c =: PaymentUtils.PAYMENT_STATUS_PRE_PENDING AND Id =: payment.Id] == 1);
    }
    
    @IsTest
    static void paymentProcessedStatusToSettled(){
        cmbls__Payment__c payment = [SELECT Id FROM cmbls__Payment__c WHERE cmbls__Status__c = :PaymentUtils.PAYMENT_STATUS_PRE_PENDING];
        ACH_Transaction_Log__c achLog = TestDataFactory.createACHTransactionLog(payment.Id, Constant.ACH_TRANSACTION_LOG_WF_SENT);
        insert achLog;
    
        WF_Api_Settings__c settings = WF_Api_Settings__c.getInstance();
        settings.Pre_Pending_Payments_in_Settlement_Delay__c = true;
        upsert settings;
        
        Test.startTest();
        String httpResp = '{"payment_status": "PROCESSED","payee_name": "JE Plumbing Services","payment_date": "20160617","payment_amount": 100.00,"trace_number": "001469807632881"}';
        Test.setMock(HttpCalloutMock.class, new ServiceConnectorMock(200, 'Status', httpResp, new Map<String,String>()));
        new BatchCheckACHTransactionStatus().execute(null);
        Test.stopTest();
        
        ACH_Transaction_Log__c achTransactionLog = [SELECT Id, Status__c, Response__c, Response_Code__c FROM ACH_Transaction_Log__c WHERE Payment__c = :payment.Id AND Id !=: achLog.Id];
        System.assertEquals(achTransactionLog.Status__c, Constant.ACH_TRANSACTION_LOG_STATUS_COMPLETED);
        System.assertEquals(achTransactionLog.Response__c, httpResp);
        System.assertEquals(achTransactionLog.Response_Code__c, '200');
    
        Assert.isTrue([SELECT COUNT() FROM ACH_Transaction_Log__c WHERE Status__c =: Constant.ACH_TRANSACTION_LOG_STATUS_COMPLETED AND Id =: achLog.Id] == 1);
        Assert.isTrue([SELECT COUNT() FROM cmbls__Payment__c WHERE cmbls__Status__c =: PaymentUtils.PAYMENT_STATUS_SETTLED AND Id =: payment.Id] == 1);
    }

    @IsTest
    static void paymentStatusException(){

        cmbls__Payment__c payment = [SELECT Id FROM cmbls__Payment__c WHERE cmbls__Status__c = :PaymentUtils.PAYMENT_STATUS_PRE_PENDING];
        ACH_Transaction_Log__c achLog = TestDataFactory.createACHTransactionLog(payment.Id, Constant.ACH_TRANSACTION_LOG_WF_SENT);
        insert achLog;

        Test.startTest();
        String httpResp = '{"payment_status": "EXCEPTION","payee_name": "JE Plumbing Services","payment_date": "20160617","payment_amount": 100.00}';
        Test.setMock(HttpCalloutMock.class, new ServiceConnectorMock(200, 'Status', httpResp, new Map<String,String>()));
        new BatchCheckACHTransactionStatus().execute(null);
        Test.stopTest();

        ACH_Transaction_Log__c achTransactionLog = [SELECT Id, Status__c, Response__c, Response_Code__c FROM ACH_Transaction_Log__c WHERE Payment__c = :payment.Id AND Id !=: achLog.Id];
        System.assertEquals(achTransactionLog.Status__c, Constant.ACH_TRANSACTION_LOG_STATUS_FAILED);
        System.assertEquals(achTransactionLog.Response__c, httpResp);
        System.assertEquals(achTransactionLog.Response_Code__c, '200');
        
        System.debug([SELECT Status__c FROM ACH_Transaction_Log__c WHERE Id =: achLog.Id]);
    
        Assert.isTrue([SELECT COUNT() FROM ACH_Transaction_Log__c WHERE Status__c =: Constant.ACH_TRANSACTION_LOG_WF_SENT AND Id =: achLog.Id] == 1);
        Assert.isTrue([SELECT COUNT() FROM cmbls__Payment__c WHERE cmbls__Status__c =: PaymentUtils.PAYMENT_STATUS_PRE_PENDING AND Id =: payment.Id] == 1);
    }

    @IsTest
    static void calloutFailure(){

        cmbls__Payment__c payment = [SELECT Id FROM cmbls__Payment__c WHERE cmbls__Status__c = :PaymentUtils.PAYMENT_STATUS_PRE_PENDING];
        ACH_Transaction_Log__c achLog = TestDataFactory.createACHTransactionLog(payment.Id, Constant.ACH_TRANSACTION_LOG_WF_SENT);
        insert achLog;

        Test.startTest();
        String httpResp = '';
        Test.setMock(HttpCalloutMock.class, new ServiceConnectorMock(500, 'Status', httpResp, new Map<String,String>()));
        new BatchCheckACHTransactionStatus().execute(null);
        Test.stopTest();

        ACH_Transaction_Log__c achTransactionLog = [SELECT Id, Status__c, Response__c, Response_Code__c FROM ACH_Transaction_Log__c WHERE Payment__c = :payment.Id AND Id !=: achLog.Id];
        System.assertEquals(Constant.ACH_TRANSACTION_LOG_STATUS_COMPLETED, achTransactionLog.Status__c);
        System.assertEquals(achTransactionLog.Response_Code__c, '500');
    }

}