/**
 * UpdateBankingInformation class
 * @author CloudMyBiz (r)
 * @date 3/25/2022
 * @description Service Class. Interface between business logic and specific apex contexts such as Trigger Handlers, Controllers, Batch Classes, API etc.
 * Services generally include static methods that implement business logic. Exceptions are generally thrown for the caller to handle.
 * @group Services
 */
global with sharing class UpdateBankingInformation{
    public static final String ERROR_MESSAGE = 'Unable to update Banking Information due to the following errors: {0}';
    public static final String NOTE =   'Banking Information Update on {0}{1}. Prior Bank Name: {2}, ' +
                                        'Prior Bank Routing: {3}, Prior Bank Account Number {4}. Updated Bank Name {5}, ' +
                                        'Bank Routing {6}, Updated Bank Account Number {7}\n\n';
    public static final String OUTPUT = 'Updated Repayment Id: {0}, Updated Repayment Schedules: ({1}) [{2}], Updated Payments: ({3}) [{4}]';
    
    @InvocableMethod(Label='Update Banking Information' Category='Repayment')
    global static UpdateResult[] mainInvocableMethod(UpdateRequest[] request){
        try{
            return new UpdateResult[]{new UpdateResult(RepaymentService.updateBankingInformationFromInvocable(request.get(0)), false)};
        }catch(Exception e){
            return new UpdateResult[]{new UpdateResult(String.format(ERROR_MESSAGE, new String[]{e.getMessage()}), true)};
        }
    }
    
    global class UpdateRequest {
        @InvocableVariable(Label='Repayment Id' Required=true)
        global Id repaymentId;
        
        @InvocableVariable(Label='Updated Bank Name' Required=true)
        global String bankName;
    
        @InvocableVariable(Label='Updated Bank Account Number' Required=true)
        global String bankAccountNumber;
    
        @InvocableVariable(Label='Updated Bank Routing Number' Required=true)
        global String bankRoutingNumber;
    
        @InvocableVariable(Label='Updated Bank Account Type' Required=true)
        global String bankAccountType;
        
        @InvocableVariable(Label='Update Banking Information for Scheduled Payments?' Required=false)
        global Boolean updateScheduledPayments;
        
        @InvocableVariable(Label='Update any Banking Information Overrides on Repayment Schedule?' Required=false)
        global Boolean updateRepaymentSchedules;
        
        @InvocableVariable(Label='Notes' Description='E.g. Payment scheduled on [Current Date/Time] from Case: [Case.Name]' Required=false)
        global String notes;
    
        @InvocableVariable(Label='From' Description='E.g. Case # [Case.Name]' Required=false)
        global String fromRecord;
    }
    
    global class UpdateResult {
        @InvocableVariable(Label='Output description')
        global String output;
        
        @InvocableVariable(Label='Is Success')
        global Boolean success;
        
        public UpdateResult(String message, Boolean hasErrors){
            this.output = message;
            this.success = !hasErrors;
        }
    }
}