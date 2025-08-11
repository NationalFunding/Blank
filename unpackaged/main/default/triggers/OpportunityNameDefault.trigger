trigger OpportunityNameDefault on Opportunity (before insert) {
  
    
    Set<id> accIdSet = new Set<Id>();
    Map<Id,Account> OppNameMap = new Map<Id,Account>();
    
    for(Opportunity opp : Trigger.New){
        accIdSet.add(opp.AccountId);
    }
    
    Map<Id,Account> accountMap = new Map<Id,Account>([select name from Account where id = :accIdSet]);
    Map<Id,RecordType> recordTypeMap = new Map<Id,RecordType>([select name from RecordType where sObjectType='Opportunity']);
    List<Opportunity> oppDbList = [select id,AccountId,RecordTypeId from Opportunity where AccountId =: accIdSet];
    
	if(accountMap.size()!=0)
	for(Opportunity opp : Trigger.New){
		Account theAccount = accountMap.get(opp.AccountId);
		if(theAccount!=null){
			OppNameMap.put(opp.Id,theAccount);
		}
		if(OppNameMap.size()!=0){
			integer numberForOppName = 1;
			 for(Opportunity aDbOpp : oppDbList){
			 	if(opp.AccountId == aDbOpp.AccountId){
			 		if(opp.RecordTypeId == aDbOpp.RecordTypeId){
			 			numberForOppName ++;
			 		}
			 	}
			 }
			 opp.Name = theAccount.Name + ' ' + recordTypeMap.get(opp.RecordTypeId).Name + ' Deal #' + ' ' + numberForOppName ;    
		}
	}

    
}