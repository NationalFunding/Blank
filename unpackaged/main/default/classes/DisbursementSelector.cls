/**
 * DisbursementSelector class
 * @author CloudMyBiz (r)
 * @date 8/11/2022
 * @description Service Class. Interface between business logic and specific apex contexts such as Trigger Handlers, Controllers, Batch Classes, API etc.
 * Services generally include static methods that implement business logic. Exceptions are generally thrown for the caller to handle.
 * @group Services
 */
public inherited sharing class DisbursementSelector{

    public static cmbls__Disbursement__c[] getStagingDisbursementsForGivenOpportunities(Set<Id> opportunityIds){
        return [
            SELECT Id, Opportunity__c
            FROM cmbls__Disbursement__c
            WHERE cmbls__Status__c = :DisbursementUtils.DISBURSEMENT_STATUS_STAGING AND
            Opportunity__c IN :opportunityIds
        ];
    }
}