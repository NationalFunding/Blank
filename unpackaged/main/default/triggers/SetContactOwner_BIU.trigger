trigger SetContactOwner_BIU on Contact (before insert, before update) {
    // Gather accounts
     List<Id> ids = new List<Id>();
    for (Contact ct : trigger.new)
        if (ct.AccountId != null)
			ids.add(ct.AccountId);
    
    // Query Accounts
    Map<Id,Account> accountMap = new Map<Id,Account>([SELECT Id, OwnerId FROM Account WHERE Id IN :ids]);
    
    // Set Owners
     for (Contact ct : trigger.new)
        if ((ct.AccountId != null) && (ct.OwnerId != accountMap.get(ct.AccountId).OwnerId))
            ct.OwnerId = accountMap.get(ct.AccountId).OwnerId;
}