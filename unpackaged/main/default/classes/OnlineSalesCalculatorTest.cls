/**
 * Created by oporter on 6/21/2018.
 */

@IsTest
public with sharing class OnlineSalesCalculatorTest {

    public static testMethod void test1(){
        LinkShorteningAPI__c lsapi = new LinkShorteningAPI__c(Name = 'V2', Endpoint__c = 'test', Authorization__c= '123', Service_Endpoint__c = 'test');
        insert lsapi;
        //if (lenderName.contains('National Funding') && (recordTypeName == 'Broker WC Oppty' || recordTypeName == 'Working Capital Oppty')) {

        Id workingCapitalOpptId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Working Capital Oppty').getRecordTypeId();

        Id lenderRecordType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Lender Acct').getRecordTypeId();
        Account lenderAccountPlatinum = new Account(name = 'National Funding - Platinum WC Funding' , RecordTypeId = lenderRecordType);
        insert lenderAccountPlatinum;

        Account a = new Account(name = 'test');
        insert a;

        Opportunity o = new Opportunity(RecordTypeId = workingCapitalOpptId, Lender_Account__c = lenderAccountPlatinum.Id, Residual_Assigned_To__c = 'FPC', AccountId = a.Id, StageName = 'Identified', CloseDate = Date.today());
        insert o;

        FPC_Funding_del__c fpc = new FPC_Funding_del__c(Lender_ID__c = lenderAccountPlatinum.Id, Lender_Position__c = 1, Status__c = 'Submitted', Opportunity__c = o.Id);
        insert fpc;

        FPC_Funding_del__c fpcUpdate = new FPC_Funding_del__c(Id = fpc.Id, Status__c = 'Approved');
        update fpcUpdate;

        SingleRequestMockClass fakeResponse = new SingleRequestMockClass(201,'Complete','[{"Id":"a0D2C000000Zcz7UAC","Token":"1XQhA-ofQwWJD3RtaV5-"}]',null);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, fakeResponse);
        Test.stopTest();
    }
}