/**
 * ACHBatchManager class
 * @author CloudMyBiz (r)
 * @date 07/07/2022
 * @description
 * @group 
 */

public with sharing class ACHBatchManager {

    public static void resetACHBatchFields(cmbls__ACH_Batch__c batch){
        batch.cmbls__Number_of_Transactions__c = 0;
        batch.cmbls__Number_of_Pending_Payments__c = 0;
        batch.cmbls__Total_Pending_Payment_Amount__c = 0;
        batch.cmbls__Number_of_Failed_Payments__c = 0;
        batch.cmbls__Total_Failed_Payment_Amount__c = 0;
        batch.cmbls__Total_Transaction_Amount__c = 0;
        batch.cmbls__Total_Settled_Payment_Amount__c = 0;
        batch.cmbls__Number_of_Settled_Payments__c = 0;
    }

}