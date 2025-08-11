/**
 * BatchProcessACHTransactions class
 * @author CloudMyBiz (r)
 * @date 14/07/2022
 * @info If you use a QueryLocator object, the governor limit for the total number of records retrieved by SOQL queries is bypassed
 * Use the iterable to create a complex scope for the batch job. You can also use the iterable to create your own custom process for iterating through the list.
  (If you use an iterable, the governor limit for the total number of records retrieved by SOQL queries is still enforced.)
 * @group Batch
 */
global class BatchProcessACHTransactions implements Database.Batchable<SObject>, Schedulable{

    public static Integer batchSize;
    private String objectType;

    private static final NF_ACH_Info__c settings = NF_ACH_Info__c.getInstance();

    static{
        batchSize = settings.Settlement_Delay_Batch_Size__c == null ? 50 : Integer.valueOf(settings.Settlement_Delay_Batch_Size__c);
    }

    global BatchProcessACHTransactions(String objectType){
        this.objectType = objectType;
    }

    global Iterable<SObject> start(Database.BatchableContext bc) {
        ACHTransactionIterator.queryType = ACHTransactionIterator.IteratorQueryType.NOT_RESOLVED_ACH_TRANSACTIONS;
        return (Iterable<SObject>) new ACHTransactionIterator(this.objectType);
    }

    global void execute(Database.BatchableContext bc, List<ACH_Transaction_Log__c> scope) {
        List<SObject> relatedRecordsForUpdate = new List<SObject>();
        List<cmbls__Payment__c> paymentRecordsForInsert = new List<cmbls__Payment__c>();
        List<ACH_Transaction_Log__c> achLogsForUpdate = new List<ACH_Transaction_Log__c>();
        Integer settlementDelay = NumberUtils.getInteger(settings.Settlement_in_Business_day__c);
        Date settlementDate = Date.today().addDays(settlementDelay * -1);
        
        for(ACH_Transaction_Log__c achLog : scope){
            SObject relatedRecord;
            if(achLog.Payment__c != null){
                relatedRecord = achLog.Payment__r;
            }else if(achLog.Disbursement__c != null){
                relatedRecord = achLog.Disbursement__r;
            }
            
            if(relatedRecord != null){
                String recordStatus = (String)relatedRecord.get('cmbls__Status__c');
                if(achLog.Status__c == Constant.ACH_TRANSACTION_LOG_STATUS_FAILED){
                    if(recordStatus == Constant.STATUS_SCHEDULED || recordStatus == Constant.STATUS_PENDING || recordStatus == PaymentUtils.PAYMENT_STATUS_PRE_PENDING){
                        relatedRecord.put('cmbls__Status__c', Constant.STATUS_FAILED);
                        if(relatedRecord.getSObjectType() == cmbls__Payment__c.getSObjectType()){
                            relatedRecord.put('cmbls__Fail_Date__c', System.today());
                        }
                        achLog.Status__c = Constant.ACH_TRANSACTION_LOG_STATUS_COMPLETED;
                        achLogsForUpdate.add(achLog);
                        relatedRecordsForUpdate.add(relatedRecord);
                    }
                    else if(relatedRecord.getSObjectType() == cmbls__Payment__c.getSObjectType() && recordStatus == Constant.STATUS_SETTLED){
                        String responseCode;
                        String errorDescr;
                        try{
                            if(String.isNotBlank(achLog.Response__c)){
                                WellsFargo.WebhookReturn webhookReturn = (WellsFargo.WebhookReturn)JSON.deserialize(achLog.Response__c, WellsFargo.WebhookReturn.class);
                                responseCode = webhookReturn.getReturnReasonCode();
                                errorDescr = webhookReturn.getReturnReasonDescription();
                            }
                        }catch(Exception e){
                            //Do nothing here, basically here we have a failed transaction without/invalid json response, so, we can process the payment anyways
                        }
    
                        Boolean reversalCreated = (Boolean)relatedRecord.get('cmbls__Reversal_Created__c');
                        if(String.isNotBlank(responseCode)) relatedRecord.put('cmbls__Response_Code__c', responseCode);
                        if(String.isNotBlank(errorDescr)) relatedRecord.put('cmbls__Error_Description__c', errorDescr);
                        
                        if(WellsFargoAPI.WF_Settings.Create_Reversal_Payment_for_Late_Returns__c && !reversalCreated){
                            cmbls__Payment__c reversal = PaymentService.getReversalPayment((cmbls__Payment__c)relatedRecord);
                            reversal.cmbls__Effective_Date__c = achLog.Log_Date__c.addHours(2).date();
                            reversal.cmbls__Settlement_Date__c = achLog.CreatedDate;
                            paymentRecordsForInsert.add(reversal);
                            relatedRecord.put('cmbls__Reversal_Created__c', true);
                        }else{
                            relatedRecord.put('cmbls__Status__c', Constant.STATUS_FAILED);
                        }
                        relatedRecord.put('cmbls__Fail_Date__c', System.today());
                        achLog.Status__c = Constant.ACH_TRANSACTION_LOG_STATUS_COMPLETED;
                        achLogsForUpdate.add(achLog);
                        relatedRecordsForUpdate.add(relatedRecord);
                    }
                }
                else if(achLog.Status__c == Constant.ACH_TRANSACTION_LOG_STATUS_PENDING){
                    Date recordEffectiveDate = (Date)relatedRecord.get('cmbls__Effective_Date__c');
                    if(recordStatus == PaymentUtils.PAYMENT_STATUS_PRE_PENDING){
                        relatedRecord.put('cmbls__Status__c', Constant.STATUS_PENDING);
                        if(recordEffectiveDate != null && settlementDate >= recordEffectiveDate){
                            relatedRecord.put('cmbls__Status__c', Constant.STATUS_SETTLED);
                            relatedRecord.put('cmbls__Settlement_Date__c', System.now());
                            achLog.Status__c = Constant.ACH_TRANSACTION_LOG_STATUS_COMPLETED;
                            achLogsForUpdate.add(achLog);
                        }
                        relatedRecordsForUpdate.add(relatedRecord);
                    }
                    else if(recordStatus == Constant.STATUS_PENDING){
                        if(recordEffectiveDate != null && settlementDate >= recordEffectiveDate){
                            relatedRecord.put('cmbls__Status__c', Constant.STATUS_SETTLED);
                            relatedRecord.put('cmbls__Settlement_Date__c', System.now());
                            achLog.Status__c = Constant.ACH_TRANSACTION_LOG_STATUS_COMPLETED;
                            achLogsForUpdate.add(achLog);
                            relatedRecordsForUpdate.add(relatedRecord);
                        }
                    }
                }
                else{
                    achLog.Status__c = Constant.ACH_TRANSACTION_LOG_STATUS_COMPLETED;
                    achLogsForUpdate.add(achLog);
                }
                
                if(recordStatus == PaymentUtils.PAYMENT_STATUS_FAILED && relatedRecord.getSObjectType() == cmbls__Payment__c.getSObjectType()){
                    achLog.Status__c = Constant.ACH_TRANSACTION_LOG_STATUS_COMPLETED;
                    achLogsForUpdate.add(achLog);
                }
            }
        }

        update achLogsForUpdate;
        update relatedRecordsForUpdate;
        insert paymentRecordsForInsert;
    }

    global void finish(Database.BatchableContext bc) {}

    global void execute (SchedulableContext ctx) {
        if (!UtilityTools.isBatchRunning('BatchProcessACHTransactions')) {
            Database.executeBatch(new BatchProcessACHTransactions(cmbls__Disbursement__c.getSObjectType().getDescribe().getName()), BatchProcessACHTransactions.batchSize);
            Database.executeBatch(new BatchProcessACHTransactions(cmbls__Payment__c.getSObjectType().getDescribe().getName()), BatchProcessACHTransactions.batchSize);
        }
    }

}