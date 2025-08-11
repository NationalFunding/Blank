/**
 * IntercompanyTransactionHandler class
 * @author CloudMyBiz (r)
 * @date 2/13/2023
 * @description Follows the One Trigger Per Object design pattern, which allows for the control of execution order and recursion.
 * Ideally, business logic should not be included in this class. Trigger handlers are used to control recursion and order of execution and should delegate other work to service classes.
 * @group Trigger Handlers
 */
public inherited sharing class IntercompanyTransactionHandler{

    @TestVisible private static final String PAID_STATUS = 'Paid';
    @TestVisible private static final String PAID_TYPE = 'Paid Intercompany Transaction';
    @TestVisible private static final String NATIONAL_FUNDING = 'National Funding';

    public static void onAfterInsertUpdate(cmbls__Intercompany_Transaction__c[] records, Map<Id, cmbls__Intercompany_Transaction__c> oldRecords){
        Additional_GL_Transaction__c[] recordsToCreate = new Additional_GL_Transaction__c[]{};
        Map<Id, Additional_GL_Transaction__c> existingRecords = getAdditionalGLTransactionsByIntercompanyTransactionId(records);
        Map<Id, cmbls__Intercompany_Transaction__c> inTransactionMap = new Map<Id, cmbls__Intercompany_Transaction__c>(records);
        List<cmbls__Intercompany_Transaction__c> interCompanyToClone = new List<cmbls__Intercompany_Transaction__c>();
        List<cmbls__Intercompany_Transaction__c> interCompanyToInsert = new List<cmbls__Intercompany_Transaction__c>();
        List<cmbls__Intercompany_Transaction__c> interCompanyToUpdate = new List<cmbls__Intercompany_Transaction__c>();

        for(cmbls__Intercompany_Transaction__c record : [
                SELECT Name, cmbls__Amount__c, cmbls__Disbursement__c, cmbls__Loan_Transfer_Summary__c, cmbls__Payee__c,
                        cmbls__Payer__c, cmbls__Status__c, Payee_Cash_GL__c, Payee_Intercompany__c, Payer_Cash_GL__c,
                        Payer_Intercompany__c, Posted_To_Accounting__c, Payment__c, Date_Paid__c, NF_to_NFAS2_Transfer__c,
                        Payee_Cash_GL_NFAS2__c, Payer_Cash_GL_NFAS2__c, Date_Paid_Formula__c, GL_Date__c, LoanNumber__c,
                        Repayment__c,Notes__c, cmbls__Payer__r.Name, cmbls__Payee__r.Name
                FROM cmbls__Intercompany_Transaction__c WHERE Id IN: inTransactionMap.keySet()]
        ){

            if(oldRecords != null && shouldCreateAdditionalGLRecord(record, oldRecords.get(record.Id), existingRecords)){
                recordsToCreate.add(new Additional_GL_Transaction__c(
                        Intercompany_Transaction__c = record.Id,
                        Type__c = PAID_TYPE
                ));
            }
            if(oldRecords == null && record.cmbls__Payer__c != null && record.cmbls__Payee__c != null &&
                    record.cmbls__Payee__r.Name != NATIONAL_FUNDING && record.cmbls__Payer__r.Name != NATIONAL_FUNDING){
                interCompanyToClone.add(record);
            }
        }
        if(!interCompanyToClone.isEmpty()){
            List<cmbls__Fund__c> fundNational = [SELECT Id FROM cmbls__Fund__c WHERE Name = : NATIONAL_FUNDING LIMIT 1];
            Map<Id, cmbls__Intercompany_Transaction__c> clonedInterCompany = new Map<Id, cmbls__Intercompany_Transaction__c>();
            if(!fundNational.isEmpty()){
                for(cmbls__Intercompany_Transaction__c record : interCompanyToClone){
                    cmbls__Intercompany_Transaction__c nationalInterCompany = record.clone(false);
                    nationalInterCompany.Notes__c = 'Cloned ' + record.Id + ' to have National Funding as the intermediary Entity';
                    nationalInterCompany.cmbls__Payer__c = fundNational[0].Id;
                    interCompanyToInsert.add(nationalInterCompany);
                    clonedInterCompany.put(record.Id, nationalInterCompany);
                }
                insert interCompanyToInsert;

                for(cmbls__Intercompany_Transaction__c record : interCompanyToClone){
                    record.cmbls__Payee__c = fundNational[0].Id;
                    record.Notes__c = 'Updated Payee to have National Funding as the intermediary Entity and created ' + clonedInterCompany.get(record.Id).Id;
                    interCompanyToUpdate.add(record);
                }
            }
        }

        insert recordsToCreate;
        update interCompanyToClone;

    }

    private static Map<Id, Additional_GL_Transaction__c> getAdditionalGLTransactionsByIntercompanyTransactionId(cmbls__Intercompany_Transaction__c[] records){
        Set<Id> parentIds = new Map<Id, cmbls__Intercompany_Transaction__c>(records).keySet();
        Map<Id, Additional_GL_Transaction__c> output = new Map<Id, Additional_GL_Transaction__c>();
        for(Additional_GL_Transaction__c item :[SELECT Id, Intercompany_Transaction__c FROM Additional_GL_Transaction__c WHERE Intercompany_Transaction__c IN :parentIds AND Type__c = :PAID_TYPE]){
            output.put(item.Intercompany_Transaction__c, item);
        }
        return output;
    }

    private static Boolean shouldCreateAdditionalGLRecord(cmbls__Intercompany_Transaction__c record, cmbls__Intercompany_Transaction__c oldRecord, Map<Id, Additional_GL_Transaction__c> existingRecords){
        return  !existingRecords.containsKey(record.Id) &&
                oldRecord.cmbls__Status__c != record.cmbls__Status__c &&
                record.cmbls__Status__c == PAID_STATUS;

    }
}