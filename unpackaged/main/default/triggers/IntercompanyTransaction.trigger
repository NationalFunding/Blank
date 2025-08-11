/**
 * IntercompanyTransaction class
 * @author CloudMyBiz (r)
 * @date 2/13/2023
 * @description Trigger for cmbls__Intercompany_Transaction__c. Follows the One Trigger Per Object design pattern, which allows for the control of execution order and recursion
 * @group Triggers
 */
trigger IntercompanyTransaction on cmbls__Intercompany_Transaction__c (before insert, before update, before delete, after insert, after update, after delete, after undelete){
    
    if(Trigger.isAfter){
        if(Trigger.isInsert){
            IntercompanyTransactionHandler.onAfterInsertUpdate(Trigger.new, Trigger.oldMap);
        }
        if(Trigger.isUpdate && !cmbls__Loan_Servicing_Triggers__c.getInstance().Disable_Additional_GL_Trans_Trigger__c){
            IntercompanyTransactionHandler.onAfterInsertUpdate(Trigger.new, Trigger.oldMap);
        }

    }
}