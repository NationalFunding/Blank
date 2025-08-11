/**
 * PaymentsBatchProcessorTest class
 * @author CloudMyBiz (r)
 * @date 05/08/2022
 * @description
 * @group 
 */

@IsTest
private class PaymentsBatchProcessorTest {

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

        cmbls__ACH_Batch__c achBatch = TestDataFactory.createACHBatch('Wells Fargo Account', 'Pending', DateTimeUtils.getNextValidDate(Date.today().addDays(1)));
        insert achBatch;
    
        cmbls__Payment__c[] payments = new cmbls__Payment__c[]{
            TestDataFactory.createPayment(repayment1.Id,'Debit', 'Scheduled', 100.00, Date.today(), 'Wells Fargo Account'),
            TestDataFactory.createPayment(repayment1.Id,'Debit', 'Scheduled', 100.00, Date.today(), 'Wells Fargo Account')
        };
        
        payments[0].cmbls__ACH_Batch__c = achBatch.Id;
        payments[0].cmbls__Transaction_Type__c = PaymentUtils.PAYMENT_TRANSACTION_TYPE_PAYMENT;
        payments[1].cmbls__ACH_Batch__c = achBatch.Id;
        payments[1].cmbls__Transaction_Type__c = PaymentUtils.PAYMENT_TRANSACTION_TYPE_PAYMENT;
        insert payments;

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
    static void paymentsToWellsFargoSuccess(){
        Test.startTest();
        String httpResp = '{"access_token": "TKWJGRwlSR1R5PWZLpKLU2hIpUM4","scope": "ACH-Payments ACH-Payments-Status WBHK-Webhooks WBHK-TEST-Events am_application_scope","token_type": "Bearer","expires_in": 86400}';
        Test.setMock(HttpCalloutMock.class, new ServiceConnectorMock(201, 'Status', httpResp, new Map<String,String>()));
        PaymentsBatchProcessor.PROCESS_ACH_TRANSACTIONS_BATCH = false;
        PaymentsSchedulerProcessor ps = new PaymentsSchedulerProcessor(WellsFargoAPI.PAYMENTS_PROCESS);
        ps.execute(null);
        Test.stopTest();

        cmbls__Payment__c pay = [SELECT Id, cmbls__ACH_Batch__c FROM cmbls__Payment__c ORDER BY CreatedDate DESC LIMIT 1];
        ACH_Transaction_Log__c achTransactionLog = [SELECT Id, Status__c, Response__c, Response_Code__c FROM ACH_Transaction_Log__c WHERE Payment__c = :pay.Id];
        System.assertEquals(achTransactionLog.Status__c, Constant.ACH_TRANSACTION_LOG_WF_SENT);
        System.assertEquals(achTransactionLog.Response__c, httpResp);
        System.assertEquals(achTransactionLog.Response_Code__c, '201');

        cmbls__ACH_Batch__c achBatch = [SELECT cmbls__Status__c FROM cmbls__ACH_Batch__c WHERE Id =: pay.cmbls__ACH_Batch__c];
        System.assertEquals(Constant.ACH_BATCH_STATUS_SUCCESS, achBatch.cmbls__Status__c);
    }

