trigger Lead_AU_MoveLeadContacts on Lead (after update) {
    List<Id> leadIds = new List<Id>();
    
    for (Lead l : trigger.new) 
        if (l.convertedAccountId != null) leadIds.add(l.Id); 
    
    if (leadIds.size() == 0) return;

    // We now have a list of leads that have been converted to accounts.
    // Make sure each lead contact has a reference to an associated contact on the account,
    // and each consumer credit summary for a lead contact points to the associated contact
    // If the contact doesn't exist, we create it (this is the main point!)
    // Specifically, we want:
    //  LeadContact -> Contact
    //  CCS -> LeadContact ==> CCS -> Contact
    
    // Note that for the primary lead contact, we use the auto-created ConvertedContactId on the Lead object
    Map<Id, Id> convertedContactIds = new Map<Id, Id>();
    for (Lead l : trigger.new) {
        convertedContactIds.put(l.Id, l.ConvertedContactId);
    }

    Map<Contact,Lead_Contact__c> lcMap = new Map<Contact,Lead_Contact__c>();
    Map<Lead_Contact__c,Contact> cMap = new Map<Lead_Contact__c,Contact>();

    // Get all the lead contacts and their consumer credit summaries
    List<Lead_Contact__c> leadContacts = [SELECT Id, Lead__c, Primary__c, First_Name__c, Last_Name__c, Title__c, Ownership_Percentage__c, SSN_Encrypted__c, Email__c, Home_Phone__c,
                                          Mobile_Phone__c, Mailing_Street__c, Mailing_City__c, Mailing_State_Province__c, Mailing_Zip_Postal_Code__c, Address_1__c, Address_Number__c,
                                          Street_Name__c, Street_Type__c, Birthdate__c, Nickname__c, Contact__c, FICO_Score__c, Lead__r.ConvertedContactId,
                                          (SELECT Id, Lead_Contact__c, Contact__c FROM Consumer_Credit_Summaries__r)
                                          FROM Lead_Contact__c WHERE Lead__c IN :leadIds];


    Map<Id, Contact> lcToContact_map = new Map<Id, Contact>(); // Lead Contact --> Contact
    Map<Id, FPC_Address__c> lcToAddress_map = new Map<Id, FPC_Address__c>(); // Lead Contact --> Address

    List<Contact> newContacts = new List<Contact>(); // Contacts we will add
        
    // For all lead contacts, see if we need to make an new contacts
    for (Lead_Contact__c lc : leadContacts){
        if (lc.Primary__c) {
            // This is the primary lead contact. The contact for it should be the converted contact and should already exist.
        } else if (lc.Contact__c == null) {
            // Non-primary lead contact without an associated contact.
            // Make the new contact based on the lead contact
            Contact c = new Contact();
            c.Birthdate = lc.Birthdate__c;
            c.Nickname__c = lc.Nickname__c;
            c.FirstName = lc.First_Name__c;
            c.FICO_Score__c = lc.FICO_Score__c;
            c.LastName = lc.Last_Name__c;
            c.Title = lc.Title__c;
            c.Ownership_Percentage__c = lc.Ownership_Percentage__c;
            c.SSN_Encrypted__c = lc.SSN_Encrypted__c;
            c.Email = lc.Email__c;
            c.HomePhone = lc.Home_Phone__c;
            c.MobilePhone = lc.Mobile_Phone__c;
            
            c.MailingStreet = lc.Mailing_Street__c;
            c.MailingCity = lc.Mailing_City__c;
            c.MailingState = lc.Mailing_State_Province__c;
            c.MailingPostalCode = lc.Mailing_Zip_Postal_Code__c;        

            c.AccountId = trigger.newMap.get(lc.Lead__c).convertedAccountId;
            c.OwnerId = trigger.newMap.get(lc.Lead__c).OwnerId;

            // Add it to the list of contacts we will insert
            newContacts.add(c);
            
            // Add it to the mapping between lead contact and contact
            lcToContact_map.put(lc.Id, c);

            // Since there was no contact for this lead contact, there was no address created from it either.
            // Make the new address, and we will connect it to the contact after the contact gets inserted
            FPC_Address__c add = new FPC_Address__c();
            if (lc.Address_1__c == null) {
                add.Address_1__c = lc.Mailing_Street__c;
            } else { add.Address_1__c = lc.Address_1__c;}
            add.Address_Number__c = lc.Address_Number__c;
            add.Location_Type__c = 'Home Address';
            add.Street_Name__c = lc.Street_Name__c;
            add.Street_Type__c = lc.Street_Type__c;
            add.State__c = lc.Mailing_State_Province__c;
            add.City__c = lc.Mailing_City__c;
            add.Zip_Code__c = lc.Mailing_Zip_Postal_Code__c;
            add.Account__c = trigger.newMap.get(lc.Lead__c).convertedAccountId;
            // Will set add.Contact__c after contact is inserted

            // Add it to the mapping between lead contact and new addresses
            lcToAddress_map.put(lc.Id, add);
        }
    }
    
    if (newContacts.size() > 0) {
        insert newContacts;
    }
    System.debug('[Lead_AU_MoveLeadContacts] Inserted ' + newContacts.size() + ' Contacts');

    // For each lead contact, point it to it's associated contact if it isn't already
    List<Lead_Contact__c> updateLC = new List<Lead_Contact__c>();
    for (Lead_Contact__c lc : leadContacts) {
        if(lc.Contact__c == null) {
            // Not pointing to anything yet. Make it point either to a newly created contact, or a converted contact
            if (lc.Primary__c) {
                lc.Contact__c = convertedContactIds.get(lc.Lead__c);
            } else {
                lc.Contact__c = lcToContact_map.get(lc.Id).Id;
            }
            updateLC.add(lc);
        }
    }

    if(updateLC.size() > 0) {
        update updateLC;
    }
    System.debug('[Lead_AU_MoveLeadContacts] Updated ' + updateLC.size() + ' Lead Contact -> Contact relationships');

    // For the addresses to add, set the contact and then do the insert
    for (Id lcId : lcToAddress_map.KeySet()) {
        lcToAddress_map.get(lcId).Contact__c = lcToContact_map.get(lcId).Id;
    }
    List<FPC_Address__c> newAddrs = lcToAddress_map.values();
    if(newAddrs.size() > 0) {
        insert newAddrs;
    }
    System.debug('[Lead_AU_MoveLeadContacts] Inserted ' + newAddrs.size() + ' Addresses');

    // Re-query the lead contacts to the updated Contact__c linkage
    leadContacts = [SELECT Id, Contact__c, (SELECT Id, Lead_Contact__c, Contact__c FROM Consumer_Credit_Summaries__r)
                    FROM Lead_Contact__c WHERE Lead__c IN :leadIds];

    // List of CCS we will update to point to Contact for Lead Contact
    List<Consumer_Credit_Summary__c> ccsToUpdate = new List<Consumer_Credit_Summary__c>();

    for (Lead_Contact__c lc : leadContacts) {
        for (Consumer_Credit_Summary__c ccs : lc.Consumer_Credit_Summaries__r) {
            if (ccs.Contact__c == null) {
                ccs.Contact__c = lc.Contact__c;
                ccsToUpdate.add(ccs);
            }
        }
    }

    if (ccsToUpdate.size() > 0) {
        update ccsToUpdate;
    }
    System.debug('[Lead_AU_MoveLeadContacts] Updated ' + ccsToUpdate.size() + ' Consumer Credit Summary --> Contact relationships');
}