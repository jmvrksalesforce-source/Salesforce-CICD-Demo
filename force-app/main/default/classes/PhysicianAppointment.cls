public class PhysicianAppointment {
    public static Integer weekIdx=0;
    public static Integer startingTime=800; //Visiting start time in HHMM format// Custom Label HospitalStartTime
    public static Integer closingTime=1700; //Visiting end time in HHMM format// Custom Label HospitalClosingTime
    public static Integer duration=60; //Consultation duration in Minutes // Custom Label HospitalConsulatingDuration
    public static Integer lunchHour=1300; //Lunch hour in HHMM format // Custom Label HospitalLunchHour
    
    public virtual class BaseException extends Exception {}
    
    @AuraEnabled
    public static String getAuthUrl(){
        String authUri = '';
        
        GoogleCalendar__c gc = GoogleCalendar__c.getInstance(Userinfo.getProfileId());
        
        authUri='https://accounts.google.com/o/oauth2/v2/auth?scope=https://www.googleapis.com/auth/calendar.events&access_type=offline&include_granted_scopes=true&response_type=code&state=state_parameter_passthrough_value';
        authUri +='&redirect_uri='+ gc.redirectUri__c;
        authUri +='&client_id='+ gc.clientId__c;
        
        return authUri;
    }
    
    @AuraEnabled
    public static String getPhysicians(String spec, Integer weekIdx, Integer offSet, String slotType, Integer recsPerPage, Date appDt, String srchDctr){
        //Get Physician data from contact
        try{
            if(appDt!=null && System.Date.today() > appDt) return 'Error- Please select a future date';
            //Check Google Authorization
            {
                GoogleCalendar__c gc = GoogleCalendar__c.getInstance(Userinfo.getProfileId());
                if(gc.Authorized__c==false) return 'Missing Custom Settings';
                if(gc.RefreshToken__c==null || gc.AccessToken__c==null) return 'Missing Google Authrization';
                if(gc.RefreshToken__c=='' || gc.AccessToken__c=='') return 'Missing Google Authrization';
            }
            
            try{
                startingTime = integer.valueOf(System.Label.HospitalStartTime);
                if(startingTime >= 2400 || startingTime < 100) throw new BaseException('Invalid Custom Label value HospitalStartTime: ' + startingTime);
                
                closingTime = integer.valueOf(System.Label.HospitalClosingTime);
                if(closingTime >= 2400 || closingTime < 100) throw new BaseException('Invalid Custom Label value HospitalClosingTime: ' + closingTime);
                
                if(startingTime >= closingTime) throw new BaseException('StartTime must be greater than CloseTime on Custom labels HospitalStartTime: ' + startingTime + ' & HospitalClosingTime:' + closingTime);
                
                duration = integer.valueOf(System.Label.HospitalConsulatingDuration);
                if(duration<15) duration = 15;
                lunchHour = integer.valueOf(System.Label.HospitalLunchHour);
                
                if(recsPerPage < 5) recsPerPage = 5;
                
            }catch(exception excp1){return 'Error- Static variable value is not numeric- ' + excp1.getMessage();}
            
            List<Specialization__c> spcs = new List<Specialization__c>();
            spcs = [select id, name from Specialization__c order by name];
            
            List<Contact> cnts = new List<Contact>();
            List<Contact> TotalContacts = new List<Contact>();
            if(spec!=null && spec!=''){
                Date sDt = Date.today();
                if(appDt!=null) sDt = appDt.addDays(weekIdx*7);
                Date eDt = sdt.addDays(7).addDays(weekIdx*7);
                
                String stDt = '' + sDt;
                String enDt = '' + eDt;
                stDt = stDt.substring(0, 10);
                enDt = enDt.substring(0, 10);
                
                String Query = '';
                Query += 'select id, Salutation, name, Title, Specialization__c, Specialization__r.name, Specialization__r.Appointment_Price__c, ';
                Query += '(select id, Subject, StartDateTime, EndDateTime from Events where ActivityDate >= '+ stDt + ' and ActivityDate <= ' + enDt + ' order by StartDateTime) ';
                Query += 'from Contact ';
                Query += 'where Specialization__r.name = \'' + spec + '\' ';
                if(srchDctr!=null && srchDctr!='') Query += 'and Name like \'%' + srchDctr + '%\' ';
                Query += 'order by name ';
                String cntQuery = Query;
                Query += 'limit  ' + recsPerPage + ' ';
                Query += 'offset ' + offSet*recsPerPage;

                cnts = database.query(Query);
                TotalContacts = Database.query(cntQuery);
            }
            
            if(spec!=null && spec !='' && cnts.size() == 0) return 'Info- No Physicians available';
            
            List<String> specs = new List<String>();
            Map<String,List<PhysicianAppointmentHelper.Physician>> specPhysMap = new Map<String,List<PhysicianAppointmentHelper.Physician>>();
            Map<String,List<PhysicianAppointmentHelper.Schedule>> scheduleMap = new Map<String,List<PhysicianAppointmentHelper.Schedule>>();
            
            for(Contact c:cnts){
                if(!specs.contains(c.Specialization__r.name)) Specs.add(c.Specialization__r.name);
                
                PhysicianAppointmentHelper.Physician p =new PhysicianAppointmentHelper.Physician();
                p.cntId=c.Id;
                p.Name=c.Name;
                p.Title=c.Title;
                p.Salutation = c.Salutation;
                p.Fee=c.Specialization__r.Appointment_Price__c;
                
                if(specPhysMap.containsKey(c.Specialization__r.name)){
                    List<PhysicianAppointmentHelper.Physician> Phs = new List<PhysicianAppointmentHelper.Physician>();
                    Phs = specPhysMap.get(c.Specialization__r.name);
                    Phs.add(p);
                    specPhysMap.remove(c.Specialization__r.name);
                    specPhysMap.put(c.Specialization__r.name,Phs);
                }else{
                    List<PhysicianAppointmentHelper.Physician> Phs = new List<PhysicianAppointmentHelper.Physician>();
                    Phs.add(p);
                    specPhysMap.put(c.Specialization__r.name,Phs);
                } 
                
                List<PhysicianAppointmentHelper.Schedule> templateSchds = new List<PhysicianAppointmentHelper.Schedule>();
                if(cnts.size() > 0) templateSchds = loadSchedule(weekIdx, appDt);
                
                //if(c.Events != null && c.Events.size() > 0 && templateSchds.size() > 0){
                PhysicianAppointmentHelper pah = new PhysicianAppointmentHelper(templateSchds, c.Events);
                scheduleMap.put(c.Id, pah.scheduleWithEvents(slotType));
                //} else scheduleMap.put(c.Id, templateSchds);
            }
            
            PhysicianAppointmentHelper.PhysicianInfo pi = new PhysicianAppointmentHelper.PhysicianInfo();
            pi.specPhysMap = new Map<String,List<PhysicianAppointmentHelper.Physician>>();
            pi.specializations = new List<String>();
            pi.fees = new List<Double>();
            pi.scheduleMap = new map<String,List<PhysicianAppointmentHelper.Schedule>>();
            
            pi.specializations = specs;
            pi.specPhysMap = specPhysMap;
            pi.scheduleMap = scheduleMap;
            pi.TotalRecs = TotalContacts.size();
            
            for(specialization__c sp:[select name, Appointment_Price__c from specialization__c]){
                if(!pi.specializations.contains(sp.Name)) {
                    pi.specializations.add(sp.Name);
                    pi.fees.add(sp.Appointment_Price__c);
                }
            }
            
            return JSON.serialize(pi);
        }catch(exception err) {return 'Error - Please contact support - ' + err.getMessage();}
    }
    
    public static List<PhysicianAppointmentHelper.Schedule> loadSchedule(Integer weekIdx, Date stDt){
        List<PhysicianAppointmentHelper.Schedule> lstSchedule = new List<PhysicianAppointmentHelper.Schedule>();
        
        DateTime dt;
        if(stDt!=null) dt = stDt.addDays(weekIdx*7);
        else dt = DateTime.now().addDays(weekIdx*7);
        dt = dt.addSeconds(UserInfo.getTimezone().getOffset(dt)/1000);
        DateTime dateLimit = dt.addDays(7);


        Time startTime = Time.newInstance(integer.valueOf(startingTime/100), math.mod(startingTime,100), 0, 0);
        Time closeTime = Time.newInstance(integer.valueOf(closingTime/100), math.mod(closingTime,100), 0, 0);
        Integer idx = 0;
        
        Time lunchStart = Time.newInstance(integer.valueOf(lunchHour/100), math.mod(lunchHour,100), 0, 0);
        Time lunchEnd = lunchStart.addHours(1);
        
        while(dt <= dateLimit){
            Time time1 = startTime;
            List<Boolean> availabilities = new List<Boolean>();
            List<String> slots = new List<String>();
            List<String> morningSlots = new List<String>();
            List<String> eveningSlots = new List<String>();
            List<DateTime> dateTimes = new List<DateTime>();
            
            Integer si = 0;

            while(time1 >= startTime && time1.addMinutes(duration) <= closeTime){
                if(time1 >= lunchEnd || time1.addMinutes(duration) <= lunchStart){
                    DateTime date1 = DateTime.newInstance(dt.year(), dt.month(), dt.day(), time1.hour(), time1.minute(), 0);
                    dateTimes.add(date1);
                    availabilities.add(True);
                    slots.add(date1.format('HH:mm'));
                    if(date1.hour()<12) morningSlots.add(date1.format('HH:mm'));
                    else eveningSlots.add(date1.format('HH:mm'));
                    si++;
                }
                time1 = time1.addMinutes(duration);
            }
            
            if(TRUE){
                PhysicianAppointmentHelper.Schedule sch = new PhysicianAppointmentHelper.Schedule();
                sch.monthDate = dt.format('MMM').toUpperCase() + ' ' + dt.day();
                sch.year = '' + dt.year();
                sch.day = dt.format('EEE').toUpperCase();
                sch.idx = idx;
                sch.slots = slots;
                sch.morningSlots = morningSlots;
                sch.eveningSlots = eveningSlots;
                //sch.availabilities = availabilities;
                sch.dateTimes = dateTimes;
                sch.duration = duration;
                lstSchedule.add(sch);
                idx++;
            }
            
            dt = dt.addDays(1);
        }
        
        return lstSchedule;
    }
    
    @AuraEnabled
    public static String createAppointment(Boolean createGCal, String cntId, String slot, String day, String monthDate, String year, String patientName, String email, String mobile, String subject, Double fee){
        
        try{
            
            List<Contact> cnts = [select id, Salutation, Email, Name, Title, Specialization__c, Specialization__r.name from contact where id=:cntId];
            //Create Google Calendar Event
            
            GoogleCalendar__c gc = GoogleCalendar__c.getInstance(Userinfo.getProfileId());
            
            if(cnts.size() == 0){
                return 'Error- Contact not found';
            } if(gc==null || gc.Authorized__c==false) {
                return 'Error- Not authorized to access Google credentials via Custom Settings';
            }else {
                
                contact c=cnts[0];
                
                String Description = 'Name: ' + patientName;
                Description += '\n email: ' + email;
                Description += '\n mobile: ' + mobile;
                
                String md = monthDate.replace('JAN ', '-01-');
                md = md.replace('FEB ', '-02-');
                md = md.replace('MAR ', '-03-');
                md = md.replace('APR ', '-04-');
                md = md.replace('MAY ', '-05-');
                md = md.replace('JUN ', '-06-');
                md = md.replace('JUL ', '-07-');
                md = md.replace('AUG ', '-08-');
                md = md.replace('SEP ', '-09-');
                md = md.replace('OCT ', '-10-');
                md = md.replace('NOV ', '-11-');
                md = md.replace('DEC ', '-12-');
                
                DateTime strtTime = datetime.valueOf(year+md+' '+slot+':00');
                DateTime endTime = strtTime.addMinutes(duration);
                
                String bd='{"summary":"'+subject + ' : ' + patientName +'","description":"'+subject+'","end":{"dateTime":"[EndTime]-00:00"},"start":{"dateTime":"[StartTime]-00:00"}}';
                //bd=bd.replace('summary', ''+subject);
                bd=bd.replace('[EndTime]', (''+endTime).replace(' ','T'));
                bd=bd.replace('[StartTime]', (''+strtTime).replace(' ','T'));
                
                String accessToken=gc.AccessToken__c;
                String gCalEventResult = '';
                String refreshtoken='';
                
                if(createGCal){
                    //Refresh AccessToken
                    try{
                        if(gc.RefreshToken__c!=null && gc.RefreshToken__c!=''){
                            
                            String body='';
                            body+='client_id='+gc.ClientId__c;
                            body+='&client_secret='+gc.ClientSecret__c;
                            body+='&refresh_token='+gc.RefreshToken__c;
                            body+='&grant_type=refresh_token';
                            
                            http h = new http();
                            httpRequest r=new httpRequest();
                            r.setMethod('POST');
                            r.setHeader('Content-type','application/x-www-form-urlencoded');
                            r.setBody(body);
                            r.setEndPoint('https://oauth2.googleapis.com/token');
                            httpResponse resp=h.send(r);
                            
                            System.JSONParser jp=JSON.createParser(resp.getBody());
                            while(jp.nextToken()!=null){
                                if(jp.getText()=='access_token'){
                                    jp.nextToken();
                                    accessToken=jp.getText();
                                }
                                if(jp.getText()=='refresh_token'){
                                    jp.nextToken();
                                    refreshtoken=jp.getText();
                                }
                            }
                            
                            integer sc=resp.getStatusCode();
                            if(sc==200 || sc==201){
                                //Success
                            } else {
                                return 'Error - while Refreshing the AccessToken ' + resp.getStatus().replaceAll(':','-');
                            }
                        }
                    }catch(Exception e){}
                    
                    //Create Google calendar Event
                    try{
                        String body = '';
                        http h = new http();
                        httpRequest r=new httpRequest();
                        r.setBody(bd);
                        r.setMethod('POST');
                        r.setHeader('Accept','application/json');
                        r.setHeader('Authorization','Bearer '+accessToken);
                        r.setHeader('Content-Type','application/json');
                        //r.setEndpoint(gc.ResourceURL__c.replace('[CALENDAR_ID]','jmvramakrishna@gmail.com'));
                        r.setEndpoint(gc.ResourceURL__c.replace('[CALENDAR_ID]',c.Email));
                        httpResponse resp=h.send(r);
                        integer sc=resp.getStatusCode();
                        if(sc==200 || sc==201){
                            //Success
                        } else if(sc==403 || sc==404){
                            return 'Insufficient Access :' + c.Email;
                        } else {
                            return 'Error - ' + resp.getStatus().replaceAll(':','-');
                        }
                    }catch(Exception e){}
                    
                    if(refreshtoken!=''){
                        gc.AccessToken__c = accessToken;
                        gc.RefreshToken__c = refreshtoken;
                        update gc;
                    }
                }
                
                //Create Salesforce Event
                Event e = new Event();
                e.WhoId = cntId;
                e.Subject = subject;
                e.StartDateTime = strtTime;
                e.EndDateTime = endTime;
                e.Description = Description;
                insert e;
                
                String htmlBody='Hello <b>' + patientName + '</b>, <br/><br/>';
                htmlBody+='Your Appointment has been confirmed. Please have the details specified below.<br/><br/>';
                htmlBody+='Physician: <b>' + c.Salutation + ' ' +  c.Name + '</b>';
                if(c.Title!=null && c.Title!='') htmlBody+='(' + c.Title + ')<br/>';
                if(c.Specialization__c!=null) htmlBody+='Specialization: <b>' + c.Specialization__r.name + '</b><br/>';
                htmlBody+='Appointment Date:<b>' + monthDate + ' ' + year + ' (' + day + ')</b><br/>';
                htmlBody+='Appointment Time:<b>' + slot +'</b> HRs<br/><br/>';
                htmlBody+='Please be available 10 mins before the schedule. In case of unavailability, Please inform us atleast 8 hours before the schedule. <br/><br/>';
                htmlBody+='Best Regards, <br/>';
                htmlBody+='<b>HealthCare Hospitals</b>';

                if(System.Label.SendEmail != 'True') return 'Success';
                
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                message.toAddresses = new String[] {email};
                    message.subject = 'Health Care Hospitals: Appointment confirmation - ' + monthDate + ' ' + slot;
                message.setHtmlBody(htmlBody);
                
                Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
                    Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
                
                if (results[0].success) {
                    return 'Success';
                } else {
                    return 'Error - The email failed to send: ' + results[0].errors[0].message;
                }
            }
        } catch (Exception ex) {return 'Error - ' + ex.getMessage();}
        
    }
    
    @AuraEnabled
    public static String sendGCalSharingRequest(String cntId){
        try{
            GoogleCalendar__c gc = GoogleCalendar__c.getInstance(Userinfo.getProfileId());
            
            Contact c = [select id, Salutation, Email, Name, Title, Specialization__r.name from contact where id=:cntId];
            
            String htmlBody='Dear <b>' + c.Salutation + ' ' + c.Name  + '</b>, <br/><br/>';
            htmlBody+='Health Care Hospitals is honored with your services as a <b>' + c.Specialization__r.Name + '</b> specialist. We would like to suggest the following for better and improved services.<br/><br/>';
            htmlBody+='As of now all appointments related to your consultation are available inside Salesforce. It is more efficient to save all events directly into your Google Calendar.<br/><br/>';
            htmlBody+='Hence, it is recomended to share your google calendar with Health Care Hospital\'s EmailId: <b>' + gc.RepEmail__c + '</b>.<br/><br/>';
            htmlBody+='You can also continue your services without sharing your Google calendar with us. However to monitor your schedules you have to login to Salesforce.<br/><br/>';
            htmlBody+='If you do not know about how to share your calendar then please follow this link ';
            htmlBody+='<a href=\'https://support.google.com/calendar/answer/37082?hl=en\'>How to share Google Calendar</a> <br/><br/>';
            htmlBody+='Please ignore this email if you have already shared your calendar.<br/><br/>';
            htmlBody+='Best Regards,<br/>';
            htmlBody+='Health Care Hospitals';
            
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.toAddresses = new String[] {c.Email};
                message.subject = 'Health Care Hospitals: Request for sharing Google Calendar ';
            message.setHtmlBody(htmlBody);

            if(System.Label.SendEmail != 'True') return 'Success';
            
            Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
                Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
            
            if (results[0].success) {
                return 'Success';
            } else {
                return 'Error - The email failed to send: ' + results[0].errors[0].message;
            }
        } catch (Exception ex) {return 'Error - ' + ex.getMessage();}
    }
}