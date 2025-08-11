@isTest
public class TestLeadNewEncryptedLink {
    public static testmethod void test() {
    Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
    String UniqueUserName = 'uniqueuser_' + System.currentTimeMillis() + '@example.com';
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',EmailEncodingKey='UTF-8', 
                          LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName=UniqueUserName,Available_Brands__c='Quick Bridge,National Funding');
        Insert u;
        User testUser1 = [select id from user where email ='standarduser@testorg.com' limit 1]; 
        
        ValidationRules__c customSettingForUser = ValidationRules__c.getInstance(testUser1.id);
        Lead ld = new Lead();
        ld.LastName = 'test lead 1';
        ld.Company = 'Test Company';
        ld.Account_Number__c = '1234567890';
        ld.Short_Account_Number__c = '098765432';
        ld.PostalCode = '12345';
        ld.Lending_Tree_Id__c = '1111';
        ld.Buyer_Zone_Id__c= '2222';
        ld.Activation_Date__c = Date.today();
        ld.Encrypted_Email_String__c = null;
        ld.IsConverted = FALSE;
        ld.Status = 'Prospect'; // can't do this in the initial run.
        ld.Response_Channel__c = 'Internet';
        ld.ownerId = testUser1.id;
        insert ld;
        /*LinkShorteningAPI__c lsAPI= new LinkShorteningAPI__c(Name = 'ProdEndpoint');
        insert lsAPI;
        lsAPI.Authorization__c = 'apikey 0BFC69A7-2A45-4BFA-A02D-B10C999E6491';
        lsAPI.Endpoint__c = 'https://dev.app.nationalfunding.com:8443/tokenizer/api/v1/SecurityToken'; 
        lsAPI.Retrieval_Endpoint__c = 'https://dev.app.nationalfunding.com:8443/tokenizer/api/v1/Token/';
        lsAPI.Service_Endpoint__c = 'https://dev.app.nationalfunding.com:8443/tokenizer/api/v1/Token';
        update lsAPI;*/
        
        LinkShorteningAPI__c lsAPI2= new LinkShorteningAPI__c(Name = 'V2');
        insert lsAPI2;
        lsAPI2.Authorization__c = '0BFC69A7-2A45-4BFA-A02D-B10C999E6491';
        lsAPI2.Endpoint__c = 'https://dev.app.nationalfunding.com:8443/sts/api/v1/Token'; 
        lsAPI2.Retrieval_Endpoint__c = 'https://dev.app.nationalfunding.com:8443/tokenizer/api/v1/Token/';
        lsAPI2.Service_Endpoint__c = 'https://dev.app.nationalfunding.com:8443/tokenizer/api/v2/Tokens'; 
        update lsAPI2;
        
