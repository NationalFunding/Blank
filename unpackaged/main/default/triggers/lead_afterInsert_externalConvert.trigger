trigger lead_afterInsert_externalConvert on Lead (after update) {
    if(Trigger.new[0].convertedLeadInitialStatus__c == 'Requested')
	new externalCustomLeadConvert(Trigger.new[0].id);
}