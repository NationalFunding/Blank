/**
 * BatchCheckWFNotificationsTest class
 * @author CloudMyBiz (r)
 * @date 3/28/2023
 */

@IsTest
private class BatchCheckWFNotificationsTest{
    
    @TestSetup static void setupMethod(){
        Test.startTest();
        Account acc = TestDataFactory.createAccount();
        insert acc;
    
        Bank_Account__c bankAccount = TestDataFactory.createBankAccount();
        insert bankAccount;
    
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
    
        cmbls__Payment__c payment = TestDataFactory.createPayment(repayment1.Id,'Debit', Constant.STATUS_SETTLED, 100.00, Date.today(), 'Wells Fargo Account');
        payment.cmbls__ACH_Batch__c = achBatch.Id;
        insert payment;
    
        cmbls__Disbursement_Batch__c disBatch = TestDataFactory.createDisBatch(Constant.ACH_PROCESSOR_NF_FUNDING, Constant.ACH_BATCH_STATUS_SUCCESS, DateTimeUtils.getNextValidDate(Date.today().addDays(1)));
        insert disBatch;
    
        cmbls__Disbursement__c dis = TestDataFactory.createDisbursement('Funding', Constant.STATUS_SETTLED, Constant.ACH_PROCESSOR_NF_FUNDING);
        dis.cmbls__Repayment__c = repayment2.Id;
        dis.cmbls__Disbursement_Batch__c = disBatch.Id;
        insert dis;
        
        WellsFargoAPI.WF_Settings.WF_CHECK_NOTIFICATIONS_URL__c = 'https://test.com/';
        WellsFargoAPI.WF_Settings.WF_TOKEN_URL__c = 'https://test.com/';
        WellsFargoAPI.WF_Settings.WF_COMPANY_ID__c = '123456789';
        WellsFargoAPI.WF_Settings.Gateway_Entity_Id__c = '123456789';
        upsert WellsFargoAPI.WF_Settings;
        Test.stopTest();
    }
    
    @IsTest
    static void exception(){
        WellsFargoAPI.THROW_TEST_EXCEPTION = true;
        Test.startTest();
        new BatchCheckWFNotifications(1).execute(null);
        Test.stopTest();
        
        ACH_Transaction_Log__c log = [SELECT Payment__c, Disbursement__c, Status__c, Response__c FROM ACH_Transaction_Log__c];
        Assert.areEqual(Constant.ACH_TRANSACTION_LOG_STATUS_FAILED, log.Status__c);
        Assert.areEqual(null, log.Payment__c);
        Assert.areEqual(null, log.Disbursement__c);
        Assert.isTrue(log.Response__c.contains('Exception message for testing purposes'));
    }
    
    @IsTest
    static void responseError(){
        String httpResp = '{"errors":[{"error_code":"400-009","description":"\\u0027start_datetime\\u0027 is missing from the query string.","field_name":"start_datetime","api_specification_url":"https://developer.wellsfargo.com"}]}';
        Test.setMock(HttpCalloutMock.class, new ServiceConnectorMock(400, 'Bad Request', httpResp, new Map<String,String>()));
        Test.startTest();
        new BatchCheckWFNotifications(1).execute(null);
        Test.stopTest();
    
        ACH_Transaction_Log__c log = [SELECT Payment__c, Disbursement__c, Status__c, Response__c, Response_Code__c FROM ACH_Transaction_Log__c];
        Assert.areEqual(Constant.ACH_TRANSACTION_LOG_STATUS_FAILED, log.Status__c);
        Assert.areEqual(null, log.Payment__c);
        Assert.areEqual(null, log.Disbursement__c);
        Assert.areEqual('400', log.Response_Code__c);
        Assert.areEqual(httpResp, log.Response__c);
    }
    
    @IsTest
    static void success(){
        cmbls__Disbursement__c disbursement = [SELECT Id FROM cmbls__Disbursement__c WHERE cmbls__Status__c = :PaymentUtils.PAYMENT_STATUS_SETTLED LIMIT 1];
        cmbls__Payment__c payment = [SELECT Id FROM cmbls__Payment__c WHERE cmbls__Status__c = :PaymentUtils.PAYMENT_STATUS_SETTLED LIMIT 1];
        String httpResp = '{"item_count": 2,"notifications": [' +
            '{"data": {"recipient_id": "' + String.valueOf(disbursement.Id).left(15) + '","return_reason_description": "INCORRECT R/T NUMBER                              "}},' +
            '{"data": {"recipient_id": "' + String.valueOf(payment.Id).left(15) + '","return_reason_description": "INCORRECT R/T NUMBER                              "}}' +
            ']}';
        Test.setMock(HttpCalloutMock.class, new ServiceConnectorMock(200, 'OK', httpResp, new Map<String,String>()));
        Test.startTest();
        new BatchCheckWFNotifications(1).execute(null);
        Test.stopTest();
    
        ACH_Transaction_Log__c[] logs = [SELECT Payment__c, Disbursement__c, Status__c, Response__c, Response_Code__c FROM ACH_Transaction_Log__c];
        Assert.areEqual(Constant.ACH_TRANSACTION_LOG_STATUS_COMPLETED, logs[0].Status__c);
        Assert.areEqual(Constant.ACH_TRANSACTION_LOG_STATUS_COMPLETED, logs[1].Status__c);
        Assert.areEqual(1, [SELECT COUNT() FROM cmbls__Disbursement__c WHERE Id = :disbursement.Id AND cmbls__Status__c = :PaymentUtils.PAYMENT_STATUS_FAILED]);
        Assert.areEqual(1, [SELECT COUNT() FROM cmbls__Payment__c WHERE Id = :payment.Id AND cmbls__Status__c = :PaymentUtils.PAYMENT_STATUS_FAILED]);
    }
    
