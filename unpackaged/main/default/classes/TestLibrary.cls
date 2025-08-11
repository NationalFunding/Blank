/**
 * ─────────────────────────────────────────────────────────────────────────────────────────────────
 * TITLE: TestDataFactory
 * DESCRIPTION: Utility class for creating test data for Contacts and Accounts and Opportunity
 * @author         Amrit
 * @version        1.0
 * @created        31/01/2025
 * ─────────────────────────────────────────────────────────────────────────────────────────────────
 */
@isTest
public class TestLibrary {
    public static Account createTestAccount() {
        Account newAccount = new Account(
            Name = 'Test Account',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('New Customer Acct').getRecordTypeId()
        );
        insert newAccount;
        return newAccount;
    }
	public static Account createAccountOfRecordType(String accountName, String recordTypeName) {
        Account newAccount = new Account(
            Name = accountName,
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId()
        );
        insert newAccount;
        return newAccount;
    }
    public static Contact createTestContact(Account account) {
        Contact newContact = new Contact(
            FirstName = 'John',
            LastName = 'Doe',
            AccountId = account != null ? account.Id : null,
            SSN_Encrypted__c = '123-45-6789',
            Phone = '(123) 456-7890',
            MobilePhone  = '(123) 456-7890',
            OtherPhone   = '(123) 456-7890',
            HomePhone    = '(123) 456-7890',
            FICO_Score__c = 700
        );
        insert newContact;
        return newContact;
    }
    
    public static Lead createTestLead() {
        Lead l = new Lead();
        l.FirstName = 'Tom';
        l.LastName = 'Test';
        l.Company = 'Five9';
		l.Email = 'test1@example.com';
        l.PostalCode = '12345';
        l.Short_Account_Number__c = 'SACC123';
        l.Status='House';
 		l.SSN_Encrypted__c = '123-45-6789';
        insert l;
        return l;
    }
    // Create test Campaigns
    public static List<Campaign> createTestCampaigns(Integer numCampaigns) {
        List<Campaign> testCampaigns = new List<Campaign>();
        for (Integer i = 0; i < numCampaigns; i++) {
            testCampaigns.add(new Campaign(Name = 'Test Campaign ' + i));
        }
        insert testCampaigns;
        return testCampaigns;
    }

    // Create test CampaignMembers
    public static List<CampaignMember> createTestCampaignMembers(List<Contact> contacts, List<Campaign> campaigns) {
        List<CampaignMember> testCampaignMembers = new List<CampaignMember>();
        for (Contact con : contacts) {
            for (Campaign camp : campaigns) {
                testCampaignMembers.add(new CampaignMember(
                    ContactId = con.Id,
                    CampaignId = camp.Id
                ));
            }
        }
        insert testCampaignMembers;
        return testCampaignMembers;
    }

    // Create test Opportunities
    public static List<Opportunity> createTestOpportunities(List<Account> accounts, Id lenderAccountId, Map<String, Id> recordTypeMap) {
        List<Opportunity> testOpps = new List<Opportunity>();
        for (Account acc : accounts) {
            testOpps.add(new Opportunity(
                Name = 'Test Opp 1 - ' + acc.Name,
                AccountId = acc.Id,
                RecordTypeId = recordTypeMap.get('Lease_Oppty_Record_Type'),
                Lender_Account__c = lenderAccountId,
                Merchant_Number__c = '12345',
                Funds_Released_By__c = 'ACH',
                StageName = 'Funded',
                Type = 'NEW',
                Lease_Deposit_Check_Received__c = true,
                CloseDate = System.today().addDays(30)
            ));
            testOpps.add(new Opportunity(
                Name = 'Test Opp 3 - ' + acc.Name,
                AccountId = acc.Id,
                RecordTypeId = recordTypeMap.get('EPP_Oppty'),
                Lender_Account__c = lenderAccountId,
                Merchant_Number__c = '12345',
                Funds_Released_By__c = 'ACH',
                StageName = 'Funded',
                EPP_Equip_LP__c = true,
                EPP_Equip_PO_to_Accounting__c = true,
                CloseDate = System.today().addDays(30)
            ));
            testOpps.add(new Opportunity(
                Name = 'Test Opp 4 - ' + acc.Name,
                AccountId = acc.Id,
                RecordTypeId = recordTypeMap.get('Broker_WC_Oppty'),
                StageName = 'Funded',
                Type = 'NEW',
                Lender_Account__c = lenderAccountId,
                Funds_Released_By__c = 'ACH',
                Merchant_Number__c = '12345',
                CloseDate = System.today().addDays(30)
            ));
            testOpps.add(new Opportunity(
                Name = 'Test Opp 5 - ' + acc.Name,
                AccountId = acc.Id,
                RecordTypeId = recordTypeMap.get('External_Collections'),
                StageName = 'Funded',
                Lender_Account__c = lenderAccountId,
                Funds_Released_By__c = 'ACH',
                Merchant_Number__c = '12345',
                CloseDate = System.today().addDays(30)
            ));
            testOpps.add(new Opportunity(
                Name = 'Test Opp 6 - ' + acc.Name,
                AccountId = acc.Id,
                RecordTypeId = recordTypeMap.get('FRPSA'),
                StageName = 'Funded',
                Type = 'NEW',
                Lender_Account__c = lenderAccountId,
                Funds_Released_By__c = 'ACH',
                Merchant_Number__c = '12345',
                CloseDate = System.today().addDays(30)
            ));
            testOpps.add(new Opportunity(
                Name = 'Test Opp 7 - ' + acc.Name,
                AccountId = acc.Id,
                RecordTypeId = recordTypeMap.get('Direct_MLP'),
                StageName = 'Funded',
                Type = 'NEW',
                Lender_Account__c = lenderAccountId,
                Funds_Released_By__c = 'ACH',
                Merchant_Number__c = '12345',
                CloseDate = System.today().addDays(30)
            ));
        }
        insert testOpps;
        return testOpps;
    }

    // Fetch RecordTypeIds for Opportunities
    public static Map<String, Id> getOpportunityRecordTypeMap() {
        Map<String, Id> recordTypeMap = new Map<String, Id>();
        for (RecordType rt : [
            SELECT Id, DeveloperName 
            FROM RecordType 
            WHERE SObjectType = 'Opportunity' 
            AND DeveloperName IN ('Lease_Oppty_Record_Type', 'EPP_Oppty', 'Broker_WC_Oppty', 'External_Collections', 'FRPSA', 'Broker_FRPSA', 'Direct_MLP')
        ]) {
            recordTypeMap.put(rt.DeveloperName, rt.Id);
        }
        return recordTypeMap;
    }
    public static Opportunity createOpportunity(Id lenderAccountId, Id accountId, Id oppRecordType){
        Id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('FRPSA').getRecordTypeId();
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opp 1';
        opp.AccountId = accountId;
        opp.RecordTypeId = oppRecordType !=null ? oppRecordType : oppRecordTypeId;
        opp.StageName = 'Identified';
        if (lenderAccountId != null)opp.Lender_Account__c = lenderAccountId;
        opp.CloseDate = System.today().addDays(30);
        insert opp;
        return opp;
    }
}