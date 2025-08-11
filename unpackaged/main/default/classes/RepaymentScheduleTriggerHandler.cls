/**
 * RepaymentScheduleTriggerHandler class
 * @author CloudMyBiz (r)
 * @date 8/15/2023
 * @description Follows the One Trigger Per Object design pattern, which allows for the control of execution order and recursion.
 * Ideally, business logic should not be included in this class. Trigger handlers are used to control recursion and order of execution and should delegate other work to service classes.
 * @group Trigger Handlers
 */
public inherited sharing class RepaymentScheduleTriggerHandler{
    
    public static Boolean RUN_NEXT_PAYMENT_DATE_VALIDATION = true;
    public static cmbls__Repayment_Schedule__c[] validateNextPaymentDateRecords = new cmbls__Repayment_Schedule__c[]{};
    
    public static void onBeforeInsertUpdate(List<cmbls__Repayment_Schedule__c> records, Map<Id, cmbls__Repayment_Schedule__c> oldMap){
        validateNextPaymentDateRecords = new cmbls__Repayment_Schedule__c[]{};
        Set<Id> repaysId = new Set<Id>();
        Set<String> processor = new Set<String>();
        cmbls__Repayment_Schedule__c[] recordsForValidateNextPaymentDate = new cmbls__Repayment_Schedule__c[]{};
        for(cmbls__Repayment_Schedule__c record :records){
            cmbls__Repayment_Schedule__c oldRecord = oldMap != null ? oldMap.get(record.Id) : null;
            processor.add(record.cmbls__ACH_Processor__c);

            if(record.cmbls__Next_Payment_Date__c != null && (oldRecord == null || oldRecord.cmbls__Next_Payment_Date__c != record.cmbls__Next_Payment_Date__c)){
                recordsForValidateNextPaymentDate.add(record);
            }
            if(Trigger.isBefore){
                repaysId.add(record.cmbls__Repayment__c);
            }
        }

        for(cmbls__Repayment_Schedule__c record :records){
            if(record.cmbls__End_Date__c != null && cmbls.DatetimeUtils.getNextValidDate(record.cmbls__End_Date__c) != record.cmbls__End_Date__c)
            {
                String prevValue = record.cmbls__End_Date__c.month()+ '/' + record.cmbls__End_Date__c.day() + '/' + record.cmbls__End_Date__c.year();
                String newValue = cmbls.DatetimeUtils.getNextValidDate(record.cmbls__End_Date__c).month()+ '/' + cmbls.DatetimeUtils.getNextValidDate(record.cmbls__End_Date__c).day() + '/' + cmbls.DatetimeUtils.getNextValidDate(record.cmbls__End_Date__c).year();

                record.cmbls__Notes__c =  ' End Date has been updated from ' + prevValue + ' to ' + newValue + ' so that the End Date will fall on a business day.';
                record.cmbls__End_Date__c = cmbls.DatetimeUtils.getNextValidDate(record.cmbls__End_Date__c);
            }
        }
        
        if(RUN_NEXT_PAYMENT_DATE_VALIDATION && !System.isBatch() && !System.isFuture()){
            RUN_NEXT_PAYMENT_DATE_VALIDATION = false;
            if(recordsForValidateNextPaymentDate.size() == 1){ //If only one record, we can run the validation immediately
                RepaymentScheduleService.validateNextPaymentDate(recordsForValidateNextPaymentDate[0]);
            }else{//Otherwise, lets prepare a batch to be executed onAfter
                validateNextPaymentDateRecords = recordsForValidateNextPaymentDate;
            }
        }
        if(!repaysId.isEmpty() && Trigger.isInsert) checkingPaymentAmountMethod(records, repaysId);
    }
    
    public static void onAfterInsertUpdate(List<cmbls__Repayment_Schedule__c> records, Map<Id, cmbls__Repayment_Schedule__c> oldMap){
        if(!validateNextPaymentDateRecords.isEmpty() && !System.isBatch() && !System.isFuture()){
            Database.executeBatch(new RSNextPaymentDateBatch(new Map<Id, cmbls__Repayment_Schedule__c>(validateNextPaymentDateRecords).keySet()), RSNextPaymentDateBatch.getBatchSize());
            validateNextPaymentDateRecords = new cmbls__Repayment_Schedule__c[]{};
        }
        if(Trigger.isInsert){
            updateRepaymentStatusToRecovery(records, oldMap);
        }
    }

    public static void checkingPaymentAmountMethod(List<cmbls__Repayment_Schedule__c> records, Set<Id> repaysId){
        Map<Id,cmbls__Repayment__c> mapRepayments = new Map<Id,cmbls__Repayment__c>([SELECT Id, cmbls__Status__c FROM cmbls__Repayment__c WHERE Id IN: repaysId]);
        for(cmbls__Repayment_Schedule__c repaySchedule : records){
            if(mapRepayments.containsKey(repaySchedule.cmbls__Repayment__c) == true &&
                    (mapRepayments.get(repaySchedule.cmbls__Repayment__c).cmbls__Status__c == RepaymentUtils.STATUS_WRITE_OFF ||
                    mapRepayments.get(repaySchedule.cmbls__Repayment__c).cmbls__Status__c == RepaymentUtils.STATUS_RECOVERY) &&
                    repaySchedule.cmbls__Payment_Amount_Method__c != RepaymentUtils.PAYMENT_AMOUNT_METHOD_REMAINING
            ){
                repaySchedule.cmbls__Payment_Amount_Method__c = RepaymentUtils.PAYMENT_AMOUNT_METHOD_REMAINING;
            }
    }
}

    public static void updateRepaymentStatusToRecovery(List<cmbls__Repayment_Schedule__c> records, Map<Id, cmbls__Repayment_Schedule__c> oldMap){
        Map<Id, cmbls__Repayment_Schedule__c> recordsMap = new Map<Id, cmbls__Repayment_Schedule__c>(records);
        List<cmbls__Repayment__c> repayments = new List<cmbls__Repayment__c>();
        for(cmbls__Repayment_Schedule__c repaySchedule :[
                SELECT
                        cmbls__Payment_Amount_Method__c, cmbls__Repayment__r.cmbls__Status__c, cmbls__Repayment__c
                FROM cmbls__Repayment_Schedule__c
                WHERE Id IN: recordsMap.keySet()]
        ){
            if(repaySchedule.cmbls__Repayment__r.cmbls__Status__c == RepaymentUtils.STATUS_WRITE_OFF){
                repayments.add(new cmbls__Repayment__c(
                        Id = repaySchedule.cmbls__Repayment__c,
                        cmbls__Status__c = RepaymentUtils.STATUS_RECOVERY
                ));
            }
        }
        if(!repayments.isEmpty()) update repayments;
    }

}