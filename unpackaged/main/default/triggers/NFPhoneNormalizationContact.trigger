trigger NFPhoneNormalizationContact on Contact (before insert, before update) {
    if (trigger.isBefore){
        if (trigger.isInsert){
            NF_Lead_Utility util = new NF_Lead_Utility();
            util.normalizedPhoneContact(trigger.new);
            util.normalizedPhoneMContact(trigger.new);
            util.normalizedPhoneOContact(trigger.new);
			util.normalizedPhoneHContact(trigger.new);
        }
        
        if (trigger.isUpdate){
			NF_Lead_Utility util = new NF_Lead_Utility();
            util.normalizedPhoneContact(trigger.new);
            util.normalizedPhoneMContact(trigger.new);
            util.normalizedPhoneOContact(trigger.new);
			util.normalizedPhoneHContact(trigger.new);
        }
    }
}