/**
 * RepaymentScheduleTrigger class
 * @author CloudMyBiz (r)
 * @date 8/15/2023
 * @description Trigger for cmbls__Repayment_Schedule__c. Follows the One Trigger Per Object design pattern, which allows for the control of execution order and recursion
 * @group Triggers
 */
trigger RepaymentScheduleTrigger on cmbls__Repayment_Schedule__c (before insert, before update, before delete, after insert, after update, after delete, after undelete){
    if(!cmbls__Loan_Servicing_Triggers__c.getInstance().Disable_Custom_Rpmt_Schedule_Trigger__c){
        if(Trigger.isBefore){
            if(Trigger.isUpdate || Trigger.isInsert){
                RepaymentScheduleTriggerHandler.onBeforeInsertUpdate(Trigger.new, Trigger.oldMap);
            }
        }
        if(Trigger.isAfter){
            if(Trigger.isUpdate || Trigger.isInsert){
                RepaymentScheduleTriggerHandler.onAfterInsertUpdate(Trigger.new, Trigger.oldMap);
            }
        }
    }
}