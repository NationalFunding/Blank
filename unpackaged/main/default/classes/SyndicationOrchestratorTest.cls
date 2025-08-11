/**
 * Created by oporter on 12/31/2018.
 */

@isTest
public with sharing class SyndicationOrchestratorTest {

    public static testMethod void testSuccess(){
        SingleRequestMockClass fakeResponse = new SingleRequestMockClass(204, 'Complete', 'test', null);
        Test.startTest();
        Opportunity opp = new Opportunity(StageName = 'test', CloseDate = Date.today(),Name = 'test');
        insert opp;
        FPC_Funding_del__c fundingRecord = new FPC_Funding_del__c(Opportunity__c = opp.Id);
        insert fundingRecord;
        List<Id> fundingRecordList = new List<Id>();
        fundingRecordList.add(fundingRecord.Id);
        Test.setMock(HttpCalloutMock.class, fakeResponse);
        SyndicationOrchestrator.authenticateAndPostSyndicationService('test', '123', 'test', fundingRecord.Id);
        Test.stopTest();
        system.assertEquals(fundingRecord.Status__c, null); //this will change depending on how we call the class from the PB
    }

    public static testMethod void testSynd(){
        STSConfig__c stsConfig = new STSConfig__c(Endpoint__c = 'test');
        insert stsConfig;
        Syndication__c syndicationCustomSetting = new Syndication__c(Endpoint__c = 'test', APIKey__c = '123456789');
        insert syndicationCustomSetting;
        SingleRequestMockClass fakeResponse = new SingleRequestMockClass(204, 'Complete', 'test', null);
        Test.startTest();
        Opportunity opp = new Opportunity(StageName = 'test', CloseDate = Date.today(),Name = 'test');
        insert opp;
        FPC_Funding_del__c fundingRecord = new FPC_Funding_del__c(Opportunity__c = opp.Id);
        insert fundingRecord;
        List<Id> fundingRecordList = new List<Id>();
        
        Test.setMock(HttpCalloutMock.class, fakeResponse);
        SyndicationOrchestrator.SyndicationRequestWrapper wrapper = new SyndicationOrchestrator.SyndicationRequestWrapper();
        wrapper.fundingId = fundingRecord.Id;
    	wrapper.brand = 'Quick Bridge'; 
        List<SyndicationOrchestrator.SyndicationRequestWrapper> requestList = new List<SyndicationOrchestrator.SyndicationRequestWrapper>{ wrapper };
        SyndicationOrchestrator.getSyndication(requestList);
        Test.stopTest();
        system.assertEquals(fundingRecord.Status__c, null); //this will change depending on how we call the class from the PB
    }

    public static testMethod void testError(){
        Opportunity opp = new Opportunity(StageName = 'test', CloseDate = Date.today(),Name = 'test');
        insert opp;
        FPC_Funding_del__c fundingRecord = new FPC_Funding_del__c(Opportunity__c = opp.Id);
        insert fundingRecord;
        SyndicationOrchestrator.updateFundingRecordError(401, 'Internal Error', fundingRecord.Id);
        system.assertEquals(null, fundingRecord.Status__c); //this will change depending on how we call the class from the PB
    }

    public static testMethod void testCallPB(){
        STSConfig__c stsConfig = new STSConfig__c(Endpoint__c = 'test');
        insert stsConfig;
        Syndication__c syndicationCustomSetting = new Syndication__c(Endpoint__c = 'test', APIKey__c = '123456789');
        insert syndicationCustomSetting;
        SingleRequestMockClass fakeResponse = new SingleRequestMockClass(204, 'Complete', 'test', null);
        Test.startTest();
        Opportunity opp = new Opportunity(StageName = 'test', CloseDate = Date.today(),Name = 'test');
        insert opp;
        FPC_Funding_del__c fundingRecord = new FPC_Funding_del__c(Opportunity__c = opp.Id);
        insert fundingRecord;
        List<Id> fundingRecordList = new List<Id>();
        fundingRecordList.add(fundingRecord.Id);
        Test.setMock(HttpCalloutMock.class, fakeResponse);
        fundingRecord.Status__c = 'Send to Lender';
        fundingRecord.Send_Method__c = 'Automated';
        update fundingRecord;
        Test.stopTest();
        system.assertEquals(fundingRecord.Status__c, 'Send to Lender');
    }
}