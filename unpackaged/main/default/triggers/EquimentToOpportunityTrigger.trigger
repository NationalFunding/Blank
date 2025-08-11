trigger EquimentToOpportunityTrigger on FPC_Equipment__c (after insert, after undelete, after update, after delete) {
	set <id> oppId = new set <id>();
	if(trigger.isDelete){
		for(FPC_Equipment__c equ : trigger.old) {
			oppId.add(equ.Opportunity__c);
		}
	}else{
		for(FPC_Equipment__c equ : trigger.new) {
			oppId.add(equ.Opportunity__c);
		}
	}
	List <FPC_Equipment__c> equList = [select Grand_Total_f__c , 
										Opportunity__c from FPC_Equipment__c
										where Opportunity__c =: oppId];
	map <ID,Double> idToValue = new map <ID,Double>();
	for(FPC_Equipment__c equ : equList){
		if(idToValue.containsKey(equ.Opportunity__c)){
			Double tempValue = idToValue.get(equ.Opportunity__c);
			if(tempValue == null){
				tempValue = 0;
			}
			if(equ.Grand_Total_f__c == null){

			} else {
				tempValue += equ.Grand_Total_f__c;
			}			
			idToValue.put(equ.Opportunity__c,tempValue);
		} else {
			idToValue.put(equ.Opportunity__c,equ.Grand_Total_f__c);
		}
	}
	/*if(trigger.isDelete){
		for(FPC_Equipment__c equ : trigger.old){
			system.debug('46*************');
			//Double tempValue = tempValue - equ.Grand_Total_f__c;
			if(idToValue.containsKey(equ.Opportunity__c)){
				system.debug('49*************');
				Double tempValue = idToValue.get(equ.Opportunity__c);
				if(equ.Grand_Total_f__c == null){
					tempValue = tempValue - 0;
				} else {
					tempValue = tempValue - equ.Grand_Total_f__c;
				}				
				system.debug('52*************');
			}
		}
	} else {
		for(FPC_Equipment__c equ : trigger.new){
			if(idToValue.containsKey(equ.Opportunity__c)){
				Double tempValue = idToValue.get(equ.Opportunity__c);
				if(trigger.isInsert || trigger.isUnDelete){
					if(equ.Grand_Total_f__c == null){
						tempValue = tempValue + 0;
					} else {
						tempValue += equ.Grand_Total_f__c;
					}					
				}else if(trigger.isUpdate){
					if(equ.Grand_Total_f__c == null){
						tempValue = tempValue + 0;
					} else {
						tempValue = tempValue + equ.Grand_Total_f__c - trigger.oldMap.get(equ.id).Grand_Total_f__c;
					}					
				}
				idToValue.put(equ.Opportunity__c,tempValue);
			} else {
				idToValue.put(equ.Opportunity__c,equ.Grand_Total_f__c);
			}
		}
	}*/
	List <Opportunity> oppList = new List <Opportunity>();
	oppList = [select id,Actual_Equip_Cost__c from Opportunity where id =:oppId];
	for(Opportunity opp : oppList){
		Double tempValue = idToValue.get(opp.id);
		opp.Actual_Equip_Cost__c = tempValue;
	}
	update oppList;
	/*map <ID,ID> EquimentToOpportunityMap = new map <ID,ID>();
	if(trigger.isInsert){
		for(FPC_Equipment__c equ : trigger.new){
			EquimentToOpportunityMap.put(equ.id,equ.Opportunity__c);
			
		}	
	}*/
}