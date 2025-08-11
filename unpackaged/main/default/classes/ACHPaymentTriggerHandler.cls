public class ACHPaymentTriggerHandler{
    
    private List<ACH_Payment__c> achPayments;
    private Map<Id,ACH_Payment__c> oldMap;
    Set<Id> bankIds = new Set<Id>();
    Set<Id> orgBankIds  = new Set<Id>();
    
    public ACHPaymentTriggerHandler(List<ACH_Payment__c> achPayments,Map<Id,ACH_Payment__c> oldMap){
        this.achPayments = achPayments;
        this.oldMap = oldMap;
        
        if(achPayments.size()>0){
            for(ACH_Payment__c payment:achPayments){
                if(payment.Payee_Bank_Account__c != null){
                    bankIds.add(payment.Payee_Bank_Account__c);
                }
                if(payment.Organization_s_Bank_Account__c!=null){
                    orgBankIds.add(payment.Organization_s_Bank_Account__c);
                }
            }
        } 
    }
    
    /************************************************************************************************************************************************
    COMMENTED LEGACY CODE DUE TO AN INACTIVE TRIGGER
    CMB IS ACTIVATING THIS TRIGGER AGAIN TO ADD LOGIC ON PAYMENT CREATION AS PART OF FUNDINGO
    !!! THIS CODE IS THROWING ERRORS !!!!
    ************************************************************************************************************************************************
    public void updateACHPaymentFields(){
        Map<Id, Bank_Account__c> bankMap = new Map<Id, Bank_Account__c>([
            select Id, Bank_Account_Number__c, Bank_Account_Type__c
                , Bank_Name__c, Routing_Number__c, Receiving_Company_Name__c
                , Payee_s_Name__c
            from Bank_Account__c
            where Id in :bankIds
        ]);
        List<RecordType> pmtRecordTypes = [select Id, Name, SObjectType from RecordType where SObjectType = 'ACH_Payment__c'];
        Map<String, Id> recordTypeIdMap = new Map<String, Id>();
        for(RecordType rt : pmtrecordTypes){
            recordTypeIdMap.put(rt.Name, rt.Id);
        }


        for(ACH_Payment__c payment : achPayments){
            system.debug(payment.RecordType.Name);
            if(payment.RecordTypeId != null){
                if(String.valueOf(payment.RecordTypeId).equalsIgnoreCase(recordTypeIdMap.get('Broker/Internal'))){
                    if(payment.Payee_Bank_Account__c != null){
                        Bank_Account__c paymentBank = bankMap.get(payment.Payee_Bank_Account__c);
                        payment.Payee_s_Account_Type__c = (paymentBank.Bank_Account_Type__c != null ? paymentBank.Bank_Account_Type__c : '');
                        payment.Payee_s_Bank_Account_Number__c = (paymentBank.Bank_Account_Number__c != null ? paymentBank.Bank_Account_Number__c : '');
                        payment.Payee_s_Bank_Name__c = (paymentBank.Bank_Name__c != null ? paymentBank.Bank_Name__c : '');
                        payment.Payee_s_Routing_Number__c = (paymentBank.Routing_Number__c != null ? paymentBank.Routing_Number__c : '');
                        payment.Payee_s_Name__c = (paymentBank.Payee_s_Name__c != null ? paymentBank.Payee_s_Name__c : '');
                        payment.Receiving_Company_Name__c = (paymentBank.Receiving_Company_Name__c != null ? paymentBank.Receiving_Company_Name__c : '');
                    }
                }
            }
        }
    }
    public void afterInsertHandler(){
        Id brokerRecType = [select Id from RecordType where Name = 'Broker/Internal' and SObjectType = 'ACH_Payment__c' limit 1].Id;
        Map<Id, Bank_Account__c> orgBankMap = new Map<Id, Bank_Account__c>([
            select Id, Bank_Account_Number__c, Bank_Account_Type__c
                , Bank_Name__c, Routing_Number__c, National_Funding_Account__c
            from Bank_Account__c
            where Id in :orgBankIds
        ]);
        List<Bank_Account__c> nfBankAcc = [select Id from Bank_Account__c where National_Funding_Account__c = true limit 1];
        List<ACH_Payment__c> newACHPayments = new List<ACH_Payment__c>();
        if(nfBankAcc.size() == 1){
            for(ACH_Payment__c payment : achPayments){
                if(orgBankMap.get(payment.Organization_s_Bank_Account__c).National_Funding_Account__c == false){
                    ACH_Payment__c newPmt = new ACH_Payment__c();
                    newPmt.Amount__c = payment.Amount__c;
                    newPmt.Opportunity__c = payment.Opportunity__c;
                    newPmt.Organization_s_Bank_Account__c = nfBankAcc[0].Id;
                    newPmt.RecordTypeId = brokerRecType;
                    newPmt.Payee_Bank_Account__c = payment.Organization_s_Bank_Account__c;
                    newPmt.Create_ACH_File_Date__c = payment.Pay_On_This_Date__c;
                    newPmt.Pay_On_This_Date__c = HolidayUtil.INSTANCE.getNextWorkingDate(payment.Pay_On_This_Date__c);
                    newPmt.ACH_Payment__c = payment.Id;
                    newPmt.NF_Lease_Loan_Number__c = payment.NF_Lease_Loan_Number__c;
                    newPmt.Lease_or_Loan__c = payment.Lease_or_Loan__c;
                    newACHPayments.add(newPmt);
                }
            }
        }

        if(newACHPayments.size() > 0){
            insert newACHPayments;
        }
    }
    */
    
    public void autoCreateDisbursements(Map<Id,ACH_Payment__c> newMap){
        List<cmbls__Disbursement__c> disToCreate = new List<cmbls__Disbursement__c>();
        List<ACH_Payment__c> newPayments = getACHPaymentById(newMap.keySet());
        for(ACH_Payment__c pay : newPayments){
            cmbls__Disbursement__c dis = new cmbls__Disbursement__c();
            dis.cmbls__Status__c = DisbursementUtils.DISBURSEMENT_STATUS_STAGING;
            if(pay.ACH_Rejected__c){
                if(pay.ACH_Rejected_Reason__c == DisbursementUtils.DISBURSEMENT_REASON_CANCELED){
                    dis.cmbls__ACH_Processor__c = DisbursementUtils.DISBURSEMENT_PROCESSOR_WIRE;
                }else{
                    dis.cmbls__ACH_Processor__c = null;
                    dis.cmbls__Status__c = DisbursementUtils.DISBURSEMENT_PROCESSOR_REJECTED;
                    dis.ACH_Rejected_Reason__c = pay.ACH_Rejected_Reason__c;
                }
            }else{
                dis.cmbls__ACH_Processor__c = pay.Organization_s_Bank_Account__r.ACH_Processor__c;
            }
            
            dis.RecordTypeId =  DisbursementUtils.PAYMENT_RECORD_TYPE_FUNDING;
            
            if(pay.Payment_Type__c != null){
                if(pay.Payment_Type__c.contains(DisbursementUtils.DISBURSEMENT_PAYMENT_TYPE_FUNDING)){
                    dis.RecordTypeId =  DisbursementUtils.PAYMENT_RECORD_TYPE_FUNDING;
                }else if(pay.Payment_Type__c.contains(DisbursementUtils.DISBURSEMENT_PAYMENT_TYPE_COMMISSION)){
                    dis.RecordTypeId =  DisbursementUtils.PAYMENT_RECORD_TYPE_COMMISSION;
                }else if(pay.Payment_Type__c.contains(DisbursementUtils.DISBURSEMENT_PAYMENT_TYPE_PAYOFF)){
                    dis.RecordTypeId =  DisbursementUtils.PAYMENT_RECORD_TYPE_PAYOFF;
                }
            }
            
            dis.cmbls__Effective_Date__c = pay.Pay_On_This_Date__c;
            dis.cmbls__Addenda__c = pay.Opportunity__r.Account.Company_DBA__c;
            dis.Opportunity__c = pay.Opportunity__c;
            dis.cmbls__Transaction_Amount__c = pay.Amount__c;
            dis.cmbls__Bank_Account_Number__c = pay.Payee_s_Bank_Account_Number__c;
            dis.cmbls__Bank_Routing_Number__c = pay.Payee_s_Routing_Number__c;
            dis.cmbls__Bank_Account_Type__c = pay.Payee_s_Account_Type__c;
            dis.Bank_Name__c = pay.Payee_s_Bank_Name__c;
            dis.cmbls__Payee_Name__c = pay.Receiving_Company_Name__c;
            
            disToCreate.add(dis);
        }
        insert disToCreate;
    }
    
    private static ACH_Payment__c[] getACHPaymentById(Set<Id> recordIds){
        return [
            SELECT
                Id, Receiving_Company_Name__c,ACH_Rejected__c,ACH_Rejected_Reason__c,Organization_s_Bank_Account__r.ACH_Processor__c, Payment_Type__c,
                Pay_On_This_Date__c, Opportunity__r.Account.Company_DBA__c, Amount__c,Payee_s_Bank_Name__c, Payee_s_Bank_Account_Number__c,
                Payee_s_Routing_Number__c,Payee_s_Account_Type__c
            FROM ACH_Payment__c WHERE Id IN :recordIds];
    }
}