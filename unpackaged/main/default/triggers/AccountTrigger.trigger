/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────
* TITLE: AccountTrigger
* DESCRIPTION: Apex trigger
* @author         Amrit
* @version        1.0
* @created        22/01/2025
* @mofidied       
* ────────────────────────────────────────────────────────────────────────────────────────────────   */
trigger AccountTrigger on Account (before insert, before update) {
     try {
         if (Trigger.isBefore) {
             if (Trigger.isInsert) {
                 AccountTriggerHelper.beforeInsert(Trigger.new);
             }
             if (Trigger.isUpdate) {
                 AccountTriggerHelper.beforeUpdate(Trigger.new, Trigger.oldMap);
             }
         }
     } catch (Exception e) {
        System.debug('Error in AccountTrigger: ' + e.getMessage());
    }
}