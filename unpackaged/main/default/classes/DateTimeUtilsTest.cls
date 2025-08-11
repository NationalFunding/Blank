/**
 * DateTimeUtilsTest class
 * @author CloudMyBiz (r)
 * @date 1/10/2023
 */

@IsTest
private class DateTimeUtilsTest{
    @IsTest
    static void getNameOfDay(){
        Date mondayJan9 = Date.newInstance(2023, 1,9);
        System.assertEquals('Monday', DateTimeUtils.getNameOfDay(mondayJan9));
        System.assertEquals(mondayJan9, DateTimeUtils.getNextValidDate(mondayJan9));
        System.assertEquals(mondayJan9, DateTimeUtils.getNextWeekday(mondayJan9));
    }
}