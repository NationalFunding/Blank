/**
 * Created by oporter on 12/22/2017.
 */
@isTest
public with sharing class AutomatedCreditStartOppTest {

    @TestSetup
    static void makeData(){
        LinkShorteningAPI__c mcs = new LinkShorteningAPI__c(Name = 'V2', Endpoint__c = 'test', Service_Endpoint__c = 'test', Authorization__c = 'test');
        insert mcs;
    }

    @isTest
    public static void insertOpp() {
        Test.startTest();
        Id lenderRecordType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Lender Acct').getRecordTypeId();
        List<Credit_Review__c> oldList  = new List<Credit_Review__c>([SELECT Id FROM Credit_Review__c]);
        Account lenderAccountPlatinum = new Account(name = 'National Funding - Platinum WC Funding' , RecordTypeId = lenderRecordType);
        insert lenderAccountPlatinum;
        Opportunity o = new Opportunity(Account = lenderAccountPlatinum, StageName = 'Statements In - MCA', Name = 'Test Opp 1', CloseDate = Date.today()); 
        insert o;
        List<Credit_Review__c> newList = new List<Credit_Review__c>([SELECT Id FROM Credit_Review__c]);
        Test.stopTest();
        //assert that the class was called
        System.assertNotEquals(oldList.size(), newList.size());

    }

    @isTest
    public static void updateOpp() {
        Test.startTest();
        Id lenderRecordType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Lender Acct').getRecordTypeId();
        List<Credit_Review__c> oldList = new List<Credit_Review__c>([SELECT Id FROM Credit_Review__c]);
        Account lenderAccountPlatinum = new Account(name = 'National Funding - Platinum WC Funding' , RecordTypeId = lenderRecordType);
        insert lenderAccountPlatinum;
        Contact c = new Contact(LastName = 'Test', Account = lenderAccountPlatinum, Isprimary__c = true);
        insert c;
        Opportunity o = new Opportunity(StageName = 'Identified', Account = lenderAccountPlatinum, FACILITY_OWNED_LEASED__c = TRUE, Name = 'Test Opp 2', CloseDate = Date.today());
        insert o;
        Opportunity o2 = new Opportunity(Id = o.Id, StageName = 'Statements In - MCA');
        update o;
        List<Credit_Review__c> newList  = new List<Credit_Review__c>([SELECT Id FROM Credit_Review__c]);
        Test.stopTest();
        //assert that the class was called
        System.assertEquals(oldList.size(), newList.size());
    }
}