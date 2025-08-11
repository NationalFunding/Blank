@isTest
public class RelatedContentDocumentLinkRecordsTest {
	
    @isTest
    static void getfilesTest(){
        
		//Create Document Parent Record
		Account a = new Account(Name='Test Account');
		Insert a;
 
		//Create ContentVersion Record
		ContentVersion cv = new ContentVersion(Title = 'Test Document', PathOnClient = 'TestDocument.pdf', VersionData = Blob.valueOf('Test Content'), IsMajorVersion = true);
		Insert cv;
 
		//Get Content Documents
		Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
 
		//Create ContentDocumentLink 
		ContentDocumentLink cdl = New ContentDocumentLink(LinkedEntityId = a.Id, ContentdocumentId = conDocId, shareType = 'V');
		Insert cdl;
        
		// Test Linked Docs Query
        list<Object> CDLList = RelatedContentDocumentLinkRecords.getfiles(a.Id);
        system.assertNotEquals(null, CDLList, 'Related Document Query Failed');
    }
    
    @isTest
    static void getRelatedFilesTest(){
        
        // Create Account
        Account a = new Account(Name='Test Account');
		Insert a;
        
        // Create Contact 1
        Contact c1 = new Contact(LastName = 'c1', AccountId = a.Id);
        insert c1;
        
        // Create Contact 2
        Contact c2 = new Contact(LastName = 'c2', AccountId = a.Id);
        insert c2;
        
        // Create Opp
        Opportunity o = new Opportunity(AccountId = a.Id, closeDate = date.today(), StageName = 'Stage1', Name = 'Name');
        insert o;
        
        // Create & Associate ContentDocumentLink to Records
        
		//Create ContentVersion Record
		ContentVersion cv = new ContentVersion(Title = 'Test Document', PathOnClient = 'TestDocument.pdf', VersionData = Blob.valueOf('Test Content'), IsMajorVersion = true);
		Insert cv;
 
		//Get Content Documents
		Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
 
		//Create ContentDocumentLink  1 - Account
		ContentDocumentLink cdl1 = New ContentDocumentLink(LinkedEntityId = a.Id, ContentdocumentId = conDocId, shareType = 'V');
		Insert cdl1;
        
        //Create ContentDocumentLink  2 - Contact
		ContentDocumentLink cdl2 = New ContentDocumentLink(LinkedEntityId = c1.Id, ContentdocumentId = conDocId, shareType = 'V');
		Insert cdl2;
        
        //Create ContentDocumentLink  3 - Contact
		ContentDocumentLink cdl3 = New ContentDocumentLink(LinkedEntityId = c2.Id, ContentdocumentId = conDocId, shareType = 'V');
		Insert cdl3;
        
        list <Object> ContentDocumentLink = RelatedContentDocumentLinkRecords.getRelatedFiles(a.Id, o.Id);
        
        system.assertNotEquals(null, ContentDocumentLink, 'getRelatedFiles Validation Failed');
    }
    
    @isTest
    static void shareFilesTest(){
        
        // Create Account
        Account a = new Account(Name='Test Account');
		Insert a;
        
        // Create Opportunity
        Opportunity o = new Opportunity(AccountId = a.Id, closeDate = date.today(), StageName = 'Stage1', Name = 'Name');
        insert o;

		//Create ContentVersion Record
		ContentVersion cv = new ContentVersion(Title = 'Test Document', PathOnClient = 'TestDocument.pdf', VersionData = Blob.valueOf('Test Content'), IsMajorVersion = true);
		Insert cv;
 
		//Get Content Documents
		Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
 
		//Create ContentDocumentLink  1 - Account
		ContentDocumentLink cdl1 = New ContentDocumentLink(LinkedEntityId = a.Id, ContentdocumentId = conDocId, shareType = 'V');
		Insert cdl1;
                
        List <Id> cdlList = new List<Id>();
        
        cdlList.add(conDocId);
        
        List<Object> ContentDocumentLink = RelatedContentDocumentLinkRecords.shareFiles(cdlList, o.Id);
        
        system.assertNotEquals(null, ContentDocumentLink, 'ShareFiles Validation Failed');
        
    }
}