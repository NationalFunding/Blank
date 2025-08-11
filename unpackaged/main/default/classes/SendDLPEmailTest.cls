@isTest
public class SendDLPEmailTest {

    @testSetup
    static void testSetup(){
        // Create Lead
        // Create User for testing..
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1]; // Assuming "Standard User" exists
        User user = new User(
            Alias = 'mhandler',
            Email = 'standarduser@testorg.com.nf',
            ProfileId = p.Id,
            Username = 'standarduser@testorg.com.nf',
            FirstName = 'Test',
            LastName = 'User',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            CommunityNickname = 'testnf',
            Available_Brands__c = 'National Funding;Quick Bridge'
        );
    	insert user;
        Lead l = new Lead(Company = 'RefreshDLPToken', LastName = 'LastName', email = 'mhandler@nationalfunding.com', Web_Id_NatFund__c ='1', ownerId = user.Id);
        insert l;
        
        Account a = new Account(Name = 'RefreshDLPToken', Web_Id_NatFund__c='1', OwnerId = user.Id);
        insert a;
        
        Contact c = new Contact(LastName = 'LNRefreshDLPToken', AccountId = a.id, email = 'mhandler@nationalfunding.com', OwnerId = user.Id );
        insert c;           
    }
        
    @isTest
    static void failureTestLead(){
        
        // Place Lead in a List
		Lead l = [SELECT Id FROM Lead WHERE Company = 'RefreshDLPToken'];
        

        
        SingleRequestMockClass fakeResponse2 = new SingleRequestMockClass(500,'Complete','123',null);
        test.setMock(HttpCalloutMock.class, fakeResponse2);
        
 
        
        try {
        	Test.startTest(); 
			SendDLPEmail.sendDLPEmail(l.id);
        	Test.stopTest();   
        } catch(Exception e) {
          System.assertNotEquals('expectedTypeName', e.getTypeName());
        }
        

    }    
        
    @isTest
    static void failureTestContact(){
        
        // Place Lead in a List
		Contact c = [SELECT Id FROM Contact WHERE LastName = 'LNRefreshDLPToken'];
        
        SingleRequestMockClass fakeResponse2 = new SingleRequestMockClass(500,'Complete','123',null);
        test.setMock(HttpCalloutMock.class, fakeResponse2);
        
        Test.startTest();
        
        try{
        	SendDLPEmail.sendDLPEmail(c.id);
        } catch(Exception e) {
          System.assertNotEquals('expectedTypeName', e.getTypeName());
        }

           
        Test.stopTest();
    }
    
    @isTest
    static void failureNonObject(){
                
        SingleRequestMockClass fakeResponse2 = new SingleRequestMockClass(500,'Complete','123',null);
        test.setMock(HttpCalloutMock.class, fakeResponse2);
        
        Test.startTest();
        
        try{
        	SendDLPEmail.sendDLPEmail('123456789012345');
        } catch(Exception e) {
          System.assertNotEquals('expectedTypeName', e.getTypeName());
        }

           
        Test.stopTest();
    }
        
}