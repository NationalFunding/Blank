/** 
 *  @Description: Test for STSHelper.cls
 *  @Created:     08/05/2025 by Will Caisido, FairSquare (Ticket: BAU-762)
 *  @Updated:     08/05/2025 by Will Caisido, FairSquare (Ticket: BAU-762)
 */

@isTest
private class STSHelperTest {
    private class MockSTSResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setHeader('Content-Type', 'application/json');
            res.setBody('"mocked-token-value"');
            return res;
        }
    }

    @isTest
    static void testGetSecurityToken() {
        // Set the mock callout
        Test.setMock(HttpCalloutMock.class, new MockSTSResponseGenerator());

        Test.startTest();
        // Inject mock endpoint instead of relying on Custom Metadata
        STSHelper helper = new STSHelper('https://mock.endpoint.test/token');
        String token = helper.getSecurityToken('fake-api-key');
        Test.stopTest();

        System.assertEquals('"mocked-token-value"', token, 'The token should match the mocked HTTP response.');
    }
}