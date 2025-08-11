/**
 * Created by oporter on 12/5/2017.
* ─────────────────────────────────────────────────────────────────────────────────────────────────
* TITLE: AutomatedCreditStart
* DESCRIPTION: Automated Credit Project Phase 1. Class is called by trigger, creates a new Credit Review and calls CreditReviewScreenController
*
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Olivia Porter       <oporter@nationalfunding.com>
* @modifiedBy     Olivia Porter       <oporter@nationalfunding.com>
* @maintainedBy   Olivia Porter       <oporter@nationalfunding.com>
* @version        3.0
* @created        2018-04-06
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* v1              oporter@nationalfunding.com
* 2017-02-13      Explanation of the change.  Multiple lines can be used to explain the change, but
*                 each line should be indented till left aligned with the previous description text.
*
* v2              oporter@nationalfunding.com
* 2018-04-06      Removed Static variables to fix bug. Bug was causing incorrect association of OCRs to Opportunties.
*                 Bulkified code.
*
* v3              oporter@nationalfunding.com
* 2018-04-20      Removed call to CreditReviewScreenController
*                 Took necessary code from CreditReviewScreen Controller and implemented within this class
*                 to minimize the amount of time we exceed gov limits. Currently we can bulk process 16 Opportunities 
*
* v4 			  aburdick@nationalfunding.com
* 2021-02-04 	  Added logic to update Opportunity Stage to PreQual under certain conditions.
*/

public class AutomatedCreditStart {

    //Creates Credit Review record associated to newly created Opportunity
    @InvocableMethod
    public static void automatedClass(List<Id> oppStatementsIn) {
        List<Credit_Review__c> crList = new List<Credit_Review__c>();
        System.debug('Total Number of SOQL Queries allowed in this apex code context: ' +  Limits.getLimitQueries());
        System.debug('Returns the number of SOQL queries that have been issued.: ' +  Limits.getQueries());
        system.debug('oppStatementsIn:: ' + oppStatementsIn + ', oppStatementsIn.count():: ' + oppStatementsIn.size());

        //for every opportunity that was passed we instantiate new pgs, Credit_Review__c object,
        for (Opportunity o : [SELECT AccountId, Broker_Preferred_Email__c, OwnerId, Owner.Email, (SELECT Id, ContactId, Role FROM OpportunityContactRoles), (SELECT Id FROM Credit_Reviews__r) FROM Opportunity WHERE Id IN :oppStatementsIn]) {
            Id pg1, pg2, pg3;
            Credit_Review__c obj;

            try {
                if (o.Credit_Reviews__r == NULL || o.Credit_Reviews__r.size() == 0) {
                    obj = new Credit_review__c();
                    obj.Credit_Review_Version__c = 'Version 2';
                    obj.Account__c = o.AccountId;
                    obj.Opportunity__c = o.Id;
                    obj.Status__c = 'In Progress';
                    obj.Create_WC_Decision_Record__c = 'Ready';
                    obj.AutomatedCreditProcess__c = TRUE;
                    obj.Broker_Preferred_Email__c = o.Broker_Preferred_Email__c;
                    obj.Opportunity_Owner_Email__c = o.Owner.Email;
                    for (OpportunityContactRole ocr : o.OpportunityContactRoles) {
                        if (ocr.Role == 'Signor') {
                            pg1 = ocr.ContactId;
                        } else if (ocr.Role == 'Guarantor 2') {
                            pg2 = ocr.ContactId;
                        } else if (ocr.Role == 'Guarantor 3') {
                            pg3 = ocr.ContactId;
                        }
                    }
                    obj.PG1__c = pg1;
                    obj.PG2__c = pg2;
                    obj.PG3__c = pg3;
                    crList.add(obj);
                } else {
                    system.debug('cr is NOT NULL');
                }
            } catch (Exception e) {
                system.debug('Credit Review in Automated Process Catch:: ' + e);
                //todo:: why are we eating this exception?
            }
        }

        if (!crList.isEmpty()) {
            insert crList;

            for (Credit_Review__c cr : crList) {
                funderInsert(cr);
                callAutomationFlow(cr);
            }
        }
    }

