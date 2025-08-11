@isTest
private class FSJSONPathParserTest {

    @isTest
    static void testParseJSONWithPath_ObjectPath() {
        // JSON with nested object
        String json = '{"user": {"name": "Alice", "age": 30}}';
        FSJSONPathParser.Request req = new FSJSONPathParser.Request();
        req.jsonString = json;
        req.path = 'user.name';

        List<FSJSONPathParser.Request> requests = new List<FSJSONPathParser.Request>{req};
        List<String> results = FSJSONPathParser.parseJSONWithPath(requests);

        System.assertEquals(1, results.size());
        System.assertEquals('Alice', results[0]);
    }

    @isTest
    static void testParseJSONWithPath_ArrayPath() {
        // JSON with array
        String json = '{"users": [{"name": "Alice"}, {"name": "Bob"}]}';
        FSJSONPathParser.Request req = new FSJSONPathParser.Request();
        req.jsonString = json;
        req.path = 'users.1.name';

        List<FSJSONPathParser.Request> requests = new List<FSJSONPathParser.Request>{req};
        List<String> results = FSJSONPathParser.parseJSONWithPath(requests);

        System.assertEquals(1, results.size());
        System.assertEquals('Bob', results[0]);
    }

    @isTest
    static void testParseJSONWithPath_InvalidPath() {
        // JSON with missing path
        String json = '{"user": {"name": "Alice"}}';
        FSJSONPathParser.Request req = new FSJSONPathParser.Request();
        req.jsonString = json;
        req.path = 'user.email'; // Invalid path

        List<FSJSONPathParser.Request> requests = new List<FSJSONPathParser.Request>{req};
        List<String> results = FSJSONPathParser.parseJSONWithPath(requests);

        System.assertEquals(1, results.size());
        System.assertEquals(null, results[0]); // Should handle gracefully
    }

    @isTest
    static void testParseJSONWithPath_ArrayRoot() {
        // JSON as array root
        String json = '[{"name": "Alice"}, {"name": "Bob"}]';
        FSJSONPathParser.Request req = new FSJSONPathParser.Request();
        req.jsonString = json;
        req.path = '0.name';

        List<FSJSONPathParser.Request> requests = new List<FSJSONPathParser.Request>{req};
        List<String> results = FSJSONPathParser.parseJSONWithPath(requests);

        System.assertEquals(1, results.size());
        System.assertEquals('Alice', results[0]);
    }

    @isTest
    static void testParseJSONWithPath_MultipleRequests() {
        FSJSONPathParser.Request req1 = new FSJSONPathParser.Request();
        req1.jsonString = '{"user": {"name": "Alice"}}';
        req1.path = 'user.name';

        FSJSONPathParser.Request req2 = new FSJSONPathParser.Request();
        req2.jsonString = '{"user": {"name": "Bob"}}';
        req2.path = 'user.name';

        List<FSJSONPathParser.Request> requests = new List<FSJSONPathParser.Request>{req1, req2};
        List<String> results = FSJSONPathParser.parseJSONWithPath(requests);

        System.assertEquals(2, results.size());
        System.assertEquals('Alice', results[0]);
        System.assertEquals('Bob', results[1]);
    }
}