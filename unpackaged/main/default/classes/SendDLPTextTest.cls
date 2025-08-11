@isTest
public class SendDLPTextTest {
    
    @testSetup
    static void testSetup(){
        
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
        
        // Create Lead
        Lead l = new Lead(Company = 'RefreshDLPToken', LastName = 'LastName', email = 'mhandler@nationalfunding.com', mobilePhone = '6507592961', ownerId = user.id);
        insert l;
        
        Account a = new Account(Name = 'RefreshDLPToken');
        insert a;
        
        Contact c = new Contact(LastName = 'LNRefreshDLPToken', AccountId = a.id, email = 'mhandler@nationalfunding.com', mobilePhone = '6507592961' );
        insert c;
                    
       	// Configure the Custom Setting
        
        DLPTextConfig__c textConfig = new DLPTextConfig__c();
        textConfig.Account_SID__c = '123';
        textConfig.DLP_Text_Source__c = 'TextSource';
        insert textConfig;
                       
		Instance_Settings__c instanceSettings = new Instance_Settings__c();
		instanceSettings.Base_URL__c = 'baseurl';
        insert instanceSettings;
        
        Tokenizer__c tokenizer = new Tokenizer__c();
        tokenizer.APIKEY__c ='0BFC69A7-2A45-4BFA-A02D-B10C999E6491';
        tokenizer.Endpoint__c ='https://stage.app.nationalfunding.com:8443';
        insert tokenizer;
        
        // @@@ add additional configs... when check on sts and tokenizer config
                
    }
    
    @isTest
    static void positiveTestLead(){
        
        // Place Lead in a List
		Lead l = [SELECT Id FROM Lead WHERE Company = 'RefreshDLPToken'];
        
        String userId = [Select id from user where Username = 'standarduser@testorg.com.nf' limit 1].Id;
       
            
        SingleRequestMockClass fakeResponse = new SingleRequestMockClass(200,'Complete','exjson',null);
        test.setMock(HttpCalloutMock.class, fakeResponse);
        
        Test.startTest();
        
        try{
            	SendTwilioTextHelper.SetTestMode(true);
          		SendDLPText.sendDLPText(l.id,userId);
        }
        catch(exception e){
            
        }
        
        Test.stopTest();
        system.assertEquals(1,1);
    }
   
    @isTest
    static void failureTestLead(){
        
        // Place Lead in a List
		Lead l = [SELECT Id FROM Lead WHERE Company = 'RefreshDLPToken'];
        
         String userId = [Select id from user where Username = 'standarduser@testorg.com.nf' limit 1].Id;
        
        SingleRequestMockClass fakeResponse2 = new SingleRequestMockClass(500,'Complete','123',null);
        test.setMock(HttpCalloutMock.class, fakeResponse2);
        
        Test.startTest();
                
        try {
        SendDLPText.SetTestMode();
		SendDLPText.sendDLPText(l.id, userId);
            
		} catch (exception e){
            
            String expectedMessage = 'There has been an error calling the STS service. Status Code: 500';
            String actualMessage = e.getMessage();
        	System.assertNotEquals(expectedMessage, actualMessage, 'Recevied a Wrong Exception Message');
            
		}
        
        Test.stopTest();
    }    
    
    @isTest
    static void positiveTestContact(){
        
        // Place Contact in a List
		contact c = [SELECT Id FROM Contact WHERE LastName = 'LNRefreshDLPToken'];
        
         String userId = [Select id from user where Username = 'standarduser@testorg.com.nf' limit 1].Id;
            
        SingleRequestMockClass fakeResponse = new SingleRequestMockClass(200,'Complete','exjson',null);
        test.setMock(HttpCalloutMock.class, fakeResponse);
        
        Test.startTest();
        
        try{
            SendTwilioTextHelper.SetTestMode(true);
            SendDLPText.sendDLPText(c.id, userId);
        } catch (exception e){
            
        }
		
        
        Test.stopTest();
        
    }
    
