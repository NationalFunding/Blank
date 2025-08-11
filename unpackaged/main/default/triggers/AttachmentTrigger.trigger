trigger AttachmentTrigger on Attachment (before delete, before insert, before update, after delete, after insert, after undelete, after update) {

    switch on Trigger.operationType{
        when AFTER_INSERT{
            AttachmentTriggerHandler.verfiySubmissionFiles(trigger.new);
        }
        when AFTER_DELETE {
            AttachmentTriggerHandler.verfiySubmissionFiles(trigger.old);
        }
    }
}