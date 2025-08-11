public class JSONToCollectionClone {
    
	// Inner class to define the input structure for Flow invocation
    public class Request {
        @InvocableVariable(label='JSON String to Convert' required=true 
            description='JSON response string with "data" key')
        public String jsonStringToConvert;
    }
	
    // Inner class to define the output structure for Flow invocation
    public class Response {
        @InvocableVariable
        public String convertedResponseBody;
    }
	
    /**
     * Invocable method to convert a list of JSON strings (containing "data" key)
     * into serialized string of record collections.
     * 
     * @param requests - List of input request objects from Flow
     * @return List of response objects with converted record collections as JSON string
    */
    @InvocableMethod(label='Convert JSON to Collection of Records')
    public static List<Response> execute(List<Request> requests) {
        List<Response> responseList = new List<Response>();
		for (Request curRequest : requests) {
            Response res = new Response();
            res.convertedResponseBody = parseJson(curRequest.jsonStringToConvert);
            responseList.add(res);
        }

        return responseList;
    }
	
    /**
     * Parses the input JSON string, extracts the "data" array,
     * and serializes it back into a string format.
     * 
     * @param jsonString - Input JSON string containing a "data" key
     * @return Serialized JSON string of the data array
     */
    private static String parseJson(String jsonString) {
        String result = '';
        try {
            Object parsedJson = JSON.deserializeUntyped(jsonString);

            if (parsedJson instanceof Map<String, Object>) {
                Map<String, Object> topLevel = (Map<String, Object>)parsedJson;

                if (topLevel.containsKey('data') && topLevel.get('data') instanceof List<Object>) {
                    List<Object> dataList = (List<Object>)topLevel.get('data');
                    result  = JSON.serialize(dataList);
                }
            }
        } catch (Exception e) {
            System.debug('Error parsing JSON: ' + e.getMessage());
        }

        return result;
    }
}