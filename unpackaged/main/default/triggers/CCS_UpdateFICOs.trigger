trigger CCS_UpdateFICOs on Consumer_Credit_Summary__c (after insert, after update, after delete) {
	
    // Use the CCSTriggerHandler class for convenience
    if (trigger.isUpdate) {
        CCSTriggerHandler.afterUpdate(trigger.new, trigger.oldMap);
    } else if (trigger.isDelete) {
        CCSTriggerHandler.afterInsertDelete(trigger.old, false);
    } else if (trigger.isInsert) {
        CCSTriggerHandler.afterInsertDelete(trigger.new, true);
    }
}