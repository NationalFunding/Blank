/**
 * ChartOfAccountSelector class
 * @author CloudMyBiz (r)
 * @date 10/24/2022
 * @description Service Class. Interface between business logic and specific apex contexts such as Trigger Handlers, Controllers, Batch Classes, API etc.
 * Services generally include static methods that implement business logic. Exceptions are generally thrown for the caller to handle.
 * @group Services
 */
public inherited sharing class ChartOfAccountSelector{

    public static Chart_of_Account_Key__c[] getChartOfAccountKeys(){
        return [SELECT Id, Name, Key__c, Company__c, Product_Type__c, Previous_Company__c FROM Chart_of_Account_Key__c];
    }

    public static Chart_of_Account__c[] getChartOfAccounts(){
        List<String> fields = new List<String>(
            Chart_of_Account__c.sObjectType.getDescribe().fields.getMap().keySet()
        );
        return Database.query('SELECT ' + String.join(fields, ',') + ' FROM Chart_of_Account__c');
    }
}