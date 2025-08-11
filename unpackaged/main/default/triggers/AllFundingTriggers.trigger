/****************************************************************  
    Trigger:        AllFundingTriggers
    Description:    after the insert of a Funding record, we want to create and associate a Calculator Link
    Author:         Olivia Porter
    Date:           6/21/2018
    Revision History:
        --> removed unnecessary update, delete, and before logic 12/16/21
****************************************************************/


trigger AllFundingTriggers on FPC_Funding_del__c (before insert, after insert) {

    if( Trigger.isInsert ){
        if(Trigger.isAfter) {
            OnlineSalesCalculator osc = new OnlineSalesCalculator();
            osc.onlineCalculatorShortenedLink(Trigger.newMap, Trigger.oldMap);
        }
    }
}