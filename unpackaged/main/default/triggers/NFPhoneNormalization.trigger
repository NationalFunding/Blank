trigger NFPhoneNormalization on Lead (before insert, before update) {
    if (trigger.isBefore){
        if (trigger.isInsert){
            NF_Lead_Utility util = new NF_Lead_Utility();
            util.normalizedPhone(trigger.new);
            util.normalizedHPhone(trigger.new);
			util.normalizedMPhone(trigger.new);
        }
        
        if (trigger.isUpdate){
			NF_Lead_Utility util = new NF_Lead_Utility();
            util.normalizedPhone(trigger.new);
            util.normalizedHPhone(trigger.new);
			util.normalizedMPhone(trigger.new);
        }
    }
}