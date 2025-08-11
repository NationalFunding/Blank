@isTest
public class ActivityAndNotesLeadHelperTest {
    
    @isTest
    static void GetActivityAndNotesOnLeadTest1(){
        Lead l = new Lead(Company = 'RefreshDLPToken', LastName = 'LastName', email = 'mhandler@nationalfunding.com', mobilePhone = '6507592961');
        insert l;
        
        Attachment attach=new Attachment();   	
    	attach.Name='Unit Test Attachment';
    	Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
    	attach.body=bodyBlob;
        attach.parentId=l.id;
        insert attach;
        
        test.startTest();
        ActivityAndNotesLeadHelper test1 = new ActivityAndNotesLeadHelper();
        test1.GetActivityAndNotesOnLead(l.id);
        test.stopTest();
    }
    
    @isTest
    static void GetActivityAndNotesOnLeadTest2(){
        Lead l = new Lead(Company = 'RefreshDLPToken', LastName = 'LastName', email = 'mhandler@nationalfunding.com', mobilePhone = '6507592961');
        insert l;
        
        Note testNote = new Note();
        testNote.Title = 'Test Account Note';
        testNote.Body = 'Test Account Note Body.';
        testNote.ParentId = l.Id;
        insert testNote;
        
        test.startTest();
        ActivityAndNotesLeadHelper test1 = new ActivityAndNotesLeadHelper();
        test1.GetActivityAndNotesOnLead(l.id);
        test.stopTest();
    }
    
    @isTest
    static void GetActivityAndNotesOnLeadTest3(){
        Lead l = new Lead(Company = 'RefreshDLPToken', LastName = 'LastName', email = 'mhandler@nationalfunding.com', mobilePhone = '6507592961');
        insert l;
        
        Task testTask = new Task();
        testTask.ActivityDate = Date.today().addDays(7);
        testTask.Subject = '1';
        testTask.whoId = l.id;
        insert testTask;
        
        test.startTest();
        ActivityAndNotesLeadHelper test1 = new ActivityAndNotesLeadHelper();
        test1.GetActivityAndNotesOnLead(l.id);
        test.stopTest();
    }
}