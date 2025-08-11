global with sharing class AutomatedMaturityFeesSchedule implements Schedulable{
    
    global final List<String> weekDays = new List<String>{'Monday','Tuesday','Wednesday','Thursday','Friday'};
    global void execute (SchedulableContext ctx) {
        if(weekDays.contains(DateTimeUtils.getNameOfDay(Datetime.now()))){
            List<cmbls__Payment__c> payments = new List<cmbls__Payment__c>();
            National_Funding_Settings__c nfSettings = [SELECT Id, Maturity_Default_Fee_Amount__c FROM National_Funding_Settings__c];
            
            String[] completedStatuses = new String[]{RepaymentUtils.STATUS_COMPLETE};
            for(cmbls__Completed_Repayment_Statuses__c status: cmbls__Completed_Repayment_Statuses__c.getAll().values()) completedStatuses.add(status.cmbls__Status__c);

            List<cmbls__Repayment__c> repayments = [
                SELECT Id, Maturity_Default_Fee_Amount__c, Permanent_Mod__c,
                      (SELECT Id FROM cmbls__Payments__r WHERE cmbls__Sub_Type__c =: PaymentUtils.PAYMENT_SUBTYPE_MATURITY AND cmbls__Effective_Date__c = TODAY)
                FROM cmbls__Repayment__c
                WHERE
                    cmbls__Maturity_Date__c < TODAY AND
                    cmbls__Status__c NOT IN :completedStatuses AND
                    Enable_Maturity_Default_Fees__c = TRUE
            ];
            
            for(cmbls__Repayment__c rep : repayments){
                if(rep.cmbls__Payments__r != null && rep.cmbls__Payments__r.size() == 0){
                    cmbls__Payment__c pay = new cmbls__Payment__c();
                    pay.cmbls__Repayment__c = rep.Id;
                    pay.RecordTypeId = PaymentUtils.PAYMENT_RECORD_TYPE_CREDIT_ID;
                    pay.cmbls__Effective_Date__c = Date.today();
                    pay.cmbls__Transaction_Type__c = PaymentUtils.PAYMENT_TRANSACTION_TYPE_FEE;
                    pay.cmbls__Sub_Type__c = PaymentUtils.PAYMENT_SUBTYPE_MATURITY;
                    pay.cmbls__Status__c = PaymentUtils.PAYMENT_STATUS_FEE_APPLIED;
                    pay.cmbls__Transaction_Amount__c = rep.Maturity_Default_Fee_Amount__c != null ? rep.Maturity_Default_Fee_Amount__c : nfSettings.Maturity_Default_Fee_Amount__c;
                    payments.add(pay);
                }
            }
            insert payments;
        }
    }
}