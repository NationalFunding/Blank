/**
 * GL_TransactionTriggerHandler class
 * @author CloudMyBiz (r)
 * @date 11/8/2022
 * @description Follows the One Trigger Per Object design pattern, which allows for the control of execution order and recursion.
 * Ideally, business logic should not be included in this class. Trigger handlers are used to control recursion and order of execution and should delegate other work to service classes.
 * @group Trigger Handlers
 */
public inherited sharing class GL_TransactionTriggerHandler{
    
    public static void onBeforeInsertUpdate(cmbls__GL_Transaction__c[] records, Map<Id, cmbls__GL_Transaction__c> oldMap){
        if(Trigger.isInsert){
            List<Accounting_Period__c> closedPeriods = [SELECT Id, Date__c FROM Accounting_Period__c WHERE Status__c = 'Closed' ORDER BY Date__c DESC LIMIT 1];
            if(!closedPeriods.isEmpty()){
                Date earliestPostDate;
                Accounting_Period__c earliest = closedPeriods[0];
                earliestPostDate = earliest.Date__c.addMonths(1).toStartOfMonth();
                for(cmbls__GL_Transaction__c tr : records){
                    tr.Earliest_Post_Date__c = earliestPostDate;
                }
            }
        }
    }
    
    public static void onAfterInsertUpdate(cmbls__GL_Transaction__c[] records, Map<Id, cmbls__GL_Transaction__c> oldMap){
        if(Trigger.isInsert){
            List<Approval.ProcessSubmitRequest> requests = new List<Approval.ProcessSubmitRequest>();
            for(cmbls__GL_Transaction__c tr : records){
                if(tr.cmbls__Date__c < tr.Earliest_Post_Date__c){
                    Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                    req1.setObjectId(tr.Id);
                    requests.add(req1);
                }
            }
            if(!requests.isEmpty()) Approval.process(requests,false);
        }
    }
}