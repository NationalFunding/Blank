public class CampaignDataWrapper {
    @AuraEnabled public String campaignMemberId;
    @AuraEnabled public String salesforceCampaignId;
    @AuraEnabled public String vendorReferenceId;
    @AuraEnabled public String recipientCompanyName;
    @AuraEnabled public String city;
    @AuraEnabled public String state;
    @AuraEnabled public String postalCode;
    @AuraEnabled public String responseDate;
    @AuraEnabled public String annualRevenue;
    @AuraEnabled public String salesforceLeadId;
    @AuraEnabled public String accountNumberFull;
    @AuraEnabled public String createdTs;
    @AuraEnabled public String brand;
    
    public CampaignDataWrapper(String campaignMemberId) {
        this.campaignMemberId = campaignMemberId;
    }
 
    // Required no-argument constructor
    public CampaignDataWrapper() {}
}