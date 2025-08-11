trigger CCSReportLink_OnUpdate on Consumer_Credit_Summary__c (after update, after insert) {
	
    String directory_suffix = ''; // FOR PRODUCTION USE EMPTY STRING!
    
    List<Id> ccsToUpdate = new List<Id>();
    for (Consumer_Credit_Summary__c ccs : trigger.new) {
        Boolean toUpdate = false;
        if(trigger.isUpdate) {
            // only execute after update if these fields changed
	        toUpdate = toUpdate || ccs.Transaction_Date__c != trigger.oldMap.get(ccs.id).Transaction_Date__c;
	        toUpdate = toUpdate || ccs.RecordTypeId != trigger.oldMap.get(ccs.id).RecordTypeId;
	        toUpdate = toUpdate || ccs.Credit_Score__c != trigger.oldMap.get(ccs.id).Credit_Score__c;
        } else {
            toUpdate = true; // Always execute on insert
        }
        if(toUpdate) {
        	ccsToUpdate.add(ccs.id);
        }
    }
    
    if(ccsToUpdate.size() == 0) {
        return;
    }
    
    Map<Id, RecordType> recordTypes = new Map<Id, RecordType>([Select Id, Name from RecordType]);
    List<Consumer_Credit_Summary__c> ccsList = [SELECT Id, 
                                                	   RecordTypeId, 
                                                	   Record_Type_Name__c,
                                                       Credit_Score__r.Latest_Report_URL__c, 
                                                	   Transaction_Date__c,
                                                	   URL_for_View_Link__c,
                                                	   Credit_Report_Link__c,
                                                	   CaseSafe_Id__c
                                               FROM Consumer_Credit_Summary__c where Id in :ccsToUpdate];
    
    for (Consumer_Credit_Summary__c ccs : ccsList) {
        string url = ccs.Credit_Report_Link__c;
        if (ccs.Record_Type_Name__c == 'Equifax_Consumer' && ccs.Transaction_Date__c != null) {
            url = 'file://s44/EQF' + directory_suffix + '/' + ccs.Transaction_Date__c.year() + '/' + ccs.Transaction_Date__c.month() + 
                  '/Equifax_' + ccs.CaseSafe_Id__c + '_' + 
                  ccs.Transaction_Date__c.year() + '.' + ccs.Transaction_Date__c.month() + '.' + ccs.Transaction_Date__c.day() + '.pdf';
        } else if (ccs.Record_Type_Name__c == 'Experian_Consumer' && ccs.Transaction_Date__c != null) {
            url = 'file://s44/EXP' + directory_suffix + '/' + ccs.Transaction_Date__c.year() + '/' + ccs.Transaction_Date__c.month() + 
                  '/Experian_' + ccs.CaseSafe_Id__c + '_' + 
                  ccs.Transaction_Date__c.year() + '.' + ccs.Transaction_Date__c.month() + '.' + ccs.Transaction_Date__c.day() + '.pdf';
        } else if (ccs.Record_Type_Name__c == 'Merit') {
            url = ccs.Credit_Score__r.Latest_Report_URL__c;
        }
        ccs.Credit_Report_Link__c = url;
    }
	update ccsList;
}