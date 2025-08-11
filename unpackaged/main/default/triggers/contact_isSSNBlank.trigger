trigger contact_isSSNBlank on Contact (before insert, before update) {
    for (Contact c : trigger.new){
        c.SSN_Is_Blank__c = ((c.SSN_Encrypted__c == '') || (c.SSN_Encrypted__c == null));        
    }
}