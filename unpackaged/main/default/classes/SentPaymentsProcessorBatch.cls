global with sharing class SentPaymentsProcessorBatch implements Database.Batchable<SObject>, Schedulable{
    
    @TestVisible private static final String DEBUG_LOG_FAILURE_SUBJECT = '{0} Job failure';
    @TestVisible private static final String DEBUG_LOG_FAILURE_DESCRIPTION = '{0} record Status failed to update to {1} - {2}';
    @TestVisible private static cmbls__Payment__c paymentFailureRecord; //Used on UnitTest to throw an error on a specific record
    @TestVisible private static Boolean rescheduleFires; //Used on UnitTest to be sure this get rescheduled
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        //Query to return no records, easy way is to query any record where Id = NULL
        String query = 'SELECT Id FROM ACH_Transaction_Log__c WHERE Id = NULL';
        
        //Check batch is not already running
        if(batchIsNotRunning(bc)) query = PaymentService.getSentToWellsFargoPendingPaymentsQuery();
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<SObject> scope){
        Map<Id, SObject> recordsToUpdate = new Map<Id, SObject>();
        cmbls__Debug_Log__c[] debugLogsToInsert = new cmbls__Debug_Log__c[]{};
        Map<Id, ACH_Transaction_Log__c> logsToUpdateByParent = new Map<Id, ACH_Transaction_Log__c>();
        
        for(SObject item :scope){
            ACH_Transaction_Log__c log = (ACH_Transaction_Log__c)item;
            log.Pre_Pending_Update_Attempts__c = NumberUtils.getInteger(log.Pre_Pending_Update_Attempts__c) + 1;
            
            if(String.isNotBlank(log.Payment__c)){
                recordsToUpdate.put(log.Payment__c, new cmbls__Payment__c(
                    Id = log.Payment__c,
                    cmbls__Status__c = PaymentUtils.PAYMENT_STATUS_PRE_PENDING
                ));
                logsToUpdateByParent.put(log.Payment__c, log);
            }else if(String.isNotBlank(log.Disbursement__c)){
                recordsToUpdate.put(log.Disbursement__c, new cmbls__Disbursement__c(
                    Id = log.Disbursement__c,
                    cmbls__Date_Sent__c = log.CreatedDate.date(),
                    cmbls__Status__c = PaymentUtils.PAYMENT_STATUS_PRE_PENDING
                ));
                logsToUpdateByParent.put(log.Disbursement__c, log);
            }
        }
        
        if(Test.isRunningTest() && paymentFailureRecord != null){
            recordsToUpdate.get(paymentFailureRecord.Id).put('cmbls__Transaction_Amount__c', null);
            paymentFailureRecord = null;
        }
        
        SObject[] recordsToUpdateList = recordsToUpdate.values();
        Integer index = 0;
        for(Database.SaveResult result :Database.update(recordsToUpdateList, false)){
            if(!result.isSuccess()){
                Id recordId = recordsToUpdateList[index].Id;
                String objectName = recordId.getSobjectType().getDescribe().getLabel();
                cmbls__Debug_Log__c log = UtilityTools.getDebugLogForDMLFailure(null, recordsToUpdate.get(recordId), result);
                log.cmbls__Subject__c = String.format(DEBUG_LOG_FAILURE_SUBJECT, new String[]{getJobName()});
                log.cmbls__Description__c = String.format(DEBUG_LOG_FAILURE_DESCRIPTION, new String[]{objectName, PaymentUtils.PAYMENT_STATUS_PRE_PENDING, recordId});
                debugLogsToInsert.add(log);
            }
            index++;
        }
        
        update logsToUpdateByParent.values();
        insert debugLogsToInsert;
    }
    
    global void finish(Database.BatchableContext bc){
        if(PaymentService.getSentToWellsFargoPendingPaymentsCount() > 0){
            if(Test.isRunningTest()){
                rescheduleFires = true; //Set to true to let UnitTest know this is working as expected and tries to reschedule
                return;
            }
            Database.executeBatch(new SentPaymentsProcessorBatch(), PaymentsBatchProcessor.getBatchScope());
        }
    }
    
    global void execute(SchedulableContext sc){
        Database.executeBatch(new SentPaymentsProcessorBatch(), PaymentsBatchProcessor.getBatchScope());
    }
    
    public static Integer getPrePendingUpdateMaxAttempts(){
        return WellsFargoAPI.WF_Settings.Pre_Pending_Update_Max_Attempts__c != null ? NumberUtils.getInteger(WellsFargoAPI.WF_Settings.Pre_Pending_Update_Max_Attempts__c) : 10;
    }
    
    public static Boolean batchIsNotRunning(Database.BatchableContext bc){
        String[] statuses = new String[]{'Processing','Preparing','Holding'};
        if(Test.isRunningTest()) statuses.add('Queued');//Include Queued for Unittest
        String query =  'SELECT COUNT() FROM AsyncApexJob ' +
                        'WHERE ' +
                            'JobType = \'BatchApex\' AND ' +
                            'ApexClass.Name = \'SentPaymentsProcessorBatch\' AND ' +
                            'Status IN :statuses';
        if(bc != null) query += ' AND Id != \'' + bc.getJobId() + '\'';
        return Database.countQuery(query) == 0;
    }
    
    public static String getJobName(){
        String output = 'Update Pre-Pending Status ';
        return output;
    }
}