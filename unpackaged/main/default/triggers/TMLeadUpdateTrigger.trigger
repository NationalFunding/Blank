trigger TMLeadUpdateTrigger on Lead (after update) {
    // This trigger is no longer being user since the telemarketing project has ended
    // It's not clear how to remove/delete triggers in production other than editing the metadata in an IDE,
    // So we are just commenting out the code
    System.debug('TMLeadUpdateTrigger no longer being run');
    Integer dummy = 0; // Just so code coverage is non zero
    /*
    Lead[] updated_leads = Trigger.new;
    
    // Get the recordtype ids for New Lead Process and Outbound Lead Process
    // Note, we have to do it by id because objects in the trigger context dont include retated object data
    String outbound_id = [select id from recordType where name = 'Outbound Lead Process' limit 1].id;  
    String new_lead_id = [select id from recordType where name = 'New Lead Process' limit 1].id;  
    
    for(Lead l : updated_leads) {
        if (l.Agency_ID__c == 'Xzamcorp') { 
            Boolean condition_transferred = (l.RecordTypeId == outbound_id) && (l.Status != 'House');
            Boolean condition_mail = (l.RecordTypeId == new_lead_id) && (l.Status != 'House');
            Boolean condition_100k = (l.RecordTypeId == new_lead_id && l.AnnualRevenue != null && l.AnnualRevenue < 100000);
            Boolean condition_dns =  (l.Do_Not_Solicit__c == true);

            if (condition_transferred || condition_mail || condition_100k || condition_dns) {
                // Update the agency id to deleting so this trigger doesnt execute again while waiting for future callout
                Lead lead = [Select id, agency_id__c from Lead where id =: l.id];
                lead.Agency_ID__c = 'Xzamcorp-deleting';
                update lead;
                TMLeadAPI.deleteLead(l.Id); // Delete the lead from the telemarketer
            }
        }
    }
    */
}