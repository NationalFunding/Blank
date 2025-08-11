@isTest
public with sharing class AttachmentTriggerTest {
        
    @isTest
    static void createLeadAttachmentTest() {
        //Create Document Parent Record
        Lead t = new Lead(
            company = 'MyCompany',
            FirstName = 'John',
            LastName = 'Snow'
        );
        Insert t;
       
        Blob b = Blob.valueOf('Test Data');
        Attachment att = new Attachment(
            ParentId = t.Id,
            body = b,
            Name = 'test'
        );
        Insert att;
        delete att;
    }
}