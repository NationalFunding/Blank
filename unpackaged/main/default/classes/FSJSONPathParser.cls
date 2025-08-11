public class FSJSONPathParser {
    // Request class for input parameters
    public class Request {
        // JSON string to parse
        @InvocableVariable(required=true) public String jsonString;
        
        // Path to the desired element (e.g., users.1.name)
        @InvocableVariable(required=true) public String path;
    }

    // Retrieve value from JSON using a path
    @InvocableMethod(label='Parse JSON with Path')
    public static List<String> parseJSONWithPath(List<Request> requests) {
        List<String> results = new List<String>();
        for (Request req : requests) {
            // Parse the JSON into a map or list
            Object json = JSON.deserializeUntyped(req.jsonString);

            // Traverse the JSON based on the provided path
            String value = (String) traverseJSON(json, req.path.split('\\.'));
            results.add(value);
        }

        return results;
    }

    // Helper method to traverse the JSON
    private static Object traverseJSON(Object json, List<String> pathParts) {
        Object current = json;
        for (String part : pathParts) {
            if (current instanceof Map<String, Object>) {
                // Handle object (map)
                current = ((Map<String, Object>) current).get(part);
            } else if (current instanceof List<Object>) {
                // Handle array (list)
                Integer index = Integer.valueOf(part);
                current = ((List<Object>) current)[index];
            } else {
                // Unsupported type or invalid path
                return null;
            }
        }

        return current;
    }
}