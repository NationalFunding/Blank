@isTest
public class GetAccountContactsTest {

    @isTest
    static void getContactListTest(){
        
        // Create Account
        Account a = new Account(Name = 'CompanyName');
        insert a;
        
        // Create Test Contacts
        List<Contact> testContacts = new List<Contact>{
            new Contact(FirstName = 'Name1Franky', LastName = 'Name1', Title = 'Title1', Phone='123456789', AccountId = a.id, MobilePhone = '9999999999'),
            new Contact(FirstName = 'Name2', LastName = 'Name2Victories', Title = 'Title2', Phone='123456789', AccountId = a.id, MobilePhone = '9999999996'),
            new Contact(FirstName = 'Name3', LastName = 'Name3', Title = 'Title3Commander', Phone='123456789', AccountId = a.id, MobilePhone = '9999999997'),
            new Contact(FirstName = 'Name4', LastName = 'Name4', Title = 'Title4', Phone='1234008811', AccountId = a.id, MobilePhone = '9999999998')
        };
        
        // Insert Test Contacts
        insert testContacts;
        
        TwilioSF__Opt_In_Keyword__c keyword = new TwilioSF__Opt_In_Keyword__c(Name = 'Start');
        insert keyword;

        DateTime todaysDate = Datetime.now();
        TwilioSF__Opt_In__c optIn = new TwilioSF__Opt_In__c(TwilioSF__Opt_In_Keyword__c = keyword.Id, TwilioSF__Phone_Number__c= '9999999999', TwilioSF__Active__c = true, TwilioSF__Contact__c = testContacts[0].Id, TwilioSF__Opt_In_Date_Time__c = todaysDate, TwilioSF__Opt_In_Phone_Number_Unformatted__c = '9999999999'  );
        insert optIn;

        // Test Contacts Search
        list<Contact> Contacts = GetAccountContacts.getContactList(a.id);
        system.assertNotEquals(null, Contacts, 'Contacts Query Failed');
        
    }

    @isTest
    static void getContactListTestOpportunity(){
        
        // Create Account
        Account a = new Account(Name = 'CompanyName');
        insert a;

        Opportunity o = new Opportunity(AccountId = a.Id, CloseDate = Date.today(), StageName = 'New', Name = 'Test Opp');
        insert o;
        
        // Create Test Contacts
        List<Contact> testContacts = new List<Contact>{
            new Contact(FirstName = 'Name1Franky', LastName = 'Name1', Title = 'Title1', Phone='123456789', AccountId = a.id, MobilePhone = '9999999999'),
            new Contact(FirstName = 'Name2', LastName = 'Name2Victories', Title = 'Title2', Phone='123456789', AccountId = a.id, MobilePhone = '9999999996'),
            new Contact(FirstName = 'Name3', LastName = 'Name3', Title = 'Title3Commander', Phone='123456789', AccountId = a.id, MobilePhone = '9999999997'),
            new Contact(FirstName = 'Name4', LastName = 'Name4', Title = 'Title4', Phone='1234008811', AccountId = a.id, MobilePhone = '9999999998')
        };
        
        // Insert Test Contacts
        insert testContacts;
        
        TwilioSF__Opt_In_Keyword__c keyword = new TwilioSF__Opt_In_Keyword__c(Name = 'Start');
        insert keyword;

        DateTime todaysDate = Datetime.now();
        TwilioSF__Opt_In__c optIn = new TwilioSF__Opt_In__c(TwilioSF__Opt_In_Keyword__c = keyword.Id, TwilioSF__Phone_Number__c= '9999999999', TwilioSF__Active__c = true, TwilioSF__Contact__c = testContacts[0].Id, TwilioSF__Opt_In_Date_Time__c = todaysDate, TwilioSF__Opt_In_Phone_Number_Unformatted__c = '9999999999'  );
        insert optIn;

        // Test Contacts Search
        list<Contact> Contacts = GetAccountContacts.getContactList(o.AccountId);
        system.assertNotEquals(null, Contacts, 'Contacts Query Failed');
        
    }
    
    @isTest
    static void getContactInfoTest(){
        
        // Create Account
        Account a = new Account(Name = 'CompanyName');
        insert a;
        
        // Create Contact
        Contact c = new Contact(LastName = 'Ln1', SMS_Opt_In__c = True, SMS_Opt_Out__c = False, SMS_Requested__c = True, Last_Opt_In_Message_Sent__c = system.now(), SMS_Opt_In_Date_Time__c = system.now(), SMS_Requested_Date_Time__c = system.now());
        insert c;
        
        List<Contact> Contacts = GetAccountContacts.getContactInfo(c.Id);
        
        system.assertNotEquals(null, Contacts, 'GetContactInfo Test Validation Failed');
    }

    // @isTest
    // static void stressTestBulkRecords(){
    

    //     List<Account> listAccounts = new List<Account>();
    //     for(Integer i = 0; i < 60000; i++){
    //         Account a = new Account(Name = 'CompanyName' + i);
    //         listAccounts.add(a);
    //     }
    //     insert listAccounts;

    //     List<Contact> testContacts = new List<Contact>();
    //     for(Integer i = 0; i < 60000; i++){
    //         Contact con =  new Contact(FirstName = 'Name1Franky' + i, LastName = 'Name1' + i, Title = 'Title1' + i, Phone='123456789' + i, AccountId = listAccounts[i].id, MobilePhone = '999999999' + i);
    //         testContacts.add(con);
    //     }
    //     insert testContacts;
        
    //     TwilioSF__Opt_In_Keyword__c keyword = new TwilioSF__Opt_In_Keyword__c(Name = 'Start');
    //     insert keyword;

    //     List<TwilioSF__Opt_In__c> twilList = new List<TwilioSF__Opt_In__c>();
    //     DateTime todaysDate = Datetime.now();
    //     for(Integer i = 0; i < 60000; i++){
    //         TwilioSF__Opt_In__c optIn = new TwilioSF__Opt_In__c(TwilioSF__Opt_In_Keyword__c = keyword.Id, TwilioSF__Phone_Number__c= '999999999' + i, TwilioSF__Active__c = true, TwilioSF__Contact__c = testContacts[i].Id, TwilioSF__Opt_In_Date_Time__c = todaysDate, TwilioSF__Opt_In_Phone_Number_Unformatted__c = '999999999' + i );
    //         twilList.add(optIn);
    //     }
    //     insert twilList;

    //     // Test Contacts Search
    //     list<Contact> Contacts = GetAccountContacts.getContactList(listAccounts[0].id);
    //     system.debug('Contacts:: ' + Contacts);
    //     // system.assertNotEquals(null, Contacts, 'Contacts Query Failed');
        
    // }
    
}