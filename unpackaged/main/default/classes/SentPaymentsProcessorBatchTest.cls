/**
 * SentPaymentsProcessorBatchTest class
 * @author CloudMyBiz (r)
 * @date 6/23/2023
 */

@IsTest
private class SentPaymentsProcessorBatchTest{
    
    @TestSetup static void setupMethod(){
        Test.startTest();
        Account acc = new Account(Name = 'Test account');
        insert acc;
        
        cmbls__Repayment__c repayment = TestDataFactory.createRepayment(acc.Id);
        repayment.cmbls__ACH_Processor__c = 'Wells Fargo - NF Collections';
        repayment.Merchant_Number__c = '123456';
        insert repayment;
        
        delete [SELECT Id FROM cmbls__Payment__c];
        
        cmbls__ACH_Batch__c achBatch = TestDataFactory.createACHBatch('Wells Fargo - NF Collections', 'Pending', DateTimeUtils.getNextValidDate(Date.today().addDays(1)));
        insert achBatch;
        
        cmbls__Payment__c[] payments = new cmbls__Payment__c[]{
            TestDataFactory.createPayment(repayment.Id,'Debit', 'Scheduled', 100.00, Date.today(), 'Wells Fargo - NF Collections'),
            TestDataFactory.createPayment(repayment.Id,'Debit', 'Scheduled', 100.00, Date.today(), 'Wells Fargo - NF Collections'),
            TestDataFactory.createPayment(repayment.Id,'Debit', 'Scheduled', 100.00, Date.today(), 'Wells Fargo - NF Collections'),
            TestDataFactory.createPayment(repayment.Id,'Debit', 'Scheduled', 100.00, Date.today(), 'Wells Fargo - NF Collections'),
            TestDataFactory.createPayment(repayment.Id,'Debit', 'Scheduled', 100.00, Date.today(), 'Wells Fargo - NF Collections')
        };
        for(cmbls__Payment__c item :payments){
            item.cmbls__ACH_Batch__c = achBatch.Id;
            item.cmbls__Transaction_Type__c = PaymentUtils.PAYMENT_TRANSACTION_TYPE_PAYMENT;
        }
        insert payments;
        
        delete [SELECT Id FROM cmbls__Disbursement_Batch__c];
        cmbls__Disbursement_Batch__c disBatch = TestDataFactory.createDisBatch(Constant.ACH_PROCESSOR_NF_FUNDING, 'Pending', DateTimeUtils.getNextValidDate(Date.today().addDays(1)));
        insert disBatch;
        
        cmbls__Disbursement__c[] disbursements = new cmbls__Disbursement__c[]{
            TestDataFactory.createDisbursement('Funding', Constant.STATUS_SCHEDULED, Constant.ACH_PROCESSOR_NF_FUNDING),
            TestDataFactory.createDisbursement('Funding', Constant.STATUS_SCHEDULED, Constant.ACH_PROCESSOR_NF_FUNDING),
            TestDataFactory.createDisbursement('Funding', Constant.STATUS_SCHEDULED, Constant.ACH_PROCESSOR_NF_FUNDING),
            TestDataFactory.createDisbursement('Funding', Constant.STATUS_SCHEDULED, Constant.ACH_PROCESSOR_NF_FUNDING),
            TestDataFactory.createDisbursement('Funding', Constant.STATUS_SCHEDULED, Constant.ACH_PROCESSOR_NF_FUNDING)
        };
        
        for(cmbls__Disbursement__c item :disbursements){
            item.cmbls__Repayment__c = repayment.Id;
            item.cmbls__Disbursement_Batch__c = disBatch.Id;
        }
        insert disbursements;
        
        delete [SELECT Id FROM ACH_Transaction_Log__c];
        ACH_Transaction_Log__c[] logs = new ACH_Transaction_Log__c[]{};
        SObject[] records = new SObject[]{};
        records.addAll(payments);
        records.addAll(disbursements);
        for(SObject item :records){
            ACH_Transaction_Log__c log = TestDataFactory.createACHTransactionLog(item.Id, Constant.ACH_TRANSACTION_LOG_WF_SENT);
            log.Response_Code__c = '201';
            logs.add(log);
        }
        insert logs;
        
        WF_Api_Settings__c wellsFargoAPiSettings = TestDataFactory.wfSettings();
        insert wellsFargoAPiSettings;
        
        NF_ACH_Info__c nfSettings = NF_ACH_Info__c.getInstance();
        nfSettings.Settlement_in_Business_day__c = 5;
        insert nfSettings;
        Test.stopTest();
    }
    
    @IsTest
    static void executePaymentsNoFailures(){
        Test.startTest();
        new SentPaymentsProcessorBatch().execute(null);
        Test.stopTest();
        
        for(ACH_Transaction_Log__c item :[SELECT Pre_Pending_Update_Attempts__c, Payment__r.cmbls__Status__c FROM ACH_Transaction_Log__c WHERE Payment__c != NULL]){
            Assert.areEqual(1, item.Pre_Pending_Update_Attempts__c);
            Assert.areEqual(PaymentUtils.PAYMENT_STATUS_PRE_PENDING, item.Payment__r.cmbls__Status__c);
        }
        
        Assert.areEqual(0, [SELECT COUNT() FROM cmbls__Debug_Log__c]);
    }
    
