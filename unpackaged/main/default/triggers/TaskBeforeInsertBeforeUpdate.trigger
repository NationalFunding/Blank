trigger TaskBeforeInsertBeforeUpdate on Task (before insert, before update) {

for(Task t:Trigger.new)
    {
        if((Trigger.isInsert && t.Status == 'Completed') || (Trigger.isUpdate && t.Status == 'Completed' && Trigger.oldmap.get(t.Id).Status != 'Completed'))
          {
               t.Date_Activity_Logged__c = Datetime.Now();
          }
     }     
}