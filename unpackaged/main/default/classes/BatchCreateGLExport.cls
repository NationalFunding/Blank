/**
 * BatchCreateGLExport class
 * @author CloudMyBiz (r)
 * @date 5/30/2023
 */

global inherited sharing class BatchCreateGLExport implements Database.Batchable<SObject>, Schedulable{
    global Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator([SELECT Id FROM cmbls__GL_Transaction__c WHERE cmbls__Sent_to_GP__c = NULL AND cmbls__GP_Batch__c = NULL]);
    }
    global void execute(Database.BatchableContext bc, List<cmbls__GL_Transaction__c> scope){
        cmbls__GP_Batch__c[] existingBatch = [SELECT Id FROM cmbls__GP_Batch__c WHERE Batch_Related_Id__c = :bc.getJobId()];
        cmbls__GP_Batch__c batch;
        if(existingBatch.isEmpty()){
            batch = new cmbls__GP_Batch__c(cmbls__Status__c = 'Success', Batch_Related_Id__c = bc.getJobId());
            insert batch;
        }else{
            batch = existingBatch[0];
        }
        
        for(cmbls__GL_Transaction__c item :scope){
            item.cmbls__GP_Batch__c = batch.Id;
            item.cmbls__Sent_to_GP__c = System.now();
        }
        update scope;
    }
    
    global void finish(Database.BatchableContext bc){}
    
    global void execute(SchedulableContext sc){
        Database.executeBatch(new BatchCreateGLExport());
    }

}