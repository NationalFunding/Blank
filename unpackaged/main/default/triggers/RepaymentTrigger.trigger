trigger RepaymentTrigger on cmbls__Repayment__c (after insert, after update) {

    if(!cmbls__Loan_Servicing_Triggers__c.getInstance().Disable_Custom_Repayment_Trigger__c){
        if(Trigger.isAfter){
            if(Trigger.isInsert || Trigger.isUpdate) RepaymentTriggerHandler.onAfterInsertUpdate(Trigger.new, Trigger.oldMap);
        }
    }
}