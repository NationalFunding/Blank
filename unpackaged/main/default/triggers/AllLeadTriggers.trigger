trigger AllLeadTriggers on Lead (before insert, after insert, before update, after update, before delete, after delete) {

    if (Trigger.isBefore) {
        if (Trigger.isInsert) {

            lead_isSSNBlankHelper ssnBlank= new lead_isSSNBlankHelper();
            ssnBlank.isLeadSSNBlank(Trigger.new);

            LeadDeDuplicationHelper ldh = new LeadDeDuplicationHelper();
            ldh.handleDuplicates(Trigger.new);
        } 
        if (Trigger.isUpdate) {

            lead_isSSNBlankHelper ssnBlank= new lead_isSSNBlankHelper();
            ssnBlank.isLeadSSNBlank(Trigger.new);

          } 
        if (Trigger.isDelete) {
            // ** Call class logic here! **
          } 
    } else if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            // ** Call class logic here! **
        } 
        if (Trigger.isUpdate) {
          // ** Call class logic here! **
        }
        if (Trigger.isDelete) {
          // ** Call class logic here! **
        }
    }
}