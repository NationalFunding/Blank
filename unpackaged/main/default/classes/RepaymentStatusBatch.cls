/**
 * RepaymentStatusBatch class
 * @author CloudMyBiz (r)
 * @date 3/22/2022
 * @info If you use a QueryLocator object, the governor limit for the total number of records retrieved by SOQL queries is bypassed
 * Use the iterable to create a complex scope for the batch job. You can also use the iterable to create your own custom process for iterating through the list.
  (If you use an iterable, the governor limit for the total number of records retrieved by SOQL queries is still enforced.)
 * @group Batch
 */
global class RepaymentStatusBatch implements Database.Batchable<SObject>, Schedulable{
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator('SELECT Id, Pause_Date__c, Resume_Date__c FROM cmbls__Repayment__c WHERE Pause_Date__c = TODAY OR Resume_Date__c = TODAY');
    }
    
    global void execute(Database.BatchableContext bc, List<SObject> scope){
        Set<Id> repaymentsToResume = new Set<Id>();
        cmbls__Repayment__c[] repaymentsToUpdate = new cmbls__Repayment__c[]{};
        
        for(SObject item :scope){
            cmbls__Repayment__c repayment = (cmbls__Repayment__c)item;
            if(repayment.Pause_Date__c == System.today()){
                repayment.cmbls__Status__c = RepaymentUtils.STATUS_TEMPORARY_PAUSE;
            }else if(repayment.Resume_Date__c == System.today()){
                repayment.cmbls__Status__c = RepaymentUtils.STATUS_ACTIVE;
                repaymentsToResume.add(repayment.Id);
            }
            repaymentsToUpdate.add(repayment);
        }
        
        cmbls__Repayment_Schedule__c[] schedules = RepaymentScheduleSelector.getRepaymentSchedulesByRepaymentIds(repaymentsToResume);
        for(cmbls__Repayment_Schedule__c schedule :schedules){
            schedule.cmbls__Next_Payment_Date__c = null;
        }
        
        Database.update(repaymentsToUpdate);
        Database.update(schedules);
    }
    
    global void finish(Database.BatchableContext bc){}
    
    global void execute(SchedulableContext param1){
        Database.executeBatch(new RepaymentStatusBatch());
    }
}