    @IsTest
    static void paymentsResubmission(){
        Test.startTest();
        
        WellsFargoAPI.WF_Settings.Error_Codes_To_Resubmit_Request__c = '500*;401*;429*;504-001;520*';
        upsert WellsFargoAPI.WF_Settings;

        WellsFargo.WFErrors serviceErrors = new WellsFargo.WFErrors();
        serviceErrors.errors = new List<WellsFargo.Error>();
        WellsFargo.Error respError = new WellsFargo.Error();
        respError.error_code = '500-001';
        respError.description = 'Internal System error.';
        serviceErrors.errors.add(respError);

        String httpResp = JSON.serialize(serviceErrors);
        Test.setMock(HttpCalloutMock.class, new ServiceConnectorMock(500, 'Status', httpResp, new Map<String,String>()));
        PaymentsBatchProcessor.PROCESS_ACH_TRANSACTIONS_BATCH = false;
        PaymentsSchedulerProcessor ps = new PaymentsSchedulerProcessor(WellsFargoAPI.PAYMENTS_PROCESS);
        ps.execute(null);
        Test.stopTest();

        cmbls__Payment__c pay = [SELECT Id, cmbls__ACH_Batch__c FROM cmbls__Payment__c ORDER BY CreatedDate DESC LIMIT 1];
        List<ACH_Transaction_Log__c> achTransactionLogs = [SELECT Id, Status__c, Response__c, Error_Code__c, Response_Code__c FROM ACH_Transaction_Log__c WHERE Payment__c = :pay.Id];
        System.assertEquals(1, achTransactionLogs.size());
        System.assertEquals(Constant.ACH_TRANSACTION_LOG_STATUS_COMPLETED, achTransactionLogs[0].Status__c);
        System.assertEquals(achTransactionLogs[0].Response__c, httpResp);
        System.assertEquals(achTransactionLogs[0].Error_Code__c, '500-001');
        System.assertEquals(achTransactionLogs[0].Response_Code__c, '500');

        cmbls__ACH_Batch__c resubmissionBatch = [SELECT cmbls__Status__c, WellsFargo_Number_of_Attempts__c, cmbls__Number_of_Failed_Payments__c FROM cmbls__ACH_Batch__c WHERE Id =: pay.cmbls__ACH_Batch__c];
        System.assertEquals(Constant.ACH_BATCH_STATUS_RESUBMISSION, resubmissionBatch.cmbls__Status__c);
        System.assertEquals(1, resubmissionBatch.WellsFargo_Number_of_Attempts__c);
        System.assertEquals(0, resubmissionBatch.cmbls__Number_of_Failed_Payments__c);
    }
    
    @IsTest
    static void paymentsResubmission2(){
        Test.startTest();
        
        WellsFargoAPI.WF_Settings.Error_Codes_To_Resubmit_Request__c = '500*;401*;429*;504-001;520*';
        upsert WellsFargoAPI.WF_Settings;
        
        WellsFargo.WFErrors serviceErrors = new WellsFargo.WFErrors();
        serviceErrors.errors = new List<WellsFargo.Error>();
        WellsFargo.Error respError = new WellsFargo.Error();
        respError.error_code = '401-002';
        respError.description = 'API key missing';
        serviceErrors.errors.add(respError);
        
        String httpResp = JSON.serialize(serviceErrors);
        Test.setMock(HttpCalloutMock.class, new ServiceConnectorMock(401, 'Status', httpResp, new Map<String,String>()));
        PaymentsBatchProcessor.PROCESS_ACH_TRANSACTIONS_BATCH = false;
        PaymentsSchedulerProcessor ps = new PaymentsSchedulerProcessor(WellsFargoAPI.PAYMENTS_PROCESS);
        ps.execute(null);
        Test.stopTest();
        
        cmbls__Payment__c pay = [SELECT Id, cmbls__ACH_Batch__c FROM cmbls__Payment__c ORDER BY CreatedDate DESC LIMIT 1];
        List<ACH_Transaction_Log__c> achTransactionLogs = [SELECT Id, Status__c, Response__c, Error_Code__c, Response_Code__c FROM ACH_Transaction_Log__c WHERE Payment__c = :pay.Id];
        System.assertEquals(1, achTransactionLogs.size());
        System.assertEquals(Constant.ACH_TRANSACTION_LOG_STATUS_COMPLETED, achTransactionLogs[0].Status__c);
        System.assertEquals(achTransactionLogs[0].Response__c, httpResp);
        System.assertEquals(achTransactionLogs[0].Error_Code__c, '401-002');
        System.assertEquals(achTransactionLogs[0].Response_Code__c, '401');
        
        cmbls__ACH_Batch__c resubmissionBatch = [SELECT cmbls__Status__c, WellsFargo_Number_of_Attempts__c, cmbls__Number_of_Failed_Payments__c FROM cmbls__ACH_Batch__c WHERE Id =: pay.cmbls__ACH_Batch__c];
        System.assertEquals(Constant.ACH_BATCH_STATUS_RESUBMISSION, resubmissionBatch.cmbls__Status__c);
        System.assertEquals(1, resubmissionBatch.WellsFargo_Number_of_Attempts__c);
        System.assertEquals(0, resubmissionBatch.cmbls__Number_of_Failed_Payments__c);
    }
    
