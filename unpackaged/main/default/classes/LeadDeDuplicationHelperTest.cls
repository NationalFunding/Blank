/*
* TITLE:            LeadDeDuplicationHelperTest
* DESCRIPTION:      Test class for LeadDeDuplicationHelper
* @modifiedBy       Olivia Porter       olivia.k.porter@gmail.com
* @version          1.0
* @created          2022-08-25
*/
@isTest
public with sharing class LeadDeDuplicationHelperTest {

    @testSetup static void createTestData(){
        Lead oldLead = new Lead(FirstName = 'oldLeadFN', LastName = 'oldLeadLN', Company = 'oldLeadCompany', Status = 'House', PostalCode = '92110');
        insert oldLead;

        Campaign camp = new Campaign(Name = 'TestCampaignName');
        insert camp;

        CampaignMember cm = new CampaignMember(CampaignId = camp.Id, LeadId = oldLead.Id, Account_Number__c = '1234567891011121');
        insert cm;
    }

    @isTest
    public static void duplicateLeadMerge(){
        Lead newLead = new Lead(FirstName = 'TestFN', LastName= 'TestLN', Company = 'TestCompanyName', Web_Lead__c = true, 
                                Internet_Workflows__c = 'To Be Processed - Merged', PostalCode = '92110', 
                                Account_Number__c = '1234567891011121', Short_Account_Number__c = '123456789');
        insert newLead;


        CampaignMember cmStatus = [SELECT Status FROM CampaignMember LIMIT 1];
        Lead oldLead = [SELECT FirstName, Status FROM Lead WHERE Id != :newLead.Id LIMIT 1];
        Lead newLeadThatShouldBeDeleted = [SELECT Delete_Me__c FROM Lead WHERE Id = :newLead.Id LIMIT 1];

        System.assertEquals('Responded', cmStatus.Status); //making sure the CM was updated
        System.assertEquals('TestFN', oldLead.FirstName); //making sure the old lead is updated with new lead data
        System.assertEquals(true, newLeadThatShouldBeDeleted.Delete_Me__c); //making sure we are marking new lead to be deleted
    }

}