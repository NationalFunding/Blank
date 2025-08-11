/**
 * BatchCheckACHTransactionStatus class
 * @author CloudMyBiz (r)
 * @date 07/02/2023
 * @info If you use a QueryLocator object, the governor limit for the total number of records retrieved by SOQL queries is bypassed
 * Use the iterable to create a complex scope for the batch job. You can also use the iterable to create your own custom process for iterating through the list.
  (If you use an iterable, the governor limit for the total number of records retrieved by SOQL queries is still enforced.)
 * @group Batch
 */
global class BatchCheckACHTransactionStatus implements Database.Batchable<SObject>, Schedulable, Database.AllowsCallouts{

    public static Integer batchSize = 5;
    private String objectType;
    private String accessToken;

    global BatchCheckACHTransactionStatus(){}

    global BatchCheckACHTransactionStatus(String objectType) {
        this.objectType = objectType;
    }

    global Iterable<SObject> start(Database.BatchableContext bc) {
        ACHTransactionIterator.queryType = ACHTransactionIterator.IteratorQueryType.SENT_TO_WF_ACH_TRANSACTIONS;
        return (Iterable<SObject>) new ACHTransactionIterator(this.objectType);
    }

    global void execute(Database.BatchableContext bc, List<ACH_Transaction_Log__c> scope) {

        this.accessToken = WellsFargoAPI.getAccessToken();
        WF_Api_Settings__c settings = WF_Api_Settings__c.getInstance();
        
        List<SObject> relatedRecordsForUpdate = new List<SObject>();
        List<ACH_Transaction_Log__c> logsForUpsert = new List<ACH_Transaction_Log__c>();
        for(ACH_Transaction_Log__c achOriginalLog : scope) {
            String transactionId = '';
            SObject relatedRecord;
            if (achOriginalLog.Payment__c != null) {
                relatedRecord = achOriginalLog.Payment__r;
                transactionId = achOriginalLog.Payment__r.Wells_Fargo_Payment_ID_Formula__c;
            } else if (achOriginalLog.Disbursement__c != null) {
                relatedRecord = achOriginalLog.Disbursement__r;
                transactionId = achOriginalLog.Disbursement__r.Wells_Fargo_Disbursement_ID_Formula__c;
            }

            WellsFargo achRequest = new WellsFargo();
            achRequest.record = relatedRecord;
            achRequest.token = this.accessToken;
            WellsFargoAPI.achPaymentStatusCheck(achRequest, transactionId);
            achRequest.achLog.setLookupField(achRequest.record.Id);
            logsForUpsert.add(achRequest.achLog.log);
    
            String recordStatus = (String)relatedRecord.get('cmbls__Status__c');
            Date recordEffectiveDate = (Date)relatedRecord.get('cmbls__Effective_Date__c');
            Date settlementDate = Date.today().addDays(NumberUtils.getInteger(NF_ACH_Info__c.getInstance().Settlement_in_Business_day__c));
            Boolean markAsSettled = settings.Pre_Pending_Payments_in_Settlement_Delay__c &&
                                    recordStatus == PaymentUtils.PAYMENT_STATUS_PRE_PENDING &&
                                    recordEffectiveDate != null && settlementDate <= recordEffectiveDate;
            
            // If we have an ACH Trace number means that payment was processed correctly.
            if(String.isNotBlank(achRequest.achLog?.log.ACH_Trace_Number__c) || markAsSettled){
                achOriginalLog.Status__c = Constant.ACH_TRANSACTION_LOG_STATUS_PENDING;
                if(markAsSettled){
                    relatedRecord.put('cmbls__Status__c', Constant.STATUS_SETTLED);
                    achOriginalLog.Status__c = Constant.ACH_TRANSACTION_LOG_STATUS_COMPLETED;
                    relatedRecordsForUpdate.add(relatedRecord);
                }
                logsForUpsert.add(achOriginalLog);
            }
        }
        upsert logsForUpsert;
        update relatedRecordsForUpdate;
    }

    global void finish(Database.BatchableContext bc) {

    }

    global void execute (SchedulableContext ctx) {
        Database.executeBatch(new BatchCheckACHTransactionStatus(cmbls__Disbursement__c.getSObjectType().getDescribe().getName()), BatchCheckACHTransactionStatus.batchSize);
        Database.executeBatch(new BatchCheckACHTransactionStatus(cmbls__Payment__c.getSObjectType().getDescribe().getName()), BatchCheckACHTransactionStatus.batchSize);
    }

}