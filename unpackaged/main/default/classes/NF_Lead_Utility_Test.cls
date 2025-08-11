@isTest
public class NF_Lead_Utility_Test {  
     @isTest
    static void testNormalizedPhone() {
        // Create test leads
        List<Lead> leads = new List<Lead>{
            new Lead(FirstName = 'John', LastName = 'Doe', Company = 'TestCo', Phone = '(123) 456-7890'),
            new Lead(FirstName = 'Jane', LastName = 'Smith', Company = 'TestCo', Phone = '9876543210'),
            new Lead(FirstName = 'Bob', LastName = 'Brown', Company = 'TestCo', Phone = null)
        };
        insert leads;

        // Invoke method
        NF_Lead_Utility util = new NF_Lead_Utility();
        util.normalizedPhone(leads);

        // Verify results
        for (Lead l : leads) {
            if (l.Phone != null) {
                String cleanedPhone = l.Phone.replaceAll('[^0-9]', '');
                System.assertEquals(Decimal.valueOf(cleanedPhone), l.Phone_Trim__c);
            } else {
                System.assertEquals(null, l.Phone_Trim__c);
            }
        }
    }

    @isTest
    static void testNormalizedMPhone() {
        // Create test leads
        List<Lead> leads = new List<Lead>{
            new Lead(FirstName = 'John', LastName = 'Doe', Company = 'TestCo', MobilePhone = '(123) 456-7890'),
            new Lead(FirstName = 'Jane', LastName = 'Smith', Company = 'TestCo', MobilePhone = '9876543210'),
            new Lead(FirstName = 'Bob', LastName = 'Brown', Company = 'TestCo', MobilePhone = null)
        };
        insert leads;

        // Invoke method
        NF_Lead_Utility util = new NF_Lead_Utility();
        util.normalizedMPhone(leads);

        // Verify results
        for (Lead l : leads) {
            if (l.MobilePhone != null) {
                String cleanedPhone = l.MobilePhone.replaceAll('[^0-9]', '');
                System.assertEquals(Decimal.valueOf(cleanedPhone), l.MobilePhone_Trim__c);
            } else {
                System.assertEquals(null, l.MobilePhone_Trim__c);
            }
        }
    }

    @isTest
    static void testNormalizedHPhone() {
        // Create test leads
        List<Lead> leads = new List<Lead>{
            new Lead(FirstName = 'John', LastName = 'Doe', Company = 'TestCo', Home_Phone__c = '(123) 456-7890'),
            new Lead(FirstName = 'Jane', LastName = 'Smith', Company = 'TestCo', Home_Phone__c = '9876543210'),
            new Lead(FirstName = 'Bob', LastName = 'Brown', Company = 'TestCo', Home_Phone__c = null)
        };
        insert leads;

        // Invoke method
        NF_Lead_Utility util = new NF_Lead_Utility();
        util.normalizedHPhone(leads);

        // Verify results
        for (Lead l : leads) {
            if (l.Home_Phone__c != null) {
                String cleanedPhone = l.Home_Phone__c.replaceAll('[^0-9]', '');
                System.assertEquals(Decimal.valueOf(cleanedPhone), l.Home_Phone_Trim__c);
            } else {
                System.assertEquals(null, l.Home_Phone_Trim__c);
            }
        }
    }

    @isTest
    static void testNormalizedPhoneContact() {
        // Create test contacts
        List<Contact> contacts = new List<Contact>{
            new Contact(FirstName = 'John', LastName = 'Doe', Phone = '(123) 456-7890'),
            new Contact(FirstName = 'Jane', LastName = 'Smith', Phone = '9876543210'),
            new Contact(FirstName = 'Bob', LastName = 'Brown', Phone = null)
        };
        insert contacts;

        // Invoke method
        NF_Lead_Utility util = new NF_Lead_Utility();
        util.normalizedPhoneContact(contacts);

        // Verify results
        for (Contact c : contacts) {
            if (c.Phone != null) {
                String cleanedPhone = c.Phone.replaceAll('[^0-9]', '');
                System.assertEquals(Decimal.valueOf(cleanedPhone), c.Phone_Trim__c);
            } else {
                System.assertEquals(null, c.Phone_Trim__c);
            }
        }
    }

