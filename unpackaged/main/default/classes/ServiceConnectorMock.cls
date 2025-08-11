@IsTest
public with sharing class ServiceConnectorMock implements HttpCalloutMock{

    protected Integer code;
    protected String status;
    protected String body;
    protected Map<String, String> responseHeaders;

    public ServiceConnectorMock(Integer code, String status, String body, Map<String, String> responseHeaders) {
        this.code = code;
        this.status = status;
        this.body = body;
        this.responseHeaders = responseHeaders;
    }

    public HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();
        for(String key : this.responseHeaders.keySet()) {
            res.setHeader(key, this.responseHeaders.get(key));
        }
        if(String.isNotBlank(this.body)) res.setBody(this.body);
        if(this.code != null) res.setStatusCode(this.code);
        if(String.isNotBlank(this.status)) res.setStatus(this.status);
        return res;
    }

}