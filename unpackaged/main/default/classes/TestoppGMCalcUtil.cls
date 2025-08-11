@isTest
public class TestoppGMCalcUtil {

    // Store record type ID for lender account
    private static Id lenderRecordTypeId;

    // Store Opportunity Account and Lender Account Ids for reuse
    private static Id oppAccountId;
    private static Id lenderAccountId;

    // Store all test opportunities
    private static List<Opportunity> allTestOpps;

    // Common test data setup for all test methods
    @TestSetup
    static void setupTestData() {
        // Get RecordTypeId for 'Lender Acct'
        lenderRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Lender Acct').getRecordTypeId();

        // Create and insert a Lender Account
        Account lenderAccount = new Account(
            Name = 'Test Lender Account',
            Type = 'Lender - MCA',
            RecordTypeId = lenderRecordTypeId
        );
        insert lenderAccount;
        lenderAccountId = lenderAccount.Id;

        // Create and insert a generic Account for Opportunity
        Account oppAccount = TestLibrary.createTestAccount();
        oppAccountId = oppAccount.Id;

        // Prepare list of Opportunities with varying conditions
        allTestOpps = new List<Opportunity>();

        // Opp 1: Without Lender_Account__c and Flag = false (initial setup for error test)
        allTestOpps.add(new Opportunity(
            Name = 'Test Opp 2 - No Lender Account',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            FlagToClickCalculateActuals__c = false,
            AccountId = oppAccount.Id
        ));

        // Opp 2: With Lender_Account__c and Flag = true (valid scenario for calculation)
        allTestOpps.add(new Opportunity(
            Name = 'Test Opp 3 - Valid for Calculation',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            FlagToClickCalculateActuals__c = true,
            Lender_Account__c = lenderAccount.Id,
            AccountId = oppAccount.Id
        ));

        // Opp 3: Another valid opportunity for calculation
        allTestOpps.add(new Opportunity(
            Name = 'Test Opp 4 - Valid for Calculation',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            FlagToClickCalculateActuals__c = true,
            Lender_Account__c = lenderAccount.Id,
            AccountId = oppAccount.Id
        ));

        // Insert all test opportunities
        insert allTestOpps;
    }

    // Test case: Ensure DML fails when Flag is set but Lender_Account__c is missing
    @isTest
    static void testNoLenderError() {
        // Get Opportunity without lender
        Opportunity oppWithoutLender = [
            SELECT Id, StageName, FlagToClickCalculateActuals__c
            FROM Opportunity
            WHERE Lender_Account__c = NULL
            LIMIT 1
        ];

        // Simulate update triggering flag and stage change
        oppWithoutLender.StageName = 'Qualification';
        oppWithoutLender.FlagToClickCalculateActuals__c = true;

        Test.startTest();
        try {
            update oppWithoutLender;
            System.assert(false, 'Expected error not thrown');
        } catch (DmlException e) {
            // Validate error message contains required field reference
            System.assert(e.getMessage().contains('Lender_Account__c'));
        }
        Test.stopTest();
    }

    // Test case: Ensure valid Opportunity updates without error
    @isTest
    static void testValidUpdate() {
        // Get one valid Opportunity for update
        Opportunity validOpp = [
            SELECT Id, StageName
            FROM Opportunity
            WHERE FlagToClickCalculateActuals__c = true
            AND Lender_Account__c != NULL
            LIMIT 1
        ];

        // Change StageName to simulate progression
        validOpp.StageName = 'Proposal';

        Test.startTest();
        update validOpp;
        Test.stopTest();

        // Verify update succeeded
        Opportunity updatedOpp = [SELECT StageName FROM Opportunity WHERE Id = :validOpp.Id];
        System.assertEquals('Proposal', updatedOpp.StageName);
    }

    // Test case: Directly call utility class methods with updated Opportunity
    @isTest
    static void Test() {
        // Static method invocation: test getJavaPVa formula logic
        oppGMCalcUtil.getJavaPVa(1.5, 2.5, 3);

        // Prepare opportunity with all calculation fields populated
        Opportunity opp = [
            SELECT Id, Num_Discounted_Pmts_For_Actual__c, Actual_Monthly_Payment__c, Actual_Term__c,
                   Calc_Net_Proceeds_For_Actual__c, Doc_Fee_Collected__c, Advanced_Payments_For_Actual__c,
                   Lender_Account__c
            FROM Opportunity
            WHERE Lender_Account__c != NULL
            AND FlagToClickCalculateActuals__c = true
            LIMIT 1
        ];

        // Set fields required by constructor logic
        opp.Num_Discounted_Pmts_For_Actual__c = 1.5;
        opp.Actual_Monthly_Payment__c = 2.5;
        opp.Actual_Term__c = 3.5;
        opp.Calc_Net_Proceeds_For_Actual__c = 1.5;
        opp.Doc_Fee_Collected__c = 2.5;
        opp.Advanced_Payments_For_Actual__c = 3.5;
        opp.Discount_PV_Overwrite__c = false;

        update opp;

        // Instantiate oppGMCalcUtil with prepared opportunity
        Test.startTest();
        oppGMCalcUtil oppGM = new oppGMCalcUtil(new List<Opportunity>{opp});
        Test.stopTest();
    }
}