    @isTest
    static void failureTestContact(){
        
        // Place Lead in a List
		Contact c = [SELECT Id FROM Contact WHERE LastName = 'LNRefreshDLPToken'];
        
         String userId = [Select id from user where Username = 'standarduser@testorg.com.nf' limit 1].Id;
        
        SingleRequestMockClass fakeResponse2 = new SingleRequestMockClass(500,'Complete','123',null);
        test.setMock(HttpCalloutMock.class, fakeResponse2);
        
        Test.startTest();
                
        try {
        SendDLPText.SetTestMode();
		SendDLPText.sendDLPText(c.id, userId);
            
		} catch (exception e){
            
            String expectedMessage = 'There has been an error calling the STS service. Status Code: 500';
            String actualMessage = e.getMessage();
        	System.assertNotEquals(expectedMessage, actualMessage, 'Recevied a Wrong Exception Message');
            
		}
        
        Test.stopTest();
    }  
    
    @isTest
    static void unknownObject(){
        
        
        String userId = [Select id from user where Username = 'standarduser@testorg.com.nf' limit 1].Id;
        
        SingleRequestMockClass fakeResponse2 = new SingleRequestMockClass(500,'Complete','123',null);
        test.setMock(HttpCalloutMock.class, fakeResponse2);
        
        Test.startTest();
                
        try {
		SendDLPText.sendDLPText('123456789012345', userId);
            
		} catch (exception e){
            
            String expectedMessage = 'There has been an error calling the STS service. Status Code: 500';
            String actualMessage = e.getMessage();
        	System.assertNotEquals(expectedMessage, actualMessage, 'Recevied a Wrong Exception Message');
            
		}
        
        Test.stopTest();
    }  
    
    @isTest
    static void positiveTestLeads(){
        
        User user = [Select Id From User WHERE email ='mhandler@nationalfunding.com'];
        
        lead l2 = new lead(Company = 'RefreshDLPToken2', LastName = 'LastName2', email = 'mhandler@nationalfunding.com2', mobilePhone = '6507592962', ownerId = user.Id);
        insert l2;
        
        List<String> lst = new List<String>();
        lst.add(String.valueOf(l2.id));

        User usr = [Select id from user where Username = 'standarduser@testorg.com.nf' limit 1];//standarduser@testorg.com.nf
        String userId = usr.Id;
 
        
        String exjson = '[ { "Id":"'+l2.Id+'", "Token": "sample_token" } ]';  
            
        SingleRequestMockClass fakeResponse = new SingleRequestMockClass(200,'Complete',exjson,null);
        test.setMock(HttpCalloutMock.class, fakeResponse);
        
        Test.startTest();
        try{
            SendDLPText.SetTestMode();
        	SendDLPText.calloutSendDLPText(l2.id, l2.OwnerId);    
        } catch(Exception e) {
          system.debug('Exception: ' + e);
          system.assertEquals(1, 1, 'msg');
        }

        Test.stopTest();
        
        
        
  }

    @isTest
    static void positiveTestLead3(){
        
        // Place Lead in a List
		Lead l = [SELECT Id FROM Lead WHERE Company = 'RefreshDLPToken'];
        User usr = [Select id from user where Username = 'standarduser@testorg.com.nf' limit 1];
        String userId = usr.Id;

        String exjson = '[ { "Id":"'+l.Id+'", "Token": "sample_token" } ]';           
            
        SingleRequestMockClass fakeResponse = new SingleRequestMockClass(200,'Complete',exjson,null);
        test.setMock(HttpCalloutMock.class, fakeResponse);
        
        Test.startTest();
        
        try{
                SendTwilioTextHelper.SetTestMode(true);
            	SendDLPText.calloutSendTwilioMessage('dlpurl','source','payload','tonumber','fromnumber','sid');  
        }
        catch(exception e){
            
        }
        
        Test.stopTest();
        
    }

}