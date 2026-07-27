public class PhysicianAppointmentHelper {
    List<Schedule> templateSchds;
    List<Event> events;
    
    //Constructor
    public PhysicianAppointmentHelper(List<Schedule> templateSchds, List<Event> events){
        this.events = events;
        this.templateSchds = templateSchds;
    }
    
    //Wrapper Physicians Data
    public class PhysicianInfo{
        public List<String> specializations;
        public List<Double> fees;
        public Integer TotalRecs;
        public Map<String,List<Physician>> specPhysMap; //Each Specialization Vs List of Physicians
        public Map<String,List<Schedule>> scheduleMap; //Each Physician Vs Schedule
    }
    
    //Wrapper Schedule for each day
    public class Schedule{
        public Integer idx;
        public String monthDate;
        public String year;
        public String day;
        public Integer duration;
        public List<String> slots;
        public List<String> morningSlots;
        public List<String> eveningSlots;
        public List<DateTime> dateTimes;
        //public List<String> noon;
        //public List<Boolean> availabilities;
        //public Id eventId;
        //public String subject;
    }
    
    public class Physician{
        public String cntId;
        public String Salutation;
        public String Name;
        public String Title;
        public Decimal Fee;
    }
    
    public List<Schedule> scheduleWithEvents(String slotType){
        // This method embeds Events in the schedule of an individual person
        integer i=0, j=0, k=0, m=0, n=0;
        
        if(events!=null && templateSchds!=null){
            while(i < templateSchds.size() && k < events.size()){
                while(j < templateSchds[i].DateTimes.size() && k < events.size()){
                    DateTime dt = templateSchds[i].DateTimes[j];
                    if(dt >= events[k].EndDateTime){
                        k++;
                    }
                    else if(dt.addMinutes(PhysicianAppointment.duration) <= events[k].startDateTime){
                        j++;
                    }
                    else {
                        //String subject = events[k].subject;
                        templateSchds[i].slots[j] = 'Busy';
                        if(dt.hour() < 12){
                            templateSchds[i].morningSlots[j] = 'Busy';
                            m++;
                        }
                        else {
                            n=j - templateSchds[i].morningSlots.size();
                            templateSchds[i].eveningSlots[n] = 'Busy';
                        }
                        //templateSchds[i].availabilities[j] = false;
                        j++;
                    }
                }
                j=0;
                m=0;
                n=0;
                i++;
            }
        }
        
        //remove other slots to reduce cache size
        for(Schedule schd:templateSchds){
            schd.slots = null;
            if(slotType=='Morning') schd.eveningSlots = null;
            else if(slotType=='Evening') schd.morningSlots = null;
        }
        
        return templateSchds;
    }
}