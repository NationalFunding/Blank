trigger CCS_beforeInsert on Consumer_Credit_Summary__c (before insert) {
    CCSTriggerHandler.beforeInsert(trigger.new);
}