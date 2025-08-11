@isTest
public with sharing class CreditReviewScreen_LWCTest {


    @isTest
    private static void unitTestForConstructor(){

        Account acc = new Account(name = 'Test Account');
        insert acc;
        Id workingCapitalOpptId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Working Capital Oppty').getRecordTypeId();
        Opportunity opp = new Opportunity( RecordTypeId = workingCapitalOpptId, AccountId = acc.id, name = 'Test opp',StageName = 'Credit Review', CloseDate= Date.today().addDays(7));
        insert opp;

        contact PG1 = new contact(LastName = 'PG1');
        contact PG2 = new contact(LastName = 'PG2');
        contact PG3 = new contact(LastName = 'PG3');
        contact relatedContact = new Contact(LastName = 'Related');
        List<contact> contactList = new List<contact>();
        contactList.add(PG1);
        contactList.add(PG2);
        contactList.add(PG3);
        contactList.add(relatedContact);
        insert contactList;
        Account businessAccount = new Account(name = 'Standard');
        insert businessAccount;
        Business_Credit_Summary__c bcSummary = new Business_Credit_Summary__c(Account__c = businessAccount.id,Status__c ='Completed');
        insert bcSummary;

        Credit_review__c credit_review = new Credit_review__c(Opportunity__c = opp.Id, Create_WC_Decision_Record__c  = 'Ready', Status__c  = 'Withdrawn',PG1__c = PG1.id,
                EXP_Business_Summary__c = bcSummary.id, PG2__c = PG2.id,PG3__c = PG3.id, Approval_Expiration_Date__c = Date.today().addDays(15));
        insert credit_review;

        Bank_Data__c bankData = new Bank_Data__c(Account__c = acc.id,Account_Number__c='56644799',Bank_Name__c='STATE BANK',Routing_Number__c='0070799');
        insert bankData;
        Credit_Review_Bank_Summary__c crbSummary = new Credit_Review_Bank_Summary__c(Credit_Review__c =credit_review.id, Related_Bank_Data__c = bankData.id);
        insert crbSummary;
        Bank_Monthly_Ledgers__c bmLedgers = new Bank_Monthly_Ledgers__c(Bank_Data__c = bankData.id,Beginning_Balance__c = 300,Deposits_Count__c=3,Counter_Deposits__c=2,
                                                                        Other_Deposits__c=1,Withdrawls__c=2,Ending_Balance__c=250,Negative_Days__c=1,NSF_s__c=30,Avg_Daily_Balance__c=50);
        insert bmLedgers;
        Credit_Review_Monthly_Ledger__c crmLedger = new Credit_Review_Monthly_Ledger__c(Bank_Monthly_Ledger__c  = bmLedgers.id,Bank_Summary__c=crbSummary.id,sort_order__c = Date.today().addDays(3),
                                                                                        Include_in_Averages__c = true,year__c =Date.today().addDays(3).year(), month__c = Date.today().addDays(3).month() );
        insert crmLedger;
        Credit_Review_Related_Business__c creditReviewBusiness = new Credit_Review_Related_Business__c(Account__c =  businessAccount.id,Credit_Review__c = credit_review.id);
        insert creditReviewBusiness;
        Consumer_Credit_Summary__c ccSummary = new Consumer_Credit_Summary__c(contact__c = relatedContact.id, status__c = 'Completed', Transaction_Date__c = Date.today().addDays(-7), FirstName__c = relatedContact.FirstName, LastName__c = relatedContact.LastName);
        insert ccSummary;
        Credit_Review_Related_Contact__c creditReviewContact = new Credit_Review_Related_Contact__c(Contact__c = relatedContact.id, Credit_Review__c = credit_review.id);
        insert creditReviewContact;

        CreditReviewScreen_LWC.SummaryModelClass wrapperRes = CreditReviewScreen_LWC.individualBankTabSummaryTab(credit_review.Id);
        system.assert(wrapperRes!=null);
    }
}