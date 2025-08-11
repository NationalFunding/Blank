trigger GL_TransactionTrigger on cmbls__GL_Transaction__c (before insert, before update, before delete, after insert, after update, after delete, after undelete){
    
    if(!cmbls__Loan_Servicing_Triggers__c.getInstance().Disable_GL_Transactions_Trigger__c){
        if(Trigger.isInsert){
            if(Trigger.isBefore) GL_TransactionTriggerHandler.onBeforeInsertUpdate(Trigger.new, Trigger.oldMap);
            if(Trigger.isAfter) GL_TransactionTriggerHandler.onAfterInsertUpdate(Trigger.new, Trigger.oldMap);
        }
    }
}