    @IsTest
    static void executeDisbursementNoFailures(){
        cmbls__Disbursement__c[] records = [SELECT Id, cmbls__Disbursement_Batch__c, cmbls__Disbursement_Batch__r.cmbls__Status__c FROM cmbls__Disbursement__c];
        cmbls__Loan_Servicing_Settings__c lsSetting = cmbls__Loan_Servicing_Settings__c.getOrgDefaults();
        lsSetting.cmbls__Disb_Status_Not_Assigned_to_Batch__c = PaymentUtils.PAYMENT_STATUS_PRE_PENDING;
        upsert lsSetting;
        
        Test.startTest();
        new SentPaymentsProcessorBatch().execute(null);
        Test.stopTest();
        
        Map<Id, cmbls__Disbursement__c> processedRecordsMap = new Map<Id, cmbls__Disbursement__c>([SELECT Id, cmbls__Disbursement_Batch__c FROM cmbls__Disbursement__c WHERE Id IN :records]);
        for(cmbls__Disbursement__c record :records){
            Assert.areEqual(record.cmbls__Disbursement_Batch__c, processedRecordsMap.get(record.Id).cmbls__Disbursement_Batch__c);
        }
        
        for(ACH_Transaction_Log__c item :[SELECT Pre_Pending_Update_Attempts__c, Disbursement__c, Disbursement__r.cmbls__Status__c FROM ACH_Transaction_Log__c WHERE Disbursement__c != NULL]){
            Assert.areEqual(1, item.Pre_Pending_Update_Attempts__c);
            Assert.areEqual(PaymentUtils.PAYMENT_STATUS_PRE_PENDING, item.Disbursement__r.cmbls__Status__c);
        }
        
        Assert.areEqual(0, [SELECT COUNT() FROM cmbls__Debug_Log__c]);
    }
    
    @IsTest
    static void executeDisbursementsNoFailures(){
        Test.startTest();
        new SentPaymentsProcessorBatch().execute(null);
        Test.stopTest();
        
        for(ACH_Transaction_Log__c item :[SELECT Pre_Pending_Update_Attempts__c, Disbursement__r.cmbls__Status__c FROM ACH_Transaction_Log__c WHERE Disbursement__c != NULL]){
            Assert.areEqual(1, item.Pre_Pending_Update_Attempts__c);
            Assert.areEqual(PaymentUtils.PAYMENT_STATUS_PRE_PENDING, item.Disbursement__r.cmbls__Status__c);
        }
        
        Assert.areEqual(0, [SELECT COUNT() FROM cmbls__Debug_Log__c]);
    }
    
    @IsTest
    static void executeMaxNumberOfAttempts(){
        WF_Api_Settings__c apiSettings = WF_Api_Settings__c.getInstance();
        
        ACH_Transaction_Log__c[] logs = [SELECT Id FROM ACH_Transaction_Log__c];
        for(ACH_Transaction_Log__c item :logs){
            item.Pre_Pending_Update_Attempts__c = apiSettings.Pre_Pending_Update_Max_Attempts__c;
        }
        update logs;
        
        Test.startTest();
        new SentPaymentsProcessorBatch().execute(null);
        Test.stopTest();
        
       
    }
    
    @IsTest
    static void executeRecordUpdateFailure(){
        cmbls__Payment__c[] records = [SELECT Id FROM cmbls__Payment__c];
        
        Test.startTest();
        SentPaymentsProcessorBatch.paymentFailureRecord = records[1];
        new SentPaymentsProcessorBatch().execute(null);
        Test.stopTest();

        for(ACH_Transaction_Log__c item :[SELECT Pre_Pending_Update_Attempts__c, Payment__c, Payment__r.cmbls__Status__c FROM ACH_Transaction_Log__c WHERE Payment__c != NULL]){
           // Assert.areEqual(1, item.Pre_Pending_Update_Attempts__c);
            if(item.Payment__c == records[1].Id){
                //Assert.areEqual(PaymentUtils.PAYMENT_STATUS_SCHEDULED, item.Payment__r.cmbls__Status__c);
            }else{
               // Assert.areEqual(PaymentUtils.PAYMENT_STATUS_PRE_PENDING, item.Payment__r.cmbls__Status__c);
            }
        }
        
        cmbls__Debug_Log__c debugLog = [SELECT cmbls__Subject__c, cmbls__Description__c, cmbls__Log__c FROM cmbls__Debug_Log__c];
        String objectName = cmbls__Payment__c.getSObjectType().getDescribe().getLabel();
        String expectedSubject = String.format(SentPaymentsProcessorBatch.DEBUG_LOG_FAILURE_SUBJECT, new String[]{SentPaymentsProcessorBatch.getJobName()});
        String expectedDescription = String.format(SentPaymentsProcessorBatch.DEBUG_LOG_FAILURE_DESCRIPTION, new String[]{objectName, PaymentUtils.PAYMENT_STATUS_PRE_PENDING, records[1].Id});

        
    }
}