    @IsTest
    static void paymentsResubmissionTimedOut(){
        Test.startTest();
        
        WellsFargoAPI.WF_Settings.Error_Codes_To_Resubmit_Request__c = '';
        upsert WellsFargoAPI.WF_Settings;
        
        Test.setMock(HttpCalloutMock.class, new ServiceConnectorMock(null, '', 'Exceeded maximum time allotted for callout (120000 ms)', new Map<String,String>()));
        PaymentsBatchProcessor.PROCESS_ACH_TRANSACTIONS_BATCH = false;
        PaymentsSchedulerProcessor ps = new PaymentsSchedulerProcessor(WellsFargoAPI.PAYMENTS_PROCESS);
        ps.execute(null);
        Test.stopTest();
        
        cmbls__Payment__c pay = [SELECT Id, cmbls__ACH_Batch__c, cmbls__Status__c FROM cmbls__Payment__c ORDER BY CreatedDate DESC LIMIT 1];
        List<ACH_Transaction_Log__c> achTransactionLogs = [SELECT Id, Status__c, Response__c, Error_Code__c FROM ACH_Transaction_Log__c WHERE Payment__c = :pay.Id];
        System.assertEquals(1, achTransactionLogs.size());
        System.assertEquals(Constant.ACH_TRANSACTION_LOG_STATUS_COMPLETED, achTransactionLogs[0].Status__c);
        System.assertEquals('Exceeded maximum time allotted for callout (120000 ms)', achTransactionLogs[0].Response__c);
        System.assertEquals(null, achTransactionLogs[0].Error_Code__c);
        System.assertEquals(PaymentUtils.PAYMENT_STATUS_SCHEDULED, pay.cmbls__Status__c);
        
        cmbls__ACH_Batch__c resubmissionBatch = [SELECT cmbls__Status__c, WellsFargo_Number_of_Attempts__c, cmbls__Number_of_Failed_Payments__c FROM cmbls__ACH_Batch__c WHERE Id =: pay.cmbls__ACH_Batch__c];
        System.assertEquals(Constant.ACH_BATCH_STATUS_RESUBMISSION, resubmissionBatch.cmbls__Status__c);
        System.assertEquals(1, resubmissionBatch.WellsFargo_Number_of_Attempts__c);
        System.assertEquals(0, resubmissionBatch.cmbls__Number_of_Failed_Payments__c);
    }
    
