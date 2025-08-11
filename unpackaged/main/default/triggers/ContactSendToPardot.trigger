trigger ContactSendToPardot on Contact (after insert, after update) {
	if( PardotProspectController.calledFromTrigger == false ) {
		integer futureMethodCount = 0;
		for(Contact c : Trigger.New) {
			if(c.Send_To_Pardot__c == true) {
				PardotProspectController.SendInfoToPardot(c.Email, c.Id, Userinfo.getSessionId());
				futureMethodCount++;
				if( futureMethodCount == 10 ) {
					break;
				}
			}
		}
	}
}