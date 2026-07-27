@RestResource(urlMapping='/SyncGoogleEvents/*')
global class SyncGoogleEvents {
    @HttpPost
    global static void doPost(){
        System.debug('SyncGoogleEvents doPost');
        
        String reqBody=RestContext.request.requestBody.toString();
        system.debug(reqBody);
        
        reqBody=reqBody.replace('"end"','"endStr"');
        
        EventWrapper ew=(EventWrapper) JSON.deserialize(reqBody,EventWrapper.class);
        
        system.debug(JSON.serialize(ew));

        if(ew.orig==null) {
            // New Event request
        	Event ev=formatEvent(ew.updated, true, false);
            insert ev;
        } else if(ew.updated==null) {
            // Delete request
        	Event ev=formatEvent(ew.orig, false, true);
            ev.Calendar_Event_Status__c='Abgesagt';
            update ev;
        } else {
            // Update request
        	Event ev=formatEvent(ew.updated, false, false);
            update ev;
        }

        setResponse(200,'{"message":"Success"}');
    }

    public static Event formatEvent(EventDetails ed, Boolean isNew, Boolean isDelete) {
        System.debug('SyncGoogleEvents formatEvent');

        Event ev = new Event();
        if(!isNew) ev.Id = ed.record_id;
        if(isDelete) return ev;

        if(ed.event_type=='FirstAppointment') ev.Calendar_Event_Type__c = 'Ersttermin';
        else if(ed.event_type=='FollowingAppointment') ev.Calendar_Event_Type__c = 'Folgetermin';
        else if(ed.event_type=='SecondAppointment') ev.Calendar_Event_Type__c = 'Folgetermin';
        else if(ed.event_type=='ObjectAdmission') ev.Calendar_Event_Type__c = 'Objektaufnahme';
        else if(ed.event_type=='NotaryAppointment') ev.Calendar_Event_Type__c = 'Notartermin';

        ev.Subject = ed.subject;
        ev.Location = ed.location;
        ev.Description = ed.description;
        ev.StartDateTime = Datetime.valueOfGmt(ed.start.replace('T', ' ').replace('Z',''));
        ev.EndDateTime = Datetime.valueOfGmt(ed.endStr.replace('T', ' ').replace('Z','')); 

		if(ed.appointment_type=='OnSite') ev.Sub_Type__c = 'Vor-Ort-Termin	';
		else if(ed.appointment_type=='Call') ev.Sub_Type__c = 'Telefontermin';
		else if(ed.appointment_type=='Virtual') ev.Sub_Type__c = 'Virtual';

        ev.before_event__c = ed.before_event_id;
        ev.after_event__c = ed.after_event_id;
        ev.optimal_slot__c = ed.optimal_slot;
        try{ ev.travel_time__c = Double.valueOf(ed.travel_time); } catch (Exception e){system.debug(e.getMessage());}
        ev.current_user__c = ed.current_user;
        try{ ev.OwnerId = ed.owner_id; } catch (Exception e){system.debug(e.getMessage());}
        //ev.Calendar_Event_Type__c = ed.record_type;
        //ev.CreatedById = '0051t000003Uj7xAAC';

        return ev;
    }
    
    global static void setResponse(Integer stCode, String body){
        System.debug('SyncGoogleEvents setResponse');

        RestResponse res = RestContext.response;
        res.statusCode=stCode;
        res.responseBody=Blob.valueOf(body);
        
        System.debug(JSON.serialize(res));
    }
    
    public class EventWrapper {
        public String entity;
        public String source_service;
        public EventDetails orig;
        public EventDetails updated;
    }

    public class EventDetails {
        public String id;
        public String event_type;
        public String email; // What to bind with??
        public String subject;
        public String location;
        public String description;
        public String source;
        public String start;
        public String endStr;
        public String appointment_type;
        public String before_event_id;
        public String after_event_id;
        public Boolean optimal_slot;
        public String travel_time;
        public String current_user;
        public String owner_id;
        public String record_id;
        public String record_type;
        public String created_by_id;
    }
}