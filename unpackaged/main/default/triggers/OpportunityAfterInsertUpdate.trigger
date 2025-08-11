trigger OpportunityAfterInsertUpdate on Opportunity (after insert, after update)
{
    system.debug('OpportunityAfterInsertUpdate first run value:: ' + OpportunityAfterInsertUpdateHelperClass.firstRun);

    if(OpportunityAfterInsertUpdateHelperClass.firstRun==true)
    {
        if(Trigger.isInsert)
        {
            //create the Doc Formula record
            Doc_Formulas__c[] insertDC = new Doc_Formulas__c[0];
            for(Opportunity o: Trigger.New)
            {
                Doc_Formulas__c dc = new Doc_Formulas__c();
                dc.Opportunity_Name__c = o.Id;

                insertDC.add(dc);
            }
            insert insertDC;
        }
        else
        {
            //update the Doc Formula record by calling RecalcRoles
            Set<Id> oppIds = new Set<Id>();
            for(Opportunity o : Trigger.new)
            {
                oppIds.add(o.Id);
            }

            //this is causing SOQL gov limit issues
            //OP 2.7.18 additions - First Run Logic
            RecalcRoles.Recalc(oppIds);
        }
        OpportunityAfterInsertUpdateHelperClass.firstRun = false;
    }
}