/**
 * ReschedulePayment class
 * @author CloudMyBiz (r)
 * @date 3/24/2022
 * @description Service Class. Interface between business logic and specific apex contexts such as Trigger Handlers, Controllers, Batch Classes, API etc.
 * Services generally include static methods that implement business logic. Exceptions are generally thrown for the caller to handle.
 * @group Services
 */
global with sharing class ReschedulePayment{
    
    public static final String SUCCESS_MESSAGE = 'Canceled Payment Id: {0}, New Rescheduled Payment: {1}';
    public static final String ERROR_MESSAGE = 'Unable to reschedule the Payment due to the following errors: {0}';
    public static final String NOT_SCHEDULED_ERROR_MESSAGE = 'Payment: {0} is not in a “Scheduled” Status and cannot be rescheduled. Current Status = [{1}]';
    
    @InvocableMethod(Label='Reschedule a Payment' Category='Payment')
    global static RescheduleResult[] mainInvocableMethod(RescheduleRequest[] request){
        try{
            cmbls__Payment__c record = PaymentService.rescheduleAPaymentFromInvocable(request.get(0));
            return new RescheduleResult[]{new RescheduleResult(String.format(SUCCESS_MESSAGE, new String[]{request.get(0).paymentId, record.Id}),false)};
        }catch(Exception e){
            return new RescheduleResult[]{new RescheduleResult(String.format(ERROR_MESSAGE, new String[]{e.getMessage()}), true)};
        }
    }
    
    global class RescheduleRequest {
        @InvocableVariable(Label='Payment Id' Required=true)
        global Id paymentId;
        
        @InvocableVariable(Label='New Effective Date'  Required=true)
        global Date effectiveDate;
        
        @InvocableVariable(Label='Notes' Description='E.g. Payment canceled due to being rescheduled on [Current Date/Time] from Case: [Case.Name]' Required=false)
        global String notes;
    }
    
    global class RescheduleResult {
        @InvocableVariable(Label='Output description')
        global String output;
        
        @InvocableVariable(Label='Is Success')
        global Boolean success;
        
        public RescheduleResult(String message, Boolean hasErrors){
            this.output = message;
            this.success = !hasErrors;
        }
    }
    
    public class ReschedulePaymentException extends Exception{}
}