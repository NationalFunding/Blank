/**
 * Created on 22/02/2022.
 *  * Batch class to integrate all scheduled Payments with Wells Fargo System.
  *
 */
global class PaymentsBatchProcessor implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.Stateful, Schedulable{

    static Integer DEFAULT_BATCH_SIZE = 90;

    //Process to execute(Payment integration / Payment status check)
    String process;
    //Access token to access WF API
    String accessToken;
    List<ACHTransactionLog> achLogs;
    Map<String, cmbls__ACH_Batch__c> payBatches = new Map<String, cmbls__ACH_Batch__c>();
    Map<String, cmbls__Disbursement_Batch__c> disBatches = new Map<String, cmbls__Disbursement_Batch__c>();

    Map<Id, Set<Id>> recordsForResubmission;

    Map<Id, ACH_Transaction_Log__c> mapACHTransactionsByPmtDisb = new Map<Id, ACH_Transaction_Log__c>();
    Integer numberRecordsSentToAPI;

    static Boolean doRecursion = true;

    // This is used to force a timeout for every other chunk in the batch
    public Boolean testTimeoutEveryOtherChunk = false;

    @TestVisible private static Boolean PROCESS_ACH_TRANSACTIONS_BATCH = true;
    @TestVisible private static final String DEBUG_LOG_BATCH_UPDATE_FAILURE_SUBJECT = '{0} Job: {1} ACH Batch record update failure.';
    @TestVisible private static final String DEBUG_LOG_BATCH_UPDATE_FAILURE_DESCRIPTION = '{0} ACH Batch record tried to be updated but failed';
    @TestVisible private static final String DEBUG_LOG_ACH_LOG_INSERT_FAILURE_SUBJECT = '{0} Job: ACH Transaction Log record insert failure.';
    @TestVisible private static final String DEBUG_LOG_ACH_LOG_INSERT_FAILURE_DESCRIPTION = 'ACH Transaction Log record tried to be inserted but failed';
    @TestVisible private static Boolean throwACHTransactionLogInsertError = false;

    public PaymentsBatchProcessor(String p){
        process = p;
        achLogs = new List<ACHTransactionLog>();
        recordsForResubmission = new Map<Id, Set<Id>>();
        numberRecordsSentToAPI = 0;
    }

    public PaymentsBatchProcessor(String p, Map<Id, Set<Id>> resubmissionRecords){
        this(p);
        recordsForResubmission = resubmissionRecords;
    }

    public PaymentsBatchProcessor(String p, Set<Id> achBatches){
        this(p);
        recordsForResubmission = PaymentSelector.getScheduledPaymentsByBatchIds(achBatches);
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        Set<Id> resubmissionRecords = new Set<Id>();
        if(!recordsForResubmission.isEmpty()){
            for(Set<Id> recordIds :recordsForResubmission.values()) resubmissionRecords.addAll(recordIds);
        }
        return Database.getQueryLocator(PaymentService.getPendingPayments(process, resubmissionRecords));
    }

    global void execute(Database.BatchableContext BC, List<SObject> scope){
        List<cmbls__Debug_Log__c> debugLogs = new List<cmbls__Debug_Log__c>();
        accessToken = WellsFargoAPI.getAccessToken();
        //TODO refactor this so it is declared in the execute scope
        achLogs.clear();
        // reset recordsForResubmission - these were already returned in query locator and if left populated will result in resubmission loop
        recordsForResubmission = new Map<Id, Set<Id>>();
        for(SObject record : scope) populateBatches(record);
        if(process == WellsFargoAPI.PAYMENTS_PROCESS || process == WellsFargoAPI.DISBURSEMENT_PROCESS){
            mapACHTransactionsByPmtDisb = ACHTransactionsSelector.getTransactionsByPmtOrDisbursement(scope);
            processPayments(scope);
        }

        ACH_Transaction_Log__c[] achTransactionLogs = ACHTransactionLog.getLogs(achLogs);

        // If testing timeouts, set every other batch chunk ach transaction logs to timeout errors
        if (testTimeoutEveryOtherChunk) {
            if (Math.mod(numberRecordsSentToAPI, 2) == 0) {
                for (ACH_Transaction_Log__c log : achTransactionLogs) {
                    log.Description__c = null;
                    log.Error_Code__c = null;
                    log.Response__c = 'Exceeded maximum time allotted for callout (120000 ms)';
                    log.Status__c = 'Completed';
                    log.Response_Code__c = null;
                }
            }
        }

        if(Test.isRunningTest() && throwACHTransactionLogInsertError){
            achTransactionLogs[0].Payment__c = 'a8X3n000000h42EEAQ'; //Adding Wrong Id here to make insert to fails and add a Debug Log
        }

        Integer index = 0;
        for(Database.SaveResult result :Database.insert(achTransactionLogs, false)){
            if(!result.isSuccess()){
                cmbls__Debug_Log__c log = UtilityTools.getDebugLogForDMLErrors(null, achTransactionLogs[index], result.getErrors());
                log.cmbls__Subject__c = String.format(DEBUG_LOG_ACH_LOG_INSERT_FAILURE_SUBJECT, new String[]{getJobName(process)});
                log.cmbls__Description__c = DEBUG_LOG_ACH_LOG_INSERT_FAILURE_DESCRIPTION;
                debugLogs.add(log);
            }
            index++;
        }

        insert debugLogs;
    }

    // Schedulable
    global void execute(SchedulableContext ctx) {
        if (!UtilityTools.isBatchRunning('PaymentsBatchProcessor')) {
            Database.executeBatch(new PaymentsBatchProcessor(process, recordsForResubmission), getBatchScope());
        }
    }

    global void finish(Database.BatchableContext BC){
        updateRelatedACHBatches();
        resubmitJob();
        executeNextBatchJobs();
    }

    private void resubmitJob(){
        PaymentsBatchProcessor cls;

        // Resubmission of records
        if(!recordsForResubmission.isEmpty() && doRecursion){
            cls = new PaymentsBatchProcessor(process, recordsForResubmission);
        }else{
            Integer pendingPayments = Database.countQuery(PaymentService.getPendingPaymentsCount(process, new Set<Id>()));
            if(pendingPayments > 0) cls = new PaymentsBatchProcessor(process);
        }

        if(doRecursion && cls != null){
            if(Test.isRunningTest()) doRecursion = false;
            //parse to cron expression
            String nextFireTime = DateTimeUtils.getCronExpressionForGivenDatetime(System.now().addMinutes(WellsFargoAPI.getNextTimePaymentsJobWillRun()));
            if(doRecursion) System.schedule(getJobName(process) + ' [Resubmission] - ' + nextFireTime, nextFireTime, new PaymentsBatchProcessor(process, recordsForResubmission));
        }
    }

    private void processPayments(List<SObject> scope){
        for(SObject record : scope){
            WellsFargo achRequest = new WellsFargo();
            achRequest.record = record;
            achRequest.token = accessToken;
            achRequest.processRecord = sendToWellsFargo(record);
            if(achRequest.processRecord){
                numberRecordsSentToAPI += 1;
                WellsFargoAPI.processPayment(achRequest);
                achRequest.achLog.setLookupField(achRequest.record.Id);
                achLogs.add(achRequest.achLog);
            }
            processBatch(achRequest);
        }
    }

    private Boolean sendToWellsFargo(SObject record){
        Boolean processBatch = true;
        SObject batch;

        if(DisbursementUtils.isDisbursement(record)){
            batch = getDisbursementBatch((cmbls__Disbursement__c)record);
        }else if(PaymentUtils.isPayment(record)){
            batch = getACHBatch((cmbls__Payment__c) record);
        }

        if(batch != null){
            Integer numOfAttempts = NumberUtils.getInteger((Decimal)batch.get('WellsFargo_Number_of_Attempts__c'));
            processBatch = numOfAttempts < NumberUtils.getInteger(WellsFargoAPI.WF_Settings.Max_Number_of_attempts__c) && numberRecordsSentToAPI < WellsFargoAPI.getMaxNumberRecordsWellsFargoAPISupports();
        }
        // In regards to the ACH Logs, If no ACH Transaction Log record or the Http Status Code is not successfully, it will do the callout to WellsFargo.
        return (
            !mapACHTransactionsByPmtDisb.containsKey(record.Id) || mapACHTransactionsByPmtDisb.get(record.Id).Response_Code__c != '201'
        ) && processBatch;
    }

    private void processBatch(WellsFargo achRequest){
        SObject originalBatch;

        if(DisbursementUtils.isDisbursement(achRequest.record)){
            cmbls__Disbursement__c tmpDis = (cmbls__Disbursement__c)achRequest.record;
            cmbls__Disbursement_Batch__c disbursementBatch = getDisbursementBatch(tmpDis);

            if(isSuccessTransaction(achRequest)){
                disbursementBatch.cmbls__Number_of_Pending_Disbursements__c ++;
                disbursementBatch.cmbls__Total_Pending_Disbursement_Amount__c += tmpDis.cmbls__Transaction_Amount__c;

            }else if(isFailedTransaction(achRequest, tmpDis.cmbls__Status__c)){
                disbursementBatch.cmbls__Number_of_Failed_Disbursements__c++;
                disbursementBatch.cmbls__Total_Failed_Disbursement_Amount__c += tmpDis.cmbls__Transaction_Amount__c;
            }

            disbursementBatch.cmbls__Batch_Date_Time__c = Datetime.now();
            disbursementBatch.cmbls__Number_of_Transactions__c++;
            disbursementBatch.cmbls__Total_Transaction_Amount__c += tmpDis.cmbls__Transaction_Amount__c;

            originalBatch = disbursementBatch;
        }else if(PaymentUtils.isPayment(achRequest.record)) {
            cmbls__Payment__c tmpPay = (cmbls__Payment__c) achRequest.record;
            cmbls__ACH_Batch__c paymentBatch = getACHBatch(tmpPay);

            if(isSuccessTransaction(achRequest)){
                paymentBatch.cmbls__Number_of_Pending_Payments__c++;
                paymentBatch.cmbls__Total_Pending_Payment_Amount__c += tmpPay.cmbls__Transaction_Amount__c;

            }else if(isFailedTransaction(achRequest, tmpPay.cmbls__Status__c)){
                paymentBatch.cmbls__Number_of_Failed_Payments__c++;
                paymentBatch.cmbls__Total_Failed_Payment_Amount__c += tmpPay.cmbls__Transaction_Amount__c;
            }

            paymentBatch.cmbls__Batch_Date_Time__c = Datetime.now();
            paymentBatch.cmbls__Number_of_Transactions__c++;
            paymentBatch.cmbls__Total_Transaction_Amount__c += tmpPay.cmbls__Transaction_Amount__c;

            originalBatch = paymentBatch;
        }

        if(shouldResubmitBatch(achRequest)){
            Set<Id> records = recordsForResubmission.get(originalBatch.Id);
            if(records == null) records = new Set<Id>();
            records.add(achRequest.record.Id);
            recordsForResubmission.put(originalBatch.Id, records);
        }
    }

    private void populateBatches(SObject record){
        if(PaymentUtils.isPayment(record)){
            cmbls__Payment__c payment = (cmbls__Payment__c)record;
            if(!payBatches.containsKey(payment.cmbls__ACH_Batch__c)){
                cmbls__ACH_Batch__c batch = payment.cmbls__ACH_Batch__r;
                ACHBatchManager.resetACHBatchFields(batch);
                payBatches.put(batch.Id, batch);
            }
        }else if(DisbursementUtils.isDisbursement(record)){
            cmbls__Disbursement__c disbursement = (cmbls__Disbursement__c)record;
            if(!disBatches.containsKey(disbursement.cmbls__Disbursement_Batch__c)){
                cmbls__Disbursement_Batch__c batch = disbursement.cmbls__Disbursement_Batch__r;
                DisbursementBatchManager.resetDisbursementBatchFields(batch);
                disBatches.put(batch.Id, batch);
            }
        }
    }

    private cmbls__Disbursement_Batch__c getDisbursementBatch(cmbls__Disbursement__c disbursement){
        return disBatches.get(disbursement.cmbls__Disbursement_Batch__c);
    }

    private cmbls__ACH_Batch__c getACHBatch(cmbls__Payment__c payment){
        return payBatches.get(payment.cmbls__ACH_Batch__c);
    }

    private Boolean shouldResubmitBatch(WellsFargo achRequest){
        return  (achRequest.doResubmission && !achRequest.failedRecord) ||
                numberRecordsSentToAPI > WellsFargoAPI.getMaxNumberRecordsWellsFargoAPISupports();
    }

    private static Boolean isSuccessTransaction(WellsFargo achRequest){
        return achRequest.achLog.log != null && achRequest.achLog.log.Status__c == Constant.ACH_TRANSACTION_LOG_WF_SENT;
    }

    private Boolean isFailedTransaction(WellsFargo achRequest, String recordStatus){
        return achRequest.achLog.log.Status__c == Constant.ACH_TRANSACTION_LOG_STATUS_FAILED || (mapACHTransactionsByPmtDisb.containsKey(achRequest.record.Id)
            && mapACHTransactionsByPmtDisb.get(achRequest.record.Id).Status__c == Constant.ACH_TRANSACTION_LOG_STATUS_FAILED) ||
            recordStatus == Constant.STATUS_FAILED;
    }

    private void updateRelatedACHBatches(){
        SObject[] achBatches = new SObject[]{};
        achBatches.addAll(payBatches.values());
        achBatches.addAll(disBatches.values());
        for(SObject batch :achBatches){
            batch.put('cmbls__Batch_Date_Time__c', System.now());
            batch.put('cmbls__Status__c', Constant.DISBURSEMENT_BATCH_STATUS_SUCCESS);

            Decimal numberOfAttempts = (Decimal)batch.get('WellsFargo_Number_of_Attempts__c');
            // We log the attempt only if we don't exceed the max number records the api supports, that way we don't reduce attempts for resubmissions.
            if(numberRecordsSentToAPI <= WellsFargoAPI.getMaxNumberRecordsWellsFargoAPISupports()){
                numberOfAttempts = NumberUtils.getInteger(numberOfAttempts) + 1;
                batch.put('WellsFargo_Number_of_Attempts__c', numberOfAttempts);
            }

            if(numberOfAttempts == NumberUtils.getInteger(WellsFargoAPI.WF_Settings.Max_Number_of_attempts__c)){
                batch.put('cmbls__Description__c', 'Max number of resubmission attempts reached.');
            }

            if(recordsForResubmission.containsKey(batch.Id)){
                if(numberOfAttempts >= NumberUtils.getInteger(WellsFargoAPI.WF_Settings.Max_Number_of_attempts__c)){
                    recordsForResubmission.remove(batch.Id);
                }else{
                    batch.put('cmbls__Status__c', Constant.ACH_BATCH_STATUS_RESUBMISSION);
                }
            }
        }

        Map<Id, SObject> achBatchesMap = new Map<Id, SObject>(achBatches);

        List<cmbls__Debug_Log__c> debugLogs = new List<cmbls__Debug_Log__c>();
        for(Database.SaveResult result :Database.update(achBatches, false)){
            if(!result.isSuccess()){
                String processType = process == WellsFargoAPI.PAYMENTS_PROCESS ? 'WellsFargo - Process Payments' : 'WellsFargo - Process Disbursements';
                cmbls__Debug_Log__c log = UtilityTools.getDebugLogForDMLFailure(null, achBatchesMap.get(result.getId()), result);
                log.cmbls__Subject__c = String.format(DEBUG_LOG_BATCH_UPDATE_FAILURE_SUBJECT, new String[]{getJobName(process), processType});
                log.cmbls__Description__c = String.format(DEBUG_LOG_BATCH_UPDATE_FAILURE_DESCRIPTION, new String[]{processType});
                debugLogs.add(log);
            }
        }

        insert debugLogs;
    }

    private void executeNextBatchJobs(){
        if(PROCESS_ACH_TRANSACTIONS_BATCH && recordsForResubmission.isEmpty()){
            if(process == WellsFargoAPI.DISBURSEMENT_PROCESS){
                // Process ACH Transactions right after created.
                Database.executeBatch(new BatchProcessACHTransactions(cmbls__Disbursement__c.getSObjectType().getDescribe().getName()), BatchProcessACHTransactions.batchSize);
            }else if(process == WellsFargoAPI.PAYMENTS_PROCESS){
                // Process ACH Transactions right after created.
                Database.executeBatch(new BatchProcessACHTransactions(cmbls__Payment__c.getSObjectType().getDescribe().getName()), BatchProcessACHTransactions.batchSize);
            }
        }
        executeUpdateStatusJob();
    }

    private static void executeUpdateStatusJob(){
        if(SentPaymentsProcessorBatch.batchIsNotRunning(null)){
            Database.executeBatch(new SentPaymentsProcessorBatch(), PaymentsBatchProcessor.getBatchScope());
        }
    }

    public static String getJobName(String processType){
        String output = 'Wells Fargo - Process ';
        if(processType == WellsFargoAPI.PAYMENTS_PROCESS){
            output += 'Payments';
        }else if(processType == WellsFargoAPI.DISBURSEMENT_PROCESS){
            output += 'Disbursements';
        }
        return output;
    }

    public static Integer getBatchScope(){
        Decimal batchScopeFromSettings = WellsFargoAPI.WF_Settings.WF_Batch_Scope__c;
        Integer output = (batchScopeFromSettings == null || batchScopeFromSettings == 0) ? DEFAULT_BATCH_SIZE : Integer.valueOf(batchScopeFromSettings);
        return output > 90 ? DEFAULT_BATCH_SIZE : output;
    }
}