/**
 * ─────────────────────────────────────────────────────────────────────────────────────────────────
 * TITLE: JSONAndCampaignMemberTest
 * DESCRIPTION: Test class to cover JSONToCollectionClone, FSJSONPathParser and CampaignMemberCallout classes.
 * AUTHOR: Rajendra
 * VERSION: 1.0
 * CREATED DATE: 09/06/2025
 * ─────────────────────────────────────────────────────────────────────────────────────────────────
 */
@isTest
public class JSONAndCampaignMemberTest {
    
    // Mock response class for HTTP callout
    public class CampaignMemberMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            res.setBody('{"SalesforceLeadId":"00Qxx0000001234"}');
            return res;
        }
    }
    
    @isTest
    static void testJSONToCollectionCloneValidJson() {
        String validJson = '{"data":[{"Name":"John"},{"Name":"Doe"}]}';
        
        JSONToCollectionClone.Request req = new JSONToCollectionClone.Request();
        req.jsonStringToConvert = validJson;
        
        List<JSONToCollectionClone.Request> input = new List<JSONToCollectionClone.Request>{req};
            List<JSONToCollectionClone.Response> responses = JSONToCollectionClone.execute(input);
        
        System.assertEquals(1, responses.size());
        System.assert(responses[0].convertedResponseBody.contains('John'), 'Should contain John');
        System.assert(responses[0].convertedResponseBody.contains('Doe'), 'Should contain Doe');
    }
    
    @isTest
    static void testJSONToCollectionCloneInvalidJson() {
        String invalidJson = '{"invalidKey":[{"Name":"Test"}]}';
        
        JSONToCollectionClone.Request req = new JSONToCollectionClone.Request();
        req.jsonStringToConvert = invalidJson;
        
        List<JSONToCollectionClone.Request> input = new List<JSONToCollectionClone.Request>{req};
            List<JSONToCollectionClone.Response> responses = JSONToCollectionClone.execute(input);
        
        String actual = responses[0].convertedResponseBody;
        System.assert(
            String.isEmpty(actual) || actual == '[]',
            'Expected empty or default JSON array for missing "data"'
        );
    }
    
    
    @isTest
    static void testCampaignMemberCallout() {
        Test.setMock(HttpCalloutMock.class, new CampaignMemberMock());
        
        CampaignMemberCallout.Input input = new CampaignMemberCallout.Input();
        input.relativeUrl = 'common/lead/v2/campaignmember/123/activate?userId=005xx000001234';
        
        List<CampaignMemberCallout.Input> inputs = new List<CampaignMemberCallout.Input>{input};
            List<CampaignMemberCallout.Output> outputs = CampaignMemberCallout.campaignMemberAction(inputs);
        
        System.assertEquals(1, outputs.size());
        System.assertEquals('00Qxx0000001234', outputs[0].recordId);
        System.assertEquals(null, outputs[0].errorMessage);
    }
    
    @isTest
    static void testCampaignMemberCallout_NullInputs() {
        List<CampaignMemberCallout.Output> outputs = CampaignMemberCallout.campaignMemberAction(null);
        System.assertEquals(1, outputs.size());
        System.assertEquals('No input provided.', outputs[0].errorMessage);
    }
    
    
    @isTest
    static void simpleTest() {
        String jsonString = '{"user": {"name": "Raj"}}';
        FSJSONPathParser.Request req = new FSJSONPathParser.Request();
        req.jsonString = jsonString;
        req.path = 'user.name';
        List<String> result = FSJSONPathParser.parseJSONWithPath(new List<FSJSONPathParser.Request>{ req });
        System.assertEquals(1, result.size());
        System.assertEquals('Raj', result[0]);
    }
    
    @isTest
    static void testArrayPath() {
        // Covers: List<Object> block
        String jsonString = '{"users": [ {"name": "Raj"}, {"name": "Amit"} ]}';
        FSJSONPathParser.Request req = new FSJSONPathParser.Request();
        req.jsonString = jsonString;
        req.path = 'users.1.name'; // Access 2nd object in array

        List<String> result = FSJSONPathParser.parseJSONWithPath(new List<FSJSONPathParser.Request>{ req });

        System.assertEquals(1, result.size());
        System.assertEquals('Amit', result[0]); // Confirms list access
    }
}