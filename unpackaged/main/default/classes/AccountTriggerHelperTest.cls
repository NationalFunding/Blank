/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────
* TITLE: AccountTriggerHelperTest
* DESCRIPTION:This a test class for AccountTrigger
* @author         Amrit
* @version        1.0
* @created        22/01/2025
* @mofidied       
* ────────────────────────────────────────────────────────────────────────────────────────────────   */
@isTest
public class AccountTriggerHelperTest {
    @testSetup
    static void setupTestData() {
        // Create test data required for your tests
        Group testGroup = new Group(Name = 'Test Group', Type = 'Regular');
        insert testGroup;

        GroupMember testGroupMember = new GroupMember(
            GroupId = testGroup.Id, 
            UserOrGroupId = UserInfo.getUserId()
        );
        insert testGroupMember;
    }

    @isTest
    static void testBeforeInsert() {
        // Create a list of test accounts to insert
        Account testAccount = new Account(
            Name = 'Test Account LLC',
            Legal_Name__c = 'Test Legal Name LLC',
            Fed_Tax_ID__c = '12-3456789',
            Phone = '(123) 456-7890'
        );
        Test.startTest();
        insert testAccount;
        Test.stopTest();
        // Fetch the inserted account
        Account insertedAccount = [SELECT Name, Fed_Tax_ID__c, Fed_Tax_ID_Hashed__c, Legal_Name_Normal__c 
                                   FROM Account WHERE Id = :testAccount.Id];

        // Assertions
        System.assertEquals('123456789', insertedAccount.Fed_Tax_ID__c, 'Federal Tax ID should be normalized.');
        Assert.isNotNull(insertedAccount.Fed_Tax_ID_Hashed__c, 'Hashed Federal Tax ID should be generated.');
        System.assertEquals('TEST LEGAL NAME', insertedAccount.Legal_Name_Normal__c, 'Legal name normalization failed.');
    }

    @isTest
    static void testBeforeUpdate() {
        // Insert an initial account
        Account testAccount = new Account(
            Name = 'Test Account',
            Legal_Name__c = 'Initial Legal Name Ltd',
            Fed_Tax_ID__c = '987-654321'
        );
        insert testAccount;

        // Update the account
        testAccount.Legal_Name__c = 'Updated Legal Name LLC';
        testAccount.Fed_Tax_ID__c = '111-222333';

        Test.startTest();
        update testAccount;
        Test.stopTest();

        // Fetch the updated account
        Account updatedAccount = [SELECT Legal_Name_Normal__c, Fed_Tax_ID__c, Fed_Tax_ID_Hashed__c 
                                  FROM Account WHERE Id = :testAccount.Id];

        // Assertions
        System.assertEquals('111222333', updatedAccount.Fed_Tax_ID__c, 'Federal Tax ID should be normalized after update.');
        Assert.isNotNull(updatedAccount.Fed_Tax_ID_Hashed__c, 'Hashed Federal Tax ID should be updated.');
        System.assertEquals('UPDATED LEGAL NAME', updatedAccount.Legal_Name_Normal__c, 'Legal name normalization failed after update.');
    }

    @isTest
    static void testValidationErrorForInvalidTaxId() {
        // Create an account with an invalid tax ID
        Account testAccount = new Account(
            Name = 'Test Account Invalid Tax',
            Fed_Tax_ID__c = '12345',
            Legal_Name__c = 'Invalid Tax Legal Name LLC'
        );

        Test.startTest();
        try {
            insert testAccount;
            System.assert(false, 'Expected an exception due to invalid tax ID.');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('The entered Federal Tax Id number is incorrect'), 
                'Validation error message for tax ID should be thrown.');
        }
        Test.stopTest();
    }
    //Test GenerateVendorMethod
    @isTest
    static void testGenerateVendor() {
        // Create a new Account
        Account newAccount = TestLibrary.createAccountOfRecordType('vendorAccount','Vendor Acct');
        Test.startTest();
     	Test.stopTest();
        Account processedAccount = [SELECT vendor_number__c FROM Account WHERE Id = :newAccount.Id];
        System.assertEquals('1', processedAccount.vendor_number__c, 'The new Vendor Number should be equal to 1');
    }
}