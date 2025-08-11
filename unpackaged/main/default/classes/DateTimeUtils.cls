public with sharing class DateTimeUtils {

    private static Map<String, Set<Date>> integrationHolidays = new Map<String, Set<Date>>();
    private static Map<String, Set<Date>> holidaysForPreviousMonth = new Map<String, Set<Date>>();

    public static String getNameOfDay(Date dt) {
        return getNameOfDay(Datetime.newInstance(dt, Time.newInstance(0, 0, 0, 0)));
    }

    public static String getNameOfDay(Datetime dt) {
        return dt.format('EEEE'); //EEEE = Day of Week
    }

    public static Set<Date> getBankHolidaysFor(String processor) {
        if(integrationHolidays.containsKey(processor)) return integrationHolidays.get(processor);
        
        Set<Date> holidaySet = new Set<Date>();
        for (cmbls__Bank_Holiday__c holiday : [SELECT Name, cmbls__Holiday_Date__c, cmbls__ACH_Processor__c
                                                        FROM cmbls__Bank_Holiday__c
                                                        WHERE cmbls__Holiday_Date__c >= TODAY
                                                        AND (cmbls__Holiday_Date__c = THIS_YEAR OR cmbls__Holiday_Date__c = NEXT_YEAR)
                                                        AND (cmbls__ACH_Processor__c =:processor OR cmbls__ACH_Processor__c = 'All')]) {
            holidaySet.add(holiday.cmbls__Holiday_Date__c);
        }
    
        integrationHolidays.put(processor, holidaySet);
    
        return holidaySet;
    }

    public static Boolean isValidDate(Date dt, Set<Date> holidays) {
        String dayOfWeek = getNameOfDay(dt);
        if(dayOfWeek == 'Saturday' || dayOfWeek == 'Sunday') return false;
        if(holidays == null) holidays = getBankHolidaysFor('');
        return !holidays.contains(dt);
    }

    public static Boolean isWeekday(Date dt) {
        String dayOfWeek = getNameOfDay(dt);
        if(dayOfWeek == 'Saturday' || dayOfWeek == 'Sunday')  return false;
        return true;
    }

    public static Date getNextValidDate(Date dt) {
        return getNextValidDate(dt, '');
    }

    public static Date getNextValidDate(Date dt, String processor) {
        return getNextValidDate(dt, getBankHolidaysFor(processor));
    }

    public static Date getNextValidDate(Date dt, Set<Date> holidays) {
        return isValidDate(dt, holidays) ? dt : getNextValidDate(dt.addDays(1), holidays);
    }

    public static Date getNextWeekday(Date dt) {
        return isWeekday(dt) ? dt : getNextWeekday(dt.addDays(1));
    }
    
    public static String getSOQLDateFormat(Date dt){
        String month = '0' + dt.month();
        String day = '0' + dt.day();
        return dt.year() + '-' + month.right(2) + '-' + day.right(2);
    }
    
    public static String getCronExpressionForGivenDatetime(Datetime datetimeValue){
        String hour = String.valueOf(datetimeValue.hour());
        String min = String.valueOf(datetimeValue.minute());
        String day = String.valueOf(datetimeValue.day());
        String month = String.valueOf(datetimeValue.month());
        String year = String.valueOf(datetimeValue.year());
        //parse to cron expression
        return '0 ' + min + ' ' + hour + ' ' + day + ' ' + month + ' ? ' + year;
    }
    
    public static Date getMaxDate(Date date1, Date date2){
        if(date1 == null && date2 == null) return null;
        if(date1 == null && date2 != null) return date2;
        if(date1 != null && date2 == null) return date1;
        return (date1 > date2) ? date1 : date2;
    }

}