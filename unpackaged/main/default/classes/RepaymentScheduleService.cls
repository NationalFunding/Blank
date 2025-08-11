/**
 * RepaymentScheduleService class
 * @author CloudMyBiz (r)
 * @date 3/22/2022
 * @description
 * @group 
 */

global inherited sharing class RepaymentScheduleService{
    
    public static cmbls__Repayment_Schedule__c validateNextPaymentDate(cmbls__Repayment_Schedule__c record){
        if(!cmbls.DatetimeUtils.isValidDate(record.cmbls__Next_Payment_Date__c, record.cmbls__ACH_Processor__c)){
            record.cmbls__Next_Payment_Date__c = cmbls.DatetimeUtils.getNextValidDate(record.cmbls__Next_Payment_Date__c, record.cmbls__ACH_Processor__c);
        }
        return record;
    }
    
    public static cmbls__Repayment_Schedule__c createRepaymentScheduleFromInvocable(CreateRepaymentSchedule.CreateRequest mainRequest){
        Set<Date> holidays = cmbls.DatetimeUtils.getAllHolidays();
        cmbls__Repayment_Schedule__c record = new cmbls__Repayment_Schedule__c(
            cmbls__Repayment__c = mainRequest.repaymentId,
            cmbls__Start_Date__c = getPreviousValidDate(mainRequest.expectedFirstPaymentDate, holidays),
            cmbls__Next_Payment_Date__c = cmbls.DatetimeUtils.getNextValidDate(mainRequest.expectedFirstPaymentDate),
            cmbls__End_Date__c = mainRequest.endDate,
            cmbls__Preset__c = mainRequest.paymentFrequency,
            cmbls__Days__c = mainRequest.day,
            cmbls__Active__c = true,
            cmbls__Default__c = mainRequest.isDefault,
            cmbls__Installment_Amount__c = mainRequest.paymentAmount,
            cmbls__Notes__c = mainRequest.notes
        );
        Database.insert(record);
        return record;
    }
    
    @TestVisible private static Date getPreviousValidDate(Date compareDate, Set<Date> holidays){
        compareDate = compareDate.addDays(-1);
        return cmbls.DatetimeUtils.isValidDate(compareDate, holidays) ? compareDate : getPreviousValidDate(compareDate, holidays);
    }
}