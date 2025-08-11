@isTest(SeeAllData=true)
public class TestConsoleApplicationLinkController {

    static testMethod void myUnitTest()
    {
        Account acct = new Account();
        acct.Name = 'test';
        acct.Web_Id_NatFund__c = '11111111';
        insert acct;

        Opportunity o = new Opportunity();
        o.Name = 'test';
        o.StageName = 'New';
        o.CloseDate = Date.today();
        o.AccountId = acct.id;
        o.Signor_Phone__c = '111111111';
        insert o;

        Contact cont = new Contact();
        cont.AccountId = acct.Id;
        cont.FirstName='Test';
        cont.LastName='Test';
        insert cont;

        Lead l = new Lead();
        l.Company = 'test';
        l.FirstName='Test';
        l.LastName='Test';
        l.Web_Id_NatFund__c = '1111111';
        l.Account_Number__c = '1234567890';
        l.Short_Account_Number__c = '098765432';
        l.PostalCode = '12345';
        l.Lending_Tree_Id__c = '1111';
        l.Buyer_Zone_Id__c= '2222';
        l.Status = 'House'; // can't do this in the initial run.
        l.IsConverted = FALSE;
        l.Response_Channel__c = 'Internet';
        insert l;

        Test.startTest();
        ConsoleApplicationLinkController k = new ConsoleApplicationLinkController();
        HttpMockGenerator mock = new HttpMockGenerator('[{"Id":"' + l.Id+ '","Token":"bxofefoHG9wLuWDiynV4"}]', 200);
        Test.setMock(HttpCalloutMock.class, mock);
        String value1= cont.id + ',' + acct.Web_Id_NatFund__c;
        String value2= l.id + ',' + + l.Web_Id_NatFund__c;
        String value3 = 'error';
        ConsoleApplicationLinkController.getShortenedLink(l.id, l.Web_Id_NatFund__c, 'National Funding', 'Quick Bridge');
        ConsoleApplicationLinkController.getShortenedLinkOneParam(value2, 'National Funding', 'Quick Bridge');
        ConsoleApplicationLinkController.getShortenedLinkLT(value2, 'National Funding', 'Quick Bridge');
        //ConsoleApplicationLinkController.getShortenedLinkLoanMod(value2, 'National Funding', 'Quick Bridge');
        //ConsoleApplicationLinkController.getShortenedLinkSecondDML(value2, 'National Funding', 'Quick Bridge');
        
        ConsoleApplicationLinkController.returnURL(cont.id);
        Test.stopTest();
    }
    
     static testMethod void myUnitTest2()
    {
        Account acct = new Account();
        acct.Name = 'test';
        acct.Web_Id_NatFund__c = '11111111';
        insert acct;

        Opportunity o = new Opportunity();
        o.Name = 'test';
        o.StageName = 'New';
        o.CloseDate = Date.today();
        o.AccountId = acct.id;
        o.Signor_Phone__c = '111111111';
        insert o;

        Contact cont = new Contact();
        cont.AccountId = acct.Id;
        cont.FirstName='Test';
        cont.LastName='Test';
        insert cont;

        Lead l = new Lead();
        l.Company = 'test';
        l.FirstName='Test';
        l.LastName='Test';
        l.Web_Id_NatFund__c = '1111111';
        l.Account_Number__c = '1234567890';
        l.Short_Account_Number__c = '098765432';
        l.PostalCode = '12345';
        l.Lending_Tree_Id__c = '1111';
        l.Buyer_Zone_Id__c= '2222';
        l.Status = 'House'; // can't do this in the initial run.
        l.IsConverted = FALSE;
        l.Response_Channel__c = 'Internet';
        insert l;

        Test.startTest();
        ConsoleApplicationLinkController k = new ConsoleApplicationLinkController();
        HttpMockGenerator mock = new HttpMockGenerator('[{"Id":"' + l.Id+ '","Token":"bxofefoHG9wLuWDiynV4"}]', 200);
        Test.setMock(HttpCalloutMock.class, mock);
        String value1= cont.id + ',' + acct.Web_Id_NatFund__c;
        String value2= l.id + ',' + + l.Web_Id_NatFund__c;
        String value3 = 'error';
        //ConsoleApplicationLinkController.getShortenedLink(l.id, l.Web_Id_NatFund__c, 'National Funding', 'Quick Bridge');
        //ConsoleApplicationLinkController.getShortenedLinkOneParam(value2, 'National Funding', 'Quick Bridge');
        //ConsoleApplicationLinkController.getShortenedLinkLT(value2, 'National Funding', 'Quick Bridge');
        ConsoleApplicationLinkController.getShortenedLinkLoanMod(value2, 'National Funding', 'Quick Bridge');
        ConsoleApplicationLinkController.getShortenedLinkSecondDML(value2, 'National Funding', 'Quick Bridge');
        
        ConsoleApplicationLinkController.returnURL(cont.id);
        Test.stopTest();
    }
    
    static testMethod void bulkContactTest()
    {
        Account a = new Account( Web_Id_NatFund__c= '123456789', Name = 'Test');
        insert a;

        Contact c = new Contact();
        c.AccountId = a.Id;
        c.LastName = 'lastname';
        c.FirstName = 'firstname';
        insert c;

        Test.startTest();
        ConsoleApplicationLinkController k = new ConsoleApplicationLinkController();
        HttpMockGenerator mock = new HttpMockGenerator('[{"Id":"1","Token":"t0"},{"Id":"2","Token":"t1"},{"Id":"3","Token":"t2"},{"Id":"4","Token":"t3"}]', 200);
        Test.setMock(HttpCalloutMock.class, mock);
        String valContacts = '{"ID":"' + c.Id+'","Properties":{"NFD":"11111111", "ContactId":"' +c.id+'","GeneratingTime":"' + Date.today().format() + '"}}';
        String valLeads = null;
        ConsoleApplicationLinkController.getShortenedLinkBULK(valContacts, valLeads);
        ConsoleApplicationLinkController.getShortenedLinkBULKNOTFUTURE(valContacts, valLeads);
        Test.stopTest();
    }
    static testMethod void bulkLeadTest()
    {
        Lead l = new Lead();
        l.IsConverted = FALSE;
        l.LastName = 'test lead 1';
        l.Company = 'Test Company';
        insert l;

        Test.startTest();
        ConsoleApplicationLinkController k = new ConsoleApplicationLinkController();
        HttpMockGenerator mock = new HttpMockGenerator('[{"Id":"1","Token":"t0"},{"Id":"2","Token":"t1"},{"Id":"3","Token":"t2"},{"Id":"4","Token":"t3"}]', 200);
        Test.setMock(HttpCalloutMock.class, mock);
        String valContacts = null;
        String valLeads = '{"ID":"' + l.Id+'","Properties":{"NFD":"11111111", "LeadId":"' +l.id+'","GeneratingTime":"' + Date.today().format() + '"}}';
        ConsoleApplicationLinkController.getShortenedLinkBULK(valContacts, valLeads);
        ConsoleApplicationLinkController.getShortenedLinkBULKNOTFUTURE(valContacts, valLeads);
        Test.stopTest();
    }

}