    @isTest
    static void testNormalizedPhoneAccount() {
        // Create test accounts
        List<Account> accounts = new List<Account>{
            new Account(Name = 'Account1', Phone = '(123) 456-7890'),
            new Account(Name = 'Account2', Phone = '9876543210'),
            new Account(Name = 'Account3', Phone = null)
        };
        insert accounts;

        // Invoke method
        NF_Lead_Utility util = new NF_Lead_Utility();
        util.normalizedPhoneAccount(accounts);

        // Verify results
        for (Account a : accounts) {
            if (a.Phone != null) {
                String cleanedPhone = a.Phone.replaceAll('[^0-9]', '');
                System.assertEquals(Decimal.valueOf(cleanedPhone), a.Phone_Trim__c);
            } else {
                System.assertEquals(null, a.Phone_Trim__c);
            }
        }
    }

    @isTest
    static void testNormalizePhoneFields() {
        // Create test leads
        List<Lead> leads = new List<Lead>{
            new Lead(FirstName = 'John', LastName = 'Doe', Company = 'TestCo', Phone = '(123) 456-7890', MobilePhone = '9876543210'),
            new Lead(FirstName = 'Jane', LastName = 'Smith', Company = 'TestCo', Phone = '(123) 478-7890', MobilePhone = '9876543210')
        };
        insert leads;

        // Define phone field mapping
        Map<String, String> phoneFields = new Map<String, String>{
            'Phone' => 'Phone_Trim__c',
            'MobilePhone' => 'MobilePhone_Trim__c'
        };

        // Invoke method
        NF_Lead_Utility.normalizePhoneFields((List<SObject>)leads, phoneFields);

        // Verify results
        for (Lead l : leads) {
            if (l.Phone != null) {
                String cleanedPhone = l.Phone.replaceAll('[^0-9]', '');
                System.assertEquals(Decimal.valueOf(cleanedPhone), l.Phone_Trim__c);
            } else {
                System.assertEquals(null, l.Phone_Trim__c);
            }

            if (l.MobilePhone != null) {
                String cleanedMobile = l.MobilePhone.replaceAll('[^0-9]', '');
                System.assertEquals(Decimal.valueOf(cleanedMobile), l.MobilePhone_Trim__c);
            } else {
                System.assertEquals(null, l.MobilePhone_Trim__c);
            }
        }
    }
    @isTest
    static void testNormalizedPhone3Account() {
        // Create test accounts
        List<Account> accounts = new List<Account>{
            new Account(Name = 'Account1', Phone_3__c = '(123) 456-7890'),  // Valid phone number with formatting
            new Account(Name = 'Account2', Phone_3__c = '9876543210'),      // Valid phone number without formatting
            new Account(Name = 'Account3', Phone_3__c = null),             // Null phone number
            new Account(Name = 'Account4', Phone_3__c = 'ABC123XYZ789')    // Invalid characters in the phone number
        };
        insert accounts;
    
        // Invoke method
        NF_Lead_Utility util = new NF_Lead_Utility();
        util.normalizedPhone3Account(accounts);
    
        // Reload the accounts to verify the updates
        accounts = [SELECT Id, Phone_3__c, Phone_3_Trim__c FROM Account];
    
        // Verify results
        for (Account acc : accounts) {
            if (String.isNotBlank(acc.Phone_3__c)) {
                String cleanedPhone = acc.Phone_3__c.replaceAll('[^0-9]', '');
                if (!String.isEmpty(cleanedPhone)) {
                    System.assertEquals(Decimal.valueOf(cleanedPhone), acc.Phone_3_Trim__c, 'Phone_3_Trim__c should match the cleaned phone number');
                } else {
                    System.assertEquals(null, acc.Phone_3_Trim__c, 'Phone_3_Trim__c should be null for invalid numbers');
                }
            } else {
                System.assertEquals(null, acc.Phone_3_Trim__c, 'Phone_3_Trim__c should be null for blank Phone_3__c');
            }
        }
	}
    @isTest
	static void testNormalizedPhone2Account() {
        // Create test accounts
        List<Account> accounts = new List<Account>{
            new Account(Name = 'Account1', Phone_2__c = '(123) 456-7890'),  // Valid phone number with formatting
            new Account(Name = 'Account2', Phone_2__c = '9876543210'),      // Valid phone number without formatting
            new Account(Name = 'Account3', Phone_2__c = null),             // Null phone number
            new Account(Name = 'Account4', Phone_2__c = 'ABC123XYZ789')    // Invalid characters in the phone number
        };
        insert accounts;
    
        // Invoke method
        NF_Lead_Utility util = new NF_Lead_Utility();
        util.normalizedPhone2Account(accounts);
    
        // Reload the accounts to verify the updates
        accounts = [SELECT Id, Phone_2__c, Phone_2_Trim__c FROM Account];
    
        // Verify results
        for (Account acc : accounts) {
            if (String.isNotBlank(acc.Phone_2__c)) {
                String cleanedPhone = acc.Phone_2__c.replaceAll('[^0-9]', '');
                if (!String.isEmpty(cleanedPhone)) {
                    System.assertEquals(Decimal.valueOf(cleanedPhone), acc.Phone_2_Trim__c, 'Phone_2_Trim__c should match the cleaned phone number');
                } else {
                    System.assertEquals(null, acc.Phone_2_Trim__c, 'Phone_2_Trim__c should be null for invalid numbers');
                }
            } else {
                System.assertEquals(null, acc.Phone_2_Trim__c, 'Phone_2_Trim__c should be null for blank Phone_2__c');
            }
        }
    }
    @isTest
    static void testNormalizedPhoneMContact() {
        // Create test Contact records
        List<Contact> contacts = new List<Contact>{
            new Contact(LastName = 'Contact1', MobilePhone = '(123) 456-7890'),  // Valid phone number with formatting
            new Contact(LastName = 'Contact2', MobilePhone = '9876543210'),      // Valid phone number without formatting
            new Contact(LastName = 'Contact3', MobilePhone = null),             // Null phone number
            new Contact(LastName = 'Contact4', MobilePhone = 'ABC123XYZ789')    // Invalid characters in the phone number
        };
        insert contacts;
    
        // Reload contacts to ensure proper IDs
        contacts = [SELECT Id, MobilePhone, MobilePhone_Trim__c FROM Contact];
    
        // Invoke the method
        NF_Lead_Utility util = new NF_Lead_Utility();
        util.normalizedPhoneMContact(contacts);
    
        // Reload the contacts to verify the updates
        contacts = [SELECT Id, MobilePhone, MobilePhone_Trim__c FROM Contact];
    
        // Verify results
        for (Contact con : contacts) {
            if (String.isNotBlank(con.MobilePhone)) {
                String cleanedPhone = con.MobilePhone.replaceAll('[^0-9]', ''); // Remove non-numeric characters
                if (!String.isEmpty(cleanedPhone)) {
                    System.assertEquals(
                        Decimal.valueOf(cleanedPhone), 
                        con.MobilePhone_Trim__c, 
                        'MobilePhone_Trim__c should match the cleaned phone number'
                    );
                } else {
                    System.assertEquals(null, con.MobilePhone_Trim__c, 'MobilePhone_Trim__c should be null for invalid numbers');
                }
            } else {
                System.assertEquals(null, con.MobilePhone_Trim__c, 'MobilePhone_Trim__c should be null for blank MobilePhone');
            }
        }
    }
	@isTest
    static void testNormalizedPhoneOContact() {
        // Create test Contact records
        List<Contact> contacts = new List<Contact>{
            new Contact(LastName = 'Contact1', OtherPhone = '(123) 456-7890'),  // Valid phone number with formatting
            new Contact(LastName = 'Contact2', OtherPhone = '9876543210'),      // Valid phone number without formatting
            new Contact(LastName = 'Contact3', OtherPhone = null),             // Null phone number
            new Contact(LastName = 'Contact4', OtherPhone = 'ABC123XYZ789')    // Invalid characters in the phone number
        };
        insert contacts;
    
        // Reload contacts to ensure proper IDs
        contacts = [SELECT Id, OtherPhone, OtherPhone_Trim__c FROM Contact];
    
        // Invoke the method
        NF_Lead_Utility util = new NF_Lead_Utility();
        util.normalizedPhoneOContact(contacts);
    
        // Reload the contacts to verify the updates
        contacts = [SELECT Id, OtherPhone, OtherPhone_Trim__c FROM Contact];
    
        // Verify results
        for (Contact con : contacts) {
            if (String.isNotBlank(con.OtherPhone)) {
                String cleanedPhone = con.OtherPhone.replaceAll('[^0-9]', ''); // Remove non-numeric characters
                if (!String.isEmpty(cleanedPhone)) {
                    System.assertEquals(
                        Decimal.valueOf(cleanedPhone), 
                        con.OtherPhone_Trim__c, 
                        'OtherPhone_Trim__c should match the cleaned phone number'
                    );
                } else {
                    System.assertEquals(null, con.OtherPhone_Trim__c, 'OtherPhone_Trim__c should be null for invalid numbers');
                }
            } else {
                System.assertEquals(null, con.OtherPhone_Trim__c, 'OtherPhone_Trim__c should be null for blank OtherPhone');
            }
        }
    }
    @isTest
    static void testNormalizedPhoneHContact() {
        // Create test Contact records
        List<Contact> contacts = new List<Contact>{
            new Contact(LastName = 'Contact1', HomePhone = '(123) 456-7890'),  // Valid phone number with formatting
            new Contact(LastName = 'Contact2', HomePhone = '9876543210'),      // Valid phone number without formatting
            new Contact(LastName = 'Contact3', HomePhone = null),             // Null phone number
            new Contact(LastName = 'Contact4', HomePhone = 'ABC123XYZ789'),   // Invalid characters in the phone number
            new Contact(LastName = 'Contact5', HomePhone = '')                // Empty phone number
        };
        insert contacts;
    
        // Reload contacts to ensure proper IDs
        contacts = [SELECT Id, HomePhone, HomePhone_Trim__c FROM Contact];
    
        // Invoke the method
        NF_Lead_Utility util = new NF_Lead_Utility();
        util.normalizedPhoneHContact(contacts);
    
        // Reload the contacts to verify the updates
        contacts = [SELECT Id, HomePhone, HomePhone_Trim__c FROM Contact];
    
        // Verify results
        for (Contact con : contacts) {
            if (String.isNotBlank(con.HomePhone)) {
                String cleanedPhone = con.HomePhone.replaceAll('[^0-9]', ''); // Remove non-numeric characters
                if (!String.isEmpty(cleanedPhone)) {
                    System.assertEquals(
                        Decimal.valueOf(cleanedPhone), 
                        con.HomePhone_Trim__c, 
                        'HomePhone_Trim__c should match the cleaned phone number'
                    );
                } else {
                    System.assertEquals(null, con.HomePhone_Trim__c, 'HomePhone_Trim__c should be null for invalid numbers');
                }
            } else {
                System.assertEquals(null, con.HomePhone_Trim__c, 'HomePhone_Trim__c should be null for blank or null HomePhone');
            }
        }
    }
}