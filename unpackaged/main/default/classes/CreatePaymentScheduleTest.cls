/**
 * Created by oporter on 7/20/2018.
 */

//todo:: loop through all the payments and make sure the amount is correct
//todo:: loop through all the payments and make sure every payment day is the one that I expect but I can't say start date is today


@isTest
public with sharing class CreatePaymentScheduleTest {

    public static testMethod void monthlyPaymentFrequencyWeekDayTest() {
        CreatePaymentSchedule plugin = new CreatePaymentSchedule();
        Map<String, Object> inputParams = new Map<String, Object>();
        Payment_Agreement__c pa = new Payment_Agreement__c();
        insert pa;

        Decimal amount = 12;
        string frequency = 'Monthly';
        Date startDate = Date.today();
        Decimal numberOfPayments = 12;
        String inputPaymentAgreementId = pa.Id;
        InputParams.put('varAmount', amount); //Amount
        InputParams.put('varFrequency', frequency); //Frequency
        InputParams.put('varPaymentTotal', numberOfPayments); //Number_of_Payments
        InputParams.put('varStartDate', startDate); //Start_date
        InputParams.put('inputPaymentAgreementId', inputPaymentAgreementId); //Payment_Agreement__c record

        Process.PluginRequest request = new Process.PluginRequest(inputParams);
        plugin.invoke(request);

        List<Scheduled_Payment__c> testAmount = [SELECT Amount__c FROM Scheduled_Payment__c];

        Process.PluginDescribeResult result = plugin.describe();
        system.assertEquals([SELECT Count() FROM Scheduled_Payment__c], numberOfPayments, 'Validating the actual number of payments for monthly week day test');
        system.assertEquals(testAmount[0].Amount__c, amount, 'Validating that amount is equal');
    }

    public static testMethod void weeklyWeekDayTest(){
        CreatePaymentSchedule plugin = new CreatePaymentSchedule();
        Map<String, Object> inputParams = new Map<String, Object>();
        Payment_Agreement__c pa = new Payment_Agreement__c();
        insert pa;

        Decimal amount = 12;
        string frequency = 'Weekly';
        Date startDate = Date.today();
        Decimal numberOfPayments = 12;
        String inputPaymentAgreementId = pa.Id;
        InputParams.put('varAmount', amount); //Amount
        InputParams.put('varFrequency', frequency); //Frequency
        InputParams.put('varPaymentTotal', numberOfPayments); //Number_of_Payments
        InputParams.put('varStartDate', startDate); //Start_date
        InputParams.put('inputPaymentAgreementId', inputPaymentAgreementId); //Payment_Agreement__c record

        Process.PluginRequest request = new Process.PluginRequest(inputParams);

        plugin.invoke(request);
        List<Scheduled_Payment__c> testAmount = [SELECT Amount__c FROM Scheduled_Payment__c];

        Process.PluginDescribeResult result = plugin.describe();
        system.assertEquals([SELECT Count() FROM Scheduled_Payment__c], numberOfPayments, 'Validating the actual number of payments for monthly week day test');
        system.assertEquals(testAmount[0].Amount__c, amount, 'Validating that amount is equal');

    }
    public static testMethod void dailyWeekDayTest(){
        CreatePaymentSchedule plugin = new CreatePaymentSchedule();
        Map<String, Object> inputParams = new Map<String, Object>();
        Payment_Agreement__c pa = new Payment_Agreement__c();
        insert pa;

        Decimal amount = 12;
        string frequency = 'Daily';
        Date startDate = Date.today();
        Decimal numberOfPayments = 12;
        String inputPaymentAgreementId = pa.Id;
        InputParams.put('varAmount', amount); //Amount
        InputParams.put('varFrequency', frequency); //Frequency
        InputParams.put('varPaymentTotal', numberOfPayments); //Number_of_Payments
        InputParams.put('varStartDate', startDate); //Start_date
        InputParams.put('inputPaymentAgreementId', inputPaymentAgreementId); //Payment_Agreement__c record

        Process.PluginRequest request = new Process.PluginRequest(inputParams);

        plugin.invoke(request);
        List<Scheduled_Payment__c> testAmount = [SELECT Amount__c FROM Scheduled_Payment__c];

        Process.PluginDescribeResult result = plugin.describe();
        system.assertEquals([SELECT Count() FROM Scheduled_Payment__c], numberOfPayments, 'Validating the actual number of payments for monthly week day test');
        system.assertEquals(testAmount[0].Amount__c, amount, 'Validating that amount is equal');
    }
    public static testMethod void biWeeklyWeekDayTest(){
        CreatePaymentSchedule plugin = new CreatePaymentSchedule();
        Map<String, Object> inputParams = new Map<String, Object>();
        Payment_Agreement__c pa = new Payment_Agreement__c();
        insert pa;

        Decimal amount = 12;
        string frequency = 'Bi-Weekly';
        Date startDate = Date.today();
        Decimal numberOfPayments = 12;
        String inputPaymentAgreementId = pa.Id;
        InputParams.put('varAmount', amount); //Amount
        InputParams.put('varFrequency', frequency); //Frequency
        InputParams.put('varPaymentTotal', numberOfPayments); //Number_of_Payments
        InputParams.put('varStartDate', startDate); //Start_date
        InputParams.put('inputPaymentAgreementId', inputPaymentAgreementId); //Payment_Agreement__c record

        Process.PluginRequest request = new Process.PluginRequest(inputParams);

        plugin.invoke(request);
        List<Scheduled_Payment__c> testAmount = [SELECT Amount__c FROM Scheduled_Payment__c];

        Process.PluginDescribeResult result = plugin.describe();
        system.assertEquals([SELECT Count() FROM Scheduled_Payment__c], numberOfPayments, 'Validating the actual number of payments for monthly week day test');
        system.assertEquals(testAmount[0].Amount__c, amount, 'Validating that amount is equal');
    }
    public static testMethod void monthlyWeekndTest() {
        CreatePaymentSchedule plugin = new CreatePaymentSchedule();
        Map<String, Object> inputParams = new Map<String, Object>();
        Payment_Agreement__c pa = new Payment_Agreement__c();
        insert pa;

        Decimal amount = 12;
        string frequency = 'Monthly';
        Date startDate = Date.newInstance(2018, 11, 08);
        Decimal numberOfPayments = 12;
        String inputPaymentAgreementId = pa.Id;
        InputParams.put('varAmount', amount); //Amount
        InputParams.put('varFrequency', frequency); //Frequency
        InputParams.put('varPaymentTotal', numberOfPayments); //Number_of_Payments
        InputParams.put('varStartDate', startDate); //Start_date
        InputParams.put('inputPaymentAgreementId', inputPaymentAgreementId); //Payment_Agreement__c record

        Process.PluginRequest request = new Process.PluginRequest(inputParams);

        plugin.invoke(request);
        List<Scheduled_Payment__c> testAmount = [SELECT Amount__c FROM Scheduled_Payment__c];

        Process.PluginDescribeResult result = plugin.describe();
        system.assertEquals([SELECT Count() FROM Scheduled_Payment__c], numberOfPayments, 'Validating the actual number of payments for monthly week day test');
        system.assertEquals(testAmount[0].Amount__c, amount, 'Validating that amount is equal');
    }

    public static testMethod void weeklyWeekendTest(){
        CreatePaymentSchedule plugin = new CreatePaymentSchedule();
        Map<String, Object> inputParams = new Map<String, Object>();
        Payment_Agreement__c pa = new Payment_Agreement__c();
        insert pa;

        Decimal amount = 12;
        string frequency = 'Weekly';
        Date startDate = Date.newInstance(2018, 11, 08);
        Decimal numberOfPayments = 12;
        String inputPaymentAgreementId = pa.Id;
        InputParams.put('varAmount', amount); //Amount
        InputParams.put('varFrequency', frequency); //Frequency
        InputParams.put('varPaymentTotal', numberOfPayments); //Number_of_Payments
        InputParams.put('varStartDate', startDate); //Start_date
        InputParams.put('inputPaymentAgreementId', inputPaymentAgreementId); //Payment_Agreement__c record

        Process.PluginRequest request = new Process.PluginRequest(inputParams);

        plugin.invoke(request);
        List<Scheduled_Payment__c> testAmount = [SELECT Amount__c FROM Scheduled_Payment__c];

        Process.PluginDescribeResult result = plugin.describe();
        system.assertEquals([SELECT Count() FROM Scheduled_Payment__c], numberOfPayments, 'Validating the actual number of payments for monthly week day test');
        system.assertEquals(testAmount[0].Amount__c, amount, 'Validating that amount is equal');
    }
    public static testMethod void dailyWeekndTest(){
        CreatePaymentSchedule plugin = new CreatePaymentSchedule();
        Map<String, Object> inputParams = new Map<String, Object>();
        Payment_Agreement__c pa = new Payment_Agreement__c();
        insert pa;

        Decimal amount = 12;
        string frequency = 'Daily';
        Date startDate = Date.newInstance(2018, 11, 08);
        Decimal numberOfPayments = 12;
        String inputPaymentAgreementId = pa.Id;
        InputParams.put('varAmount', amount); //Amount
        InputParams.put('varFrequency', frequency); //Frequency
        InputParams.put('varPaymentTotal', numberOfPayments); //Number_of_Payments
        InputParams.put('varStartDate', startDate); //Start_date
        InputParams.put('inputPaymentAgreementId', inputPaymentAgreementId); //Payment_Agreement__c record

        Process.PluginRequest request = new Process.PluginRequest(inputParams);

        plugin.invoke(request);
        List<Scheduled_Payment__c> testAmount = [SELECT Amount__c FROM Scheduled_Payment__c];

        Process.PluginDescribeResult result = plugin.describe();
        system.assertEquals([SELECT Count() FROM Scheduled_Payment__c], numberOfPayments, 'Validating the actual number of payments for monthly week day test');
        system.assertEquals(testAmount[0].Amount__c, amount, 'Validating that amount is equal');
    }
    public static testMethod void biWeeklyWeekendTest(){
        CreatePaymentSchedule plugin = new CreatePaymentSchedule();
        Map<String, Object> inputParams = new Map<String, Object>();
        Payment_Agreement__c pa = new Payment_Agreement__c();
        insert pa;

        Decimal amount = 12;
        string frequency = 'Bi-Weekly';
        Date startDate = Date.newInstance(2018, 11, 08);
        Decimal numberOfPayments = 12;
        String inputPaymentAgreementId = pa.Id;
        InputParams.put('varAmount', amount); //Amount
        InputParams.put('varFrequency', frequency); //Frequency
        InputParams.put('varPaymentTotal', numberOfPayments); //Number_of_Payments
        InputParams.put('varStartDate', startDate); //Start_date
        InputParams.put('inputPaymentAgreementId', inputPaymentAgreementId); //Payment_Agreement__c record

        Process.PluginRequest request = new Process.PluginRequest(inputParams);

        plugin.invoke(request);
        List<Scheduled_Payment__c> testAmount = [SELECT Amount__c FROM Scheduled_Payment__c];

        Process.PluginDescribeResult result = plugin.describe();
        system.assertEquals([SELECT Count() FROM Scheduled_Payment__c], numberOfPayments, 'Validating the actual number of payments for monthly week day test');
        system.assertEquals(testAmount[0].Amount__c, amount, 'Validating that amount is equal');
    }

    public static testMethod void monthlyWeekndSunTest() {
        CreatePaymentSchedule plugin = new CreatePaymentSchedule();
        Map<String, Object> inputParams = new Map<String, Object>();
        Payment_Agreement__c pa = new Payment_Agreement__c();
        insert pa;

        Decimal amount = 12;
        string frequency = 'Monthly';
        Date startDate = Date.newInstance(2018, 08, 12);
        Decimal numberOfPayments = 12;
        String inputPaymentAgreementId = pa.Id;
        InputParams.put('varAmount', amount); //Amount
        InputParams.put('varFrequency', frequency); //Frequency
        InputParams.put('varPaymentTotal', numberOfPayments); //Number_of_Payments
        InputParams.put('varStartDate', startDate); //Start_date
        InputParams.put('inputPaymentAgreementId', inputPaymentAgreementId); //Payment_Agreement__c record

        Process.PluginRequest request = new Process.PluginRequest(inputParams);

        plugin.invoke(request);
        List<Scheduled_Payment__c> testAmount = [SELECT Amount__c FROM Scheduled_Payment__c];

        Process.PluginDescribeResult result = plugin.describe();
        system.assertEquals([SELECT Count() FROM Scheduled_Payment__c], numberOfPayments, 'Validating the actual number of payments for monthly week day test');
        system.assertEquals(testAmount[0].Amount__c, amount, 'Validating that amount is equal');
    }

    public static testMethod void weeklyWeekendSunTest(){
        CreatePaymentSchedule plugin = new CreatePaymentSchedule();
        Map<String, Object> inputParams = new Map<String, Object>();
        Payment_Agreement__c pa = new Payment_Agreement__c();
        insert pa;

        Decimal amount = 12;
        string frequency = 'Weekly';
        Date startDate = Date.newInstance(2018, 08, 12);
        Decimal numberOfPayments = 12;
        String inputPaymentAgreementId = pa.Id;
        InputParams.put('varAmount', amount); //Amount
        InputParams.put('varFrequency', frequency); //Frequency
        InputParams.put('varPaymentTotal', numberOfPayments); //Number_of_Payments
        InputParams.put('varStartDate', startDate); //Start_date
        InputParams.put('inputPaymentAgreementId', inputPaymentAgreementId); //Payment_Agreement__c record

        Process.PluginRequest request = new Process.PluginRequest(inputParams);

        plugin.invoke(request);
        List<Scheduled_Payment__c> testAmount = [SELECT Amount__c FROM Scheduled_Payment__c];

        Process.PluginDescribeResult result = plugin.describe();
        system.assertEquals([SELECT Count() FROM Scheduled_Payment__c], numberOfPayments, 'Validating the actual number of payments for monthly week day test');
        system.assertEquals(testAmount[0].Amount__c, amount, 'Validating that amount is equal');
    }
    public static testMethod void dailyWeekndSunTest(){
        CreatePaymentSchedule plugin = new CreatePaymentSchedule();
        Map<String, Object> inputParams = new Map<String, Object>();
        Payment_Agreement__c pa = new Payment_Agreement__c();
        insert pa;

        Decimal amount = 12;
        string frequency = 'Daily';
        Date startDate = Date.newInstance(2018, 08, 12);
        Decimal numberOfPayments = 12;
        String inputPaymentAgreementId = pa.Id;
        InputParams.put('varAmount', amount); //Amount
        InputParams.put('varFrequency', frequency); //Frequency
        InputParams.put('varPaymentTotal', numberOfPayments); //Number_of_Payments
        InputParams.put('varStartDate', startDate); //Start_date
        InputParams.put('inputPaymentAgreementId', inputPaymentAgreementId); //Payment_Agreement__c record

        Process.PluginRequest request = new Process.PluginRequest(inputParams);

        plugin.invoke(request);
        List<Scheduled_Payment__c> testAmount = [SELECT Amount__c FROM Scheduled_Payment__c];

        Process.PluginDescribeResult result = plugin.describe();
        system.assertEquals([SELECT Count() FROM Scheduled_Payment__c], numberOfPayments, 'Validating the actual number of payments for monthly week day test');
        system.assertEquals(testAmount[0].Amount__c, amount, 'Validating that amount is equal');
    }
    public static testMethod void biWeeklyWeekendSunTest(){
        CreatePaymentSchedule plugin = new CreatePaymentSchedule();
        Map<String, Object> inputParams = new Map<String, Object>();
        Payment_Agreement__c pa = new Payment_Agreement__c();
        insert pa;

        Decimal amount = 12;
        string frequency = 'Bi-Weekly';
        Date startDate = Date.newInstance(2018, 08, 12);
        Decimal numberOfPayments = 12;
        String inputPaymentAgreementId = pa.Id;
        InputParams.put('varAmount', amount); //Amount
        InputParams.put('varFrequency', frequency); //Frequency
        InputParams.put('varPaymentTotal', numberOfPayments); //Number_of_Payments
        InputParams.put('varStartDate', startDate); //Start_date
        InputParams.put('inputPaymentAgreementId', inputPaymentAgreementId); //Payment_Agreement__c record

        Process.PluginRequest request = new Process.PluginRequest(inputParams);

        plugin.invoke(request);
        List<Scheduled_Payment__c> testAmount = [SELECT Amount__c FROM Scheduled_Payment__c];

        Process.PluginDescribeResult result = plugin.describe();
        system.assertEquals([SELECT Count() FROM Scheduled_Payment__c], numberOfPayments, 'Validating the actual number of payments for monthly week day test');
        system.assertEquals(testAmount[0].Amount__c, amount, 'Validating that amount is equal');
    }
}