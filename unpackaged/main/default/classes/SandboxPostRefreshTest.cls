/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────
* TITLE: SandboxPostRefreshTest 
* DESCRIPTION:This class is test class of SandboxPostRefresh 
* @author         Supriya Gore
* @version        1.0
* @created        18/03/2025
* @mofidied       
* ────────────────────────────────────────────────────────────────────────────────────────────────   */

@isTest
private class SandboxPostRefreshTest {

    @isTest
    static void testRunApexClass() {
        Test.startTest();
        
        SandboxPostRefresh sandboxClass = new SandboxPostRefresh();
        
        sandboxClass.runApexClass(null);  // Passing null for context (or you could simulate SandboxContext if needed)

        Test.stopTest();

        // Verify that the metadata records exist
        List<Data_Masking_Configuration__mdt> metadataRecords = [SELECT ObjectName__c, FieldName__c, MaskType__c FROM Data_Masking_Configuration__mdt];
        for(Data_Masking_Configuration__mdt cm : metadataRecords){
            if(cm.FieldName__c == 'Email'){
                System.assertEquals('invalid', cm.MaskType__c, 'The masktype for email should be invalid');
            }
        }

    }
    
}