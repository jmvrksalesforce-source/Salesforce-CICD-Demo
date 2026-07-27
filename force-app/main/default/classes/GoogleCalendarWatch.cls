public class GoogleCalendarWatch {

    // Define your Google Calendar API endpoint
    private static String API_ENDPOINT = 'https://www.googleapis.com/calendar/v3/calendars/primary/events/watch';

    // Define the callback URL where Google Calendar will send notifications
    private static String CALLBACK_URL = 'https://your-callback-url.com'; // Replace with your callback URL

    // Google Calendar API Key or OAuth2 Access Token
    private static String API_KEY_OR_ACCESS_TOKEN = 'your-api-key-or-access-token'; // Replace with your API key or access token

    public static void configureCalendarWatch() {
        // Create a JSON request body with watch parameters
        String requestBody = '{' +
            '"id": "unique-id" + system.now(),' + // Provide a unique ID for this watch request
            '"type": "web_hook",' +
            '"address": "' + CALLBACK_URL + '"' + // Replace with your callback URL
        '}';

        // Make an HTTP request to configure the watch
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(API_ENDPOINT);
        request.setMethod('POST');
        request.setHeader('Authorization', 'Bearer ' + API_KEY_OR_ACCESS_TOKEN);
        request.setHeader('Content-Type', 'application/json');
        request.setBody(requestBody);

        try {
            HttpResponse response = http.send(request);
            if (response.getStatusCode() == 200) {
                // Watch request was successfully configured
                System.debug('Google Calendar watch request configured successfully.');
            } else {
                // Handle errors and response data as needed
                System.debug('Error configuring Google Calendar watch: ' + response.getBody());
            }
        } catch (Exception e) {
            // Handle exceptions
            System.debug('Exception configuring Google Calendar watch: ' + e.getMessage());
        }
    }
}