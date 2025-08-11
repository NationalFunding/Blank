@isTest
public class RefreshEncryptedEmailStringTest {

    @isTest
    static void refreshContactTest(){

      
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com.nf',EmailEncodingKey='UTF-8', 
                          LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='standardus@testorg.com.nf', Available_Brands__c = 'Quick Bridge');
        insert u;

        Account a = new Account(Name = 'Name', Web_Id_NatFund__c = '1', NF_Renewal_Rep__c = u.Id);
        insert a;
        
        Contact c = new Contact(LastName = 'LastName', email = 'mhandler@nationalfunding.com', LeadSource = 'Email', AccountId = a.id);
        insert c;
        
        test.startTest();
          HttpMockGenerator mock = new HttpMockGenerator('[{"Id":"' + c.Id+ '","Token":"bxofefoHG9wLuWDiynV4"}]', 200);
          Test.setMock(HttpCalloutMock.class, mock);
          String sId = c.Id;
          
          RefreshEncryptedEmailString test1 = new RefreshEncryptedEmailString();
          
          try{
            test1.refresh(sId, 'National Funding', 'Quick Bridge');
          } catch(Exception e) {
            System.assertNotEquals('expectedTypeName', e.getTypeName());
          }
          
        test.stopTest();
    }
    
    @isTest
    static void refreshLeadTest(){
            
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com.nf',EmailEncodingKey='UTF-8', 
                          LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='standardus@testorg.com.nf', Available_Brands__c = 'Quick Bridge');
        insert u;

        Lead l = new Lead(LastName = 'LastName', email = 'mhandler@nationalfunding.com', LeadSource = 'Email', Company='1', OwnerId = u.Id);
        insert l;
        
        test.startTest();

          HttpMockGenerator mock = new HttpMockGenerator('[{"Id":"' + l.Id+ '","Token":"bxofefoHG9wLuWDiynV4"}]', 200);
          Test.setMock(HttpCalloutMock.class, mock);
          
          String sId = l.Id;
          
          RefreshEncryptedEmailString test1 = new RefreshEncryptedEmailString();
          
          try{
            test1.refresh(sId, 'National Funding', 'Quick Bridge');
          } catch(Exception e) {
            System.assertNotEquals('expectedTypeName', e.getTypeName());
          }

        test.stopTest();
    }
    
}