    @IsTest
    static void successCreateReversal(){
        WF_Api_Settings__c setting = WF_Api_Settings__c.getInstance();
        setting.Create_Reversal_Payment_for_Late_Returns__c = true;
        upsert setting;
        
        cmbls__Disbursement__c disbursement = [SELECT Id FROM cmbls__Disbursement__c WHERE cmbls__Status__c = :PaymentUtils.PAYMENT_STATUS_SETTLED LIMIT 1];
        cmbls__Payment__c payment = [SELECT Id FROM cmbls__Payment__c WHERE cmbls__Status__c = :PaymentUtils.PAYMENT_STATUS_SETTLED LIMIT 1];
        String httpResp = '{"item_count": 2,"notifications": [' +
            '{"data": {"recipient_id": "' + String.valueOf(disbursement.Id).left(15) + '","return_reason_description": "INCORRECT R/T NUMBER                              "}},' +
            '{"data": {"recipient_id": "' + String.valueOf(payment.Id).left(15) + '","return_reason_description": "INCORRECT R/T NUMBER                              "}}' +
            ']}';
        Test.setMock(HttpCalloutMock.class, new ServiceConnectorMock(200, 'OK', httpResp, new Map<String,String>()));
        Test.startTest();
        new BatchCheckWFNotifications(1).execute(null);
        Test.stopTest();
        
        ACH_Transaction_Log__c[] logs = [SELECT Payment__c, Disbursement__c, Status__c, Response__c, Response_Code__c FROM ACH_Transaction_Log__c];
        Assert.areEqual(Constant.ACH_TRANSACTION_LOG_STATUS_COMPLETED, logs[0].Status__c);
        Assert.areEqual(Constant.ACH_TRANSACTION_LOG_STATUS_COMPLETED, logs[1].Status__c);
        Assert.areEqual(1, [SELECT COUNT() FROM cmbls__Disbursement__c WHERE Id = :disbursement.Id AND cmbls__Status__c = :PaymentUtils.PAYMENT_STATUS_FAILED]);
        Assert.areEqual(1, [SELECT COUNT() FROM cmbls__Payment__c WHERE Id = :payment.Id AND cmbls__Status__c = :PaymentUtils.PAYMENT_STATUS_SETTLED AND cmbls__Reversal_Created__c = TRUE]);
        Assert.areEqual(1, [SELECT COUNT() FROM cmbls__Payment__c WHERE cmbls__Reversal_Of__c = :payment.Id AND cmbls__Status__c = :PaymentUtils.PAYMENT_STATUS_SETTLED]);
    }
    
    @IsTest
    static void ignoredReversalAndCancel(){
        WF_Api_Settings__c setting = WF_Api_Settings__c.getInstance();
        setting.Create_Reversal_Payment_for_Late_Returns__c = true;
        upsert setting;
        
        cmbls__Disbursement__c disbursement = [SELECT Id FROM cmbls__Disbursement__c WHERE cmbls__Status__c = :PaymentUtils.PAYMENT_STATUS_SETTLED LIMIT 1];
        disbursement.cmbls__Status__c = PaymentUtils.PAYMENT_STATUS_FAILED;
        update disbursement;
        
        cmbls__Payment__c payment = [SELECT Id FROM cmbls__Payment__c WHERE cmbls__Status__c = :PaymentUtils.PAYMENT_STATUS_SETTLED LIMIT 1];
        payment.cmbls__Reversal_Created__c = true;
        update payment;
        
        
        String httpResp = '{"item_count": 2,"notifications": [' +
            '{"data": {"recipient_id": "' + disbursement.Id + '","return_reason_description": "INCORRECT R/T NUMBER                              "}},' +
            '{"data": {"recipient_id": "' + payment.Id + '","return_reason_description": "INCORRECT R/T NUMBER                              "}}' +
            ']}';
        Test.setMock(HttpCalloutMock.class, new ServiceConnectorMock(200, 'OK', httpResp, new Map<String,String>()));
        Test.startTest();
        BatchCheckWFNotifications.isTest = true;
        new BatchCheckWFNotifications(1).execute(null);
        Test.stopTest();
        
        Assert.areEqual(0, [SELECT COUNT() FROM ACH_Transaction_Log__c WHERE Disbursement__c =:disbursement.Id OR Payment__c = :payment.Id]);
        Assert.areEqual(1, [SELECT COUNT() FROM cmbls__Disbursement__c WHERE Id = :disbursement.Id AND cmbls__Status__c = :PaymentUtils.PAYMENT_STATUS_FAILED]);
        Assert.areEqual(1, [SELECT COUNT() FROM cmbls__Payment__c WHERE Id = :payment.Id AND cmbls__Status__c = :PaymentUtils.PAYMENT_STATUS_SETTLED AND cmbls__Reversal_Created__c = TRUE]);
        Assert.areEqual(0, [SELECT COUNT() FROM cmbls__Payment__c WHERE cmbls__Reversal_Of__c = :payment.Id AND cmbls__Status__c = :PaymentUtils.PAYMENT_STATUS_SETTLED]);
    }
    
