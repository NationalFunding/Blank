/**
 * RSNextPaymentDateBatch class
 * @author CloudMyBiz (r)
 * @date 8/15/2023
 * @info If you use a QueryLocator object, the governor limit for the total number of records retrieved by SOQL queries is bypassed
 * Use the iterable to create a complex scope for the batch job. You can also use the iterable to create your own custom process for iterating through the list.
  (If you use an iterable, the governor limit for the total number of records retrieved by SOQL queries is still enforced.)
 * @group Batch
 */
global class RSNextPaymentDateBatch implements Database.Batchable<SObject>{
    
    public static final String ERROR_MESSAGE = 'Unable to validate Repayment Schedule Next Payment Date due to the following errors: \n\n{0}';
    @TestVisible private static final String ERROR_SUBJECT = 'Loan Servicing - Repayment Schedule - Validate Next Payment Date: Process Error';
    global Set<Id> recordIds;
    
    global RSNextPaymentDateBatch(Set<Id> rsRecordIds){
        recordIds = rsRecordIds;
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator([SELECT Id, cmbls__Next_Payment_Date__c, cmbls__ACH_Processor__c FROM cmbls__Repayment_Schedule__c WHERE Id IN :recordIds]);
    }
    
    global void execute(Database.BatchableContext bc, List<cmbls__Repayment_Schedule__c> scope){
        try{
            cmbls__Repayment_Schedule__c[] recordsToUpdate = new cmbls__Repayment_Schedule__c[]{};
            for(cmbls__Repayment_Schedule__c record :scope){
                Date oldDate = record.cmbls__Next_Payment_Date__c;
                RepaymentScheduleService.validateNextPaymentDate(record);
                if(record.cmbls__Next_Payment_Date__c != oldDate) recordsToUpdate.add(record);
            }
            
            if(!recordsToUpdate.isEmpty()){
                RepaymentScheduleTriggerHandler.RUN_NEXT_PAYMENT_DATE_VALIDATION = false;
                update recordsToUpdate;
            }
        }catch(Exception e){
            insert new cmbls__Debug_Log__c(cmbls__Subject__c = ERROR_SUBJECT, cmbls__Description__c = e.getMessage(), cmbls__Log__c = String.format(ERROR_MESSAGE, new String[]{e.getStackTraceString()}));
        }
    }
    
    global void finish(Database.BatchableContext bc){}
    
    public static Integer getBatchSize(){
        Double settingSize = cmbls__Loan_Servicing_Settings__c.getInstance().RSNextPaymentDateBatch_Size__c;
        return settingSize != null && settingSize <= 100 ? Integer.valueOf(settingSize) : 20;
    }
}