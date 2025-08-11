/**
 * BatchGenerateFunasAmortization class
 * @author CloudMyBiz (r)
 * @date 14/06/2022
 * @info If you use a QueryLocator object, the governor limit for the total number of records retrieved by SOQL queries is bypassed
 * Use the iterable to create a complex scope for the batch job. You can also use the iterable to create your own custom process for iterating through the list.
  (If you use an iterable, the governor limit for the total number of records retrieved by SOQL queries is still enforced.)
 * @group Batch
 */
global with sharing class BatchGenerateFunasAmortization implements Database.Batchable<SObject>, Database.AllowsCallouts, Schedulable{

    global BatchGenerateFunasAmortization() {}

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([SELECT Id, Name, cmbls__Current_Interest_Rate__c, cmbls__Funding_Amount__c,
                cmbls__Loan_Start_Date__c, cmbls__Payment_Amount__c, cmbls__Next_Invoice_Date__c,
                cmbls__Interest_Accrual_Method__c, cmbls__Interest_Accrual_Frequency__c,
        (SELECT Id, cmbls__Invoice_Date__c, cmbls__Total__c FROM cmbls__Invoices__r WHERE Omit_From_FUNAS_Auto_Generation__c = FALSE)
        FROM cmbls__Repayment__c
        WHERE Generate_FUNAS_Amortization_Schedule__c = TRUE]);
    }

    global void execute(Database.BatchableContext bc, List<cmbls__Repayment__c> scope) {

        Map<String, funas__Amortization_Schedule_Setup__c> mapAmortizationScheduleSetupsByRepayment = FunasAmortizationScheduleService.getAmortizationScheduleSetup(scope);
        Map<String, List<funas__Amortization_Schedule_Event__c>> mapAmortizationScheduleEvents = FunasAmortizationScheduleService.getAmortizationScheduleEvents(scope);

        List<cmbls__Amortization_Schedule__c> amortizationSchedules = new List<cmbls__Amortization_Schedule__c>();
        for(cmbls__Repayment__c repayment : scope){
            // Get FunasDTO in order to call the service.
            FunasDTO.FunasSetup funasDTOSetup = new FunasDTO.FunasSetup(mapAmortizationScheduleSetupsByRepayment.get(repayment.Name), mapAmortizationScheduleEvents.get(repayment.Name));
            funasDTOSetup.targetObjectId = repayment.Id;
            String amortSchedulesStr = FunasAmortizationScheduleService.calculateFunasAmortization(JSON.serialize(new List<FunasDTO.FunasSetup>{funasDTOSetup}));
            amortizationSchedules.addAll(FunasAmortizationScheduleService.parseAmortizationSchedules(amortSchedulesStr, repayment));
        }

        FunasAmortizationScheduleService.deleteAmortizationScheduleByParent(scope);
        // Insert amortization returned by Funas package.
        insert amortizationSchedules;

        // Update Repayments to avoid being pulled again by the next job's run.
        update scope;
    }

    global void finish(Database.BatchableContext bc) {}

    /* Schedulable method */
    public void execute(SchedulableContext SC) {
        Database.executeBatch(new BatchGenerateFunasAmortization(), 10);
    }

}