/**
 * ChartOfAccountKeyTrigger class
 * @author CloudMyBiz (r)
 * @date 11/2/2022
 * @description Trigger for Chart_of_Account_Key__c. Follows the One Trigger Per Object design pattern, which allows for the control of execution order and recursion
 * @group Triggers
 */
trigger ChartOfAccountKeyTrigger on Chart_of_Account_Key__c (before insert, before update, before delete, after insert, after update, after delete, after undelete){
    
    if(Trigger.isBefore){
        if(Trigger.isUpdate || Trigger.isInsert){
            ChartOfAccountKeyTriggerHandler.onBeforeInsertUpdate(Trigger.new, Trigger.oldMap);
        }
    }
}