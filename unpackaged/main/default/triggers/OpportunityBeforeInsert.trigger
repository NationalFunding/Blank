trigger OpportunityBeforeInsert on Opportunity (before insert, before update) {
	// 05.13.2013 (CBSL/Jody L.)
    // When an opportunity is marked as Won, check off in Account that owner owns a completed opp.
    
    if (trigger.isUpdate) {
	    List<Id> acctIds = new List<Id>();
        List<Account> accts = new List<Account>();
        List<Opportunity> oppsToWorkOn = new List<Opportunity>(); // reducing processing time
        
        for (Opportunity opport : trigger.new) {
            if (trigger.oldMap.get(opport.id).StageName != opport.StageName && opport.isWon) {
                oppsToWorkOn.add(opport);
                acctIds.add(opport.AccountId);
            }
        }
        
        if (acctIds.size() > 0) {
            Map<Id,Account> accountMap = new Map<Id,Account>([SELECT Id,OwnerId FROM Account WHERE Id IN :acctIds]);
	        
            for (Opportunity opport : oppsToWorkOn)
                if (opport.OwnerId == accountMap.get(opport.AccountId).OwnerId)
					accts.add(new Account(Id = opport.AccountId, Funded_by_Account_Owner__c = true));

            if (accts.size() > 0)
				update accts;
        }
    }
    // 10.16.2012 (CBSL/Jody L.)
	// Create Campaign Influence related to the Responded Campaign associated with the lead.
    List<Id> accountIds = new List<Id>();
	Map<Id,DateTime> accountDateLimit = new Map<Id,DateTime>();

    for (Opportunity opp : trigger.new) {
		accountIds.add(opp.AccountId);
        accountDateLimit.put(opp.AccountId,opp.CreatedDate);
        if (trigger.isInsert)
            opp.CampaignId = null;
    }
    
    if (trigger.isUpdate) { // we don't want to update if we don't have to.  Saving on # of DB queries.
        Boolean canFail = true;
        for (Opportunity opp : trigger.new)
            if (opp.CampaignId == null)
            	canFail = false;
        
        if (canFail) return;
    }
    
    List<Contact> contacts = [SELECT Id, AccountId FROM Contact WHERE AccountId IN :accountIds];
    List<Id> contactIds = new List<Id>();
    
    for (Contact c : contacts)
        contactIds.add(c.Id);
    
	List<CampaignMember> cmembers = [SELECT CampaignId, HasResponded, FirstRespondedDate, Contact.AccountId FROM CampaignMember WHERE ContactId IN :contactIds AND HasResponded = true AND FirstRespondedDate != null];
    Map<Id,CampaignMember> acctToCampaign = new Map<Id,CampaignMember>();
        
    for (CampaignMember cm : cmembers)
        if ((cm.HasResponded) && (accountDateLimit.get(cm.Contact.AccountId) > cm.FirstRespondedDate) && (!acctToCampaign.containsKey(cm.Contact.AccountId) || acctToCampaign.get(cm.Contact.AccountId).FirstRespondedDate < cm.FirstRespondedDate))
            acctToCampaign.put(cm.Contact.AccountId,cm);
    
      for (Opportunity opp : trigger.new)
          if (acctToCampaign.containsKey(opp.AccountId) && opp.CampaignId == null)
              opp.CampaignId = acctToCampaign.get(opp.AccountId).CampaignId;
}