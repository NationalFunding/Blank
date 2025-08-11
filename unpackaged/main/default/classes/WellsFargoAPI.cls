/**
 * WellsFargoAPI class
 * @author CloudMyBiz (r)
 * @date 18/07/2022
 * @description Service Class. Interface between business logic and specific apex contexts such as Trigger Handlers, Controllers, Batch Classes, API etc.
 * Services generally include static methods that implement business logic. Exceptions are generally thrown for the caller to handle.
 * @group Services
 */
public inherited sharing class WellsFargoAPI {

    //Processes to execute
    public static final String PAYMENTS_PROCESS = 'PAYMENTS_PROCESS';
    public static final String DISBURSEMENT_PROCESS = 'DISBURSEMENT_PROCESS';

    public static WF_Api_Settings__c WF_Settings = WF_Api_Settings__c.getInstance();
    public static Map<String,WellsFargo_Config__mdt> WF_Fields;
    public static Map<String,Wells_Fargo_Credentials__c> WF_Credentials;
    public static final Integer DEFAULT_MINUTES_NEX_TIME_JOB_WILL_RUN = 5;
    public static final Integer MAX_NUMBER_RECORDS_API_SUPPORTS_PER_MINUTE = 300;

    @TestVisible private static Boolean THROW_TEST_EXCEPTION = false;

    //Method to get the access token.
    public static String getAccessToken(){
        try{
            //Get variables for the request FROM General Config custom setting.
            // for Webhook integration, the scope is WBHK-TEST-Events
            String url = WF_Settings.WF_TOKEN_URL__c + '?grant_type=client_credentials&scope=ACH-Payments%20ACH-Payments-Status%20WBHK-Webhooks';

            //Encoded the consumer key & consumer secret
            String encodedKey = EncodingUtil.base64Encode(Blob.valueOf(WF_Settings.WF_CONSUMER_KEY__c + ':' + WF_Settings.WF_CONSUMER_SECRET__c));

            //Create Map for request's headers
            Map<String, String> headers = new Map<String, String>{'Authorization'=> 'Basic ' + encodedKey, 'Content-Type' =>'application/x-www-form-urlencoded'};

            HttpResponse res = ServiceConnectorHelper.sendWellsFargoRequest('POST', url, headers, '{}');

            JSONParser parser = JSON.createParser(res.getBody());
            String accessToken = '';
            //get token FROM the response
            while (parser.nextToken() != null) {
                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'access_token')) {
                    parser.nextToken();
                    accessToken = parser.getText();
                }
            }
            return accessToken;

        }catch(Exception ex){
            return '';
        }
    }

    public static void processPayment(WellsFargo paymentRequest){
        //Generates body requests FROM the payment record.
        String bodyRequest = JSON.serialize(processPaymentsRequestBody(paymentRequest.record));

        //Create Map for request's headers
        Map<String, String> headers = new Map<String, String>{
                'gateway-company-id' => WF_Settings.WF_COMPANY_ID__c,
                'request-id' => getUUID(), 'Content-Type' =>'application/json',
                'Authorization' => 'Bearer ' + paymentRequest.token
        };

        HttpResponse res;

        List<String> settingErrorCodes = getErrorCodes();
        try {

            //Uncomment this lines below to mock responses from DEV Environment
            //res = new HttpResponse();res.setBody('');res.setStatusCode(201);

            //Comment this line below to use mock responses from DEV Environment
            res = ServiceConnectorHelper.sendWellsFargoRequest('POST', WF_Settings.WF_PAYMENTS_CREATE_URL__c, headers, bodyRequest);
            WellsFargo.WFErrors errorsResp;
            try{
                errorsResp = (WellsFargo.WFErrors) JSON.deserialize(res.getBody(), WellsFargo.WFErrors.class);
            }catch(Exception ex){
                System.debug('Deserialize exception: Sending the wrong response?: HttpResp: ' + res.getBody() + ', Raw exc: ' + ex.getMessage());
            }

            paymentRequest.achLog.log.Request__c =  bodyRequest;
            paymentRequest.achLog.log.Response__c = res?.getBody();
            paymentRequest.achLog.log.Log_Date__c = Datetime.now();
            paymentRequest.achLog.log.Response_Code__c = String.valueOf(res.getStatusCode());
            paymentRequest.achLog.log.Status__c = Constant.ACH_TRANSACTION_LOG_STATUS_COMPLETED;

            if(res.getStatusCode() == 201){
                paymentRequest.achLog.log.Status__c = Constant.ACH_TRANSACTION_LOG_WF_SENT;
            }else{
                paymentRequest.achLog.log.Status__c = Constant.ACH_TRANSACTION_LOG_STATUS_FAILED;
                paymentRequest.failedRecord = true;//always set as failed record unless there is a setting (bellow) to resubmit
                if(errorsResp != null && !errorsResp.errors?.isEmpty()){
                    for(WellsFargo.Error apiErrorCode : errorsResp.errors){
                        paymentRequest.achLog.log.Error_Code__c = apiErrorCode.error_code;
                        
                        //Sometimes the API returns "error_code":"1003-001","description":"Duplicate payment ID, transaction not processed."
                        //When this happens, we need to process it as 201 since the payment was already sent
                        if('1003-001'.equals(apiErrorCode.error_code)){
                            paymentRequest.achLog.log.Response_Code__c = '201';
                            paymentRequest.achLog.log.Status__c = Constant.ACH_TRANSACTION_LOG_WF_SENT;
                            paymentRequest.failedRecord = false;
                            paymentRequest.doResubmission = false;
                            break;
                        }else{
                            for(String settingErrorCode : settingErrorCodes){
                                if(paymentRequest.doResubmission) break;
                                paymentRequest.doResubmission = settingErrorCode == apiErrorCode.error_code;
                                // * wildcard
                                if(settingErrorCode.endsWith('*')){
                                    paymentRequest.doResubmission = settingErrorCode.left(3).equalsIgnoreCase(apiErrorCode.error_code?.split('-')[0]);
                                }
                            }
                        }
                    }
                }else{
                    paymentRequest.doResubmission = isTimedOutException(res?.getBody());
                }

                if(paymentRequest.doResubmission){
                    paymentRequest.failedRecord = false;
                    paymentRequest.achLog.log.Status__c = Constant.ACH_TRANSACTION_LOG_STATUS_COMPLETED;
                }
            }
        }catch(Exception ex){
            if(String.isNotBlank(paymentRequest.achLog.log.Response__c)){
                paymentRequest.achLog.log.Response__c = paymentRequest.achLog.log.Response__c + '\n\n Exception: ' + ex.getMessage();
            }else{
                paymentRequest.achLog.log.Response__c = ex.getMessage();
            }
            
            paymentRequest.achLog.log.Request__c = bodyRequest;
            paymentRequest.achLog.log.Log_Date__c = Datetime.now();
            paymentRequest.doResubmission = isTimedOutException(ex.getMessage());
            paymentRequest.failedRecord = !paymentRequest.doResubmission;
            paymentRequest.achLog.log.Status__c = Constant.ACH_TRANSACTION_LOG_STATUS_COMPLETED;
            System.debug(ex.getStackTraceString());
        }
    }

    public static void achPaymentStatusCheck(WellsFargo wfRequest, String transactionId){

        //Create Map for request's headers
        Map<String, String> headers = new Map<String, String>{
                'gateway-company-id' => WF_Settings.WF_COMPANY_ID__c,
                'request-id' => getUUID(), 'Content-Type' =>'application/json',
                'Authorization' => 'Bearer ' + wfRequest.token
        };

        HttpResponse res;
        try {
            String request = WF_Settings.WF_PAYMENTS_CHECK_STATUS_URL__c + '/' + transactionId;

            //Uncomment this lines below to mock responses from DEV Environment
//            res = new HttpResponse();
//            res.setBody('{\n' +
//                '"payment_status": "EXCEPTION",\n' +
//                '"payee_name": "JE Plumbing Services",\n' +
//                '"payment_date": "20150220",\n' +
//                '"payment_amount": 1000.98,\n' +
//                '}');
//            res.setStatusCode(200);

            //Comment this line below to use mock responses from DEV Environment
            res = ServiceConnectorHelper.sendWellsFargoRequest('GET', request, headers, null);
            WellsFargo.WFErrors errorsResp;
            try{
                errorsResp = (WellsFargo.WFErrors) JSON.deserialize(res.getBody(), WellsFargo.WFErrors.class);
            }catch(Exception ex){
                System.debug('Deserialize exception: Sending the wrong response?: HttpResp: ' + res.getBody() + ', Raw exc: ' + ex.getMessage());
            }

            wfRequest.achLog.log.Request__c =  request;
            wfRequest.achLog.log.Response__c = res?.getBody();
            wfRequest.achLog.log.Log_Date__c = Datetime.now();
            wfRequest.achLog.log.Response_Code__c = String.valueOf(res.getStatusCode());
            wfRequest.achLog.log.Status__c = Constant.ACH_TRANSACTION_LOG_STATUS_COMPLETED;

            if(res.getStatusCode() == 200) {
                WellsFargo.ACHPaymentStatusResponse webhookReturn = (WellsFargo.ACHPaymentStatusResponse)JSON.deserialize(res?.getBody(), WellsFargo.ACHPaymentStatusResponse.class);
                if(webhookReturn.payment_status?.equalsIgnoreCase(WellsFargo.PAYMENT_STATUS_PROCESSED)){
                    wfRequest.achLog.log.ACH_Trace_Number__c = webhookReturn.trace_number;
                    wfRequest.achLog.log.Status__c = Constant.ACH_TRANSACTION_LOG_STATUS_COMPLETED;
                }else if(webhookReturn.payment_status?.equalsIgnoreCase(WellsFargo.PAYMENT_STATUS_PENDING)){
                    wfRequest.achLog.log.Status__c = Constant.ACH_TRANSACTION_LOG_STATUS_COMPLETED;
                }else if(webhookReturn.payment_status?.equalsIgnoreCase(WellsFargo.PAYMENT_STATUS_EXCEPTION)){
                    wfRequest.achLog.log.Status__c = Constant.ACH_TRANSACTION_LOG_STATUS_FAILED;
                }
            }
        }catch(Exception ex){
            if(String.isNotBlank(wfRequest.achLog.log.Response__c)){
                wfRequest.achLog.log.Response__c = wfRequest.achLog.log.Response__c + '\n\n Exception: ' + ex.getMessage();
            }else{
                wfRequest.achLog.log.Response__c = ex.getMessage();
            }
            wfRequest.achLog.log.Log_Date__c = Datetime.now();
            wfRequest.achLog.log.Status__c = Constant.ACH_TRANSACTION_LOG_STATUS_COMPLETED;
        }
    }

    public static void achNotificationsCheck(WellsFargo wfRequest, Integer pageNumber){
        //Create Map for request's headers
        Map<String, String> headers = new Map<String, String>{
                'gateway-entity-id' => WF_Settings.Gateway_Entity_Id__c,
                'client-request-id' => getUUID(),
                'Content-Type' =>'application/json',
                'Authorization' => 'Bearer ' + wfRequest.token
        };

        try{
            Integer daysBack = WF_Settings.Days_Back_Retrieve_Notifications__c != null ? Integer.valueOf(WF_Settings.Days_Back_Retrieve_Notifications__c) : 5;
            if(Test.isRunningTest() && THROW_TEST_EXCEPTION){
                CalloutException ex = new CalloutException();
                ex.setMessage('Exception message for testing purposes');
                throw ex;
            }
            String startDatetime = getDateForNotificationCheckRequest(System.today().addDays(-daysBack));
            String endDatetime = getDateForNotificationCheckRequest(System.today());

            String request = WF_Settings.WF_CHECK_NOTIFICATIONS_URL__c + '?start_datetime=' + startDatetime + '&end_datetime=' + endDatetime + '&page=' + pageNumber;
            HttpResponse res = ServiceConnectorHelper.sendWellsFargoRequest('GET', request, headers, null);
            WellsFargo.WFErrors errorsResp;
            try{
                errorsResp = (WellsFargo.WFErrors) JSON.deserialize(res.getBody(), WellsFargo.WFErrors.class);
            }catch(Exception ex){
                System.debug('Deserialize exception: Sending the wrong response?: HttpResp: ' + res.getBody() + ', Raw exc: ' + ex.getMessage());
            }

            if(res.getStatusCode() == 200) {
                wfRequest.rawResponse = res?.getBody();
            }else{
                wfRequest.hasErrors = true;
                wfRequest.achLog.log.Status__c = Constant.ACH_TRANSACTION_LOG_STATUS_FAILED;
                wfRequest.achLog.log.Request__c =  request;
                wfRequest.achLog.log.Response__c = res?.getBody();
                wfRequest.achLog.log.Log_Date__c = Datetime.now();
                wfRequest.achLog.log.Response_Code__c = String.valueOf(res.getStatusCode());
                if(errorsResp != null && !errorsResp.errors?.isEmpty()){
                    for(WellsFargo.Error apiErrorCode : errorsResp.errors) wfRequest.achLog.log.Error_Code__c = apiErrorCode.error_code;
                }
            }
        }catch(Exception ex){
            wfRequest.hasErrors = true;
            wfRequest.achLog.log.Status__c = Constant.ACH_TRANSACTION_LOG_STATUS_FAILED;
            wfRequest.achLog.log.Response__c = ex.getMessage();
            if(String.isNotBlank(wfRequest.achLog.log.Response__c)) wfRequest.achLog.log.Response__c = wfRequest.achLog.log.Response__c + '\n\n Exception: ' + ex.getMessage();
        }
    }

    //get ACHRequest.PaymentRequestBody FROM the payment record
    private static WellsFargo.PaymentRequestBody processPaymentsRequestBody(SObject pay){
        WellsFargo.PaymentRequestBody paymentReq = new WellsFargo.PaymentRequestBody();
        if(pay.getSObjectType() == cmbls__Disbursement__c.getSObjectType()){
            String credentialKey = getCredentialKey(pay);
            paymentReq.payment_id =  getWFConfigValue('transactionId_Dis', pay);
            paymentReq.debit_credit_indicator = getWFConfigValue('creditIndicator_Dis', pay);
            paymentReq.payment_amount = Double.valueOf(getWFConfigValue('transactionAmount_Dis', pay));
            paymentReq.payment_description = String.isBlank(getWFConfigValue('description_Dis', pay)) ? 'No description.' : getWFConfigValue('description_Dis', pay);
            paymentReq.payment_format = getWFConfigValue('paymentFormat_Dis', pay);
            paymentReq.payment_method = getWFConfigValue('paymentMethod_Dis', pay);
            paymentReq.payment_date = getDateFormat((Date)pay.get('cmbls__Effective_Date__c'));

            //Payee
            paymentReq.payee.name = getNameForAPIRequest(getWFConfigValue('payeeName_Dis', pay));
            paymentReq.payee.bank_information.bank_account_number = getWFConfigValue('payeeNumber_Dis', pay);
            paymentReq.payee.bank_information.bank_account_type = getWFConfigField(getWFConfigValue('payeeType_Dis', pay));
            paymentReq.payee.bank_information.bank_id = getWFConfigValue('payeeId_Dis', pay);
            paymentReq.payee.bank_information.bank_id_type = getWFConfigValue('payeeIdType_Dis', pay);

            //Payer
            paymentReq.payer.name = getNameForAPIRequest(getWFCredentialValue(credentialKey, 'Credit_Bank_Account_Name__c'));
            paymentReq.payer.bank_information.bank_account_number = getWFCredentialValue(credentialKey, 'Credit_Bank_Account_Number__c');
            paymentReq.payer.bank_information.bank_account_type = getWFCredentialValue(credentialKey, 'Credit_Bank_Account_Type__c');
            paymentReq.payer.bank_information.bank_id = getWFCredentialValue(credentialKey, 'Credit_Bank_Id__c');
            paymentReq.payer.bank_information.bank_id_type = getWFCredentialValue(credentialKey, 'Credit_Bank_Id_Type__c');

        }else if(pay.getSObjectType() == cmbls__Payment__c.getSObjectType()){
            String credentialKey = getCredentialKey(pay);
            paymentReq.payment_id = getWFConfigValue('transactionId_Pay', pay);
            paymentReq.debit_credit_indicator = getWFConfigValue('creditIndicator_Pay', pay);
            paymentReq.payment_amount = Double.valueOf(getWFConfigValue('transactionAmount_Pay', pay));
            paymentReq.payment_description = String.isBlank(getWFConfigValue('description_Pay', pay)) ? 'No description.' : getWFConfigValue('description_Pay', pay);
            paymentReq.payment_format = getWFConfigValue('paymentFormat_Pay', pay);
            paymentReq.payment_method = getWFConfigValue('paymentMethod_Pay', pay);
            paymentReq.payment_date = getDateFormat((Date)pay.get('cmbls__Effective_Date__c'));

            //Payee
            paymentReq.payee.name = getNameForAPIRequest(getWFCredentialValue(credentialKey, 'Debit_Bank_Account_Name__c'));
            paymentReq.payee.bank_information.bank_account_number = getWFCredentialValue(credentialKey, 'Debit_Bank_Account_Number__c');
            paymentReq.payee.bank_information.bank_account_type = getWFCredentialValue(credentialKey, 'Debit_Bank_Account_Type__c');
            paymentReq.payee.bank_information.bank_id = getWFCredentialValue(credentialKey, 'Debit_Bank_Id__c');
            paymentReq.payee.bank_information.bank_id_type = getWFCredentialValue(credentialKey, 'Debit_Bank_Id_Type__c');

            //Payer
            paymentReq.payer.name = getNameForAPIRequest(getWFConfigValue('payerName_Pay', pay));
            paymentReq.payer.bank_information.bank_account_number = getWFConfigValue('payerNumber_Pay', pay);
            paymentReq.payer.bank_information.bank_account_type = getWFConfigField(getWFConfigValue('payerType_Pay', pay));
            paymentReq.payer.bank_information.bank_id = getWFConfigValue('payerId_Pay', pay);
            paymentReq.payer.bank_information.bank_id_type = getWFConfigValue('payerIdType_Pay', pay);
        }
        return paymentReq;
    }
    
    public static String getNameForAPIRequest(String value){
        String output = value?.replaceAll('[^a-zA-Z0-9]', '');
        if(String.isNotBlank(output) && output.length() > 60){
            output = output.substring(0, 60);
        }
        return output;
    }

    //get a new UUID for the WF integration
    public static String getUUID(){
        Blob b = Crypto.generateAesKey(128);
        String h = EncodingUtil.convertToHex(b);
        String guid = h.substring(0,10)+ '-' + h.substring(10,15) + '-' + h.substring(15,20) ;
        return guid;
    }

    public static String getWFConfigField(String mdRecordName){
        initWFConfig();
        if(WF_Fields.containsKey(mdRecordName)){
            return WF_Fields.get(mdRecordName).SF_Field__c;
        }
        return '';
    }

    public static String getWFConfigValue(String mdRecordName, SObject sobj){
        initWFConfig();
        if(WF_Fields.containsKey(mdRecordName)){
            WellsFargo_Config__mdt mdt_record = WF_Fields.get(mdRecordName);
            if(mdt_record.Type__c == 'Field'){
                return sobj.get(mdt_record.SF_Field__c) != null ? sobj.get(mdt_record.SF_Field__c) + '' : '';
            }else if(mdt_record.Type__c == 'Fixed'){
                return mdt_record.SF_Field__c;
            }
        }
        return '';
    }

    public static String getWFCredentialValue(String credentialKey, String fieldName){
        initWFCredentials();
        if(WF_Credentials.containsKey(credentialKey)){
            Wells_Fargo_Credentials__c cred_record = WF_Credentials.get(credentialKey);
            return '' + cred_record.get(fieldName);
        }
        return '';
    }

    public static String getCredentialKey(SObject sobj){
        String tmpProcessor = (String)sobj.get('cmbls__ACH_Processor__c');
        if(String.isNotEmpty(tmpProcessor)){
            String processor = tmpProcessor.substringAfter('-').trim();
            if (String.isNotBlank(processor)) {
                return processor;
            }
        }
        return '';
    }

    public static String getDateFormat(Date value){
        if(value == null) value = System.today().addDays(1);
        return value.year() + String.valueOf('0' + value.month()).right(2) + String.valueOf('0' + value.day()).right(2);
    }

    private static List<String> getErrorCodes(){
        List<String> lstErrorsCodes = new List<String>();
        if(String.isBlank(WF_Settings.Error_Codes_To_Resubmit_Request__c)) return lstErrorsCodes;
        lstErrorsCodes.addAll(WF_Settings.Error_Codes_To_Resubmit_Request__c.split(';'));
        lstErrorsCodes.addAll(WF_Settings.Error_Codes_To_Resubmit_Request__c.split(','));
        return lstErrorsCodes;
    }

    private static void initWFCredentials(){
        if(WF_Credentials == null){
            WF_Credentials = new Map<String, Wells_Fargo_Credentials__c>();
            for(Wells_Fargo_Credentials__c fc : [SELECT
                    ACH_Processor_Key__c,
                    Credit_Bank_Account_Name__c, Credit_Bank_Account_Number__c, Credit_Bank_Account_Type__c, Credit_Bank_Id__c, Credit_Bank_Id_Type__c,
                    Debit_Bank_Account_Name__c, Debit_Bank_Account_Number__c, Debit_Bank_Account_Type__c,  Debit_Bank_Id__c, Debit_Bank_Id_Type__c
            FROM Wells_Fargo_Credentials__c]){
                WF_Credentials.put(fc.ACH_Processor_Key__c, fc);
            }
        }

    }

    private static void initWFConfig(){
        if(WF_Fields == null){
            WF_Fields = new Map<String, WellsFargo_Config__mdt>();
            for(WellsFargo_Config__mdt fc : [SELECT DeveloperName,Type__c,SF_Field__c FROM WellsFargo_Config__mdt]){
                WF_Fields.put(fc.DeveloperName, fc);
            }
        }
    }

    public static Integer getNextTimePaymentsJobWillRun(){
        return NumberUtils.getInteger(WellsFargoAPI.WF_Settings.Next_Resubmission_Attempt_Minutes__c) == 0 ? DEFAULT_MINUTES_NEX_TIME_JOB_WILL_RUN : NumberUtils.getInteger(WellsFargoAPI.WF_Settings.Next_Resubmission_Attempt_Minutes__c);
    }

    public static Integer getMaxNumberRecordsWellsFargoAPISupports(){
        return NumberUtils.getInteger(WellsFargoAPI.WF_Settings.WellsFargo_Max_Number_Records_Per_Batch__c) == 0 ? MAX_NUMBER_RECORDS_API_SUPPORTS_PER_MINUTE : NumberUtils.getInteger(WellsFargoAPI.WF_Settings.WellsFargo_Max_Number_Records_Per_Batch__c);
    }

    private static String getDateForNotificationCheckRequest(Date dateValue){
        if(dateValue == null) dateValue = System.today();
        String day = ('0' + dateValue.day()).right(2);
        String month = ('0' + dateValue.month()).right(2);
        return dateValue.year() + '-' + month + '-' + day + 'T00:00:00Z';
    }
    
    private static Boolean isTimedOutException(String body){
        if(String.isBlank(body)) return false;
        return  body.containsIgnoreCase('Read timed out') ||
                body.containsIgnoreCase('Exceeded maximum time');
    }
}