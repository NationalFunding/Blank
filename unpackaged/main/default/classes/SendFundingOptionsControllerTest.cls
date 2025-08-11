//Created by Olivia Porter on 8/17/18

@isTest
private class SendFundingOptionsControllerTest{

    public class ContactWrapper {
        public boolean IsSelected { get; set; }
        public Contact Contact { get; set; }
        public boolean HasEmail { get; set; }
        public String cType {get; set;}

        public ContactWrapper(Contact c, boolean hasEmail){
            Contact = c;
            IsSelected = false;
            this.HasEmail = hasEmail;
        }
    }

    @isTest
    static void Test_SendFundingOptions(){
        createTestData();
        Account acc = new Account(Name = 'unit test account', Phone = '+1 300 2011231', Type = 'Customer');
        insert acc;

        Contact c = new Contact(LastName = 'harry1', Email='test@nationalfunding.com', AccountId = acc.Id);
        Contact c1 = new Contact(LastName = 'harry', Email='test2@nationalfunding.com', AccountId = acc.Id);
        insert c;
        insert c1;

        Opportunity opp = new Opportunity(Name = 'TestOpp', Account = acc, AccountId = acc.Id, StageName = 'Approved - MCA', CloseDate = Date.today());
        insert opp;

        Test.startTest();
            PageReference pageRef = Page.SendFundingOptions;
            Test.setCurrentPage(pageRef);

            HttpMockGenerator mock = new HttpMockGenerator('[{"Id":"' + c.Id+ '","Token":"bxofefoHG9wLuWDiynV4"}]', 200);
            Test.setMock(HttpCalloutMock.class, mock);

            SendFundingOptionsController ext = new SendFundingOptionsController(new Apexpages.StandardController(opp));
            //testing without selecting any contact
            ext.SendEmail();
            boolean foundDesiredMsg = false;
            for(ApexPages.Message msg :  ApexPages.getMessages()) {
                if(msg.getSummary() == 'Please select at least 1 contact'){
                    foundDesiredMsg = true;
                }
            }
            System.assertEquals(true, foundDesiredMsg, 'At lease 1 Contact validation did not worked');

            ext.contactList[0].IsSelected = True;
            system.debug('------------>' + ext.contactList[0]);
            ext.contactList[1].IsSelected = False;
            //testing without selecting any bank
            ext.SendEmail();
            foundDesiredMsg = false;
        Test.stopTest();
        for(ApexPages.Message msg :  ApexPages.getMessages()) {
            if(msg.getSummary() == 'Please select at least 1 bank'){
                foundDesiredMsg = true;
            }
        }
        System.assertEquals(false, foundDesiredMsg, 'At lease 1 Bank validation did not worked');
    }

    @isTest
    static void Test_SendFundingOptions2(){
        createTestData();

        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com.nf',EmailEncodingKey='UTF-8', 
                        LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US', ProfileId = p.Id, 
                        TimeZoneSidKey='America/Los_Angeles', UserName='standardus@testorg.com.nf', Available_Brands__c = 'Quick Bridge;National Funding');
        insert u;

        Account acc = new Account(Name = 'unit test account', Phone = '+1 300 2011231', Type = 'Customer', NF_Renewal_Rep__c = u.Id);
        insert acc;

        Contact c = new Contact(LastName = 'harry1', Email='bkravitz@nationalfunding.com', AccountId = acc.Id);
        Contact c1 = new Contact(LastName = 'harry', Email='oporter@nationalfunding.com', AccountId = acc.Id);
        insert c;
        insert c1;

        Opportunity opp = new Opportunity(Name = 'TestOpp', Account = acc, AccountId = acc.Id, StageName = 'Approved - MCA', CloseDate = Date.today());
        insert opp;

        Test.startTest();
            PageReference pageRef = Page.SendFundingOptions;
            Test.setCurrentPage(pageRef);

            HttpMockGenerator mock = new HttpMockGenerator('[{"Id":"' + c.Id+ '","Token":"bxofefoHG9wLuWDiynV4"}]', 200);
            Test.setMock(HttpCalloutMock.class, mock);

