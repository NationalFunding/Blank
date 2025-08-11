trigger CS_MoveScoresToContacts on Lead (after update) {
    List<Id> leadIds = new List<Id>();
    Map<Id,Id> leadToContact = new Map<Id,Id>();
    
    for (Lead l : trigger.new)
        if (trigger.oldMap.get(l.Id).ConvertedAccountId != trigger.newMap.get(l.Id).ConvertedAccountId)
            leadIds.add(l.Id);
    
    if (leadIds.size() == 0)
        return;
    
    System.debug('[CS_MoveScoresToContacts] Processing ' + leadIds.size() + ' converted Leads');

    // For each leadid we are going to process, see if it has any lead contacts. If it does, then don't convert the credit scores. 
    // This change is to deal with the change in March 2016 to go from Credit Scores to Lead Contacts and Consumer Credit Summaries
    List<Lead> leads = [SELECT Id FROM Lead where Id in :leadIds and Id NOT IN (Select Lead__c from Lead_Contact__c)];
    leadIds.clear();
    for(Lead l : leads) {
        leadIds.add(l.Id); // This lead doesn't have any lead contacts so we will create the contacts the old way via the credit scores
    }

    if(leadIds.size() == 0) {
        // There were no converted leads without lead contacts.
        System.debug('[CS_MoveScoresToContacts] All converted Leads had at least one lead contact.');
        return;
    }

    // There are some leads with credit scores but no lead contacts. Continue processing
    System.debug('[CS_MoveScoresToContacts] Attempting to create Contacts from Credit Scores for ' + leadIds.size() + ' converted Leads without any Lead Contacts');

    List<Credit_Score__c> cscores = [SELECT Id, Linked_with_Lead__c, Zip_Postal_Code__c, Title__c, SSN__c, Ownership_Percentage__c, Address_Street__c, Address_Number__c, Home_Phone__c, Mobile_Phone__c, City__c, State__c, First_Name__c, Last_Name__c, Email__c, DOB__c, Lead__c, FICO_Score__c FROM Credit_Score__c WHERE Lead__c IN :leadIds];
    //List<CampaignMember> cmembers = [SELECT Id, CampaignId, LeadId, Status, FirstRespondedDate FROM CampaignMember WHERE LeadId IN :leadIds AND Status = 'Received'];
    Map<Id,Contact> firstContacts = new Map<Id,Contact>();
    List<Id> accountIds = new List<Id>();
    List<Contact> contacts = new List<Contact>();
    Contact c;
    for (Credit_Score__c cs : cscores) {
        if (cs.Linked_With_Lead__c) {
            Lead l = trigger.newMap.get(cs.Lead__c);
            c = new Contact(Id = trigger.newMap.get(cs.Lead__c).ConvertedContactId);
            c.BirthDate = l.Birth_Date__c!=null?l.Birth_Date__c:cs.DOB__c;
            c.Email = l.Email != null?l.Email:cs.Email__c;
            c.HomePhone = l.Home_Phone__c != null?l.Home_Phone__c:cs.Home_Phone__c;
            c.MobilePhone = l.MobilePhone != null?l.MobilePhone:cs.Mobile_Phone__c;
            //c.FICO_Score__c = l.FICO_Score__c != null ? l.FICO_Score__c : cs.FICO_Score__c;
            c.FICO_Score__c = cs.FICO_Score__c;
        }
        else {
            c = new Contact();
            c.FirstName = cs.First_Name__c;
            c.LastName = cs.Last_Name__c;
            c.Email = cs.Email__c;
            c.MailingStreet = cs.Address_Number__c + ' ' + cs.Address_Street__c;
            c.MailingCity = cs.City__c;
            c.MailingState = cs.State__c;
            c.MailingPostalCode = cs.Zip_Postal_Code__c;
            c.HomePhone = cs.Home_Phone__c;
            c.MobilePhone = cs.Mobile_Phone__c;
            c.Title = cs.Title__c;
            c.Ownership_Percentage__c = cs.Ownership_Percentage__c;
            c.BirthDate = cs.DOB__c;
            c.FICO_Score__c = cs.FICO_Score__c;
            // added by TR - 4/21/15 jjj          
            // c.RecordType = [select Id from RecordType where Name = 'Customer Contact'];
            system.debug('<<<<<' + c.RecordTypeId);
        }
        
        c.AccountId = trigger.newMap.get(cs.Lead__c).ConvertedAccountId;
        c.SSN_Encrypted__c = cs.SSN__c;
        c.OwnerId = trigger.newMap.get(cs.Lead__c).OwnerId;
        c.Original_Credit_Score_ID__c = cs.Id;
        c.Related_Credit_Score__c = cs.Id;
        contacts.add(c);
            
        if (!firstContacts.containsKey(cs.Lead__c))
            firstContacts.put(cs.Lead__c,c);
    }
    
    System.debug('[CS_MoveScoresToContacts] Inserted ' + contacts.size() + ' Contacts based on Credit Score');
    upsert contacts;
    
    cscores = new List<Credit_Score__c>();
    for (Contact cont : contacts)
        cscores.add(new Credit_Score__c(id = cont.Related_Credit_Score__c, Contact__c = cont.id));
        
    update cscores;
    /*Map<Id,CampaignMember> leadCampaign = new Map<Id,CampaignMember>();
    for (CampaignMember cm : cmembers)
        if (!leadCampaign.containsKey(cm.LeadId) || leadCampaign.get(cm.LeadId).FirstRespondedDate < cm.FirstRespondedDate)
            leadCampaign.put(cm.LeadId,cm);
    
    List<Opportunity> opps = new List<Opportunity>();
    for (Lead l : trigger.new)
        if (l.ConvertedOpportunityId != null && leadCampaign.containsKey(l.id)) {
            Opportunity opp = new Opportunity(id = l.ConvertedOpportunityId);
            opp.CampaignId = leadCampaign.get(l.id).CampaignId;
            opps.add(opp);
        }
    
    if (opps.size() > 0)
        update opps;*/
    /*List<CampaignMember> cms = new List<CampaignMember>(); 
    for (Id LeadId : firstContacts.keySet()) {
        c = firstContacts.get(LeadId);
        for (CampaignMember cm : cmembers) {
            if (cm.LeadId != LeadId)
                continue;
            
            CampaignMember ncm = new CampaignMember();
            ncm.CampaignId = cm.CampaignId;
            ncm.ContactId = c.Id;
            ncm.Status = cm.Status;
            
            cms.add(ncm);
        }
    }
    
    insert cms;*/
}