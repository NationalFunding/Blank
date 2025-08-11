@IsTest
public with sharing class WellsFargoPaymentsTest {

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
        repayment2.cmbls__ACH_Processor__c = 'Wells Fargo - Main Account';
        repayments.add(repayment2);
        insert repayments;

        cmbls__ACH_Batch__c achBatch = TestDataFactory.createACHBatch('Wells Fargo Account', 'Pending', DateTimeUtils.getNextValidDate(Date.today().addDays(1)));
        insert achBatch;

        cmbls__Payment__c payment = TestDataFactory.createPayment(repayment1.Id,'Debit', 'Scheduled', 100.00, Date.today(), 'Wells Fargo Account');
        payment.cmbls__ACH_Batch__c = achBatch.Id;
        payment.cmbls__Transaction_Type__c = PaymentUtils.PAYMENT_TRANSACTION_TYPE_PAYMENT;
        insert payment;

        cmbls__Disbursement_Batch__c disBatch = TestDataFactory.createDisBatch('Wells Fargo - Main Account', 'Pending', DateTimeUtils.getNextValidDate(Date.today().addDays(1)));
        insert disBatch;

        cmbls__Disbursement__c dis = TestDataFactory.createDisbursement('Funding', 'Scheduled', 'Wells Fargo - NF Funding');
        dis.cmbls__Repayment__c = repayment2.Id;
        dis.cmbls__Disbursement_Batch__c = disBatch.Id;
        insert dis;

        WF_Api_Settings__c wellsFargoAPiSettings = TestDataFactory.wfSettings();
        insert wellsFargoAPiSettings;
        Test.stopTest();
    }

    @IsTest
    static void paymentsToPendingSuccess(){
        Test.startTest();
        String httpResp = '{"access_token": "TKWJGRwlSR1R5PWZLpKLU2hIpUM4","scope": "ACH-Payments ACH-Payments-Status WBHK-Webhooks WBHK-TEST-Events am_application_scope","token_type": "Bearer","expires_in": 86400}';
        Test.setMock(HttpCalloutMock.class, new ServiceConnectorMock(201, 'Status', httpResp, new Map<String,String>()));
        PaymentsSchedulerProcessor ps = new PaymentsSchedulerProcessor('PAYMENTS_PROCESS');
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

        WellsFargo.WFErrors serviceErrors = new WellsFargo.WFErrors();
        serviceErrors.errors = new List<WellsFargo.Error>();
        WellsFargo.Error respError = new WellsFargo.Error();
        respError.error_code = '500-001';
        respError.description = 'Internal System error.';
        serviceErrors.errors.add(respError);

        String httpResp = JSON.serialize(serviceErrors);
        Test.setMock(HttpCalloutMock.class, new ServiceConnectorMock(500, 'Status', httpResp, new Map<String,String>()));
        PaymentsSchedulerProcessor ps = new PaymentsSchedulerProcessor('PAYMENTS_PROCESS');
        ps.execute(null);
        Test.stopTest();

        cmbls__Payment__c pay = [SELECT Id, cmbls__ACH_Batch__c FROM cmbls__Payment__c ORDER BY CreatedDate DESC LIMIT 1];
        List<ACH_Transaction_Log__c> achTransactionLogs = [SELECT Id, Status__c, Response__c, Error_Code__c, Response_Code__c FROM ACH_Transaction_Log__c WHERE Payment__c = :pay.Id];
        System.assertEquals(1, achTransactionLogs.size());
        System.assertEquals(Constant.ACH_TRANSACTION_LOG_STATUS_COMPLETED, achTransactionLogs[0].Status__c);
        System.assertEquals(achTransactionLogs[0].Response__c, httpResp);
        System.assertEquals(achTransactionLogs[0].Error_Code__c, '500-001');
        System.assertEquals(achTransactionLogs[0].Response_Code__c, '500');
    }

    @IsTest
    static void batchNumberOfAttemptsReached(){

        WF_Api_Settings__c settings = WF_Api_Settings__c.getOrgDefaults();
        settings.Max_Number_of_attempts__c = 2;
        update settings;

        WellsFargo.WFErrors serviceErrors = new WellsFargo.WFErrors();
        serviceErrors.errors = new List<WellsFargo.Error>();
        WellsFargo.Error respError = new WellsFargo.Error();
        respError.error_code = '500-001';
        respError.description = 'Internal System error.';
        serviceErrors.errors.add(respError);

        String httpResp = JSON.serialize(serviceErrors);
        Test.setMock(HttpCalloutMock.class, new ServiceConnectorMock(500, 'Status', httpResp, new Map<String,String>()));

        Test.startTest();
        PaymentsSchedulerProcessor ps = new PaymentsSchedulerProcessor('PAYMENTS_PROCESS');
        ps.execute(null);
        Test.stopTest();

        cmbls__Payment__c pay = [SELECT Id, cmbls__ACH_Batch__c FROM cmbls__Payment__c ORDER BY CreatedDate DESC LIMIT 1];
        List<ACH_Transaction_Log__c> achTransactionLogs = [SELECT Id, Status__c, Response__c, Error_Code__c, Response_Code__c FROM ACH_Transaction_Log__c WHERE Payment__c = :pay.Id];
        System.assertEquals(1, achTransactionLogs.size());
        System.assertEquals(Constant.ACH_TRANSACTION_LOG_STATUS_COMPLETED, achTransactionLogs[0].Status__c);
        System.assertEquals(achTransactionLogs[0].Response__c, httpResp);
        System.assertEquals(achTransactionLogs[0].Error_Code__c, '500-001');
        System.assertEquals(achTransactionLogs[0].Response_Code__c, '500');
    }

    @IsTest
    static void paymentsError(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ServiceConnectorMock(400, 'Status', 'Error', new Map<String,String>()));
        PaymentsSchedulerProcessor ps = new PaymentsSchedulerProcessor('PAYMENTS_PROCESS');
        ps.execute(null);
        Test.stopTest();

        cmbls__Payment__c pay = [SELECT Id, cmbls__ACH_Batch__c FROM cmbls__Payment__c ORDER BY CreatedDate DESC LIMIT 1];
        ACH_Transaction_Log__c achTransactionLog = [SELECT Id, Status__c, Response__c, Response_Code__c FROM ACH_Transaction_Log__c WHERE Payment__c = :pay.Id];
        System.assertEquals(achTransactionLog.Response__c, 'Error');
        System.assertEquals(achTransactionLog.Response_Code__c, '400');
    }

     @IsTest
    static void webhookTest(){
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();

        req.addHeader('httpMethod', 'POST');
        req.requestURI = '/services/apexrest/wellsFargoPayments/';
        String postData = '{"notification_id":"55558888","additional_data_available":false,"create_datetime":"2019-10-19T00:41:08+0000","data":{"return_trace_number":"111111111111111","ach_company_id":"ABCXYZ1111","return_reason_code":"R01","ach_file_originator_id":"1111111111","payment_currency":"USDUSD","bank_account_number_masked":"...1111","original_trace_number":"111111111111111","ach_transaction_code":"27","bank_id":"111111111","tir_company_name":"ABCXYZABC","batch_sequence_number":"00000","ach_file_key":"000000000","found_not_found_return_indicator":"F","recipient_id":"XYZ","descriptive_date":"190823","exception_report_created_datetime":"2018-11-16T16:05:37Z","payment_amount":7.65,"entry_class_code":"ARC","calculated_effective_date":"2018-11-15","return_type_code_description":"Return","original_dfi_routing_number":"11111111","return_reason_description":"INSUFFICIENTFUNDS","ach_company_name":"ABCXYZ","original_return_reason_code":"R01","return_type_code":"10","company_entry_description":"RETRYPYMT","recipient_name":"FIRST_NAMELAST_NAME","redeposit":"1","received_returned_comment_code":"o"}}';
        req.requestBody = Blob.valueOf(postData);
        RestContext.request = req; 
        RestContext.response= res;
        Test.startTest();
        WellsFargoConnector.POST();
        Test.stopTest();

    }

    public static WF_Api_Settings__c wfSettings(){
        return new WF_Api_Settings__c(
            WF_CONSUMER_KEY__c = '123',
            WF_COMPANY_ID__c =  '2213547186',
            WF_CONSUMER_SECRET__c = '123',
            WF_DELAYS_DAYS__c = 1,
            WF_PAYMENTS_CHECK_URL__c = 'url',
            WF_PAYMENTS_CREATE_URL__c = 'url',
            WF_TOKEN_URL__c = 'url',
            Save_Communication_Logs__c = true
        );
    }

    public static cmbls__Payment__c createPayment(Id repaymentId, String recordTypeName, String status, Decimal amount, Date effectiveDate, String processor){
        String recordTypeId = Schema.SObjectType.cmbls__Payment__c.getRecordTypeInfosByDeveloperName().get(recordTypeName).getRecordTypeId();
        return new cmbls__Payment__c(
            cmbls__Repayment__c = repaymentId,
            RecordTypeId = recordTypeId,
            cmbls__Status__c = status,
            cmbls__Transaction_Amount__c = amount,
            cmbls__Effective_Date__c = effectiveDate,
            cmbls__ACH_Processor__c = processor
        );
    }

    public static cmbls__Disbursement__c createDisbursement(String recordTypeName, String status, String processor){
        String recordTypeId = Schema.SObjectType.cmbls__Disbursement__c.getRecordTypeInfosByDeveloperName().get(recordTypeName).getRecordTypeId();
        return new cmbls__Disbursement__c(
            RecordTypeId = recordTypeId,
            cmbls__Status__c = status,
            cmbls__Effective_Date__c = Date.today(),
            cmbls__Transaction_Amount__c = 100,
            cmbls__ACH_Processor__c = processor
        );
    }

    public static cmbls__ACH_Batch__c createACHBatch(String providerName, String status, Date effectiveDate) {
        cmbls__ACH_Batch__c batch = new cmbls__ACH_Batch__c();
        batch.cmbls__ACH_Provider_Name__c = providerName;
        batch.cmbls__Status__c = status;
        batch.cmbls__Effective_Date__c = effectiveDate;
        return batch;
    }

    public static cmbls__Disbursement_Batch__c createDisBatch(String providerName, String status, Date effectiveDate) {
        cmbls__Disbursement_Batch__c batch = new cmbls__Disbursement_Batch__c();
        batch.cmbls__ACH_Provider_Name__c = providerName;
        batch.cmbls__Status__c = status;
        batch.cmbls__Effective_Date__c = effectiveDate;
        return batch;
    }

    public static cmbls__Repayment__c createRepayment(Id accId, Date maturity) {
        return new cmbls__Repayment__c(
            cmbls__Status__c = 'Active',
            cmbls__Payee_Account__c = accId,
            cmbls__Funding_Amount__c = 10204.08,
            cmbls__Intial_Repayment_Amount__c = 10204.08,
            cmbls__Current_Interest_Rate__c = 0.0710,
            cmbls__Original_Interest_Rate__c = 0.0710,
            cmbls__Payments_Updated__c = true,
            cmbls__Payment_Amount__c = 10204.08,
            cmbls__Payment_Frequency__c = 'Monthly',
            cmbls__Funded_Date__c = Date.today().addDays(-120),
            cmbls__Term_Days_Default__c = 120,
            cmbls__Bank_Name__c = '123123',
            cmbls__ACH_Processor__c = 'Texas Capital Bank',
            cmbls__Bank_Account_Number__c = '123123',
            cmbls__Type_of_Account__c = 'Savings',
            cmbls__Bank_Routing_Number__c = '123123123',
            cmbls__Is_Interest_Based_Loan__c = true,
            cmbls__Interest_Accrual_Method__c = '365/360',
            cmbls__Fee_Group__c = 'Default',
            cmbls__Maturity_Date__c = maturity,
            Merchant_Number__c = '878787'
        );
    }
}