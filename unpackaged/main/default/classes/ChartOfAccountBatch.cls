/**
 * Created by CMB on 6/12/2023.
 */
global inherited sharing class ChartOfAccountBatch implements Schedulable, Database.Batchable<SObject>{
    
    public String query;
    
    public ChartOfAccountBatch(){
        query = 'SELECT Id, cmbls__Record_Id__c, cmbls__Number_of_Attempts__c FROM cmbls__Queued_Event__c ' +
            'WHERE ' +
            'cmbls__Type__c = \'' + ChartOfAccountService.QUEUED_EVENT_TYPE + '\' AND ' +
            'cmbls__Date_Processed__c = NULL AND ' +
            'Deleted_Record_Id__c = FALSE AND ' +
            '(cmbls__Number_of_Attempts__c = NULL OR cmbls__Number_of_Attempts__c <= 1)';
    }
    
    public ChartOfAccountBatch(String customQuery){
        query = customQuery;
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, cmbls__Queued_Event__c[] scope){
        ChartOfAccountService.processQueuedEvents(scope);
    }
    
    global void finish(Database.BatchableContext bc){
        Integer remainingRecords = Database.countQuery('SELECT COUNT() FROM cmbls__Queued_Event__c ' +
            'WHERE cmbls__Type__c = \'' + ChartOfAccountService.QUEUED_EVENT_TYPE + '\' AND ' +
            'cmbls__Date_Processed__c = NULL AND ' +
            'Deleted_Record_Id__c = FALSE AND ' +
            '(cmbls__Number_of_Attempts__c = NULL OR cmbls__Number_of_Attempts__c <= 1)');
        if(!Test.isRunningTest() && remainingRecords > 0) Database.executeBatch(new ChartOfAccountBatch(), 1);
    }
    
    global void execute(SchedulableContext sc){
        Database.executeBatch(new ChartOfAccountBatch(), ChartOfAccountService.getBatchSize());
    }
}