/**
 * Created by oporter on 4/18/2017.
 */
@isTest
public with sharing class viewAllCaseCommentsActivitiesTest {

    public static testMethod void testTaskList(){
        Account a = new Account(Name = 'Test Account Name');
        insert a;
        Case c = new Case(Account = a);
        insert c;
        ApexPages.currentPage().getParameters().put('CaseId', c.id);
        CaseComment cc  =  new CaseComment(ParentId = c.Id);
        insert cc;
        Task t = new Task(Private__c = FALSE, WhatId = c.Id);
        insert t;
        Account a2 = new Account(Name = 'Test Account Name');
        insert a2;
        Case c2 = new Case(Account = a);
        insert c2;
        ApexPages.currentPage().getParameters().put('AcctId', a2.id);
        CaseComment cc2  =  new CaseComment(ParentId = c2.Id);
        insert cc2;
        Task t2 = new Task();
        insert t2;
        viewAllCaseCommentsActivitiesController vaccac = new viewAllCaseCommentsActivitiesController();
    }
    public static testMethod void testCommentList(){
        Account a = new Account(Name = 'Test Account Name');
        insert a;
        Case c = new Case(Account = a);
        insert c;
        ApexPages.currentPage().getParameters().put('CaseId', c.id);
        Task t = new Task(Private__c = FALSE, WhatId = c.Id);
        insert t;
        Account a2 = new Account(Name = 'Test Account Name');
        insert a2;
        Case c2 = new Case(Account = a);
        insert c2;
        ApexPages.currentPage().getParameters().put('AcctId', a2.id);
        CaseComment cc  =  new CaseComment(ParentId = c2.Id);
        insert cc;
        CaseComment cc2  =  new CaseComment(ParentId = c2.Id);
        insert cc2;
        Task t2 = new Task(Private__c = FALSE, WhatId = c.Id);
        insert t2;
        viewAllCaseCommentsActivitiesController vaccac = new viewAllCaseCommentsActivitiesController();
    }
    static testmethod void test1() {
        Account a = new Account(Name = 'Test Account Name');
        insert a;
        Case c = new Case(Account = a);
        insert c;
        Task t = new Task(Private__c = FALSE, WhatId = c.Id, Date_Activity_Logged__c = Datetime.now());
        insert t;
        Account a2 = new Account(Name = 'Test Account Name');
        insert a2;
        Case c2 = new Case(Account = a);
        insert c2;
        CaseComment cc  =  new CaseComment(ParentId = c2.Id);
        insert cc;
        CaseComment cc2  =  new CaseComment(ParentId = c2.Id);
        insert cc2;
        Task t2 = new Task(Private__c = FALSE, WhatId = c.Id, Date_Activity_Logged__c = Datetime.now().addDays(2));
        insert t2;
        Task t3 = new Task(Private__c = FALSE, WhatId = c.Id, Date_Activity_Logged__c = Datetime.now().addDays(-10));
        insert t3;
        List<viewAllCaseCommentsActivitiesController.CaseInfo> caseList = new List<viewAllCaseCommentsActivitiesController.CaseInfo>();
        caseList.add(new viewAllCaseCommentsActivitiesController.CaseInfo(c, t));
        caseList.add(new viewAllCaseCommentsActivitiesController.CaseInfo(c2, t2));
        caseList.add(new viewAllCaseCommentsActivitiesController.CaseInfo(c2, t3));
        caseList.sort();
        System.debug(caseList);
    }

    static testmethod void test2() {
        Account act2 = new Account(Name = 'Test Account Name');
        insert act2;
        Case ct2 = new Case(Account = act2);
        insert ct2;
        Task tt2 = new Task(Private__c = FALSE, WhatId = ct2.Id);
        insert tt2;
        Account aa2 = new Account(Name = 'Test Account Name');
        insert aa2;
        Case cc2 = new Case(Account = act2);
        insert cc2;
        CaseComment comm2  =  new CaseComment(ParentId = cc2.Id);
        insert comm2;
        CaseComment commc2  =  new CaseComment(ParentId = cc2.Id);
        insert commc2;
        Task ttt2 = new Task(Private__c = FALSE, WhatId = ct2.Id);
        insert ttt2;
        List<viewAllCaseCommentsActivitiesController.CaseCommentInfo> caseList = new List<viewAllCaseCommentsActivitiesController.CaseCommentInfo>();
        caseList.sort();
        System.debug(caseList);
    }

    public static testmethod void twilioMessageTest(){
        //building mock messages
        Account act2 = new Account(Name = 'Test Account Name');
        insert act2;
        Case ct2 = new Case(Account = act2, AccountId = act2.Id);
        insert ct2;
        Contact c = new Contact(LastName = 'Test User', AccountId = act2.Id);
        insert c;
        Task tt2 = new Task(Private__c = FALSE, WhatId = ct2.Id);
        insert tt2;
        CaseComment comm2  =  new CaseComment(ParentId = ct2.Id);
        insert comm2;
        CaseComment commc2  =  new CaseComment(ParentId = ct2.Id);
        insert commc2;
        Date d = Date.newInstance(2022, 12, 9);
        Date d2 = Date.newInstance(2023, 1, 7);

        ApexPages.currentPage().getParameters().put('CaseId', ct2.id);

        TwilioSF__Message__c newMessage = new TwilioSF__Message__c(TwilioSF__Account__c =ct2.AccountId, TwilioSF__Contact__c  = c.Id, TwilioSF__Date_Created__c = d);
        insert newMessage;
            
        TwilioSF__Message__c newMessage2 = new TwilioSF__Message__c(TwilioSF__Account__c =ct2.AccountId, TwilioSF__Contact__c  = c.Id, TwilioSF__Date_Created__c = d2 );
        insert newMessage2;  

        viewAllCaseCommentsActivitiesController vaccac = new viewAllCaseCommentsActivitiesController();
        List<TwilioSF__Message__c> allMessageList = [SELECT TwilioSF__From_Number_Unformatted__c, TwilioSF__To_Number_Unformatted__c, Id, Name, TwilioSF__Contact__r.Name, TwilioSF__Contact__c, TwilioSF__Body__c, Created_Date_Time__c,OwnerId, Owner.Name, TwilioSF__Date_Sent__c, TwilioSF__Date_Created__c, TwilioSF__To_Number__c, TwilioSF__From_Number__c
                                                        FROM TwilioSF__Message__c
                                                        WHERE TwilioSF__Contact__r.AccountId = :ct2.AccountId 
                                                        ORDER BY TwilioSF__Date_Created__c DESC];
        system.assertEquals(2, allMessageList.size()); 
    }


}