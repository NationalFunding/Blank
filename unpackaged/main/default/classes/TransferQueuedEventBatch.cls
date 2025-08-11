/**
 * TransferQueuedEventBatch class
 * @author CloudMyBiz (r)
 * @date 8/11/2022
 * @info If you use a QueryLocator object, the governor limit for the total number of records retrieved by SOQL queries is bypassed
 * Use the iterable to create a complex scope for the batch job. You can also use the iterable to create your own custom process for iterating through the list.
  (If you use an iterable, the governor limit for the total number of records retrieved by SOQL queries is still enforced.)
 * @group Batch
 */
global class TransferQueuedEventBatch implements Database.Batchable<SObject>, Schedulable{
    
    public static final String TRANSFER_RECORDS_CREATION = 'TRANSFER RECORDS CREATION';
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        //First we need to check if not and existing batch running, if so, just return null to prevent parallel processing
        if(!isAutomaticTransferEnabled() || isBatchRunning(bc.getJobId())) return null;
    
        return Database.getQueryLocator([
            SELECT Id, cmbls__Record_Id__c, cmbls__Number_of_Attempts__c FROM cmbls__Queued_Event__c
            WHERE
                cmbls__Type__c = :TRANSFER_RECORDS_CREATION AND
                cmbls__Date_Processed__c = NULL AND
                Deleted_Record_Id__c = FALSE AND
                (cmbls__Number_of_Attempts__c = NULL OR cmbls__Number_of_Attempts__c < 5) AND
                Canceled__c = FALSE AND
                (Process_On__c = NULL OR Process_On__c <= TODAY)
        ]);
    }
    
    global void execute(Database.BatchableContext bc, cmbls__Queued_Event__c[] scope){
        RepaymentService.createTransferRecords(scope);
    }
    
    global void finish(Database.BatchableContext bc){}
    
    global void execute(SchedulableContext sc){
        Database.executeBatch(new TransferQueuedEventBatch(), TransferQueuedEventBatch.getBatchSize());
    }
    
    public static Set<Id> getExistingEventsForGivenRecordIds(Set<Id> recordIds){
        Set<Id> existingQueuedEvents = new Set<Id>();
        for(cmbls__Queued_Event__c item :[SELECT cmbls__Record_Id__c FROM cmbls__Queued_Event__c WHERE cmbls__Type__c = :TRANSFER_RECORDS_CREATION AND cmbls__Date_Processed__c = NULL AND cmbls__Record_Id__c IN :recordIds]){
            existingQueuedEvents.add(item.cmbls__Record_Id__c);
        }
        return existingQueuedEvents;
    }
    
    public static Boolean isAutomaticTransferEnabled(){
        cmbls__Loan_Servicing_Settings__c settings = cmbls__Loan_Servicing_Settings__c.getInstance();
        return  settings.Enable_Automatic_Transfers__c &&
                String.isNotBlank(settings.National_Funding_Fund_Id__c) &&
                settings.National_Funding_Fund_Id__c instanceof Id &&
                Id.valueOf(settings.National_Funding_Fund_Id__c).getSobjectType() == cmbls__Fund__c.SObjectType;
    }
    
    public static Integer getBatchSize(){
        Integer output = 10;
        cmbls__Loan_Servicing_Settings__c settings = cmbls__Loan_Servicing_Settings__c.getInstance();
        if(settings.Automatic_Transfer_Batch_Size__c != null) output = Integer.valueOf(settings.Automatic_Transfer_Batch_Size__c);
        return output;
    }
    
    private static Boolean isBatchRunning(Id jobId){
        Set<String> jobStatuses = new Set<String>{'Processing', 'Holding', 'Preparing'};
        AsyncApexJob[] currentJobs = [SELECT Id FROM AsyncApexJob WHERE Id != :jobId AND Status IN :jobStatuses AND ApexClass.Name = 'TransferQueuedEventBatch' LIMIT 1];
        return !currentJobs.isEmpty();
    }
}