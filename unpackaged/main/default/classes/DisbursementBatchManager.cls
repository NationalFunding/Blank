/**
 * DisbursementBatchManager class
 * @author CloudMyBiz (r)
 * @date 07/07/2022
 * @description
 * @group 
 */

public with sharing class DisbursementBatchManager {

    public static void resetDisbursementBatchFields(cmbls__Disbursement_Batch__c batch){
        batch.cmbls__Number_of_Transactions__c = 0;
        batch.cmbls__Number_of_Pending_Disbursements__c = 0;
        batch.cmbls__Total_Pending_Disbursement_Amount__c = 0;
        batch.cmbls__Number_of_Failed_Disbursements__c = 0;
        batch.cmbls__Total_Failed_Disbursement_Amount__c = 0;
        batch.cmbls__Total_Transaction_Amount__c = 0;
        batch.cmbls__Total_Settled_Disbursement_Amount__c = 0;
        batch.cmbls__Number_of_Settled_Disbursements__c = 0;
    }

}