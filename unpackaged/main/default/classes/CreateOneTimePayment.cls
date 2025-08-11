/**
 * CreateOneTimePayment class
 * @author CloudMyBiz (r)
 * @date 3/24/2022
 * @description Service Class. Interface between business logic and specific apex contexts such as Trigger Handlers, Controllers, Batch Classes, API etc.
 * Services generally include static methods that implement business logic. Exceptions are generally thrown for the caller to handle.
 * @group Services
 */
global with sharing class CreateOneTimePayment{
    
    public static final String ERROR_MESSAGE = 'Unable to create the Payment due to the following errors: {0}';
    
    @InvocableMethod(Label='Create a one time payment' Category='Payment')
    global static CreateResult[] mainInvocableMethod(CreateRequest[] request){
        try{
            cmbls__Payment__c record = PaymentService.createOneTimePaymentFromInvocable(request.get(0));
            return new CreateResult[]{new CreateResult(record.Id, false)};
        }catch(Exception e){
            return new CreateResult[]{new CreateResult(String.format(ERROR_MESSAGE, new String[]{e.getMessage()}), true)};
        }
    }
    
    global class CreateRequest {
        @InvocableVariable(Label='Repayment Id' Required=true)
        global Id repaymentId;
        
        @InvocableVariable(Label='Effective Date'  Required=true)
        global Date effectiveDate;
        
        @InvocableVariable(Label='Transaction Amount' Required=true)
        global Decimal transactionAmount;
        
        @InvocableVariable(Label='Sub Type' Required=false)
        global String subType;
        
        @InvocableVariable(Label='ACH Processor' Required=false)
        global String achProcessor;
        
        @InvocableVariable(Label='Notes' Description='E.g. Payment scheduled on [Current Date/Time] from Case: [Case.Name]' Required=false)
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