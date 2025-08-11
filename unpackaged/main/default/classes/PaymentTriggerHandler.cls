/**
 * PaymentTriggerHandler class
 * @author CloudMyBiz (r)
 * @date 6/19/2023
 */

public inherited sharing class PaymentTriggerHandler{
    
    public static void onBeforeInsertUpdate(cmbls__Payment__c[] records, Map<Id, cmbls__Payment__c> oldMap){
        PaymentService.processACHBatchOnUpdate(records, oldMap);
    }
    
    public static void onAfterInsertUpdate(cmbls__Payment__c[] records, Map<Id, cmbls__Payment__c> oldMap){
        Set<Id> repaymentIdsFromCompletedToActive = new Set<Id>();
        for(cmbls__Payment__c record :records){
            cmbls__Payment__c oldRecord = oldMap != null ? oldMap.get(record.Id) : null;
            if(PaymentService.shouldMoveRepaymentToActive(record, oldRecord)){
                repaymentIdsFromCompletedToActive.add(record.cmbls__Repayment__c);
            }
        }
        
        if(!repaymentIdsFromCompletedToActive.isEmpty()) RepaymentService.moveRepaymentsFromCompletedToActive(repaymentIdsFromCompletedToActive);
    }
}