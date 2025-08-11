@isTest
public class viewAllActivitiesAndNotesLeadLEXTest {

    @isTest
    static void getActivityAndNotesTest(){
        
        test.startTest();
        
        // Create Lead Record
		Lead l = new Lead(LastName = 'LastName123456', Company = 'CompanyName123456', Status = '0: Contact', Email = 'mhandler@nationalfunding.com', MobilePhone = '6193135569');
        insert l;
        system.debug('Lead Id: ' + l.id);
        
        User user = [Select id from user where profile.name='System Administrator' Limit 1];
        
        Task t = new Task(OwnerId = user.id, Subject = 'Subject', Status = 'Open', Priority = 'Normal', WhoId = l.id);
		insert t;
        
        Task t2 = new Task(OwnerId = user.id, Subject = 'Subject', Status = 'Open', Priority = 'Normal', WhoId = l.id);
        insert t2;
        
        Event e = new Event(WhoId = l.id, Type = 'Call', Subject = 'Subject', OwnerId = user.Id, DurationInMinutes = 5, ActivityDateTime = system.now());
        insert e;
                    
        Note n = new Note(Body = 'Body', OwnerId = user.id, Title = 'Title', ParentId = l.Id);
        insert n;
        
        viewAllActivitiesAndNotesLeadLEX.getActivityAndNotes(l.id);
        
        test.stopTest();
    }
}