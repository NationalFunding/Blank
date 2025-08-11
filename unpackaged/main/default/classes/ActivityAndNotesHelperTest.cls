@isTest
public class ActivityAndNotesHelperTest {

    @isTest
    static void getActivityAndNotesTest(){
        
        test.startTest();
        
        // Create Lead Record
		Account a = new Account (Name='Name');
        insert a;
        
        Contact c = new Contact(LastName = 'ln', accountId = a.id);
        insert c;
        
        Opportunity o = new Opportunity(Name = 'Name', StageName ='1', CloseDate =system.today(), accountId = a.id);
        insert o;
        
        User user = [Select id from user where profile.name='System Administrator' Limit 1];
        
        Task t = new Task(OwnerId = user.id, Subject = 'Subject', Status = 'Open', Priority = 'Normal', WhatId = a.id);
		insert t;
        
        Task t2 = new Task(OwnerId = user.id, Subject = 'Subject', Status = 'Closed', Priority = 'Normal', WhatId = a.id);
        insert t2;
        
        Event e = new Event(WhatId = a.id, Type = 'Call', Subject = 'Subject', OwnerId = user.Id, DurationInMinutes = 5, ActivityDateTime = system.now());
        insert e;
                    
        Note n = new Note(Body = 'Body', OwnerId = user.id, Title = 'Title', ParentId = a.Id);
        insert n;
        
        ActivityAndNotesHelper act = new ActivityAndNotesHelper();
        act.GetActivityAndNotesOnAccount(a.id);
        act.GetActivityAndNotesOnAccountInternal(a.id);
        act.GetActivityAndNotesOnAccountAll(a.id, 1, 1);

        
        test.stopTest();
    }
}