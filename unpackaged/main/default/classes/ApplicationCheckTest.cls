@isTest
public class ApplicationCheckTest {

    @isTest
    static void getOCRTest(){
        
        // Create c1
        Contact c1 = new Contact(LastName = 'LN1');
        insert c1;
        // Create c2
        Contact c2 = new Contact(LastName = 'LN2');
        insert c2;
        // Create Opp
        Opportunity o = new Opportunity(Name = 'OppName', StageName = 'Identified', closeDate = date.today() );
        insert o;
        // create opp contact role for c1 & opp
        OpportunityContactRole ocr = new OpportunityContactRole(OpportunityId = o.id, ContactId =c1.id, Role = 'role');
        insert ocr;
        
        //Test
        list <object> opportunityContactRoles = ApplicationCheck.getOCR(o.id);
        
        system.assertNotEquals(null, opportunityContactRoles, 'OCR Validation for ApplicationCheck Failed');
    }

    @isTest
    static void getAccountFieldsTest(){
        
        // Create Acc
        Account a = new Account(Name = 'Account Name', Fed_Tax_ID__c = '123456789', Legal_Status__c = 'LLC', Date_Established__c = date.today(), State_of_Incorporation__c = 'CA', AnnualRevenue = 1234);
        insert a;
        
        //Test
        list <object> Account = ApplicationCheck.getAccountFields(a.Id);
        
        System.assertNotEquals(null, Account, 'AccountFieldsTest Validation Failed');
        
    }

    @isTest
    static void getFilesTest(){
        
        //Create Opportunity
        Opportunity o = new Opportunity(Name = 'OppName', StageName = 'Identified', closeDate = date.today() );
        insert o;
        
        //Create File 
        ContentVersion cv = new ContentVersion(Title = 'Test Document', PathOnClient = 'TestDocument.pdf', VersionData = Blob.valueOf('Test Content'), IsMajorVersion = true);
    	Insert cv;
        
        ContentVersion testContent = [Select id, contentDocumentId FROM ContentVersion where Id = :cv.Id];
        
        //Link File to Opp
        ContentDocumentLink cdl = new ContentDocumentLink(LinkedEntityId = o.id, ContentDocumentId = testcontent.ContentDocumentId);
        insert cdl;
        
        //Test
        list <object> ContentDocumentLink = ApplicationCheck.getFileAndAttachmentNames(o.Id);
        
        System.assertNotEquals(null, ContentDocumentLink, 'getFilesTest Validation Failed');
    }

    @isTest
    public static void testHasPlaid() {
        Account acc = new Account(Name = 'Test');
        insert acc;
        Bank_Data__c bd = new Bank_Data__c(Account__c = acc.Id);
        insert bd;
        Opportunity opp = new Opportunity(Name = 'Test Name', StageName = 'Qualification', CloseDate = Date.today(), AccountId = acc.Id);
        insert opp;
        boolean result = ApplicationCheck.hasPlaid(opp.Id);
        System.AssertEquals(true, result);
    }

    @isTest
    static void getContactInformationTest(){
        
        // Create Contact
        Contact c = new Contact(FirstName = 'fn', LastName = 'Ln', Title = 'Title', Email = 'mhandler@nationalfunding.com', MobilePhone = '1234567890', BirthDate = date.today(), SSN_Encrypted__c = '123456789', Ownership_Percentage__c = 100, HomePhone = '1234567890');
        insert c;
        
        // Create Opportunity
        Opportunity o = new Opportunity(Name = 'OppName', StageName = 'Identified', closeDate = date.today() );
        insert o;
        
        // Create Opp Contact Role
        OpportunityContactRole ocr = new OpportunityContactRole(OpportunityId = o.Id, ContactId = c.Id, Role = 'Signor');
        insert ocr;
        
        // Test
        list <object> Contact = ApplicationCheck.getContactInformation(o.Id);
        
        System.assertNotEquals(null, Contact, 'GetContactInformation Validation Failed');
            
    }

    @isTest
    static void getApplicationSettingsCMDT() {
        ApplicationCheck.getApplicationSettingsCMDT();
    }
}