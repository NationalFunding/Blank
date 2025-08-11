@isTest
public class FSApiClientTest {

    // Mock HTTP Response for OAuth Token Request
    private class OAuthHttpCalloutMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            // Simulate the response for the OAuth request
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            res.setBody('{"tokenType": "Bearer", "token": "mock_oauth_token"}');
            return res;
        }
    }

    // Mock HTTP Response for API Request
    private class ApiHttpCalloutMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            // Simulate a successful API response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            res.setBody('{"key": "value"}');
            return res;
        }
    }
    
    // Set up mock for OAuth token request with error response
    private class ErrorOAuthHttpCalloutMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(400);
            res.setBody('{}');
            return res;
        }
    }


    @isTest
    static void testGetOAuthTokens() {
        // Set up mock for OAuth token request
        Test.setMock(HttpCalloutMock.class, new OAuthHttpCalloutMock());

        // Prepare input data
        FSApiClient.RequestInput input = new FSApiClient.RequestInput();
        input.endpoint = 'https://api.example.com/data';
        input.method = 'GET';
        input.body = null;
        input.headers = new List<String>{'Custom-Header: Value'};
        input.oauthEndpoint = 'https://auth.example.com/oauth/token';
        input.oauthCredentialsHeader = 'mock_oauth_credentials';

        List<FSApiClient.RequestInput> inputs = new List<FSApiClient.RequestInput>{input};

        // Set up mock for the API call request
        Test.setMock(HttpCalloutMock.class, new ApiHttpCalloutMock());

        // Call the method
        List<FSApiClient.ResponseOutput> responses = FSApiClient.callApi(inputs);

        // Assertions
        System.assertEquals(1, responses.size(), 'There should be one response');
        FSApiClient.ResponseOutput response = responses[0];
        System.assertEquals(200, response.statusCode, 'Status code should be 200');
        System.assertEquals('{"key": "value"}', response.body, 'Body should match mock response');
    }

    @isTest
    static void testGetOAuthTokensWithError() {

        Test.setMock(
            HttpCalloutMock.class,
            new ErrorOAuthHttpCalloutMock()
        );

        // Prepare input data
        FSApiClient.RequestInput input = new FSApiClient.RequestInput();
        input.endpoint = 'https://api.example.com/data';
        input.method = 'GET';
        input.body = null;
        input.headers = new List<String>{'Custom-Header: Value'};
        input.oauthEndpoint = 'https://auth.example.com/oauth/token';
        input.oauthCredentialsHeader = 'mock_oauth_credentials';

        List<FSApiClient.RequestInput> inputs = new List<FSApiClient.RequestInput>{input};

        // Call the method
        List<FSApiClient.ResponseOutput> responses = FSApiClient.callApi(inputs);

        // Assertions
        System.assertEquals(1, responses.size(), 'There should be one response');
        FSApiClient.ResponseOutput response = responses[0];
        System.assertEquals(400, response.statusCode, 'Status code should be 400 due to error in OAuth request');
        System.assertEquals('{}', response.body, 'Body should be the error message');
    }

    @isTest
    static void testGetOAuthTokensWithoutOAuth() {
        // Set up mock for API call request
        Test.setMock(HttpCalloutMock.class, new ApiHttpCalloutMock());

        // Prepare input data without OAuth endpoint
        FSApiClient.RequestInput input = new FSApiClient.RequestInput();
        input.endpoint = 'https://api.example.com/data';
        input.method = 'GET';
        input.body = null;
        input.headers = new List<String>{'Custom-Header: Value'};
        input.oauthEndpoint = null;  // No OAuth request
        input.oauthCredentialsHeader = null;  // No OAuth credentials

        List<FSApiClient.RequestInput> inputs = new List<FSApiClient.RequestInput>{input};

        // Call the method
        List<FSApiClient.ResponseOutput> responses = FSApiClient.callApi(inputs);

        // Assertions
        System.assertEquals(1, responses.size(), 'There should be one response');
        FSApiClient.ResponseOutput response = responses[0];
        System.assertEquals(200, response.statusCode, 'Status code should be 200');
        System.assertEquals('{"key": "value"}', response.body, 'Body should match mock response');
    }
}