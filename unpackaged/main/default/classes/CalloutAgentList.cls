/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* TITLE: CalloutAgentList
* DESCRIPTION: Generates the list of reps with their priority. A rep should be displayed as equal to all other users that have the same priority as the viewing user. For example: if 20 people have a priority of 1 within a skill, all 20 should show a 1.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Olivia Porter       <oporter@nationalfunding.com>
* @modifiedBy     Olivia Porter       <oporter@nationalfunding.com>
* @maintainedBy   Olivia Porter       <oporter@nationalfunding.com>
* @version        2.0
* @created        2016-10-??
* @modified       2017-11-06
* @systemLayer
* @see
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* v1              oporter@nationalfunding.com
* 2017-02-13      Explanation of the change.  Multiple lines can be used to explain the change, but
*                 each line should be indented till left aligned with the previous description text.
*
* v2              oporter@nationalfunding.com
* 2011-11-06      Update tokenizer service to STS service
*
*
*/
public class CalloutAgentList {
    public static string a;
    public static JSON2Apex info { get; set; }
    public static String jsonStr {get;set;}
    public static Datetime changeToPst {get;set;}
    public static String newDate {get;set;}
    Public static List<User> emailName {get;set;}
    public static Id userID {get;set;}
    public static ApexPages.Message msg {get;set;}
    public static String userEmail {get;set;}
    public static string devURL {get;set;}

    //returns list of reps
    public static String getAccounts() {
        userID = UserInfo.getUserId();
        system.debug('userId:: ' + userId);
        emailName = [SELECT Username FROM User WHERE Id= :userID];
        system.debug('list of emails::' + emailName);
        User en = emailName[0];
        system.debug('en::' + en);
        String email = en.Username;
        system.debug('this is email:' + email);
        String testEmail = 'abarraza@nationalfunding.com';
        String testEmail2 = 'aburdick@nationalfunding.com';
        String testEmail3 = 'lmolnar@nationalfunding.com';
        String testEmail4 = 'trover@nationalfunding.com';
        
        HTTPCalloutConfiguration__mdt agentDistributionConfig = HTTPCalloutConfiguration__mdt.getInstance('AgentDistribution');
        String agentDistributionEndpoint = agentDistributionConfig.Endpoint__c;

        HttpRequest req = new HttpRequest();
        req.setEndpoint(agentDistributionEndpoint + email);
        req.setMethod('GET');
        req.setTimeout(120000);
        Http h = new Http();
        string d = getAuth();
        string e = 'token ';
        string f = e + d;
        req.setheader('Authorization', f );

        try{
            HttpResponse res = h.send(req);
            jsonStr = res.getBody();
            system.debug('this is the getAccounts() jsonStr::' + jsonStr);
            if (jsonStr.startsWith('{"ErrorMessage":null')) {
                system.debug('There is no error message!');
            }
            return jsonStr;
        }
        catch(Exception z){
            return null;
        }
    }

    //getting the PDF's url back from Ladi's server
    public static string getAuth() {
        try {
            
            HTTPCalloutConfiguration__mdt stsConfig = HTTPCalloutConfiguration__mdt.getInstance('STS');
            String stsEndpoint = stsConfig.Endpoint__c ;
            String apikey = stsConfig.APIKey__C;

            Http h = new Http();
            HttpRequest req = new HttpRequest();
            req.setEndpoint(stsEndpoint);
            req.setMethod('POST');
            req.setTimeout(120000);
            req.setHeader('Content-Type', 'application/json');
            req.setBody('"' + apikey + '"');
            HttpResponse res = h.send(req);
            if (res.getStatusCode() != 200) {
                msg=new ApexPages.Message(ApexPages.severity.WARNING,'An error has occurred. Please contact your administrator for assistance.1');
                return null;
            }
            else{
                system.debug('res.getBody rep mailer: ' + res.getBody());
                return res.getBody();
            }
        }
        catch (Exception q) {
            system.debug('q: ' + q);
            return null;
        }
    }

    public static String returnedjsonStr = getAccounts();

    public class JSON2Apex {
        public String ErrorMessage {get;set;}
        public AgentList AgentList {get;set;}
    }

    public class Agents {
        public String Username {get;set;}
        public Integer PriorityNumber {get;set;}
    }

    public class AgentList {
        public Datetime DateModifiedUtc {get;set;}
        public List<Agents> Agents {get;set;}
    }

    public static JSON2Apex parse(String json) {
        return (JSON2Apex) System.JSON.deserialize(json, JSON2Apex.class);
    }

    public CalloutAgentList() {
        if (jsonStr.contains('"ErrorCode":null')) {
            system.debug('this is the value of getAccount() aka returnedjsonStr: ' + returnedjsonStr); //this is the value returnedjsonStr: {"ErrorMessage":"User oporter@nationalfunding.com is either not registered with or is logged out of Five9.","AgentList":null}
            info = (JSON2Apex)parse(returnedjsonStr);
            system.debug('this is the string-->' + info + ', ' + info.ErrorMessage + ', ' +  info.AgentList);
            changeToPst = info.AgentList.DateModifiedUtc;
            System.debug('changeToPst:: ' + changeToPst + 'converted PST time:: ' + changeToPst.format('MM/dd/yyyy HH:mm:ss', 'America/Los_Angeles'));
            newDate = changeToPst.format('MM/dd/yyyy hh:mm aa' , 'America/Los_Angeles');
            hiLightUser();
        }
        else if (jsonStr.contains('UserNotRegisteredOrLoggedOut')) {
            msg=new ApexPages.Message(ApexPages.severity.WARNING,'Agent is either not logged into Five9 or is not registered with the service. If you feel that you are not registered, please contact your administrator for assistance.');
            ApexPages.addMessage(msg);
            system.debug('this is the error message 2:' + msg);
        }
        else if (jsonStr.contains('UserHasNoPrimarySkills')) {
            msg=new ApexPages.Message(ApexPages.severity.WARNING,'An error has occurred. Please contact your administrator for assistance.2');
            ApexPages.addMessage(msg);
            system.debug('this is the error message 1:' + msg);
        }
        else if (jsonStr.contains('UserHasMoreThanOnePrimarySkill')) {
            msg=new ApexPages.Message(ApexPages.severity.WARNING,'An error has occurred. Please contact your administrator for assistance.3');
            ApexPages.addMessage(msg);
            system.debug('this is the error message 3:' + msg);
        }
        else {
            msg=new ApexPages.Message(ApexPages.severity.WARNING,'An error has occurred. Please contact your administrator for assistance.4');
            ApexPages.addMessage(msg);
            system.debug('this is the error message 4:' + msg);
        }
    }

    public static Boolean hiLightUser(){
        Boolean n = true;
        String l = UserInfo.getUserId();
        system.debug('this is the current userID:' + l);
        List<User> m = [SELECT Email From User WHERE Id = :l];
        User o = m[0];
        system.debug('this is the user o value: ' + o);
        userEmail = o.Email;
        system.debug('this is the userEmail value: ' + userEmail);
        system.debug('this is the list of emails from l: ' + m);
        if (jsonStr.contains(userEmail)){
            return n;
        }
        else {
            return null;
        }
    }
}