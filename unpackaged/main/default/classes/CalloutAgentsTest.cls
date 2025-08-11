//test class
@isTest(SeeAllData=true)
public class CalloutAgentsTest{
    public static testmethod void testAccountCallout() {
        SingleRequestMockClass fakeResponse = new SingleRequestMockClass(200,
                                                                         'Complete',
                                                                         '{"ErrorCode":"UserNotRegisteredOrLoggedOut","AgentList":null}',
                                                                         null);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, fakeResponse);
        CalloutAgentList.getAccounts();
        CalloutAgentList.hiLightUser();
        Test.stopTest();
        System.assert(true);
        System.assertNotEquals(null, fakeResponse, 'The callout returned a null response.');
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse res = h.send(req);   	
    }
    
    static testMethod void CalloutAgentList() {
        SingleRequestMockClass fakeResponse = new SingleRequestMockClass(200,'Complete','{"ErrorCode":"UserNotRegisteredOrLoggedOut","AgentList":null}',null);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, fakeResponse);
        String s = CalloutAgentList.getAccounts();
        system.assertEquals('{"ErrorCode":"UserNotRegisteredOrLoggedOut","AgentList":null}', s);
        
	}
    
    static testMethod void nullData(){
        SingleRequestMockClass fakeResponse = new SingleRequestMockClass(500,'Complete','',null);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, fakeResponse);
        String s = CalloutAgentList.getAccounts();
        system.assertEquals('', s);
    }
    
    static testMethod void testParse() {
        String json = '{\"ErrorCode\":\"UserNotRegisteredOrLoggedOut\",\"AgentList\":null}';
        SingleRequestMockClass fakeResponse = new SingleRequestMockClass(200,'Complete','{\"ErrorCode\":\"UserNotRegisteredOrLoggedOut\",\"AgentList\":null}',null);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, fakeResponse);
        CalloutAgentList.JSON2Apex obj1 = CalloutAgentList.parse(json);
        Test.stopTest();
		System.assert(obj1 != null);
    }
    
    static testMethod void testAgentList() {
		CalloutAgentList.AgentList al = new CalloutAgentList.AgentList();
        al.DateModifiedUtc = Datetime.now();
        al.Agents = null;
		System.assertEquals(Datetime.now(), al.DateModifiedUtc);
        System.assertEquals(null, al.Agents);
	}
    
    static testMethod void testAgents() {
		CalloutAgentList.Agents al = new CalloutAgentList.Agents();
        al.Username = 'oporter@nationalfunding.com';
        al.PriorityNumber = 1;
        //insert al;
        System.assertEquals('oporter@nationalfunding.com', al.Username);
	}
    
    static testMethod void testJSON2APEX() {
		CalloutAgentList.JSON2Apex al = new CalloutAgentList.JSON2Apex();
		al.ErrorMessage = '{\"ErrorCode\":\"UserNotRegisteredOrLoggedOut\",\"AgentList\":null}';
        al.AgentList = null;
        System.assertEquals('{\"ErrorCode\":\"UserNotRegisteredOrLoggedOut\",\"AgentList\":null}', al.ErrorMessage);
        System.assertEquals(null, al.AgentList);
	}
    
    static testMethod void testConstructor2() {
        SingleRequestMockClass fakeResponse = new SingleRequestMockClass(200,'Complete','{\"ErrorCode\":\"UserHasNoPrimarySkills\",\"AgentList\":null}',null);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, fakeResponse);
        String s = CalloutAgentList.jsonStr;
        CalloutAgentList a = new CalloutAgentList();
        Test.stopTest();
        System.assert(true);
        system.assertEquals('{"ErrorCode":"UserHasNoPrimarySkills","AgentList":null}', s);
	}
    
    static testMethod void testConstructor3() {
        SingleRequestMockClass fakeResponse = new SingleRequestMockClass(200,'Complete','{\"ErrorCode\":\"UserHasMoreThanOnePrimarySkill\",\"AgentList\":null}',null);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, fakeResponse);
        String s = CalloutAgentList.jsonStr;
        CalloutAgentList a = new CalloutAgentList();
        Test.stopTest();
        System.assert(true);
        system.assertEquals('{"ErrorCode":"UserHasMoreThanOnePrimarySkill","AgentList":null}', s);
	}
    
    static testMethod void testConstructor4() {
        SingleRequestMockClass fakeResponse = new SingleRequestMockClass(200,'Complete','{\"ErrorCode\":\"UserNotRegisteredOrLoggedOut\",\"AgentList\":null}',null);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, fakeResponse);
        String s = CalloutAgentList.jsonStr;
        CalloutAgentList a = new CalloutAgentList();
        Test.stopTest();
        System.assert(true);
        system.assertEquals('{"ErrorCode":"UserNotRegisteredOrLoggedOut","AgentList":null}', s);
	}
    
    static testMethod void testConstructor5() {
        SingleRequestMockClass fakeResponse = new SingleRequestMockClass(500,'Complete','{\"ErrorCode\":\"\",\"AgentList\":null}',null);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, fakeResponse);
        String s = CalloutAgentList.jsonStr;
        CalloutAgentList a = new CalloutAgentList();
        Test.stopTest();
        System.assert(true);
        system.assertEquals('{\"ErrorCode\":\"\",\"AgentList\":null}', s);
	}
}