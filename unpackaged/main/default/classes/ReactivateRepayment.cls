/**
 * ReactivateRepayment class
 * @author CloudMyBiz (r)
 * @date 3/24/2022
 * @description Service Class. Interface between business logic and specific apex contexts such as Trigger Handlers, Controllers, Batch Classes, API etc.
 * Services generally include static methods that implement business logic. Exceptions are generally thrown for the caller to handle.
 * @group Services
 */
global with sharing class ReactivateRepayment{
    
    public static final String ERROR_MESSAGE = 'Unable to reactivate the Repayment due to the following errors: {0}';
    public static final String REPAYMENT_SCHEDULE_NOTE = '"Next Payment Date" reset after Repayment status updating to Active on {0}{1}';
    public static final String REPAYMENT_NOTE = 'Repayment status updated to Active on {0}{1}';
    
    @InvocableMethod(Label='Reactivate Repayment' Category='Repayment')
    global static ReactivateResult[] mainInvocableMethod(ReactivateRequest[] request){
        try{
            return new ReactivateResult[]{new ReactivateResult(RepaymentService.reactivateRepaymentFromInvocable(request.get(0)),false)};
        }catch(Exception e){
            return new ReactivateResult[]{new ReactivateResult(String.format(ERROR_MESSAGE, new String[]{e.getMessage()}), true)};
        }
    }
    
    global class ReactivateRequest {
        @InvocableVariable(Label='Repayment Id' Required=true)
        global Id repaymentId;
    
        @InvocableVariable(Label='From' Description='E.g. Case # [Case.Name]' Required=false)
        global String fromRecord;
        
        @InvocableVariable(Label='Notes' Description='E.g.: Repayment status updated to Active on [Current Date/Time] from Case: [Case.Name]' Required=false)
        global String notes;
    }
    
    global class ReactivateResult {
        @InvocableVariable(Label='Output description')
        global String output;
        
        @InvocableVariable(Label='Is Success')
        global Boolean success;
        
        public ReactivateResult(String message, Boolean hasErrors){
            this.output = message;
            this.success = !hasErrors;
        }
    }
}