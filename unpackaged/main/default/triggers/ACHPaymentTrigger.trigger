trigger ACHPaymentTrigger on ACH_Payment__c (before insert, before update, after insert) {
    if( Trigger.isAfter ){
        if(Trigger.isInsert){
            ACHPaymentTriggerHandler handler = new ACHPaymentTriggerHandler(Trigger.new,Trigger.oldMap);
            handler.autoCreateDisbursements(Trigger.newMap);
        }
    }
}