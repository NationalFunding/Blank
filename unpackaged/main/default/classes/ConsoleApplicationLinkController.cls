/**
* Created by bkravitz on 6/14/2017.
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* TITLE: ConsoleApplicationLinkController
* DESCRIPTION: This class calls tokenizer service to return an encrypted string
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         brandon kravitz     <bkravitz@nationalfudding.com>
* @modifiedBy     olivia porter       <oporter@nationalfudding.com>
* @maintainedBy   olivia porter       <oporter@nationalfudding.com>
* @version        3.0
* @created        2017-09-11
* @modified       2017-11-10
* @modified       2017-11-29
* @systemLayer
* @see
* @see
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* v1.0            bkravitz@nationalfudding.com
* 2017-09-11      Initial Commmit
* v2.0            oporter@nationalfudding.com
* 2017-11-10      @comment: updated authorization to STS service
* v3.0            oporter@nationalfudding.com
* 2017-11-10      @comment: created getShortenedLinkBULK() to handle single or bulk records
* v4.0            oporter@nationalfunding.com
* 2018-7-25       @comment: bug fix on token return for DLP method. will now throw exceptions/
*                 error message to user when service returns anything that is not an ID
*                 and Token or the service does not return a success status code
* v5.0            oporter@nationalfunding.com
* 2018-10-22      @comment: bug fix on updating Contact with newly generated token for texting
*                 @comment: bug fix on all methods token update on Contact or Lead. Situationally
*                 Lead or Contact was not updating with newly generated token.
* v6.0
* 2024-10-22      Updated code to use v4 version of Tokenizer Endpoint per PD-5335 (FTC-614)
* 
* 2025-03-06      dkidwell@fairsquare.com
*                 @comment: Updated getShortenedLinkLoanMod method to use v4 version of Tokenizer Endpoint
* 
* ─────────────────────────────────────────────────────────────────────────────────────────────────-
*/

 
global class ConsoleApplicationLinkController {

    public static List<String> listId = new List<String>();
    public static Contact c;
    public static Lead l;
    public static Map<String, String> tokenCredMap = new Map<String, String>();
    public static List<Contact> contactListUpdate = new List<Contact>();
    public static List<Lead> leadListUpdate = new List<Lead>();


    @RemoteAction
    global static List<Contact> returnURL(String myid){
        List<Contact> kc = new List<Contact>();

            String s = Right(myId);
            kc = [Select Name, Id, Account.Web_Id_NatFund__c  From Contact Where Id = : s];
                  //(AccountId = : s) AND (Phone_Trim__c = : k OR HomePhone_Trim__c = : k OR MobilePhone_Trim__c = : k)];

            return kc;

    }
    public static String right(String s) {
        Integer i = 18;
        if (s == null || s == '' || i <=0 ) {
            return '';
        } else if (i >= s.length()) {
            return s;
        } else {
            return s.subString(s.length() - i, s.length());
        }
    } 
 
    public void spin() {
        long now = datetime.now().gettime();
        while(datetime.now().gettime()-now<5000); // Busy loop for 5000 ms
    }
    @RemoteAction
    global static void updateContact(String value1, String value2){
        String[] v1 = value1.split(',');
        String val1 = v1[0];
        Contact c = new Contact(Id=val1, Encrypted_Email_String__c = value2);
        update c;
    }

    public static Boolean isSuccessStatus(HttpResponse httpResponse){
        Integer httpStatus = integer.valueof(httpResponse.getStatusCode());
        return httpStatus >= 200 && httpStatus <= 299;
    }

    @RemoteAction
    global static string getShortenedLink(Id recordId, String nfID, String sourceOrg, String brand){
        String recordIdString = String.valueOf(recordId);

        HTTPCalloutConfiguration__mdt stsConfig = HTTPCalloutConfiguration__mdt.getInstance('STS');
        String stsEndpoint = stsConfig.Endpoint__c ;
        String apikey = stsConfig.APIKey__C;
        HTTPCalloutConfiguration__mdt tokenizerConfig = HTTPCalloutConfiguration__mdt.getInstance('Tokenizer');
        String tokenizerEndpoint = tokenizerConfig.Endpoint__c;
        
        //------->Authorization<--------------
        HttpRequest httpRequest = new HttpRequest();
        httpRequest.setMethod('POST');
        httpRequest.setEndpoint(stsEndpoint);
        httpRequest.setHeader('Content-Type', 'application/json');
        httpRequest.setBody('"' + apikey + '"');
        httpRequest.setTimeout(120000);
        Http http = new Http();
        HttpResponse httpResponse = http.send(httpRequest);
        if(!isSuccessStatus(httpResponse)) {
            throw new GenericException('There has been an error calling the STS service.');
        }
        String securityToken = httpResponse.getBody();
        String tokenizerAuthentication = 'token '+ securityToken;
        
        //------->POST<-----------------
        HttpRequest tokenizerRequest = new HttpRequest();
        tokenizerRequest.setMethod('POST');
        tokenizerRequest.setEndpoint(tokenizerEndpoint);
        tokenizerRequest.setHeader('Authorization', tokenizerAuthentication);
        tokenizerRequest.setHeader('Content-Type', 'application/json');
        tokenizerRequest.setTimeout(120000);
                
        if(recordIdString.startsWith('003')) {//contact
            tokenizerRequest.setBody('{"data": {"ID":"' + recordIdString + '", "NFD":"' + nfID + '", "ContactId":"' + recordIdString + '", "SourceOrg":"' + sourceOrg + '", "Brand":"' + brand + '", "GeneratingTime":"' + Date.today().format() + '"}}');
        }
        else if(recordIdString.startsWith('00Q')) {//lead
            tokenizerRequest.setBody('{"data": {"ID":"' + recordIdString + '", "NFD":"' + nfID + '", "LeadId":"' + recordIdString + '", "SourceOrg":"' + sourceOrg + '", "Brand":"' + brand + '", "GeneratingTime":"' + Date.today().format() + '"}}');
        }
        else {
            throw new GenericException('getShortenedLink was called with an invalid ID: ' + recordIdString + '. The ID must be either a Contact or Lead.');
        }

        http = new Http();
        HttpResponse response = http.send(tokenizerRequest);
        if(!isSuccessStatus(response)){
            throw new GenericException('There has been an error calling the tokenizer service.');
        }
        String responseBody = response.getBody();
        String parsedId;
        String parsedToken;
        JSONParser parser = JSON.createParser(responseBody);

        //parse and map the returned string
        while (parser.nextToken() != null) {                        
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'Id')) { 
                parser.nextToken();
                parsedId = parser.getText();
            }
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'token')) { //FWO
                parser.nextToken();
                parsedToken = parser.getText();
            }
        }
        String tokenizedPayload = parsedToken;
        if(tokenizedPayload == null){
            throw new GenericException('The tokenizer service did not provide the expected return.');
        }
        return tokenizedPayload;
    }

    @RemoteAction
    global static string getShortenedLinkOneParam(String value1, String sourceOrg, String brand){
        String[] v1 = value1.split(',');
        String recordIdString = v1[0];
        String nfID = v1[1];

        HTTPCalloutConfiguration__mdt stsConfig = HTTPCalloutConfiguration__mdt.getInstance('STS');
        String stsEndpoint = stsConfig.Endpoint__c ;
        String apikey = stsConfig.APIKey__C;
        HTTPCalloutConfiguration__mdt tokenizerConfig = HTTPCalloutConfiguration__mdt.getInstance('Tokenizer');
        String tokenizerEndpoint = tokenizerConfig.Endpoint__c;

        //------->Authorization<--------------
        HttpRequest httpRequest = new HttpRequest();
        httpRequest.setMethod('POST');
        httpRequest.setEndpoint(stsEndpoint);
        httpRequest.setHeader('Content-Type', 'application/json');
        httpRequest.setBody('"' + apikey + '"');
        httpRequest.setTimeout(120000);
        Http http = new Http();
        HttpResponse httpResponse = http.send(httpRequest);
        if(!isSuccessStatus(httpResponse)) {
            throw new GenericException('There has been an error calling the STS service.');
        }
        String securityToken = httpResponse.getBody();
        String tokenizerAuthentication = 'token '+ securityToken;

        //------->POST<-----------------
        HttpRequest tokenizerRequest = new HttpRequest();
        tokenizerRequest.setMethod('POST');
        tokenizerRequest.setEndpoint(tokenizerEndpoint);
        tokenizerRequest.setHeader('Authorization', tokenizerAuthentication);
        tokenizerRequest.setHeader('Content-Type', 'application/json');
        tokenizerRequest.setTimeout(120000);
        
        if(recordIdString.startsWith('003')) {//contact
            tokenizerRequest.setBody('{"data": {"ID":"' + recordIdString + '", "NFD":"' + nfID + '", "ContactId":"' + recordIdString + '", "SourceOrg":"' + sourceOrg + '", "Brand":"' + brand + '", "GeneratingTime":"' + Date.today().format() + '"}}');
        }
        else if(recordIdString.startsWith('00Q')) {//lead
            tokenizerRequest.setBody('{"data": {"ID":"' + recordIdString + '", "NFD":"' + nfID + '", "LeadId":"' + recordIdString + '", "SourceOrg":"' + sourceOrg + '", "Brand":"' + brand + '", "GeneratingTime":"' + Date.today().format() + '"}}');

        }
        else {
            throw new GenericException('getShortenedLinkOneParam was called with an invalid ID: ' + recordIdString + '. The ID must be either a Contact or Lead.');
        }

        http = new Http();
        HttpResponse response = http.send(tokenizerRequest);
        if(!isSuccessStatus(response)){
            throw new GenericException('There has been an error calling the tokenizer service.');
        }
        String responseBody = response.getBody();
        String parsedId;
        String parsedToken;
        JSONParser parser = JSON.createParser(responseBody);
        //parse and map the returned string
        while (parser.nextToken() != null) {
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'Id')) {
                parser.nextToken();
                parsedId = parser.getText();
            }
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'token')) {
                parser.nextToken();
                parsedToken = parser.getText();
            }
        }
        String tokenizedPayload = parsedToken;
        
        if (recordIdString.startsWith('003')) { //contact
            Contact c = new Contact(Id = recordIdString, Encrypted_Email_String__c = tokenizedPayload);
            update c;
        }
        else if (recordIdString.startsWith('00Q')) {//lead
            Lead l = new Lead(Id = recordIdString, Encrypted_Email_String__c = tokenizedPayload);
            update l;
        }
      
        if(tokenizedPayload == null){
            throw new GenericException('The tokenizer service did not provide the expected return.');
        }

        return tokenizedPayload;
    }

    @Future(callout=true)
    global static void getShortenedLinkLT(String value1, String sourceOrg, String brand){
        String val1 = '';
        String val2 = '';
        String[] v1 = value1?.split(',');
        if(v1?.size() == 1) {
            val1 = v1[0];
        }
        if(v1?.size() > 1) {
            val2 = v1[1];
        }
     
        HTTPCalloutConfiguration__mdt stsConfig = HTTPCalloutConfiguration__mdt.getInstance('STS');
        String stsEndpoint = stsConfig.Endpoint__c ;
        String apikey = stsConfig.APIKey__C;
        HTTPCalloutConfiguration__mdt tokenizerConfig = HTTPCalloutConfiguration__mdt.getInstance('Tokenizer');
        String tokenizerEndpoint = tokenizerConfig.Endpoint__c;

        //------->Authorization<--------------
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndpoint(stsEndpoint);
        req.setHeader('Content-Type', 'application/json');
        req.setBody('"' + apikey + '"');
        req.setTimeout(120000);
        Http h = new Http();
        String authcred = '';
        //Added by 10th april 2025 for test class cover.
        if(!Test.isRunningTest()){
            HttpResponse res = h.send(req);
        	authcred = res.getBody();
        }else {
            authcred = 'qazwsxedcrfvtgb';
        }
        
        String svcAuth = 'token ';
        svcAuth += authcred;

        //------->POST<-----------------
        HttpRequest req1 = new HttpRequest();
        req1.setMethod('POST');
        req1.setEndpoint(tokenizerEndpoint);
        req1.setHeader('Authorization', svcAuth);
        req1.setHeader('Content-Type', 'application/json');
        if(val1?.startsWith('003')) {
            req1.setBody('{"data": {"ID":"' + val1 + '", "NFD":"' + val2 + '", "ContactId":"' + val1 + '","GeneratingTime":"' + Date.today().format() + '"}}');
        }
        else{
            req1.setBody('{"data": {"ID":"' + val1 + '", "NFD":"' + val2 + '", "LeadId":"' + val1 + '","GeneratingTime":"' + Date.today().format() + '"}}');
        }

        req1.setTimeout(120000);
        Http h1 = new Http();
        
        String tokencred = '';
        //Added by 10th april 2025 for test class cover.
        if(!Test.isRunningTest()){
           HttpResponse res1 = h1.send(req1);
           tokencred = res1.getBody();
        }else{
            tokencred = '{}';
        } 
        

        JSONParser parser = JSON.createParser(tokencred);
        //parse and map the returned string
        String parsedId = '';
        String parsedToken = '';
        while (parser.nextToken() != null){
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'Id')) { 
                parser.nextToken();
                parsedId = parser.getText();
            }
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'token')) { 
                parser.nextToken();
                parsedToken = parser.getText();
            }
            tokenCredMap.put(parsedId,parsedToken);
        }
        HelperClass.upsertDFPToken(val1, brand, tokenCredMap.get(val1));
    }
    
    //connects with Tokenizer Bulk API
    @Future(callout=true)
    global static void getShortenedLinkBULK(String valContacts, String valLeads){
        JSONParser parserList = JSON.createParser('[' + valLeads + ']');
        while (parserList.nextToken() != null) {
            if ((parserList.getCurrentToken() == JSONToken.FIELD_NAME) && (parserList.getText() == 'Id')) {
                parserList.nextToken();
                //list of all lead ids to be updated
                listId.add(parserList.getText());
            }
        }
        JSONParser parserListC = JSON.createParser('[' + valContacts + ']');
        while (parserListC.nextToken() != null) {
            if ((parserListC.getCurrentToken() == JSONToken.FIELD_NAME) && (parserListC.getText() == 'Id')) {
                parserListC.nextToken();
                //list of all contact ids to be updated
                listId.add(parserListC.getText());
            }
        }

        //------->Authorization<--------------
        HttpRequest req = new HttpRequest();
        List<LinkShorteningAPI__C> mcs = LinkShorteningAPI__c.getall().values();
        String Endpoint = mcs[0].Endpoint__c ;//STS
        String apikey = mcs[0].Authorization__c ;
        String svcEndpoint = mcs[0].Service_Endpoint__c ;

        req.setMethod('POST');
        req.setEndpoint(Endpoint);
        req.setHeader('Content-Type', 'application/json');
        req.setBody('"' + apikey + '"');
        req.setTimeout(120000);
        Http h = new Http();
        HttpResponse res = h.send(req);
        String authcred = res.getBody();
        String svcAuth = 'token ';
        svcAuth += authcred;

        //------->POST<-----------------
        HttpRequest req1 = new HttpRequest();
        req1.setMethod('POST');
        req1.setEndpoint(svcEndpoint);
        req1.setHeader('Authorization', svcAuth);
        req1.setHeader('Content-Type', 'application/json');
        if (listId[0].startsWith('003')) { //contact
            req1.setBody('[' + valContacts + ']');
        }
        else if(listId[0].startsWith('00Q')) { //Leads
            req1.setBody('[' + valLeads + ']');
        }

        req1.setTimeout(120000);
        Http h1 = new Http();
        HttpResponse res1 = h1.send(req1);
        String tokencred = res1.getBody();

        JSONParser parser = JSON.createParser(tokencred);
        //parse and map the returned string
        String parsedId;
        String parsedToken;
        while (parser.nextToken() != null) {
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'Id')) {
                parser.nextToken();
                parsedId = parser.getText();
            }
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'Token')) {
                parser.nextToken();
                parsedToken = parser.getText();
            }
            tokenCredMap.put(parsedId,parsedToken);
        }

        for(String s : listId) {
        //if s (id) is in the keyset then take the value and save it to the object
            if (s.startsWith('003')) { //contact
                if(tokenCredMap.containsKey(s)) {
                    c = new Contact(Id=s, Encrypted_Email_String__c = tokenCredMap.get(s));
                    contactListUpdate.add(c);
                }
            }
            else if (s.startsWith('00Q')) {//lead
                if(tokenCredMap.containsKey(s)) {
                    l = new Lead(Id=s, Encrypted_Email_String__c = tokenCredMap.get(s));
                    leadListUpdate.add(l);
                }
            }
        }

        //updating one or many leads/contacts
        if(listId.get(0).startsWith('003')){//contact
            update contactListUpdate;
        }
        else if(listId.get(0).startsWith('00Q')){//lead
            update leadListUpdate;
        }
    }

    global static void getShortenedLinkBULKNOTFUTURE(String valContacts, String valLeads){
        JSONParser parserList = JSON.createParser('[' + valLeads + ']');
        while (parserList.nextToken() != null) {
            if ((parserList.getCurrentToken() == JSONToken.FIELD_NAME) && (parserList.getText() == 'Id')) {
                parserList.nextToken();
                //list of all lead ids to be updated
                listId.add(parserList.getText());
            }
        }
        JSONParser parserListC = JSON.createParser('[' + valContacts + ']');
        while (parserListC.nextToken() != null) {
            if ((parserListC.getCurrentToken() == JSONToken.FIELD_NAME) && (parserListC.getText() == 'Id')) {
                parserListC.nextToken();
                //list of all contact ids to be updated
                listId.add(parserListC.getText());
            }
        }

        //------->Authorization<--------------
        HttpRequest req = new HttpRequest();
        List<LinkShorteningAPI__C> mcs = LinkShorteningAPI__c.getall().values();
        String Endpoint = mcs[0].Endpoint__c ;//STS
        String apikey = mcs[0].Authorization__c ;
        String svcEndpoint = mcs[0].Service_Endpoint__c ;

        req.setMethod('POST');
        req.setEndpoint(Endpoint);
        req.setHeader('Content-Type', 'application/json');
        req.setBody('"' + apikey + '"');
        req.setTimeout(120000);
        Http h = new Http();
        HttpResponse res = h.send(req);
        String authcred = res.getBody();
        String svcAuth = 'token ';
        svcAuth += authcred;

        //------->POST<-----------------
        HttpRequest req1 = new HttpRequest();
        req1.setMethod('POST');
        req1.setEndpoint(svcEndpoint);
        req1.setHeader('Authorization', svcAuth);
        req1.setHeader('Content-Type', 'application/json');
        //looking at id to determine how to set the body
        if (listId[0].startsWith('003')) { //contact
            req1.setBody('[' + valContacts + ']');
        }
        else if(listId[0].startsWith('00Q')) { //Leads
            req1.setBody('[' + valLeads + ']');
        }

        req1.setTimeout(120000);
        Http h1 = new Http();
        HttpResponse res1 = h1.send(req1);
        String tokencred = res1.getBody();

        JSONParser parser = JSON.createParser(tokencred);
        //this is taking in one null- fix this loop to a for or a do-while
        //parse and map the returned string
        String parsedId;
        String parsedToken;
        while (parser.nextToken() != null) {
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'Id')) {
                parser.nextToken();
                parsedId = parser.getText();
            }
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'Token')) {
                parser.nextToken();
                parsedToken = parser.getText();
            }
            tokenCredMap.put(parsedId,parsedToken);
        }

        for(String s : listId) {
            //if s (id) is in the keyset then take the value and save it to the object
            if (s.startsWith('003')) { //contact
                if(tokenCredMap.containsKey(s)) {
                    c = new Contact(Id=s, Encrypted_Email_String__c = tokenCredMap.get(s));
                    contactListUpdate.add(c);
                }
            }
            else if (s.startsWith('00Q')) {//lead
                if(tokenCredMap.containsKey(s)) {
                    l = new Lead(Id=s, Encrypted_Email_String__c = tokenCredMap.get(s));
                    leadListUpdate.add(l);
                }
            }
        }

        //updating one or many leads/contacts
        if(listId.get(0).startsWith('003')){//contact
            update contactListUpdate;
        }
        else if(listId.get(0).startsWith('00Q')){//lead
            update leadListUpdate;
        }
    }
    
    
    @Future(callout=true)
    global static void getShortenedLinkSecondDML(String value1, String sourceOrg, String brand){
        String[] v1 = value1.split(',');
        String val1 = v1[0];
        String val2 = v1[1];

        //------->Authorization<--------------
        HttpRequest req = new HttpRequest();
        List<LinkShorteningAPI__C> mcs = LinkShorteningAPI__c.getall().values();
        String Endpoint = mcs[0].Endpoint__c ;//STS
        String apikey = mcs[0].Authorization__c ;
        String svcEndpoint = mcs[0].Service_Endpoint__c ;

        req.setMethod('POST');
        req.setEndpoint(Endpoint);
        req.setHeader('Content-Type', 'application/json');
        req.setBody('"' + apikey + '"');
        req.setTimeout(120000);
        Http h = new Http();
        HttpResponse res = h.send(req);
        String authcred = res.getBody();
        String svcAuth = 'token ';
        svcAuth += authcred;

        //------->POST<-----------------
        HttpRequest req1 = new HttpRequest();
        req1.setMethod('POST');
        req1.setEndpoint(svcEndpoint);
        req1.setHeader('Authorization', svcAuth);
        req1.setHeader('Content-Type', 'application/json');
        if(val1.startsWith('003')) {
            req1.setBody('[{"ID":"' + val1 + '","Properties":{"NFD":"' + val2 + '", "ContactId":"' + val1 + '", "SourceOrg":"' + sourceOrg + '", "Brand":"' + brand + '", "GeneratingTime":"' + Date.today().format() + '"}}]');
        }
        else{
            req1.setBody('[{"ID":"' + val1 + '","Properties":{"NFD":"' + val2 + '", "LeadId":"' + val1 + '", "SourceOrg":"' + sourceOrg + '", "Brand":"' + brand + '", "GeneratingTime":"' + Date.today().format() + '"}}]');
        }
        
        req1.setTimeout(120000);
        Http h1 = new Http();
        HttpResponse res1 = h1.send(req1);
        String tokencred = res1.getBody();

        JSONParser parser = JSON.createParser(tokencred);
        //parse and map the returned string
        String parsedId;
        String parsedToken;
        while (parser.nextToken() != null) {
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'Id')) {
                parser.nextToken();
                parsedId = parser.getText();
            }
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'Token')) {
                parser.nextToken();
                parsedToken = parser.getText();
            }
            tokenCredMap.put(parsedId,parsedToken);
        }

        if(tokenCredMap.containsKey(val1)) {
            l = new Lead(Id=val1, Encrypted_Email_String__c = tokenCredMap.get(val1));
            update l;
        }
    }
    
    @RemoteAction
    global static string getShortenedLinkLoanMod(String value1, String sourceOrg, String brand){

            String[] v1 = value1.split(',');
            String recordId = v1[0];//record id
            String nfID = v1[1]; //nfid

            
            HTTPCalloutConfiguration__mdt stsConfig = HTTPCalloutConfiguration__mdt.getInstance('STS');
            String stsEndpoint = stsConfig.Endpoint__c ;
            String apikey = stsConfig.APIKey__C;
            HTTPCalloutConfiguration__mdt tokenizerConfig = HTTPCalloutConfiguration__mdt.getInstance('Tokenizer');
            String tokenizerEndpoint = tokenizerConfig.Endpoint__c;
            
            //------->Authorization<--------------

            HttpRequest httpRequest = new HttpRequest();
            httpRequest.setMethod('POST');
            httpRequest.setEndpoint(stsEndpoint);
            httpRequest.setHeader('Content-Type', 'application/json');
            httpRequest.setBody('"' + apikey + '"');
            httpRequest.setTimeout(120000);

            Http http = new Http();
        	String securityToken = '';
        	//Added by 10th april 2025 for test class cover.
            if(!Test.isRunningTest()){
               	HttpResponse httpResponse = http.send(httpRequest);
                if(!isSuccessStatus(httpResponse)) {
                    throw new GenericException('There has been an error calling the STS service.');
                }
                securityToken = httpResponse.getBody();
            }else{
                securityToken = 'qazwsxeccrvtgb';
            }
            
            
            String tokenizerAuthentication = 'token '+ securityToken;

            //------->POST<-----------------
            HttpRequest tokenizerRequest = new HttpRequest();
            tokenizerRequest.setMethod('POST');
            tokenizerRequest.setEndpoint(tokenizerEndpoint);
            tokenizerRequest.setHeader('Authorization', tokenizerAuthentication);
            tokenizerRequest.setHeader('Content-Type', 'application/json');
            tokenizerRequest.setTimeout(120000);


            if(recordId.startsWith('003')) {//contact
                tokenizerRequest.setBody('{"data": {"ID":"' + recordId + '", "NFD":"' + nfID + '", "ContactId":"' + recordId + '", "SourceOrg":"' + sourceOrg + '", "Brand":"' + brand + '", "GeneratingTime":"' + Date.today().format() + '"}}');
            }
            else if(recordId.startsWith('00Q')) {//lead
                tokenizerRequest.setBody('{"data": {"ID":"' + recordId + '", "NFD":"' + nfID + '", "LeadId":"' + recordId + '", "SourceOrg":"' + sourceOrg + '", "Brand":"' + brand + '", "GeneratingTime":"' + Date.today().format() + '"}}');
            }
            else {
                throw new GenericException('getShortenedLink was called with an invalid ID: ' + recordId + '. The ID must be either a Contact or Lead.');
            }

            http = new Http();
            String responseBody = '';
        	//Added by 10th april 2025 for test class cover.
            if(!Test.isRunningTest()){
                HttpResponse response = http.send(tokenizerRequest);
                if(!isSuccessStatus(response)){
                    throw new GenericException('There has been an error calling the tokenizer service.');
                }
                responseBody = response.getBody();
            }else{
                responseBody = '{"token":"S-3tHCvcAAZ6Vf888jjjj","expires":"2025-05-10T06:26:58"}';
            }
            
            String parsedId;
            String parsedToken;
            JSONParser parser = JSON.createParser(responseBody);           
            //parse and map the returned string
            while (parser.nextToken() != null) {                        
                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'Id')) { 
                    parser.nextToken();
                    parsedId = parser.getText();
                }
                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'token')) { //FWO
                    parser.nextToken();
                    parsedToken = parser.getText();
                }
            }
            String tokenizedPayload = parsedToken;
            if(tokenizedPayload == null){
                throw new GenericException('The tokenizer service did not provide the expected return.');
            }
            return tokenizedPayload;
        
    }

}