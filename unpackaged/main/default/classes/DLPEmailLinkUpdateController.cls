/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* TITLE: DLPEmailLinkUpdateController
* DESCRIPTION: Consumes parameters and updates leads/contacts
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         DLPEmailLinkUpdateController     <bkravitz@nationalfunding.com>
* @modifiedBy     DLPEmailLinkUpdateController     <bkravitz@nationalfunding.com>
* @maintainedBy   DLPEmailLinkUpdateController     <bkravitz@nationalfunding.com>
* @version        2.0
* @created        2017-06-01
* @modified       2018-08-17
* @systemLayer
* @see
* @see
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* v            bkravitz@nationalfunding.com
* 2017-06-01      Init to Commit
* v2            oporter@nationalfunding.com
*               added Funding Email functionality
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
public class DLPEmailLinkUpdateController {
    public List<Messaging.SingleEmailMessage> emails;
    public String tokencred = ApexPages.currentPage().getParameters().get('tokencred');
    public Id myId = ApexPages.currentPage().getParameters().get('id');
    public String data = ApexPages.currentPage().getParameters().get('data');
    public String dtype = ApexPages.currentPage().getParameters().get('ptype');
    public String email = ApexPages.currentPage().getParameters().get('email');
    public String opportunityID = ApexPages.currentPage().getParameters().get('opportunityID');
    public String redirectId {get; set;}
    private Id templateId3;
    private Id templateId;
    public Task tsk;

    public PageReference init() {
        if (dtype == 'contact') {
//            System.debug('ID ' + myId + ' TOKEN ' + tokencred + ' DATA ' + data + ' EMAIL ' + email + ' OPPORTUNITYID ' + opportunityID); //id 0033D00000NfBLMQA3 EES mYQ7vc-Pd1aeEIbH6t2t DLPES DLP Email Sent email oporter@nationalfunding.com
            Contact c = new Contact(Id = myId, Encrypted_Email_String__c = tokencred, DLP_Email_Status__c = data, Email=email);
            update c;

            Opportunity oppty;
            if(opportunityID != null){
                oppty = [SELECT StageName, Brand_Experience__c FROM Opportunity WHERE Id = :opportunityID];
            }

            String redirectId = '';
            if (data != 'DLP Drip Deactivated') {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                List<Messaging.SingleEmailMessage> lstMsgs = new List<Messaging.SingleEmailMessage>();
                mail.setSenderDisplayName(UserInfo.getName());
                mail.setTargetObjectId(c.Id);
                if (data == 'Loan Modification Email Sent') {
                    templateId = [SELECT id FROM EmailTemplate WHERE developerName = 'Loan_Modification_Request'].Id;
                    mail.setTemplateId(templateId);
                    mail.setSaveAsActivity(false);
                    lstMsgs.Add(mail);
                    //Added by 10th april 2025 for test class cover.
                    if(!Test.isRunningTest()){ 
                        Messaging.sendEmail(lstMsgs);
                    }
                    redirectId = [Select Account.Id From Contact Where Id=: c.Id].Account.Id;
                }
                else if (data == 'Funding Email Sent') {
                    // SPR-155 Template will be picked based on Branding
                    string templateName = 'DLP_Funding_Options';
                    if (oppty.Brand_Experience__c =='Quick Bridge') 
                        templateName = 'DLP_Funding_Options_QB';
                    Id templateId2 = [SELECT id FROM EmailTemplate WHERE developerName =: templateName].Id;
                    mail.setTemplateId(templateId2);
                    mail.setSaveAsActivity(false);
                    lstMsgs.Add(mail);
                    //Added by 10th april 2025 for test class cover.
                    if(!Test.isRunningTest()){ 
                        Messaging.sendEmail(lstMsgs);
                    }
                    redirectId = opportunityID + '';
                    if(oppty != null) {
                        if (oppty.StageName != 'Offer Out - MCA') {
                            oppty.StageName = 'Offer Out - MCA';
                        }
                        update oppty;
                    }
                }
                else{
                    templateId3 = [SELECT id FROM EmailTemplate WHERE Name = 'Account - DLP Request'].Id;
                    mail.setTemplateId(templateId3);
                    mail.setSaveAsActivity(false);
                    lstMsgs.Add(mail);
                    //Added by 10th april 2025 for test class cover.
                    if(!Test.isRunningTest()){ 
                        Messaging.sendEmail(lstMsgs);
                    }
                    redirectId = [Select Account.Id From Contact Where Id=: c.Id].Account.Id;

                    tsk = new Task(Subject = 'DLP Email Sent', WhoId = myId, Description = 'Request Pre-Qual and Banks', ActivityDate = date.today(), Status = 'Completed');
                    insert tsk;
                }
            }
            return new PageReference('/' + redirectId);
        }
        if (dtype == 'lead') {
            Lead l = new Lead(Id = myId, Encrypted_Email_String__c = tokencred, DLP_Email_Status__c = data);
            update l;

            if (data != 'DLP Drip Deactivated') {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                List<Messaging.SingleEmailMessage> lstMsgs = new List<Messaging.SingleEmailMessage>();
                mail.setSenderDisplayName(UserInfo.getName());
                mail.setTargetObjectId(l.Id);
                templateId3 = [SELECT id FROM EmailTemplate WHERE Name = 'Lead - DLP Email' limit 1].Id;
                mail.setTemplateId(templateId3);
                mail.setSaveAsActivity(false);
                lstMsgs.Add(mail);
                //Added by 10th april 2025 for test class cover.
                if(!Test.isRunningTest()){ 
                    Messaging.sendEmail(lstMsgs);
                }
            	Task tsk = new Task(Subject = 'DLP Email Sent', WhoId = myId, Description = 'Request Pre-Qual and Banks', ActivityDate = date.today(), Status = 'Completed');
          		insert tsk;
            	return new PageReference('/' + myId);
            }
            return new PageReference('/' + myId);
        }
        return new PageReference('/' + redirectId);
    }
}