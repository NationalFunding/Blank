public with sharing class ContentDocumentTriggerHandler {
    private static Set<Id> leadsForVerification = new Set<Id>();


    public static void verfiySubmissionFiles(List<ContentDocument> newList) {

         Set<Id> contentDocumentIds = new Set<Id>();
         for (ContentDocument cd : newList) {
             contentDocumentIds.add(cd.Id);
         }

        List<ContentDocumentLink> contentDocLinks = [
            SELECT Id, ContentDocumentId, LinkedEntityId
            FROM ContentDocumentLink
            WHERE ContentDocumentId IN :contentDocumentIds
        ];

        for (ContentDocumentLink cdl : contentDocLinks) {
            if(cdl.LinkedEntityId?.getSObjectType() == Lead.sObjectType) {
                Map<String, Object> Params = new Map<String, Object>();
                Params.put('var_triggering_object','ContentDocumentLink');
                Params.put('var_lead_id', cdl.LinkedEntityId);
                Params.put('var_content_document_link_id', cdl.Id);
                //create instance of Interview
                Flow.Interview.Lead_Verify_if_Submission_Files_are_Attached leadVerifyFlow = new Flow.Interview.Lead_Verify_if_Submission_Files_are_Attached (Params);
                //Invoke start method
                leadVerifyFlow.start();
            }
        }
    }

    public static void processBeforeDelete(List<ContentDocument> oldList) {
        // Clear the static set before processing
        leadsForVerification.clear();
        
        // Collect all ContentDocument Ids that are about to be deleted
        Set<Id> contentDocumentIds = new Set<Id>();
        for (ContentDocument cd : oldList) {
            contentDocumentIds.add(cd.Id);
        }
        
        // Find all Lead records that have these documents linked
        List<ContentDocumentLink> contentDocLinks = [
            SELECT Id, ContentDocumentId, LinkedEntityId
            FROM ContentDocumentLink
            WHERE ContentDocumentId IN :contentDocumentIds
        ];
        
        for (ContentDocumentLink cdl : contentDocLinks) {
            if(cdl.LinkedEntityId?.getSObjectType() == Lead.sObjectType) {
                leadsForVerification.add(cdl.LinkedEntityId);
            }
        }
    }

    public static void verifyLeadsAfterDeletion() {
        if(leadsForVerification.isEmpty()) {
            return;
        }
        
        // For each Lead, invoke the flow to verify submission files
        for(Id leadId : leadsForVerification) {
            Map<String, Object> params = new Map<String, Object>();
            params.put('var_triggering_object', 'ContentDocumentDelete');
            params.put('var_lead_id', leadId);
            // No ContentDocumentLink ID to pass since it's been deleted
            
            Flow.Interview.Lead_Verify_if_Submission_Files_are_Attached leadVerifyFlow = 
                new Flow.Interview.Lead_Verify_if_Submission_Files_are_Attached(params);
            leadVerifyFlow.start();
        }
        
        // Clear the set after processing
        leadsForVerification.clear();
    }

    // Helper methods to access the static variable, useful for testing and the trigger
    public static Set<Id> getLeadsForVerification() {
        return leadsForVerification;
    }
    
    public static boolean hasLeadsForVerification() {
        return !leadsForVerification.isEmpty();
    }
}