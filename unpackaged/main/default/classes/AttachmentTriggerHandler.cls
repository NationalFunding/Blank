public with sharing class AttachmentTriggerHandler {
    
    public static void verfiySubmissionFiles(List<Attachment> newList) {
        
        for (Attachment attachmentRec : newList) {
            if (attachmentRec.parentId != null) {
                if(attachmentRec.parentId?.getSObjectType() == Lead.sObjectType) {
                   
                    Map<String, Object> Params = new Map<String, Object>();
                    Params.put('var_triggering_object','Attachment');
                    Params.put('var_lead_id', attachmentRec.parentId);
                    Params.put('var_attachment_id', attachmentRec.Id);

                    //create instance of Interview
                    Flow.Interview.Lead_Verify_if_Submission_Files_are_Attached leadVerifyFlow = new Flow.Interview.Lead_Verify_if_Submission_Files_are_Attached (Params);
                    //Invoke start method
                    leadVerifyFlow.start();
                }
            }
        }
    }
}