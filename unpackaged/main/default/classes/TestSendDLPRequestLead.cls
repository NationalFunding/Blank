@isTest
public class TestSendDLPRequestLead {

    public class LeadWrapper {
        public boolean IsSelected { get; set; }
        public Lead Lead { get; set; }
        public boolean HasEmail { get; set; }
        public String cType {get; set;}
        
        public LeadWrapper(Lead c, boolean hasEmail){
            Lead = c;
            IsSelected = false;
            this.HasEmail = hasEmail;
        }
    }
    
    @isTest
    static  void Test_SendDLPRequestLeadExtension(){
        createTestData();

        Account acc = new Account(Name = 'unit test account', Phone = '+1 300 2011231', Type = 'Customer');
        insert acc;

        Lead c = new Lead(LastName = 'harry1', Email='bkravitz@nationalfunding.com', Company='NF', DLP_Email_Status__c = 'DLP Email Sent');
        Lead c1 = new Lead(LastName = 'harry', Email='oporter@nationalfunding.com', Company='NF', DLP_Email_Status__c = 'DLP Drip Activated');
        insert c;
        insert c1;
        
        Test.startTest();
            PageReference pageRef = Page.SendDLPLead;
            Test.setCurrentPage(pageRef);

            HttpMockGenerator mock = new HttpMockGenerator('[{"Id":"' + c.Id+ '","Token":"bxofefoHG9wLuWDiynV4"}]', 200);
            Test.setMock(HttpCalloutMock.class, mock);
            SendDLPRequestLead ext = new SendDLPRequestLead(new Apexpages.StandardController(c1));
            ext.getItems();
            //testing without selecting any contact
            ext.SendEmail();
        Test.stopTest();
        boolean foundDesiredMsg = false;
        for(ApexPages.Message msg :  ApexPages.getMessages()) {
            if(msg.getSummary() == 'Please select atleast 1 contact'){
                foundDesiredMsg = true;
            }
        }
        System.assertEquals(false, foundDesiredMsg, 'Atlease 1 Lead validation did not worked');
    }

    @isTest
    static  void Test_SendDLPRequestLeadExtension2(){
        createTestData();

        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com.nf',EmailEncodingKey='UTF-8', 
                        LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US', ProfileId = p.Id, 
                        TimeZoneSidKey='America/Los_Angeles', UserName='standardus@testorg.com.nf', Available_Brands__c = 'Quick Bridge;National Funding');
        insert u;

        Lead c = new Lead(LastName = 'harry1', Email='bkravitz@nationalfunding.com', Company='NF', DLP_Email_Status__c = 'DLP Email Sent', OwnerId = u.Id);
        Lead c1 = new Lead(LastName = 'harry', Email='oporter@nationalfunding.com', Company='NF', DLP_Email_Status__c = '', OwnerId = u.Id);
        insert c;
        insert c1;
        
        Test.startTest();
            PageReference pageRef = Page.SendDLPLead;
            Test.setCurrentPage(pageRef);

            HttpMockGenerator mock = new HttpMockGenerator('[{"Id":"' + c.Id+ '","Token":"bxofefoHG9wLuWDiynV4"}]', 200);
            Test.setMock(HttpCalloutMock.class, mock);
            SendDLPRequestLead ext = new SendDLPRequestLead(new Apexpages.StandardController(c1));
            ext.getItems();           
            //testing without selecting any contact
            ext.SendEmail();
        Test.stopTest();
        boolean foundDesiredMsg = false;
        for(ApexPages.Message msg :  ApexPages.getMessages()) {
            if(msg.getSummary() == 'Please select atleast 1 contact'){
                foundDesiredMsg = true;
            }
        }
        System.assertEquals(false, foundDesiredMsg, 'Atlease 1 Lead validation did not worked');
    }

    @isTest
    static void Test_SendDLPRequestLeadExtension3(){
        createTestData();

        Account acc = new Account(Name = 'unit test account', Phone = '+1 300 2011231', Type = 'Customer');
        insert acc;

        Lead c = new Lead(LastName = 'harry1', Email='bkravitz@nationalfunding.com', Company='NF', DLP_Email_Status__c = 'DLP Email Sent');
        Lead c1 = new Lead(LastName = 'harry', Email='oporter@nationalfunding.com', Company='NF', DLP_Email_Status__c = 'DLP Drip Activated');
        insert c;
        insert c1;
        
        Test.startTest();
            PageReference pageRef = Page.SendDLPLead;
            Test.setCurrentPage(pageRef);
            
            HttpMockGenerator mock = new HttpMockGenerator('[{"Id":"' + c.Id+ '","Token":"bxofefoHG9wLuWDiynV4"}]', 200);
            Test.setMock(HttpCalloutMock.class, mock);
            SendDLPRequestLead ext = new SendDLPRequestLead(new Apexpages.StandardController(c));
            ext.getItems();
            List<SendDLPRequestLead.LeadWrapper> contacts = ext.Leads;
            
            //testing without selecting any contact
            ext.SendEmail();
        Test.stopTest();
        boolean foundDesiredMsg = false;
        for(ApexPages.Message msg :  ApexPages.getMessages()) {
            if(msg.getSummary() == 'Please select atleast 1 contact'){
                foundDesiredMsg = true;
            }
        }
        System.assertEquals(false, foundDesiredMsg, 'Atlease 1 Lead validation did not worked');
    }

    @isTest
    static void createTestData(){
        Account acc = new Account(Name = 'unit test account', Phone = '+1 300 2011231', Type = 'Customer');
        insert acc;
        
        HttpMockGenerator mock = new HttpMockGenerator('[{"Id":"' + acc.Id+ '","Token":"bxofefoHG9wLuWDiynV4"}]', 200);
        Test.setMock(HttpCalloutMock.class, mock);

        List<Lead> leadRecs = new List<Lead>();
        for(integer i=0; i<20; i++){
            leadRecs.add(new Lead( LastName = 'unit test contact'+i, Email = 'test'+i+'@gmail.com', Company='NF'));
        }
        insert leadRecs;

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
        
        HttpMockGenerator mock = new HttpMockGenerator('[{"Id":"' + acc.Id+ '","Token":"bxofefoHG9wLuWDiynV4"}]', 200);
        Test.setMock(HttpCalloutMock.class, mock);

        List<Lead> leadRecs = new List<Lead>();
        for(integer i=0; i<20; i++){
            leadRecs.add(new Lead(LastName = 'unit test contact'+i, Email = 'test'+i+'@gmail.com', Company='NF'));
        }
        insert leadRecs;

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
    static void Test_SendDLPRequestLeadExtension4(){
        Lead c = new Lead(LastName = 'harry1', Email='bkravitz@nationalfunding.com', Company='NF', DLP_Email_Status__c = '');
        insert c;
        
        PageReference pageRef = Page.SendDLPLead;
        Test.setCurrentPage(pageRef);
        
        HttpMockGenerator mock = new HttpMockGenerator('[{"Id":"' + c.Id+ '","Token":"bxofefoHG9wLuWDiynV4"}]', 200);
        Test.setMock(HttpCalloutMock.class, mock);
        SendDLPRequestLead ext = new SendDLPRequestLead(new Apexpages.StandardController(c));
        ext.getItems();
    }
}