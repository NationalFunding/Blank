trigger ContentDocumentTrigger on ContentDocument (before delete, before insert, before update, after delete, after insert, after undelete, after update) {
    switch on Trigger.operationType{
        when AFTER_INSERT, AFTER_UPDATE {
            ContentDocumentTriggerHandler.verfiySubmissionFiles(trigger.new);
        }
        when BEFORE_DELETE {
            ContentDocumentTriggerHandler.processBeforeDelete(trigger.old);
        }
        when AFTER_DELETE {
            if(ContentDocumentTriggerHandler.hasLeadsForVerification()) {
                ContentDocumentTriggerHandler.verifyLeadsAfterDeletion();
            }
        }
    }
}