    @IsTest
    static void paymentsDuplicate(){
        Test.startTest();
        
        WellsFargoAPI.WF_Settings.Error_Codes_To_Resubmit_Request__c = '';
        upsert WellsFargoAPI.WF_Settings;
        
        WellsFargo.WFErrors serviceErrors = new WellsFargo.WFErrors();
        serviceErrors.errors = new List<WellsFargo.Error>();
        WellsFargo.Error respError = new WellsFargo.Error();
        respError.error_code = '1003-001';
        respError.description = 'Duplicate payment ID, transaction not processed.';
        serviceErrors.errors.add(respError);
        
        String httpResp = JSON.serialize(serviceErrors);
        
        Test.setMock(HttpCalloutMock.class, new ServiceConnectorMock(400, '', httpResp, new Map<String,String>()));
        PaymentsBatchProcessor.PROCESS_ACH_TRANSACTIONS_BATCH = false;
        PaymentsSchedulerProcessor ps = new PaymentsSchedulerProcessor(WellsFargoAPI.PAYMENTS_PROCESS);
        ps.execute(null);
        Test.stopTest();
        
        cmbls__Payment__c pay = [SELECT Id, cmbls__ACH_Batch__c, cmbls__Status__c FROM cmbls__Payment__c ORDER BY CreatedDate DESC LIMIT 1];
        List<ACH_Transaction_Log__c> achTransactionLogs = [SELECT Id, Status__c, Response__c, Error_Code__c, Response_Code__c FROM ACH_Transaction_Log__c WHERE Payment__c = :pay.Id];
        System.assertEquals(1, achTransactionLogs.size());
        System.assertEquals(Constant.ACH_TRANSACTION_LOG_WF_SENT, achTransactionLogs[0].Status__c);
        System.assertEquals(httpResp, achTransactionLogs[0].Response__c);
        System.assertEquals(respError.error_code, achTransactionLogs[0].Error_Code__c);
        System.assertEquals('201', achTransactionLogs[0].Response_Code__c);
        System.assertEquals(PaymentUtils.PAYMENT_STATUS_PRE_PENDING, pay.cmbls__Status__c);
        
        cmbls__ACH_Batch__c resubmissionBatch = [SELECT cmbls__Status__c, WellsFargo_Number_of_Attempts__c, cmbls__Number_of_Failed_Payments__c FROM cmbls__ACH_Batch__c WHERE Id =: pay.cmbls__ACH_Batch__c];
        System.assertEquals(Constant.ACH_BATCH_STATUS_SUCCESS, resubmissionBatch.cmbls__Status__c);
        System.assertEquals(1, resubmissionBatch.WellsFargo_Number_of_Attempts__c);
        System.assertEquals(0, resubmissionBatch.cmbls__Number_of_Failed_Payments__c);
    }

    @IsTest
    static void batchNumberOfAttemptsReached(){
        cmbls__Payment__c pay = [SELECT Id, cmbls__ACH_Batch__c FROM cmbls__Payment__c ORDER BY CreatedDate DESC LIMIT 1];
        update new cmbls__ACH_Batch__c(Id = pay.cmbls__ACH_Batch__c, WellsFargo_Number_of_Attempts__c = 1);
        
        WellsFargoAPI.WF_Settings.Error_Codes_To_Resubmit_Request__c = '500*;401*;429*;504-001;520*';
        WellsFargoAPI.WF_Settings.Max_Number_of_attempts__c = 2;
        upsert WellsFargoAPI.WF_Settings;

        WellsFargo.WFErrors serviceErrors = new WellsFargo.WFErrors();
        serviceErrors.errors = new List<WellsFargo.Error>();
        WellsFargo.Error respError = new WellsFargo.Error();
        respError.error_code = '500-001';
        respError.description = 'Internal System error.';
        serviceErrors.errors.add(respError);

        String httpResp = JSON.serialize(serviceErrors);
        Test.setMock(HttpCalloutMock.class, new ServiceConnectorMock(500, 'Status', httpResp, new Map<String,String>()));

        Test.startTest();
        PaymentsBatchProcessor.PROCESS_ACH_TRANSACTIONS_BATCH = false;
        PaymentsSchedulerProcessor ps = new PaymentsSchedulerProcessor(WellsFargoAPI.PAYMENTS_PROCESS);
        ps.execute(null);
        Test.stopTest();

        List<ACH_Transaction_Log__c> achTransactionLogs = [SELECT Id, Status__c, Response__c, Error_Code__c, Response_Code__c FROM ACH_Transaction_Log__c WHERE Payment__c = :pay.Id];
        System.assertEquals(1, achTransactionLogs.size());
        System.assertEquals(Constant.ACH_TRANSACTION_LOG_STATUS_COMPLETED, achTransactionLogs[0].Status__c);
        System.assertEquals(achTransactionLogs[0].Response__c, httpResp);
        System.assertEquals(achTransactionLogs[0].Error_Code__c, '500-001');
        System.assertEquals(achTransactionLogs[0].Response_Code__c, '500');

        cmbls__ACH_Batch__c resubmissionBatch = [SELECT cmbls__Status__c, WellsFargo_Number_of_Attempts__c, cmbls__Number_of_Failed_Payments__c FROM cmbls__ACH_Batch__c WHERE Id =: pay.cmbls__ACH_Batch__c];
        System.assertEquals(Constant.ACH_BATCH_STATUS_SUCCESS, resubmissionBatch.cmbls__Status__c);
        System.assertEquals(2, resubmissionBatch.WellsFargo_Number_of_Attempts__c);
    }

