/**
 * Created by oporter on 3/19/2018.
 */
@IsTest
public with sharing class AutomatedCreditStartTest {

    @isTest
    public static void testAutomatedCreditStart(){
        Id lenderRecordType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Lender Acct').getRecordTypeId();
        LinkShorteningAPI__c mcs = new LinkShorteningAPI__c(Name = 'V2', Endpoint__c = 'test', Service_Endpoint__c = 'test', Authorization__c = 'test');
        insert mcs;
        
        Account lenderAccountPlatinum = new Account(name = 'National Funding - Platinum WC Funding' , RecordTypeId = lenderRecordType);
        insert lenderAccountPlatinum;
        Account a = new Account(Name = 'Acct Name', Date_Established__c = Date.today());
        insert a;
        Contact c = new Contact(LastName = 'Test', Account = a, Isprimary__c = true);
        insert c;
        Contact c2 = new Contact(LastName = 'Test', Account = a, Isprimary__c = true);
        insert c2;
        Contact c3 = new Contact(LastName = 'Test', Account = a, Isprimary__c = true);
        insert c3;
        
        Opportunity o = new Opportunity(StageName = 'Identified', Account = a, FACILITY_OWNED_LEASED__c = TRUE, Name = 'Test Opp 2', CloseDate = Date.today());
        insert o;
        OpportunityContactRole ocr1 = new OpportunityContactRole();
        ocr1.OpportunityId = o.Id;
        ocr1.Role = 'Signor';
        ocr1.IsPrimary = TRUE;
        ocr1.ContactId = c.Id;
        insert ocr1;
        
        OpportunityContactRole ocr2 = new OpportunityContactRole();
        ocr2.OpportunityId = o.Id;
        ocr2.Role = 'Guarantor 2';
        ocr2.IsPrimary = FALSE;
        ocr2.ContactId = c2.Id;
        insert ocr2;
        
        OpportunityContactRole ocr3 = new OpportunityContactRole();
        ocr3.OpportunityId = o.Id;
        ocr3.Role = 'Guarantor 3';
        ocr3.IsPrimary = FALSE;
        ocr3.ContactId = c3.Id;
        insert ocr3;
        
        List<Id> listOppty = new List<Id>();
        listOppty.add(o.Id);
        Test.startTest();
        HttpMockGenerator mock = new HttpMockGenerator('true', 200);
        Test.setMock(HttpCalloutMock.class, mock);
        AutomatedCreditStart acs = new AutomatedCreditStart();
        AutomatedCreditStart.automatedClass(listOppty);
        Test.stopTest();
    }
}