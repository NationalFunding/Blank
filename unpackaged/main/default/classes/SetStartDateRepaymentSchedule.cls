/**
 * SetStartDateRepaymentSchedule class
 * @author CloudMyBiz (r)
 * @date 5/9/2023
 * @description Service Class. Interface between business logic and specific apex contexts such as Trigger Handlers, Controllers, Batch Classes, API etc.
 * Services generally include static methods that implement business logic. Exceptions are generally thrown for the caller to handle.
 * @group Services
 */
global inherited sharing class SetStartDateRepaymentSchedule{
    
    public static final String SUCCESS_MESSAGE = 'Repayment Schedule was updated successfully';
    public static final String ERROR_MESSAGE = 'Unable to set Start Date on the Repayment Schedule due to the following errors: {0}';
    @InvocableMethod(Label='Set Start Date on Repayment Schedules' Category='Repayment Schedule')
    global static SetStartDateResult[] mainInvocableMethod(SetStartDateRequest[] request){
        SetStartDateResult[] output = new SetStartDateResult[]{};
        try{
            cmbls__Repayment_Schedule__c[] recordsToUpdate = new cmbls__Repayment_Schedule__c[]{};
            for(SetStartDateRequest item :request){
                if(item.startDate != null){
                    cmbls__Repayment_Schedule__c record = new cmbls__Repayment_Schedule__c(
                        Id = item.recordId,
                        cmbls__Start_Date__c = item.startDate,
                        cmbls__Next_Payment_Date__c = null
                    );
                    if(item.frequency == 'Weekly') record.cmbls__Days__c = DateTimeUtils.getNameOfDay(item.startDate);
                    recordsToUpdate.add(record);
                }
                output.add(new SetStartDateResult(SUCCESS_MESSAGE));
            }
            update recordsToUpdate;
        }catch(Exception e){
            output = new SetStartDateResult[]{};
            for(SetStartDateRequest item :request){
                output.add(new SetStartDateResult(String.format(ERROR_MESSAGE, new String[]{e.getMessage()})));
            }
        }
        
        return output;
    }
    
    global class SetStartDateRequest{
        @InvocableVariable(Label='Repayment Schedule > Id' Required=true)
        global Id recordId;
        
        @InvocableVariable(Label='Repayment > Loan Start Date' Required=true)
        global Date startDate;
        
        @InvocableVariable(Label='Repayment Schedule > Preset' Required=true)
        global String frequency;
    }
    
    global class SetStartDateResult {
        @InvocableVariable(Label='Output description' Required=true)
        global String output;
        
        public SetStartDateResult(String message){
            this.output = message;
        }
    }
}