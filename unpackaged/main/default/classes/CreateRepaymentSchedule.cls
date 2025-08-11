/**
 * CreateRepaymentSchedule class
 * @author CloudMyBiz (r)
 * @date 3/22/2022
 * @description Service Class. Interface between business logic and specific apex contexts such as Trigger Handlers, Controllers, Batch Classes, API etc.
 * Services generally include static methods that implement business logic. Exceptions are generally thrown for the caller to handle.
 * @group Services
 */
global with sharing class CreateRepaymentSchedule{
    
    public static final String ERROR_MESSAGE = 'Unable to create the Repayment Schedule due to the following errors: {0}';
    
    @InvocableMethod(Label='Create Repayment Schedules' Category='Repayment Schedule')
    global static CreateResult[] mainInvocableMethod(CreateRequest[] request){
        try{
            cmbls__Repayment_Schedule__c schedule = RepaymentScheduleService.createRepaymentScheduleFromInvocable(request.get(0));
            return new CreateResult[]{new CreateResult(schedule.Id, false)};
        }catch(Exception e){
            return new CreateResult[]{new CreateResult(String.format(ERROR_MESSAGE, new String[]{e.getMessage()}), true)};
        }
    }
    
    global class CreateRequest {
        @InvocableVariable(Label='Repayment Id' Required=true)
        global Id repaymentId;
        
        @InvocableVariable(Label='Expected First Payment Date OR Start Date'  Required=true)
        global Date expectedFirstPaymentDate;
    
        @InvocableVariable(Label='Payment Amount' Required=true)
        global Decimal paymentAmount;
    
        @InvocableVariable(Label='End Date' Required=false)
        global Date endDate;
    
        @InvocableVariable(Label='Preset (Payment Frequency)' Required=true)
        global String paymentFrequency;
    
        @InvocableVariable(Label='Day' Description='Possible Values:"N/A" if Daily, "Monday"-"Friday" if Weekly, "1"-"31" if Monthly' Required=true)
        global String day;
    
        @InvocableVariable(Label='Default' Required=false)
        global Boolean isDefault;
    
        @InvocableVariable(Label='Bank Account Number' Required=true)
        global String bankAccountNumber;
    
        @InvocableVariable(Label='Bank Routing Number' Required=true)
        global String bankRoutingNumber;
    
        @InvocableVariable(Label='Notes' Description='E.g. Repayment Schedule created on [Today’s Date/Time] from Case: [Case Name]' Required=false)
        global String notes;
    }
    
    global class CreateResult {
        @InvocableVariable(Label='Output description')
        global String output;
    
        @InvocableVariable(Label='Is Success')
        global Boolean success;
        
        public CreateResult(String message, Boolean hasErrors){
            this.output = message;
            this.success = !hasErrors;
        }
    }
}