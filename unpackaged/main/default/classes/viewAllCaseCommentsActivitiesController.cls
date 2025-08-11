/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* TITLE: viewAllCaseCommentsActivitiesController
* DESCRIPTION: this contrroller connects to viewAllCaseCommentsActivities.page and has a test class viewAllCaseCommentsActivitiesTest.cls
                this controller returns a summarized view of Case data including Activities, Comments, Twilio Messages, and Accounting History. 
                it is called from the View All button on Case
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Olivia Porter       <oporter@nationalfunding.com>
* @created        4/11/2017
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* v1              oporter@nationalfunding.com
* 0000-00-00      Explanation of the change.  Multiple lines can be used to explain the change

* v2              oporter@nationalfunding.com
* 2022-04-01      Addition of Twilio Message section
*/

global with sharing class viewAllCaseCommentsActivitiesController {
    public Id strAccountId {get;set;}
    public String strAccountName {get;set;}
    public Id currentPageId;
    public Id currentAcctPageId;
    public List<Case> caseId;
    public String caseNumber;
    public List<Case> orderedCaseList {get;set;}
    public List<Case> orderedTaskList1 {get;set;}
    public list<task> listSOSL;
    public list<task> listTask;
    public list<Case> orderedAccountingInstructions {get;set;}
    public Task[] listOftaskCaseTasks;
    public Datetime taskCreatedDate2;
    public Datetime orderedTaskListCreatedDate;
    public Id orderedTaskListId;
    public Id ogListId;
    public List<Task> orderedTaskListOP;
    public Datetime createdtaskdate;
    public List<caseInfo> caseTaskList {get;set;}
    public List<CaseCommentInfo> caseCommentList {get;set;}
    public Map<String, CaseInfo[]> dateHeader {get;set;}
    public Map<String, CaseCommentInfo[]> dateHeaderComments {get;set;}
    public Set<String> dateHeaderIds;
    public List<String> keys {get;set;}
    public List<String> keysComment {get;set;}
    public List<Account> sumNoteList;
    public String sumNote {get;set;}
    public Double offset{get{
        TimeZone tz = UserInfo.getTimeZone();
        //Milliseconds to Day
        return tz.getOffset(DateTime.now()) / (1000 * 3600 * 24.0);
    }}

    public Map<Id, List<TwilioSF__Message__c>> messageMap {get;set;}
    public List<Id> correctlySortedContactIdList {get;set;}
    public Map<Id, String> contactNameMap {get;set;}

    global class CaseInfo implements Comparable{
        public Task taskData {get;set;}
        public Case caseNumber {get;set;}

        public caseInfo(Case caseNumber, Task taskData){
            this.caseNumber = caseNumber;
            this.taskData = taskData;
        }

        global Integer compareTo(Object compareTo) {
            CaseInfo caseinfo = (CaseInfo)compareTo;
            system.debug('caseinfo: ' + caseinfo);
            Integer returnValue = 0;
            if (taskData.Date_Activity_Logged__c < caseinfo.taskData.Date_Activity_Logged__c) {
                returnValue = 1;
            } else if (taskData.Date_Activity_Logged__c > caseinfo.taskData.Date_Activity_Logged__c) {
                returnValue = -1;
            }
            system.debug('returnValue: ' + returnValue);
            return returnValue;
        }
    }

    global class CaseCommentInfo implements Comparable{
        public CaseComment commentData {get;set;}
        public Case caseNumber {get;set;}

        public caseCommentInfo(Case caseNumber, CaseComment commentData){
            this.caseNumber = caseNumber;
            this.commentData = commentData;
        }

        global Integer compareTo(Object compareTo) {
            CaseCommentInfo caseCommentInfo = (CaseCommentInfo)compareTo;
            system.debug('caseCommentInfo: ' + caseCommentInfo);
            Integer returnCommentValue = 0;
            if (commentData.CreatedDate < caseCommentInfo.commentData.CreatedDate) {
                returnCommentValue = 1;
            } else if (commentData.CreatedDate > caseCommentInfo.commentData.CreatedDate) {
                returnCommentValue = -1;
            }
            system.debug('returnCommentValue: ' + returnCommentValue);
            return returnCommentValue;
        }
    }

    public viewAllCaseCommentsActivitiesController() {
        if (ApexPages.currentPage().getParameters().get('CaseId') != null && ApexPages.currentPage().getParameters().get('CaseId') != '') {
            currentPageId = ApexPages.currentPage().getParameters().get('CaseId');
            caseId = [SELECT AccountId, CaseNumber, Account.Name, CreatedDate FROM Case WHERE Id = :currentPageId LIMIT 1];

            //collecting the data for comment and task tables
            for (Case c : caseId) {
                strAccountId = c.AccountId;
                strAccountName = c.Account.Name;
                caseNumber = c.CaseNumber;
            }
            if(strAccountId != null){
                sumNoteList = [SELECT Sum_Note__c FROM Account WHERE Id = :strAccountId];
                if(!sumNoteList.isEmpty()) {
                    sumNote = sumNoteList[0].Sum_Note__c;
                }
            }

            buildTwilioMessageView();

            orderedCaseList = [SELECT (SELECT Id, CommentBody, CreatedDate, ParentId, CreatedById, CreatedBy.Name FROM CaseComments ORDER BY CreatedDate DESC), AccountId, CaseNumber, Merchant_Number__c FROM Case WHERE AccountId = :strAccountId AND Id IN (SELECT ParentId FROM CaseComment WHERE Parent.AccountId = :strAccountId)];
            system.debug('orderedCaseList: ' + orderedCaseList);

            //OP UPDATES 1.11.17
            orderedTaskList1 = [SELECT (SELECT CreatedDate, Comments__c, OwnerId, Subject, Owner.Name, AccountId, WhatId, CreatedById, Account.Name,Date_Activity_Logged__c FROM Tasks WHERE Private__c = FALSE AND what.type = 'Case' AND (Status = 'Completed' OR Status = 'Closed') AND IsDeleted=false ORDER BY CreatedDate DESC), AccountId, CaseNumber, Merchant_Number__c FROM Case WHERE AccountId = :strAccountId ALL ROWS];
            system.debug('orderedTaskList1: ' + orderedTaskList1 );

            //reordering the list and creating a header for the TASK data
            caseTaskList = new List<CaseInfo>();
            for(Case c : orderedTaskList1){
                for(Task t : c.Tasks){
                    caseTaskList.add(new CaseInfo(c, t));
                    //taskCreatedDate = t.Date_Activity_Logged__c;
                }
            }
            caseCommentList = new List<CaseCommentInfo>();
            for(Case c : orderedCaseList){
                for(CaseComment cc : c.CaseComments){
                    caseCommentList.add(new CaseCommentInfo(c, cc));
                    //caseCreatedDate = cc.CreatedDate;
                }
            }
            caseTaskList.sort();
            caseCommentList.sort();
            dateHeader = new Map<String, CaseInfo[]>();// the caseinfo is in order but the string is not//https://developer.salesforce.com/forums/?id=906F00000008yqnIAA
            dateHeaderComments = new Map<String, CaseCommentInfo[]>();// the caseinfo is in order but the string is not//https://developer.salesforce.com/forums/?id=906F00000008yqnIAA
            system.debug('caseTaskList sorted: ' + caseTaskList);
            system.debug('caseCommentList sorted: ' + caseCommentList);

            for(CaseInfo ci : caseTaskList){
                String taskHeaderDate = ci.taskData.Date_Activity_Logged__c.format('MM-dd-YYYY', 'America/Los_Angeles');
                system.debug('taskHeaderDate: ' +taskHeaderDate );
                if(dateHeader.containsKey(taskHeaderDate)){
                    dateHeader.get(taskHeaderDate).add(ci);
                }
                else {
                    dateHeader.put(taskHeaderDate, new CaseInfo[]{ci});
                }
            }
            system.debug('dateHeader: ' + dateHeader);
            
            for(CaseCommentInfo cci : caseCommentList){
                String commentHeaderDate = cci.commentData.CreatedDate.format('MM-dd-yyyy', 'America/Los_Angeles'); //keeping this format in here so we can uncomment to ensure list is in correct Created Date order
                system.debug('commentHeaderDate: ' +commentHeaderDate);
                if(dateHeaderComments.containsKey(commentHeaderDate)){
                    dateHeaderComments.get(commentHeaderDate).add(cci);
                }
                else {
                    dateHeaderComments.put(commentHeaderDate, new CaseCommentInfo[]{cci});
                }
            }
            system.debug('dateHeaderComments: ' + dateHeaderComments);

            keys = new List<String>(dateHeader.keySet());
            keysComment = new List<String>(dateHeaderComments.keySet());

            //keys.sort(); //asc order is good so when I put it in repeat it will go to desc
            system.debug('keys: ' + keys);
            system.debug('keysComment: ' + keysComment);

            //Accounting Instructions
            List<Id> caseIds = new List<Id>();
            for(Accounting_Instructions__c actInst : [SELECT Case__c FROM Accounting_Instructions__c WHERE Case__r.AccountId = :strAccountId AND Accounting_Complete__c = TRUE]) {
                caseIds.add(actInst.Case__c);
                system.debug('caseIds: ' + caseIds);
            }
            orderedAccountingInstructions = [SELECT (SELECT Id, Action__c, Owner.Name, Other_Comments__c, CreatedDate, Type__c, Amount__c, Rerun_ACH_Date__c, Resume_ACH_Date__c FROM Accounting_Instructions__r WHERE Accounting_Complete__c = TRUE), AccountId, CaseNumber, Merchant_Number__c FROM Case WHERE AccountId = :strAccountId AND Id IN :caseIds ORDER BY CreatedDate DESC];
        }

        if (ApexPages.currentPage().getParameters().get('AcctId') != null && ApexPages.currentPage().getParameters().get('AcctId') != '') {
            currentAcctPageId = ApexPages.currentPage().getParameters().get('AcctId');
            caseId = [SELECT Id, AccountId, CaseNumber, Account.Name, CreatedDate FROM Case WHERE AccountId = :currentAcctPageId LIMIT 1];
            for (Case c : caseId) {
                strAccountName = c.Account.Name;
            }

            orderedCaseList = [SELECT (SELECT Id, CommentBody, CreatedDate, ParentId, CreatedById, CreatedBy.Name FROM CaseComments ORDER BY CreatedDate DESC), AccountId, CaseNumber, Merchant_Number__c FROM Case WHERE AccountId = :currentAcctPageId AND Id IN (SELECT ParentId FROM CaseComment WHERE Parent.AccountId = :currentAcctPageId)];

            //OP UPDATES 1.11.17
            orderedTaskList1 = [SELECT (SELECT CreatedDate, Comments__c, OwnerId, Subject, Owner.Name, AccountId, WhatId, CreatedById, Account.Name,Date_Activity_Logged__c FROM Tasks WHERE Private__c = FALSE AND what.type = 'Case' AND (Status = 'Completed' OR Status = 'Closed') ORDER BY CreatedDate DESC), AccountId, CaseNumber, Merchant_Number__c FROM Case WHERE AccountId = :currentAcctPageId];

            caseTaskList = new List<CaseInfo>(); 
            for(Case c : orderedTaskList1){
                for(Task t : c.Tasks){
                    caseTaskList.add(new CaseInfo(c, t));
                }
            }
            caseCommentList = new List<CaseCommentInfo>();
            for(Case c : orderedCaseList){
                for(CaseComment cc : c.CaseComments){
                    caseCommentList.add(new CaseCommentInfo(c, cc));
                }
            }
            caseTaskList.sort();
            caseCommentList.sort();
            dateHeader = new Map<String, CaseInfo[]>();// the caseinfo is in order but the string is not//https://developer.salesforce.com/forums/?id=906F00000008yqnIAA
            dateHeaderComments = new Map<String, CaseCommentInfo[]>();// the caseinfo is in order but the string is not//https://developer.salesforce.com/forums/?id=906F00000008yqnIAA
            system.debug('caseCommentList sorted: ' + caseCommentList);
            system.debug('caseTaskList sorted: ' + caseTaskList);

            for(CaseInfo ci : caseTaskList){
                String taskHeaderDate = ci.taskData.Date_Activity_Logged__c.format('MM-dd-YYYY', 'America/Los_Angeles');
                system.debug('taskHeaderDate: ' +taskHeaderDate );
                if(dateHeader.containsKey(taskHeaderDate)){
                    dateHeader.get(taskHeaderDate).add(ci);
                }
                else {
                    dateHeader.put(taskHeaderDate, new CaseInfo[]{ci});
                }
            }
            system.debug('dateHeader: ' + dateHeader);
            for(CaseCommentInfo cci : caseCommentList){
                String commentHeaderDate = cci.commentData.CreatedDate.format('MM-dd-YYYY', 'America/Los_Angeles');
                system.debug('commentHeaderDate: ' +commentHeaderDate);
                if(dateHeaderComments.containsKey(commentHeaderDate)){
                    dateHeaderComments.get(commentHeaderDate).add(cci);
                }
                else {
                    dateHeaderComments.put(commentHeaderDate, new CaseCommentInfo[]{cci});
                }
            }
            system.debug('dateHeaderComments: ' + dateHeaderComments);
            keys = new List<String>(dateHeader.keySet());
            keysComment = new List<String>(dateHeaderComments.keySet());

            //keys.sort(); //asc order is good so when I put it in repeat it will go to desc
            system.debug('keys: ' + keys);
            system.debug('keysComment: ' + keysComment);

            //Accounting Instructions
            List<Id> caseIds = new List<Id>();
            for(Accounting_Instructions__c actInst : [SELECT Case__c FROM Accounting_Instructions__c WHERE Case__r.AccountId = :currentAcctPageId AND Accounting_Complete__c = TRUE]) {
                caseIds.add(actInst.Case__c);
                system.debug('caseIds: ' + caseIds);
            }
            orderedAccountingInstructions = [SELECT (SELECT Id, Action__c, Owner.Name, Other_Comments__c, CreatedDate, Type__c, Amount__c, Rerun_ACH_Date__c, Resume_ACH_Date__c FROM Accounting_Instructions__r WHERE Accounting_Complete__c = TRUE), AccountId, CaseNumber, Merchant_Number__c FROM Case WHERE AccountId = :strAccountId AND Id IN :caseIds ORDER BY CreatedDate DESC];
        }
    }

    public void  buildTwilioMessageView(){
        // this is a list of messages, related to the case, grouped by the CONTACT, ordered by the SEND DATE TIME in DESC order
        Case caseAccountId = [SELECT AccountId FROM Case WHERE Id = :currentPageId];
        List<TwilioSF__Message__c> allMessageList = [SELECT TwilioSF__From_Number_Unformatted__c, TwilioSF__Direction__c, TwilioSF__To_Number_Unformatted__c, Id, Name, TwilioSF__Contact__r.Name, TwilioSF__Contact__c, TwilioSF__Body__c, Created_Date_Time__c,OwnerId, Owner.Name, TwilioSF__Date_Sent__c, TwilioSF__Date_Created__c, TwilioSF__To_Number__c, TwilioSF__From_Number__c
                                                        FROM TwilioSF__Message__c
                                                        WHERE TwilioSF__Contact__r.AccountId = :caseAccountId.AccountId 
                                                        AND Owner_Track_Twilio_Messages__c = true
                                                        ORDER BY TwilioSF__Date_Created__c DESC];

        //pull out each contact and their messages
        Map<Id, List<TwilioSF__Message__c>> messageContactMap = new Map<Id, List<TwilioSF__Message__c>>();
        Map<Id, String> nameMap = new Map<Id, String>();

        for(TwilioSF__Message__c val : allMessageList){
            if (messageContactMap.containsKey(val.TwilioSF__Contact__c)){//utilized ID because it is possible for two people with same name
                messageContactMap.get(val.TwilioSF__Contact__c).add(val);
            } else {
                List<TwilioSF__Message__c> messageList = new List<TwilioSF__Message__c>();
                messageList.add(val);
                messageContactMap.put(val.TwilioSF__Contact__c, messageList);
            }
            String name = val.TwilioSF__Contact__r.Name;
            Id contactId = val.TwilioSF__Contact__c;
            nameMap.put(contactId, name);
        }
        List<Id> contactIdConvert = new List<Id>(messageContactMap.keySet());
        correctlySortedContactIdList = contactIdConvert;
        contactNameMap = nameMap;
        messageMap = messageContactMap;   
    } 
}