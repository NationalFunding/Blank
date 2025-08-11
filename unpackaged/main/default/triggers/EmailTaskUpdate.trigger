trigger EmailTaskUpdate on EmailMessage (after insert) {
    //before insert and before update we want to save email replies to the Task Object
    Id emailTaskId;
    String emailTaskBody;
    String htmlBody;
    String htmlReplaced;

    for(EmailMessage e : Trigger.new){
        if(e.Incoming == false){
        	emailTaskId = e.ActivityId;
        	emailTaskBody = e.TextBody;
            if(e.HtmlBody != NULL) {
                htmlBody = e.HtmlBody;
                String removeTags = '<[^>]+>';
                String removeStyle = '<style([\\s\\S]+?)</style>';
                String removeBreak = '&nbsp;';
                String htmlNoCss = htmlBody.replaceAll(removeStyle, '');
                String htmlNoBreak = htmlNoCss.replaceAll(removeBreak, '');
                htmlReplaced = htmlNoBreak.replaceAll(removeTags, '');
                system.debug('e.htmlbody: ' + e.HtmlBody);
                system.debug('e.textbody: ' + e.TextBody);
                system.debug('htmlbody string: ' + htmlReplaced);
            }
        }
        if(e.Incoming == TRUE){
//			//create a new task on the current Case
			system.debug('got into incoming emailtaskupdate');
//			system.debug('htmlbody: ' + e.HtmlBody);
            //Task newTask = new Task(Subject = e.Subject, Description = e.TextBody, WhatId = e.ParentId, CreatedById = e.CreatedById, Date_Activity_Logged__c = e.MessageDate, Completed_By__c = e.CreatedById, Private__c = FALSE, Status= 'Completed', Type = 'Other', WhoId = e.CreatedById, ActivityDate = Date.today());
            Task newTask = new Task(Subject = e.Subject, Description = e.TextBody, WhatId = e.ParentId,CreatedById = e.CreatedById, Date_Activity_Logged__c = e.MessageDate, Completed_By__c = e.CreatedById, Private__c = FALSE, Status= 'Completed', Type = 'Other', ActivityDate = Date.today());
            insert newTask;
            system.debug('newTask: ' + newTask);
            system.debug('whoid: ' + newTask.WhoId);
        }
    }

    if(emailTaskId != null){
    	List<Task> emailTasks = [SELECT Id, Comments__c FROM Task WHERE Id = :emailTaskId];
    	for(Task et : emailTasks){
        	system.debug('et: ' + et);
            if(htmlBody != NULL) {
                et.Description = htmlReplaced;
            }
            else{
                et.Description = emailTaskBody;
            }
    	}
    	update emailTasks;
    	system.debug(emailTasks);
    }
}