    @IsTest
    static void successKeySensitive(){
        cmbls__Disbursement__c disbursement = [SELECT Id FROM cmbls__Disbursement__c WHERE cmbls__Status__c = :PaymentUtils.PAYMENT_STATUS_SETTLED LIMIT 1];
        cmbls__Payment__c payment = [SELECT Id FROM cmbls__Payment__c WHERE cmbls__Status__c = :PaymentUtils.PAYMENT_STATUS_SETTLED LIMIT 1];
        
        String httpResp = '{"item_count": 2,"notifications": [' +
            '{"data": {"recipient_id": "' + String.valueOf(disbursement.Id).left(15).toUpperCase() + '","return_reason_description": "INCORRECT R/T NUMBER"}},' +
            '{"data": {"recipient_id": "' + String.valueOf(payment.Id).left(15).toUpperCase() + '","return_reason_description": "INCORRECT R/T NUMBER"}},' +
            '{"data": {"recipient_id": "' + String.valueOf(disbursement.Id).left(15) + '","return_reason_description": "INCORRECT R/T NUMBER"}},' +
            '{"data": {"recipient_id": "' + String.valueOf(payment.Id).left(15) + '","return_reason_description": "INCORRECT R/T NUMBER"}}' +
        ']}';
        Test.setMock(HttpCalloutMock.class, new ServiceConnectorMock(200, 'OK', httpResp, new Map<String,String>()));
        Test.startTest();
        new BatchCheckWFNotifications(1).execute(null);
        Test.stopTest();
        
        ACH_Transaction_Log__c[] logs = [SELECT Payment__c, Disbursement__c, Status__c, Response__c, Response_Code__c FROM ACH_Transaction_Log__c];
        Assert.areEqual(Constant.ACH_TRANSACTION_LOG_STATUS_COMPLETED, logs[0].Status__c);
        Assert.areEqual(Constant.ACH_TRANSACTION_LOG_STATUS_COMPLETED, logs[1].Status__c);
        Assert.areEqual(1, [SELECT COUNT() FROM cmbls__Disbursement__c WHERE Id = :disbursement.Id AND cmbls__Status__c = :PaymentUtils.PAYMENT_STATUS_FAILED]);
        Assert.areEqual(1, [SELECT COUNT() FROM cmbls__Payment__c WHERE Id = :payment.Id AND cmbls__Status__c = :PaymentUtils.PAYMENT_STATUS_FAILED]);
    }
    
    @IsTest
    static void noRecordsKeySensitive(){
        cmbls__Disbursement__c disbursement = [SELECT Id FROM cmbls__Disbursement__c WHERE cmbls__Status__c = :PaymentUtils.PAYMENT_STATUS_SETTLED LIMIT 1];
        cmbls__Payment__c payment = [SELECT Id FROM cmbls__Payment__c WHERE cmbls__Status__c = :PaymentUtils.PAYMENT_STATUS_SETTLED LIMIT 1];
        
        String httpResp = '{"item_count": 2,"notifications": [' +
            '{"data": {"recipient_id": "' + String.valueOf(disbursement.Id).left(15).toUpperCase() + '","return_reason_description": "INCORRECT R/T NUMBER"}},' +
            '{"data": {"recipient_id": "' + String.valueOf(payment.Id).left(15).toUpperCase() + '","return_reason_description": "INCORRECT R/T NUMBER"}}' +
            ']}';
        Test.setMock(HttpCalloutMock.class, new ServiceConnectorMock(200, 'OK', httpResp, new Map<String,String>()));
        
        Test.startTest();
        new BatchCheckWFNotifications(1).execute(null);
        Test.stopTest();
        
        Assert.areEqual(0, [SELECT COUNT() FROM ACH_Transaction_Log__c]);
        Assert.areEqual(1, [SELECT COUNT() FROM cmbls__Disbursement__c WHERE Id = :disbursement.Id AND cmbls__Status__c = :PaymentUtils.PAYMENT_STATUS_SETTLED]);
        Assert.areEqual(1, [SELECT COUNT() FROM cmbls__Payment__c WHERE Id = :payment.Id AND cmbls__Status__c = :PaymentUtils.PAYMENT_STATUS_SETTLED]);
    }
    
    @IsTest
    static void coverage(){
        Test.startTest();
        BatchCheckWFNotifications.resubmitJob(1);
        BatchCheckWFNotifications.shouldReschedule();
        Test.stopTest();
    }
}