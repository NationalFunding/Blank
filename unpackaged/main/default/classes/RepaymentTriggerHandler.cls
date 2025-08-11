public inherited sharing class RepaymentTriggerHandler {
    
    public static void onAfterInsertUpdate(cmbls__Repayment__c[] records, Map<Id, cmbls__Repayment__c> oldMap){
        if(Trigger.isInsert){
            RepaymentService.relateDisbursements(records);
            RepaymentService.createExpenses(records);
        }
        
        if(TransferQueuedEventBatch.isAutomaticTransferEnabled()) RepaymentService.createTransferQueuedEvents(records, oldMap);
    }
}