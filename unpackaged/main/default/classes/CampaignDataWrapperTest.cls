@IsTest
private class CampaignDataWrapperTest {
    
    @IsTest
    static void testDefaultConstructorAndSetFields() {
        CampaignDataWrapper wrapper = new CampaignDataWrapper();
        
        // Set all fields
        wrapper.campaignMemberId = 'CM123';
        wrapper.salesforceCampaignId = '701XX0000001234';
        wrapper.vendorReferenceId = 'VENDOR-001';
        wrapper.recipientCompanyName = 'Acme Corp';
        wrapper.city = 'San Francisco';
        wrapper.state = 'CA';
        wrapper.postalCode = '94105';
        wrapper.responseDate = '2024-10-15';
        wrapper.annualRevenue = '1000000';
        wrapper.salesforceLeadId = '00QXX0000001234';
        wrapper.accountNumberFull = 'ACC-001234';
        wrapper.createdTs = '2024-10-10T12:00:00Z';
        wrapper.brand = 'BrandX';
        
        // Assertions
        System.assertEquals('CM123', wrapper.campaignMemberId);
        System.assertEquals('701XX0000001234', wrapper.salesforceCampaignId);
        System.assertEquals('VENDOR-001', wrapper.vendorReferenceId);
        System.assertEquals('Acme Corp', wrapper.recipientCompanyName);
        System.assertEquals('San Francisco', wrapper.city);
        System.assertEquals('CA', wrapper.state);
        System.assertEquals('94105', wrapper.postalCode);
        System.assertEquals('2024-10-15', wrapper.responseDate);
        System.assertEquals('1000000', wrapper.annualRevenue);
        System.assertEquals('00QXX0000001234', wrapper.salesforceLeadId);
        System.assertEquals('ACC-001234', wrapper.accountNumberFull);
        System.assertEquals('2024-10-10T12:00:00Z', wrapper.createdTs);
        System.assertEquals('BrandX', wrapper.brand);
    }
    
    @IsTest
    static void testConstructorWithId() {
        String testId = 'CM456';
        CampaignDataWrapper wrapper = new CampaignDataWrapper(testId);
        
        System.assertEquals(testId, wrapper.campaignMemberId);
    }
}