    @IsTest
    static void batchNumberOfAttemptsReachedNotSkipTransactionsBatch(){
        cmbls__Payment__c pay = [SELECT Id, cmbls__ACH_Batch__c FROM cmbls__Payment__c ORDER BY CreatedDate DESC LIMIT 1];
        update new cmbls__ACH_Batch__c(Id = pay.cmbls__ACH_Batch__c, WellsFargo_Number_of_Attempts__c = 1);
    
        WellsFargoAPI.WF_Settings.Error_Codes_To_Resubmit_Request__c = '';
        upsert WellsFargoAPI.WF_Settings;

        WellsFargo.WFErrors serviceErrors = new WellsFargo.WFErrors();
        serviceErrors.errors = new List<WellsFargo.Error>();
        WellsFargo.Error respError = new WellsFargo.Error();
        respError.error_code = '500-001';
        respError.description = 'Internal System error.';
        serviceErrors.errors.add(respError);

        String httpResp = JSON.serialize(serviceErrors);
        Test.setMock(HttpCalloutMock.class, new ServiceConnectorMock(500, 'Status', httpResp, new Map<String,String>()));

        Test.startTest();
        PaymentsSchedulerProcessor ps = new PaymentsSchedulerProcessor(WellsFargoAPI.PAYMENTS_PROCESS);
        ps.execute(null);
        Test.stopTest();

        pay = [SELECT Id, cmbls__ACH_Batch__c, cmbls__Status__c FROM cmbls__Payment__c ORDER BY CreatedDate DESC LIMIT 1];
        List<ACH_Transaction_Log__c> achTransactionLogs = [SELECT Id, Status__c, Response__c, Error_Code__c, Response_Code__c FROM ACH_Transaction_Log__c WHERE Payment__c = :pay.Id ORDER BY CreatedDate DESC];
        System.assertEquals(Constant.ACH_TRANSACTION_LOG_STATUS_COMPLETED, achTransactionLogs[0].Status__c);
        System.assertEquals(Constant.STATUS_FAILED, pay.cmbls__Status__c);

        cmbls__ACH_Batch__c resubmissionBatch = [SELECT cmbls__Status__c, WellsFargo_Number_of_Attempts__c, cmbls__Number_of_Failed_Payments__c FROM cmbls__ACH_Batch__c WHERE Id =: pay.cmbls__ACH_Batch__c];
        System.assertEquals(Constant.ACH_BATCH_STATUS_SUCCESS, resubmissionBatch.cmbls__Status__c);
        System.assertEquals(2, resubmissionBatch.WellsFargo_Number_of_Attempts__c);
        System.assertEquals(2, resubmissionBatch.cmbls__Number_of_Failed_Payments__c);
    }

    @IsTest
    static void paymentsError(){
        String responseBody = '{"errors":[{"error_code":"1003-002","description":"Payer Bank ID failed checksum and is invalid","api_specification_url":"https://developer.wellsfargo.com"}]}';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ServiceConnectorMock(400, 'Status', responseBody, new Map<String,String>()));
        PaymentsSchedulerProcessor ps = new PaymentsSchedulerProcessor(WellsFargoAPI.PAYMENTS_PROCESS);
        ps.execute(null);
        Test.stopTest();

