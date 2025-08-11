/*
    @Author - FTC
    @Created Date - 12/4/2024

    Batch class that is used for calculating the Expected Payment Amount field on the Repayment object.  This class is tested by the test
    class BatchCalcRepaymentExpectedPaymentAmtTest.cls.

    The class has an invocable method that is called from the Screen Flow:  Calculate Expected Payment Amount. The flow allows the Expected
    Payment Amount to be calculated for a specific Repayment record.  The screen flow is associated with an action button on the Repayment
    Object and the action button is added to a record page.

*/
public class BatchCalcRepaymentExpectedPaymentAmt implements Database.Batchable<sObject>, Schedulable, Database.Stateful {
    
    public List<cmbls__Repayment__c> repaymentsToProcess = new List<cmbls__Repayment__c>();
    public Integer totalRecordsProcessed = 0;
    public String batchStartTime;
    public String batchEndTime;
    public Integer errorCount = 0;
    public String errorMessage;

    public BatchCalcRepaymentExpectedPaymentAmt() {}

    public BatchCalcRepaymentExpectedPaymentAmt(List<cmbls__Repayment__c> incomingRepayments) {
        repaymentsToProcess = incomingRepayments;
    }

    public List<cmbls__Repayment__c> start(Database.BatchableContext bc) {
        if(repaymentsToProcess.isEmpty()) {
            return [SELECT Id, Expected_Payment_Amount__c, Expected_Payment_Last_Updated__c
                FROM cmbls__Repayment__c
                WHERE cmbls__Status__c in ('Active','Pause')];    
        }
        else {
            return repaymentsToProcess;
        }
    }

    public void execute(Database.BatchableContext bc, List<cmbls__Repayment__c > repayments) {
        batchStartTime = String.valueOf(System.now());
        totalRecordsProcessed += repayments.size();
        if(!repayments.isEmpty()) {
            summarizeAmortizations(repayments);
        }
    }

    public void execute(SchedulableContext scon) {
        Integer batchSize = getBatchSize() != null ? getBatchSize() : 1;
        Database.executeBatch(new BatchCalcRepaymentExpectedPaymentAmt(), batchSize);
    }

    public void finish(Database.BatchableContext bc) {
        batchEndTime = String.valueOf(System.now());
        String logMessage = 'Apex Job Id: '+ bc.getJobId() + ', Start Time: '+ batchStartTime +', End Time: '+ batchEndTime +', Total Records Processed: '+ totalRecordsProcessed +', Error Count: ' + errorCount +', Error Message: ' + errorMessage;
        NFLogger.logInfo('Batch Calculate Expected Payment Amount', logMessage);
    }

    @InvocableMethod(description='Calculate Expected Payment Amount')
    public static void calculateExpectedPaymentAmount(List<Id> repaymentIds) {
        List<cmbls__Repayment__c> repayments = [SELECT Id, Expected_Payment_Amount__c
                                                FROM cmbls__Repayment__c
                                                WHERE Id in:repaymentIds];
        Integer batchSize = getBatchSize() != null ? getBatchSize() : 1;
        Database.executeBatch(new BatchCalcRepaymentExpectedPaymentAmt(repayments), batchSize);
    }

    public void summarizeAmortizations(List<cmbls__Repayment__c> repayments) {

        Set<Id> repaymentIds = new Set<Id>();
        for (cmbls__Repayment__c repayment : repayments) {
            repaymentIds.add(repayment.Id);
        }
       
        Map<Id, double> resultsByRepaymentId = new Map<Id, double>();
        AggregateResult[] results = aggregateAmortizationPaymentAmounts(repaymentIds);
        for (AggregateResult result : results) {
            Id repaymentId = (Id) result.get('Repayment');
            double totalPaymentAmount = (double) result.get('PaymentAmount');

            resultsByRepaymentId.put(repaymentId, totalPaymentAmount);
        }

        List<cmbls__Repayment__c> repaymentsToUpdate = new List<cmbls__Repayment__c>();
        for (cmbls__Repayment__c repayment : repayments) {
            double totalExpectedPaymentAmount = 0;
            if (resultsByRepaymentId.containsKey(repayment.Id)) {
                totalExpectedPaymentAmount = resultsByRepaymentId.get(repayment.Id);
            }

            //Check if the Total Expected Amount has changed
            if (repayment.Expected_Payment_Amount__c != totalExpectedPaymentAmount) {
                repayment.Expected_Payment_Amount__c = totalExpectedPaymentAmount;
                repayment.Expected_Payment_Last_Updated__c = datetime.now();
                repaymentsToUpdate.add(repayment); 
            }
        }

        if(repaymentsToUpdate.isEmpty() == false) {
            Database.SaveResult[] saveResults = Database.update(repaymentsToUpdate, false);
            
            for(Database.SaveResult saveResult : saveResults) {
                if(saveResult.isSuccess() == false) {
                    errorCount++;
                    for(Database.Error error : saveResult.getErrors()) {
                        errorMessage += saveResult.getId() + ', ' + error.getStatusCode() + ', ' + error.getMessage() + '\n';
                    }
                }
            }
        }
    }

    private AggregateResult[] aggregateAmortizationPaymentAmounts(Set<Id> repaymentIds) {

        return [SELECT cmbls__Repayment__c Repayment, SUM(cmbls__Payment_Amount__c) PaymentAmount
                FROM cmbls__Amortization_Schedule__c
                WHERE cmbls__Date__c <= TODAY AND 
                      cmbls__Repayment__c IN :repaymentIds
                GROUP BY cmbls__Repayment__c];
    }

    private static Integer getBatchSize() {
        Automation_Custom_Settings__c automationSetting = Automation_Custom_Settings__c.getInstance();
        return Integer.valueOf(automationSetting.Repayment_Calculation_Batch_Size__c);
    }
}