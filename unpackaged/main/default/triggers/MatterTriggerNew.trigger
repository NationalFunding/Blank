trigger MatterTriggerNew on advpm__Matter__c (after insert, after update) {
    
    LocalCounselTriggerActivator__c orgDefault = LocalCounselTriggerActivator__c.getOrgDefaults();

    if(trigger.isAfter && orgDefault.Is_Active__c){
        if(trigger.isInsert){
            MatterTriggerNewHandler.shareOrDeleteSharedMatters(trigger.new, null);
        }
        
        if(trigger.isUpdate){
             MatterTriggerNewHandler.shareOrDeleteSharedMatters(trigger.new, trigger.oldMap);
        }
    }
}