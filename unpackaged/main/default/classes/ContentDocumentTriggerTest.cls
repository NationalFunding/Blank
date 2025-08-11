@isTest
public with sharing class ContentDocumentTriggerTest {
        
    @isTest
    static void createLeadContentDocumentTest() {
        //Create Document Parent Record
        Lead testLead = new Lead(
            company = 'MyCompany',
            FirstName = 'John',
            LastName = 'Snow'
        );
        Insert testLead;
       
        //Create ContentVersion Record
        ContentVersion cv = new ContentVersion(
            Title = 'Test Document', 
            PathOnClient = 'TestDocument.pdf', 
            VersionData = Blob.valueOf('Test Content'), 
            IsMajorVersion = true
        );
        Insert cv;

        //Get Content Documents
        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;

        //Create ContentDocumentLink 
        ContentDocumentLink cdl = New ContentDocumentLink(
            LinkedEntityId = testLead.Id, 
            ContentdocumentId = conDocId, 
            shareType = 'V'
        );
        Insert cdl;

        ContentDocument contentDoc = [SELECT Id FROM ContentDocument WHERE Id = :conDocId];
        delete contentDoc;
    }

    

}