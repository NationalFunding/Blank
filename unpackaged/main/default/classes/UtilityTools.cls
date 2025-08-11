public class  UtilityTools {
	
	public static Boolean dummyAccUpdate = false;
	public static Double getDoubleValFromDecimal(Decimal input){
		return input == null ? 0 : getDoubleValFromDouble(Double.valueOf(input));
	}
	
	public static Double getDoubleValFromDouble(Double input){
		return input == null ? 0 : input;
	}
	
	public static cmbls__Debug_Log__c getDebugLogForDMLFailure(String apexClass, SObject record, Database.SaveResult result){
		return getDebugLogForDMLErrors(apexClass, record, result?.getErrors());
	}
	
	public static cmbls__Debug_Log__c getDebugLogForDMLErrors(String apexClass, SObject record, Database.Error[] errors){
		cmbls__Debug_Log__c log = getDebugLogForRecord(apexClass, record);
		if(errors != null){
			Integer errorIndex = 1;
			for(Database.Error err :errors){
				log.cmbls__Log__c += '- Index: ' + errorIndex + '\n';
				log.cmbls__Log__c += '- Code: ' + err.getStatusCode() + '\n';
				log.cmbls__Log__c += '- Message: ' + err.getMessage() + '\n';
				log.cmbls__Log__c += '- Fields: ' + err.getFields() + '\n';
				log.cmbls__Log__c += '---------------------------------------\n';
				errorIndex++;
			}
		}
		return log;
	}
	
	public static String getStringListForINSOQLClause(String[] strList){
		return '(\'' + String.join(strList, '\',\'') + '\')';
	}
	
	private static cmbls__Debug_Log__c getDebugLogForRecord(String apexClass, SObject record){
		return new cmbls__Debug_Log__c(
			cmbls__Subject__c = apexClass + ' - record could not be created.',
			cmbls__Description__c = 'Record insert failure on ' + apexClass,
			cmbls__Log__c = 'Affected record:\n\n' + JSON.serializePretty(record) + '\n\n\nErrors:\n\n',
			cmbls__Record_Id__c = record.Id
		);
	}

    public static Boolean isBatchRunning(String className) {
        AsyncApexJob[] jobs = [
            SELECT Id
            FROM AsyncApexJob
            WHERE
            Status IN ('Holding', 'Queued', 'Preparing', 'Processing') AND
            ApexClass.Name = :className AND
            JobType='BatchApex'
        ];

        return !jobs.isEmpty();
    }
}