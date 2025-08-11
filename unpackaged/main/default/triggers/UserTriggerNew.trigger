trigger UserTriggerNew on User (before insert, after insert) {
    
    LocalCounselTriggerActivator__c orgDefault = LocalCounselTriggerActivator__c.getOrgDefaults();

    if(trigger.isBefore && trigger.isInsert && orgDefault.Is_Active__c)
    {
        Id portalProfileId = [SELECT Id FROM Profile WHERE Name = 'Local Counsel'].Id;
        
        Set<Id> conIds = new Set<Id>();
        
        for(User usr: trigger.new){
            if(usr.ContactId != null && usr.ProfileId == portalProfileId){
                conIds.add(usr.ContactId);
            }
        }
        
        Map<Id, Contact> conEmailsMap = new Map<Id, Contact>([SELECT Id, Email FROM Contact WHERE Id IN: conIds]);
        for(User usr: trigger.new){
            if(usr.ContactId != null && usr.ProfileId == portalProfileId){
                System.debug('usr.Contact.Email--'+usr.Contact.Email);
                if(conEmailsMap.containsKey(usr.ContactId)){
                    if(String.isBlank(conEmailsMap.get(usr.ContactId).Email)){
                         // Throw an error when the Contact has no email.
                         usr.addError('Please add Email address in associated Contact.');
                    }
                }
            }
        }
    }
    
    if(trigger.isAfter && trigger.isInsert && orgDefault.Is_Active__c)
    {
        Id portalProfileId = [SELECT Id FROM Profile WHERE Name = 'Local Counsel'].Id;
        Set<Id> userIds = new Set<Id>();
        for(User usr: trigger.new){
            if(usr.ContactId != null && usr.ProfileId == portalProfileId){
                userIds.add(usr.Id);
            }
        }
        if(!userIds.isEmpty()){
        	UserTriggerNewHandler.shareMattersWithUsers(userIds);
        }
    }
}