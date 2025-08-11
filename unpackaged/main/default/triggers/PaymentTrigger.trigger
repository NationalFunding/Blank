/**
 * PaymentTrigger class
 * @author CloudMyBiz (r)
 * @date 6/19/2023
 * @description Trigger for cmbls__Payment__c. Follows the One Trigger Per Object design pattern, which allows for the control of execution order and recursion
 * @group Triggers
 */
trigger PaymentTrigger on cmbls__Payment__c (before insert, before update, before delete, after insert, after update, after delete, after undelete){
    
    if(Trigger.isBefore){
        if(Trigger.isUpdate){
            PaymentTriggerHandler.onBeforeInsertUpdate(Trigger.new, Trigger.oldMap);
        }
    }
    
    if(Trigger.isAfter){
        if(Trigger.isUpdate || Trigger.isInsert){
            PaymentTriggerHandler.onAfterInsertUpdate(Trigger.new, Trigger.oldMap);
        }
    }
}