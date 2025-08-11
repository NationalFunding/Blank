trigger LeadSendToPardot on Lead (after insert, after update) {
	if( PardotProspectController.calledFromTrigger == false ) {
		integer futureMethodCount = 0;
		for(Lead l : Trigger.New) {
			if(l.Send_To_Pardot__c == true) {
				PardotProspectController.SendInfoToPardot(l.Email, l.Id, Userinfo.getSessionId());
				futureMethodCount++;
				if( futureMethodCount == 10 ) {
					break;
				}
			}
		}
	}
}