    public static void funderInsert(Credit_Review__c cr) {
        Id profileId = UserInfo.getProfileId();
        String profileName = [SELECT Id,Name FROM Profile WHERE Id = :profileId].Name;

        // Count number of lenders already for this account so we can set lender position correctly
        AggregateResult AR = [SELECT Count(id) tot FROM FPC_Funding_del__c WHERE Opportunity__c = :cr.Opportunity__c];

        // retrieve lender account
        Account lender = [SELECT Id FROM Account WHERE Name = 'National Funding - Platinum WC Funding' LIMIT 1];
        FPC_Funding_del__c fd = new FPC_Funding_del__c(Opportunity__c = cr.Opportunity__c);
        fd.Lender_ID__c = lender.id;
        fd.Lender_Position__c = (Decimal) AR.get('tot') + 1;
        fd.Status__c = 'Submitted';
        insert fd;

        //update CR with newly created funding record
        cr.Related_Funding_Record__c = fd.id;
        cr.Review_Type__c = 'Platinum Review';

        if (profileName != 'NF Partner - Brokers') {
            Id crOwnerId = [SELECT CaseSafe_User_Id__c FROM User WHERE User_Developer_Name__c = 'NF_Automation_User'].Id;
            cr.OwnerId = crOwnerId;
        }
        update cr;
        
        // Update Opportunity Stage to PreQual if record type is Direct and New or Type <> Not New and Config set to true
        Apex_Configuration__mdt config = [SELECT Active__c, DeveloperName, Label FROM Apex_Configuration__mdt WHERE DeveloperName = 'AutomatedCreditStart_Update_Opp_Stage'];
        Opportunity opp = [SELECT RecordTypeId, Type FROM Opportunity WHERE Id = :cr.Opportunity__c];
        RecordType opprt = [SELECT Id, DeveloperName From RecordType WHERE Id = :opp.RecordTypeId];
        
        if (((opprt.DeveloperName == 'MCA_Oppty' && opp.Type == 'NEW') || opp.Type == 'RENEWAL' || opp.Type == 'CONCURRENT' || opp.Type == 'RENEWAL CONCURRENT') && config.Active__c == TRUE){
            opp.StageName = 'Pre-Qual MCA';
        } else {
            system.debug('Opportunity not eligible to update stage to PreQual. Type ='+ opp.Type);
        }
        update opp; 
    }
    
        
    public static void callAutomationFlow(Credit_Review__c cr){
        Opportunity oppData = [SELECT RecordTypeId, Type, StageName FROM Opportunity WHERE Id = :cr.Opportunity__c];
        RecordType rt = [SELECT Id, DeveloperName From RecordType WHERE Id = :oppData.RecordTypeId];

        System.debug('callAutomationFlow:: Total Number of SOQL Queries allowed in this apex code context: ' + Limits.getLimitQueries());
        System.debug('callAutomationFlow:: Returns the number of SOQL queries that have been issued.: ' + Limits.getQueries());

        //publishing Platform Event
        //CRC3AutomationPlatformEvents.createPlatformEvent(cr, oppData, rt);

        //passing params to flow
        Map<String, Object> params = new Map<String, Object>();
        params.put('varCRId', cr.Id);
        params.put('inputOpptyId', cr.Opportunity__c);
        params.put('inputOpptyStageName', oppData.StageName);
        params.put('varOpptyRecordType', rt.DeveloperName);
        params.put('varFundingRecordId', cr.Related_Funding_Record__c);
        params.put('varDealType', oppData.Type);
        params.put('varCRStatus', cr.Status__c);
        params.put('vareNoahCompleteDate', cr.eNoah_Review_Completed_Date__c);
        system.debug('CRC_3_Automation_AutoStart params:: ' + params);
        if(oppData.Type == 'NEW' || oppData.Type == 'New') {
            Flow.Interview.CRC_3_Automation_AutoStart automation = new Flow.Interview.CRC_3_Automation_AutoStart(params);
            automation.start();
        }
    }
}