        Test.startTest();
        HttpMockGenerator mock = new HttpMockGenerator('[{"Id":"' + ld.Id+ '","Token":"bxofefoHG9wLuWDiynV4"}]', 200);
        Test.setMock(HttpCalloutMock.class, mock);
        Test.stopTest();
        
    }

    public static testmethod void test2() {
    Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
    String UniqueUserName = 'uniqueuser_' + System.currentTimeMillis() + '@example.com';
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',EmailEncodingKey='UTF-8', 
                          LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName=UniqueUserName,Available_Brands__c='National Funding');
        Insert u;
        User testUser1 = [select id from user where email ='standarduser@testorg.com' limit 1]; 
        
        ValidationRules__c customSettingForUser = ValidationRules__c.getInstance(testUser1.id);
        Lead ld = new Lead();
        ld.LastName = 'test lead 1';
        ld.Company = 'Test Company';
        ld.Account_Number__c = '1234567890';
        ld.Short_Account_Number__c = '098765432';
        ld.PostalCode = '12345';
        ld.Lending_Tree_Id__c = '1111';
        ld.Buyer_Zone_Id__c= '2222';
        ld.Activation_Date__c = Date.today();
        ld.Response_Channel__c = 'Internet';
        ld.Status = 'Activator'; // can't do this in the initial run.
        ld.ownerId =testUser1.id;
        insert ld;
        /*LinkShorteningAPI__c lsAPI= new LinkShorteningAPI__c(Name = 'ProdEndpoint');
        insert lsAPI;
        lsAPI.Authorization__c = '0BFC69A7-2A45-4BFA-A02D-B10C999E6491';
        lsAPI.Endpoint__c = 'https://stage.app.nationalfunding.com:8443/sts/api/v1/Token'; 
        lsAPI.Retrieval_Endpoint__c = 'https://stage.app.nationalfunding.com:8443/tokenizer/api/v2/SecurityToken';
        lsAPI.Service_Endpoint__c = 'https://stage.app.nationalfunding.com:8443/tokenizer/api/v2/Tokens';
        update lsAPI;*/

        LinkShorteningAPI__c lsAPI2= new LinkShorteningAPI__c(Name = 'V2');
        insert lsAPI2;
        lsAPI2.Authorization__c = '0BFC69A7-2A45-4BFA-A02D-B10C999E6491';
        lsAPI2.Endpoint__c = 'https://stage.app.nationalfunding.com:8443/sts/api/v1/Token'; 
        lsAPI2.Retrieval_Endpoint__c = 'https://stage.app.nationalfunding.com:8443/tokenizer/api/v2/SecurityToken';
        lsAPI2.Service_Endpoint__c = 'https://stage.app.nationalfunding.com:8443/tokenizer/api/v2/Tokens';
        update lsAPI2;

        Test.startTest();
        HttpMockGenerator mock = new HttpMockGenerator('[{"Id":"' + ld.Id+ '","Token":"bxofefoHG9wLuWDiynV4"}]', 200);
        Test.setMock(HttpCalloutMock.class, mock);
        Test.stopTest();

    }
    public static testmethod void test3() {
        
        Group publicGroup = [select id from Group where name = 'National Funding Leads'];
    
        Lead ld = new Lead();
        ld.LastName = 'test lead 1';
        ld.Company = 'Test Company';
        ld.Account_Number__c = '1234567890';
        ld.Short_Account_Number__c = '098765432';
        ld.PostalCode = '12345';
        ld.Lending_Tree_Id__c = '1111';
        ld.Buyer_Zone_Id__c= '2222';
        ld.Activation_Date__c = Date.today();
        ld.Response_Channel__c = 'Internet';
        ld.Status = 'Activator'; // can't do this in the initial run.
        if(publicGroup!=null)
        ld.ownerId = publicGroup.id;
        ld.Originating_Brand__c = 'Quick Bridge';
        insert ld;
        /*LinkShorteningAPI__c lsAPI= new LinkShorteningAPI__c(Name = 'ProdEndpoint');
        insert lsAPI;
        lsAPI.Authorization__c = '0BFC69A7-2A45-4BFA-A02D-B10C999E6491';
        lsAPI.Endpoint__c = 'https://stage.app.nationalfunding.com:8443/sts/api/v1/Token'; 
        lsAPI.Retrieval_Endpoint__c = 'https://stage.app.nationalfunding.com:8443/tokenizer/api/v2/SecurityToken';
        lsAPI.Service_Endpoint__c = 'https://stage.app.nationalfunding.com:8443/tokenizer/api/v2/Tokens';
        update lsAPI;*/

        LinkShorteningAPI__c lsAPI2= new LinkShorteningAPI__c(Name = 'V2');
        insert lsAPI2;
        lsAPI2.Authorization__c = '0BFC69A7-2A45-4BFA-A02D-B10C999E6491';
        lsAPI2.Endpoint__c = 'https://stage.app.nationalfunding.com:8443/sts/api/v1/Token'; 
        lsAPI2.Retrieval_Endpoint__c = 'https://stage.app.nationalfunding.com:8443/tokenizer/api/v2/SecurityToken';
        lsAPI2.Service_Endpoint__c = 'https://stage.app.nationalfunding.com:8443/tokenizer/api/v2/Tokens';
        update lsAPI2;

        Test.startTest();
        HttpMockGenerator mock = new HttpMockGenerator('[{"Id":"' + ld.Id+ '","Token":"bxofefoHG9wLuWDiynV4"}]', 200);
        Test.setMock(HttpCalloutMock.class, mock);
        Test.stopTest();

    }
}