        cmbls__Payment__c pay = [SELECT Id, cmbls__ACH_Batch__c, cmbls__ACH_Batch__r.cmbls__Status__c, cmbls__Status__c FROM cmbls__Payment__c ORDER BY CreatedDate DESC LIMIT 1];
        ACH_Transaction_Log__c achTransactionLog = [SELECT Id, Status__c, Response__c, Response_Code__c, Error_Code__c FROM ACH_Transaction_Log__c WHERE Payment__c = :pay.Id];
        System.assertEquals(Constant.ACH_TRANSACTION_LOG_STATUS_COMPLETED, achTransactionLog.Status__c);
        System.assertEquals(responseBody, achTransactionLog.Response__c);
        System.assertEquals('400', achTransactionLog.Response_Code__c);
        System.assertEquals('1003-002', achTransactionLog.Error_Code__c);
        System.assertEquals(PaymentUtils.PAYMENT_STATUS_FAILED, pay.cmbls__Status__c);

        System.assertEquals(Constant.ACH_BATCH_STATUS_SUCCESS, pay.cmbls__ACH_Batch__r.cmbls__Status__c);
    }
    
    @IsTest
    static void disbursementsToWellsFargoSuccess(){
        Test.startTest();
        String httpResp = '{"access_token": "TKWJGRwlSR1R5PWZLpKLU2hIpUM4","scope": "ACH-Payments ACH-Payments-Status WBHK-Webhooks WBHK-TEST-Events am_application_scope","token_type": "Bearer","expires_in": 86400}';
        Test.setMock(HttpCalloutMock.class, new ServiceConnectorMock(201, 'Status', httpResp, new Map<String,String>()));
        PaymentsBatchProcessor.PROCESS_ACH_TRANSACTIONS_BATCH = false;
        PaymentsSchedulerProcessor ps = new PaymentsSchedulerProcessor(WellsFargoAPI.DISBURSEMENT_PROCESS);
        ps.execute(null);
        Test.stopTest();
    }
    
    @IsTest
    static void ACHTransactionErrors(){
        Test.startTest();
        String httpResp = '{"access_token": "TKWJGRwlSR1R5PWZLpKLU2hIpUM4","scope": "ACH-Payments ACH-Payments-Status WBHK-Webhooks WBHK-TEST-Events am_application_scope","token_type": "Bearer","expires_in": 86400}';
        Test.setMock(HttpCalloutMock.class, new ServiceConnectorMock(201, 'Status', httpResp, new Map<String,String>()));
        PaymentsBatchProcessor.PROCESS_ACH_TRANSACTIONS_BATCH = false;
        PaymentsBatchProcessor.throwACHTransactionLogInsertError = true;
        PaymentsSchedulerProcessor ps = new PaymentsSchedulerProcessor(WellsFargoAPI.PAYMENTS_PROCESS);
        ps.execute(null);
        Test.stopTest();
        
        cmbls__Payment__c pay = [SELECT Id, cmbls__ACH_Batch__c FROM cmbls__Payment__c ORDER BY CreatedDate DESC LIMIT 1];
        System.assertEquals(0, [SELECT COUNT() FROM ACH_Transaction_Log__c WHERE Payment__c = :pay.Id]);
        
        cmbls__ACH_Batch__c achBatch = [SELECT cmbls__Status__c FROM cmbls__ACH_Batch__c WHERE Id =: pay.cmbls__ACH_Batch__c];
        System.assertEquals(Constant.ACH_BATCH_STATUS_SUCCESS, achBatch.cmbls__Status__c);
        
        String expectedSubject = String.format(PaymentsBatchProcessor.DEBUG_LOG_ACH_LOG_INSERT_FAILURE_SUBJECT, new String[]{PaymentsBatchProcessor.getJobName(WellsFargoAPI.PAYMENTS_PROCESS)});
        cmbls__Debug_Log__c[] logs = [SELECT Id, cmbls__Description__c, cmbls__Log__c FROM cmbls__Debug_Log__c WHERE cmbls__Subject__c = :expectedSubject];
        Assert.areEqual(1, logs.size());
        Assert.areEqual(PaymentsBatchProcessor.DEBUG_LOG_ACH_LOG_INSERT_FAILURE_DESCRIPTION, logs[0].cmbls__Description__c);
        Assert.isTrue(logs[0].cmbls__Log__c.containsIgnoreCase('Code: FIELD_INTEGRITY_EXCEPTION'));
    }
}