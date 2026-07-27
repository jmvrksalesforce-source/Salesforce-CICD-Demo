public class LearningHelper {
    
    public static Integer counter=0;
    
    public static void test(List<Learning__c> ls){
        counter++;
        for(Learning__c l:ls) {
            if(l.Index__c==50) l.Index__c=100;
            system.debug(l.Index__c);
        }
    }
}