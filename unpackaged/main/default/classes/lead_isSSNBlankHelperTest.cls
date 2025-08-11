@IsTest
public with sharing class lead_isSSNBlankHelperTest {

    @isTest
    public static void isSSNBlank(){
        Lead lead = new Lead();
        lead.Company = 'Test Company';
        lead.FirstName = 'First';
        lead.LastName = 'Test';
        lead.Phone = '123456789';
        lead.SSN_Encrypted__c = null;
        // lead.SSN_Is_Blank__c = true; //this is default value
        insert lead;
        
        lead = [ SELECT SSN_Encrypted__c, SSN_Is_Blank__c FROM Lead WHERE Id =: lead.Id ];
        System.assertEquals(true, lead.SSN_Is_Blank__c);
        
        lead.SSN_Encrypted__c = '123456789';
        update lead;
        
        lead = [ SELECT SSN_Encrypted__c, SSN_Is_Blank__c FROM Lead WHERE Id =: lead.Id ];
        System.assertEquals(false, lead.SSN_Is_Blank__c);

        Lead leadEncrypted = new Lead();
        leadEncrypted.Company = 'Test Company';
        leadEncrypted.FirstName = 'First';
        leadEncrypted.LastName = 'Test';
        leadEncrypted.Phone = '123456789';
        leadEncrypted.SSN_Encrypted__c = '123456789';
        // lead.SSN_Is_Blank__c = true; //this is default value
        insert leadEncrypted;
        System.assertEquals(false, leadEncrypted.SSN_Is_Blank__c);

    }
}