            SendFundingOptionsController ext = new SendFundingOptionsController(new Apexpages.StandardController(opp));
            List<SendFundingOptionsController.ContactWrapper> contacts = ext.contactList;

            //testing without selecting any contact
            ext.SendEmail();
            boolean foundDesiredMsg = false;
            for(ApexPages.Message msg :  ApexPages.getMessages()) {
                if(msg.getSummary() == 'Please select at least 1 contact'){
                    foundDesiredMsg = true;
                }
            }
            System.assertEquals(true, foundDesiredMsg, 'At lease 1 Contact validation did not worked');

            ext.contactList[0].IsSelected = True;
            system.debug('------------>' + ext.contactList[0]);
            ext.contactList[1].IsSelected = False;
            //testing without selecting any bank
            ext.SendEmail();
        Test.stopTest();
        foundDesiredMsg = false;
        for(ApexPages.Message msg :  ApexPages.getMessages()) {
            if(msg.getSummary() == 'Please select at least 1 bank'){
                foundDesiredMsg = true;
            }
        }
        System.assertEquals(false, foundDesiredMsg, 'At lease 1 Bank validation did not worked');
    }

    @isTest
    static void createTestData(){
        Account acc = new Account(Name = 'unit test account', Phone = '+1 300 2011231', Type = 'Customer');
        insert acc;

        List<Contact> contacts = new List<Contact>();
        for(integer i=0; i<20; i++){
            contacts.add(new Contact(AccountId = acc.Id, LastName = 'unit test contact'+i, Email = 'test'+i+'@gmail.com'));
        }
        insert contacts;
        Yodlee_Banks__c ybank = new Yodlee_Banks__c(Name = 'Test Bank Name');
        insert ybank;
        List<Bank_Data__c> bankAccounts = new List<Bank_Data__c>();
        integer bankAccountNo = 123456789;
        for(integer i=0; i<20; i++){
            bankAccountNo++;
            system.debug('bank account number'+i+': '+bankAccountNo);
            bankAccounts.add(new Bank_Data__c(Yodlee_Banks__c = ybank.id, Account__c = acc.Id, Bank_Name__c = 'unit test bank '+i, Account_Number__c = bankAccountNo+'', Routing_Number__c = '1231231'+i));
        }
        insert bankAccounts;
    }

    @isTest
    static void createTestData2(){
        Account acc = new Account(Name = 'unit test account', Phone = '+1 300 2011231', Type = 'Customer');
        insert acc;

        List<Contact> contacts = new List<Contact>();
        for(integer i=0; i<20; i++){
            contacts.add(new Contact(AccountId = acc.Id, LastName = 'unit test contact'+i, Email = 'test'+i+'@gmail.com'));
        }
        insert contacts;

        Yodlee_Banks__c ybank = new Yodlee_Banks__c(Name = 'test bank name');
        insert ybank;

        List<Bank_Data__c> bankAccounts = new List<Bank_Data__c>();
        integer bankAccountNo = 123456789;

        for(integer i=0; i<20; i++){
            bankAccountNo++;
            system.debug('bank account number'+i+': '+bankAccountNo);
            bankAccounts.add(new Bank_Data__c(Yodlee_Banks__c = ybank.id, Account__c = acc.Id, Bank_Name__c = 'unit test bank '+i, Account_Number__c = bankAccountNo+'', Routing_Number__c = '1231231'+i));
        }
        insert bankAccounts;
    }

    @isTest
    static void createTestData3() {
        Id accountId = '001S000000nfn6YIAQ';
        List<ContactWrapper> contactList;
        Map<Id, Contact> contactsWithoutEmail;
        contactList = new List<ContactWrapper>();
        contactsWithoutEmail = new Map<Id, Contact>();
        for(Contact c : [Select Id, Name, Email, AccountId From Contact Where AccountId =: accountId]){
            contactList.Add(new ContactWrapper(c, (c.Email != null)));
        }
    }
}