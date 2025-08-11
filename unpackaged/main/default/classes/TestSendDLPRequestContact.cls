@isTest
public class TestSendDLPRequestContact {

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
    static void Test_SendDLPRequestExtension(){
        createTestData();

        Account acc = new Account(Name = 'unit test account', Phone = '+1 300 2011231', Type = 'Customer');
        insert acc;

        Contact c = new Contact(LastName = 'harry1', Email='bkravitz@nationalfunding.com', AccountId = acc.Id);
        Contact c1 = new Contact(LastName = 'harry', Email='oporter@nationalfunding.com', AccountId = acc.Id);
        insert c;
        insert c1;
        
        Test.startTest();
            PageReference pageRef = Page.SendDLPContact;
            Test.setCurrentPage(pageRef);
            
            HttpMockGenerator mock = new HttpMockGenerator('[{"Id":"' + c.Id+ '","Token":"bxofefoHG9wLuWDiynV4"}]', 200);
            Test.setMock(HttpCalloutMock.class, mock);
            
            SendDLPRequestContact ext = new SendDLPRequestContact(new Apexpages.StandardController(acc));
            List<SendDLPRequestContact.ContactWrapper> contacts = ext.Contacts;
            
            //testing without selecting any contact
            ext.SendEmail();
            SendDLPRequestContact.getItems('DLP Drip Activated');
            SendDLPRequestContact.getItems('DLP Drip Deactivated');
            SendDLPRequestContact.getItems('test');
        
            boolean foundDesiredMsg = false;
            for(ApexPages.Message msg :  ApexPages.getMessages()) {
                if(msg.getSummary() == 'Please select atleast 1 contact'){
                    foundDesiredMsg = true;
                }
            }
            System.assertEquals(true, foundDesiredMsg, 'Atlease 1 Contact validation did not worked');
            
            ext.Contacts[0].IsSelected = True;
            system.debug('------------>' + ext.Contacts[0]);
            ext.Contacts[1].IsSelected = False;
            //testing without selecting any bank
            ext.SendEmail();
            foundDesiredMsg = false;
        Test.stopTest();
        for(ApexPages.Message msg :  ApexPages.getMessages()) {
            if(msg.getSummary() == 'Please select atleast 1 bank'){
                foundDesiredMsg = true;
            }
        }
        System.assertEquals(false, foundDesiredMsg, 'Atlease 1 Bank validation did not worked');
    }

    @isTest
    static void Test_SendDLPRequestExtension2(){
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
        
        Test.startTest();
            PageReference pageRef = Page.SendDLPContact;
            Test.setCurrentPage(pageRef);

            HttpMockGenerator mock = new HttpMockGenerator('[{"Id":"' + c.Id+ '","Token":"bxofefoHG9wLuWDiynV4"}]', 200);
            Test.setMock(HttpCalloutMock.class, mock);
            
            SendDLPRequestContact ext = new SendDLPRequestContact(new Apexpages.StandardController(acc));
            List<SendDLPRequestContact.ContactWrapper> contacts = ext.Contacts;
            
            //testing without selecting any contact
            ext.SendEmail();
            SendDLPRequestContact.getItems('DLP Drip Activated');
            SendDLPRequestContact.getItems('DLP Drip Deactivated');
            SendDLPRequestContact.getItems('test');
            
            boolean foundDesiredMsg = false;
            for(ApexPages.Message msg :  ApexPages.getMessages()) {
                if(msg.getSummary() == 'Please select atleast 1 contact'){
                    foundDesiredMsg = true;
                }
            }
            System.assertEquals(true, foundDesiredMsg, 'Atlease 1 Contact validation did not worked');
            
            ext.Contacts[0].IsSelected = True;
            system.debug('------------>' + ext.Contacts[0]);
            ext.Contacts[1].IsSelected = False;
            //testing without selecting any bank
            ext.SendEmail();
        Test.stopTest();
        foundDesiredMsg = false;
        for(ApexPages.Message msg :  ApexPages.getMessages()) {
            if(msg.getSummary() == 'Please select atleast 1 bank'){
                foundDesiredMsg = true;
            }
        }
        System.assertEquals(false, foundDesiredMsg, 'Atlease 1 Bank validation did not worked');
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
        Yodlee_Banks__c ybank = new Yodlee_Banks__c(Name = 'worst bank ever');
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
        Yodlee_Banks__c ybank = new Yodlee_Banks__c(Name = 'worst bank ever');
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
		List<ContactWrapper> Contacts;
        Map<Id, Contact> contactsWithoutEmail;
        Contacts = new List<ContactWrapper>();
        contactsWithoutEmail = new Map<Id, Contact>();
        for(Contact c : [Select Id, Name, Email, AccountId From Contact Where AccountId =: accountId]){
            Contacts.Add(new ContactWrapper(c, (c.Email != null)));
        }
    } 
}