/**
 * PauseResumeRepaymentSchedule class
 * @author CloudMyBiz (r)
 * @date 3/22/2022
 * @description Service Class. Interface between business logic and specific apex contexts such as Trigger Handlers, Controllers, Batch Classes, API etc.
 * Services generally include static methods that implement business logic. Exceptions are generally thrown for the caller to handle.
 * @group Services
 */
global with sharing class PauseResumeRepaymentSchedule{
    
    public static final String SUCCESS_MESSAGE = 'Repayment Schedule was paused successfully, will be resumed at {0}';
    public static final String ERROR_MESSAGE = 'Unable to Pause the Repayment Schedule due to the following errors: {0}';
    
    @InvocableMethod(Label='Pause & Resume Repayment Schedules' Description='Pause and resume repayment schedules.' Category='Repayment Schedule')
    global static PauseResumeResult[] mainInvocableMethod(PauseResumeRequest[] request){
        try{
            RepaymentService.pauseAndResumeRepayment(request[0].repaymentId, request[0].resumeDate);
            return new PauseResumeResult[]{new PauseResumeResult(String.format(SUCCESS_MESSAGE, new String[]{request[0].resumeDate.format()}))};
        }catch(Exception e){
            return new PauseResumeResult[]{new PauseResumeResult(String.format(ERROR_MESSAGE, new String[]{e.getMessage()}))};
        }
    }
    
    global class PauseResumeRequest{
        @InvocableVariable(Label='Repayment Id' Required=true)
        global Id repaymentId;
    
        @InvocableVariable(Label='Resume Date' Required=true Description='The date the Repayment Schedule will be re-activated')
        global Date resumeDate;
    }
    
    global class PauseResumeResult {
        @InvocableVariable(Label='Output description' Required=true)
        global String output;
    
        public PauseResumeResult(String message){
            this.output = message;
        }
    }
}