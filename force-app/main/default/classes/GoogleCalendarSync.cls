@RestResource(urlMapping='/GoogleCalSync/*')
global class GoogleCalendarSync {
	@HttpPost
    global static String postData(){
        return 'Success ' + System.now();
    }
}