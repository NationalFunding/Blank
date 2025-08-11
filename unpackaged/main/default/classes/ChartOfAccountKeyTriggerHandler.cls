/**
 * ChartOfAccountKeyTriggerHandler class
 * @author CloudMyBiz (r)
 * @date 11/2/2022
 * @description Follows the One Trigger Per Object design pattern, which allows for the control of execution order and recursion.
 * Ideally, business logic should not be included in this class. Trigger handlers are used to control recursion and order of execution and should delegate other work to service classes.
 * @group Trigger Handlers
 */
public inherited sharing class ChartOfAccountKeyTriggerHandler{
    
    public static void onBeforeInsertUpdate(Chart_of_Account_Key__c[] records, Map<Id, Chart_of_Account_Key__c> oldMap){
        ChartOfAccountService.validateChartOfAccountKeyRecordCreation(records);
    }
}