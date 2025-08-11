/*
* this trigger is used to calculate the actual values for opportunity.
* the values come from funding,account,opportunity records.
* user need to update the funding record, change status to approved.
*/


trigger CalculateActualFromOpportunity on Opportunity (before update) {
	
	Opportunity[] opps;
	
	for(Opportunity opp :  trigger.new){
			if(opp.FlagToClickCalculateActuals__c==false){
				System.debug('not click the calculate actual button,will not fire the trigger...');
				return;
			}else{
				if(opp.FlagToClickCalculateActuals__c==true && opp.Lender_Account__c==null)
				{
					opp.addError('Lender_Account__c is a required field when calculate actuals..');
					
					
					return;
				}else{
					if(opps==null)
					opps = new list<Opportunity>();
					opps.add(opp);
				}
			}
		}
	
		if(opps!=null)
			new oppGMCalcUtil(opps);
}