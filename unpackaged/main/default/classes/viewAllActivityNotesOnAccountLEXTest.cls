@isTest
public class viewAllActivityNotesOnAccountLEXTest {

    @isTest
    static void getActivityAndNotesTest(){
        
        test.startTest();
        
        // Create Account
        Account a = new Account(Name = 'CompanyName');
        insert a;
        system.debug('Account Id: ' + a.id);
        
        User user = [Select id from user where profile.name='System Administrator' Limit 1];
        
        Task t = new Task(OwnerId = user.id, Subject = 'Subject', Status = 'Open', Priority = 'Normal', WhatId = a.id);
		insert t;
        
        Task t2 = new Task(OwnerId = user.id, Subject = 'Subject', Status = 'Open', Priority = 'Normal', WhatId = a.id);
        insert t2;
        
        Event e = new Event(WhatId = a.id, Type = 'Call', Subject = 'Subject', OwnerId = user.Id, DurationInMinutes = 5, ActivityDateTime = system.now());
        insert e;
            
        //Activity a = new Activity()
        
        Note n = new Note(Body = 'Body', OwnerId = user.id, Title = 'Title', ParentId = a.Id);
        insert n;
        
        viewAllActivityNotesOnAccountLEX.getActivityAndNotes(a.id);

        //FTC-598 : getActivityAndNotesALL(string AccountId, integer PageNumber, integerPageSize);
        ActivityAndNotes anALL = viewAllActivityNotesOnAccountLEX.getActivityAndNotesALL(a.id, 1, 20);
            
        
        test.stopTest();
    }
}