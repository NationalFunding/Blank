public class FSApiClient {
    public class RequestInput {
        // API Calls variables
        // label='Username', description='Username or Client ID',
        @InvocableVariable(required=true) public String endpoint;
        @InvocableVariable(required=true) public String method;
        @InvocableVariable public String body;
        @InvocableVariable public List<String> headers;
        
        // OAuth variables
        @InvocableVariable public String oauthEndpoint;
        @InvocableVariable public String oauthCredentialsHeader;
    }

    public class ResponseOutput {        
        @InvocableVariable public Integer statusCode;
        @InvocableVariable public String status;
        @InvocableVariable public String body;
        // @InvocableVariable public sObject parsedBody;
    }

    @InvocableMethod(
        label='HTTP Client'
        description='Just a normal HTTP client.'
    )
    public static List<ResponseOutput> callApi(List<RequestInput> inputs) {
        List<ResponseOutput> responses = new List<ResponseOutput>();

        for (RequestInput input : inputs) {
            ResponseOutput response = new ResponseOutput();

            try {
                String oauthToken = null;
                String oauthTokenType = null;

                if (input.oauthEndpoint != null) {
                    // Call OAuth endpoint
                    Http oauth = new Http();
                    HttpRequest oauthReq = new HttpRequest();
                    oauthReq.setMethod('POST');
                    oauthReq.setEndpoint(input.oauthEndpoint);
                    oauthReq.setHeader('Authorization', 'Basic ' + input.oauthCredentialsHeader);
                    oauthReq.setHeader('Content-Type', 'application/json');
                    oauthReq.setBody('{"grantType": "client_credentials"}');
                    oauthReq.setTimeout(30000);

                    HttpResponse res = oauth.send(oauthReq);
                    if (res.getStatusCode() != 200) {
                        response.statusCode = res.getStatusCode();
                        response.status = res.getStatus();
                        response.body   = res.getBody();
                        responses.add(response);
                        continue;
                    }
                    
                    Map<String, Object> parsedBody = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                    oauthTokenType = (String) parsedBody.get('tokenType');
                    oauthToken     = (String) parsedBody.get('token');                
                }

                // Make the HTTP request
                Http http = new Http();
                HttpRequest req = new HttpRequest();
                req.setEndpoint(input.endpoint);
                req.setMethod(input.method);
                
                if (oauthToken != null) {
                    req.setHeader('Authorization', oauthTokenType + ' ' + oauthToken);
                }
                
                if (input.headers != null) {
                    for (String header : input.headers) {
                        List<String> splittedHeader = header.split(':',2);
                        req.setHeader(splittedHeader[0], splittedHeader[1]);
                    }
                } 
                
                // Default Content-Type header
                req.setHeader('Content-Type', 'application/json');

                if (input.body != null) {
                    req.setBody(input.body);
                }

                req.setTimeout(30000);
                HttpResponse res = http.send(req);

                response.statusCode = res.getStatusCode();
                response.status = res.getStatus();
                response.body   = res.getBody();

                System.debug('input.endpoint: ' + input.endpoint);
                System.debug('response.statusCode: ' + response.statusCode);
                System.debug('response.status: ' + response.status);
                System.debug('response.body: ' + response.body);
                
            } catch (Exception ex) {
                response.statusCode = 500;
                System.debug(ex.getMessage());
                System.debug(ex.getStackTraceString());
            }
            responses.add(response);
        }
        
        return responses;
    }
}