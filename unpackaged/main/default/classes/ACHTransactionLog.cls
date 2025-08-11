/**
 * ACHTransactionLog class
 * @author CloudMyBiz (r)
 * @date 11/07/2022
 * @description
 * @group 
 */

public with sharing class ACHTransactionLog {

    public ACH_Transaction_Log__c log;

    public ACHTransactionLog(){
        this.log = new ACH_Transaction_Log__c();
        Database.DMLOptions dmlOptions = new Database.DMLOptions();
        dmlOptions.allowFieldTruncation = true;
        this.log.setOptions(dmlOptions);
    }

    public void setLookupField(Id recordId){
        if (recordId != null && this.log != null) {
            if (recordId.getSobjectType() == cmbls__Payment__c.getSObjectType()) {
                this.log.Payment__c = recordId;
            } else if (recordId.getSobjectType() == cmbls__Disbursement__c.getSObjectType()) {
                this.log.Disbursement__c = recordId;
            }
        }
    }

    public static List<ACH_Transaction_Log__c> getLogs(List<ACHTransactionLog> logs){
        List<ACH_Transaction_Log__c> ret = new List<ACH_Transaction_Log__c>();
        for(ACHTransactionLog achLog : logs){
            ret.add(achLog.log);
        }
        return ret;
    }

}