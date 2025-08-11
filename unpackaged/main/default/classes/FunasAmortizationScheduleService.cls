/**
 * FunasAmortizationScheduleService class
 * @author CloudMyBiz (r)
 * @date 14/06/2022
 * @description
 * @group 
 */

public inherited sharing class FunasAmortizationScheduleService {

    static String testCalloutResponse = '{"TV_LOAN_EVENT_CODE":{"TVPaymentEvent":9,"TVLoanEvent":8,"TVRateChangeEvent":4},"TV_LINE_TYPE_LABEL":{"9":"TVPaymentLine","8":"TVLoanLine","4":"TVRateChangeLine"},"TV_COMPUTE_METHOD_CODE":{"TVCanadianAmortization":3,"TVUSRuleAmortization":2,"TVRule78Amortization":1,"TVNormalAmortization":0},"TV_COMPOUNDING_CODE_MONTHS":{"TVAnnualCompound":12,"TVSemiannualCompound":6,"TVFourMonthCompound":4,"TVQuarterlyCompound":3,"TVTwoMonthCompound":2,"TVMonthlyCompound":1},"TV_COMPOUNDING_CODE_DAYS":{"TVFourWeekCompound":28,"TVHalfMonthCompound":15,"TVBiWeeklyCompound":14,"TVWeeklyCompound":7,"TVDailyCompound":1},"TV_COMPOUNDING_CODE":{"TVNoCompound":13,"TVAnnualCompound":12,"TVSemiannualCompound":11,"TVFourWeekCompound":10,"TVFourMonthCompound":9,"TVQuarterlyCompound":8,"TVTwoMonthCompound":7,"TVMonthlyCompound":6,"TVHalfMonthCompound":5,"TVBiWeeklyCompound":4,"TVWeeklyCompound":3,"TVDailyCompound":2,"TVExactDaysCompound":1,"TVContinuousCompound":0},"totalPayments":102919.98,"totalLoan":100000,"totalInterest":2919.98,"totalFee":0,"statusCode":null,"SPECIAL_SERIES_INTEREST_ONLY":"<EventSpecialSeries><SSInterestOnly></SSInterestOnly></EventSpecialSeries>","roundingAmount":-0.02,"nominalRate":0.156221,"lineItems":[{"item":{"attributes":{"type":"funas__Amortization_Schedule_Line_Item__c"},"funas__Line_Type__c":"TVLoanLine","funas__Date__c":"2022-02-01","funas__Amount__c":null,"funas__Interest__c":0,"funas__Principal__c":0,"funas__Balance__c":100000,"funas__Rate__c":null,"funas__Line_Number__c":1}},{"item":{"attributes":{"type":"funas__Amortization_Schedule_Line_Item__c"},"funas__Line_Type__c":"TVPaymentLine","funas__Date__c":"2022-02-02","funas__Amount__c":5146,"funas__Interest__c":43.39,"funas__Principal__c":5102.61,"funas__Balance__c":94897.39,"funas__Rate__c":null,"funas__Line_Number__c":2}},{"item":{"attributes":{"type":"funas__Amortization_Schedule_Line_Item__c"},"funas__Line_Type__c":"TVPaymentLine","funas__Date__c":"2022-02-09","funas__Amount__c":5146,"funas__Interest__c":285.1,"funas__Principal__c":4860.9,"funas__Balance__c":90036.49,"funas__Rate__c":null,"funas__Line_Number__c":3}},{"item":{"attributes":{"type":"funas__Amortization_Schedule_Line_Item__c"},"funas__Line_Type__c":"TVPaymentLine","funas__Date__c":"2022-02-16","funas__Amount__c":5146,"funas__Interest__c":270.49,"funas__Principal__c":4875.51,"funas__Balance__c":85160.98,"funas__Rate__c":null,"funas__Line_Number__c":4}},{"item":{"attributes":{"type":"funas__Amortization_Schedule_Line_Item__c"},"funas__Line_Type__c":"TVPaymentLine","funas__Date__c":"2022-02-23","funas__Amount__c":5146,"funas__Interest__c":255.84,"funas__Principal__c":4890.16,"funas__Balance__c":80270.82,"funas__Rate__c":null,"funas__Line_Number__c":5}},{"item":{"attributes":{"type":"funas__Amortization_Schedule_Line_Item__c"},"funas__Line_Type__c":"TVPaymentLine","funas__Date__c":"2022-03-02","funas__Amount__c":5146,"funas__Interest__c":241.15,"funas__Principal__c":4904.85,"funas__Balance__c":75365.97,"funas__Rate__c":null,"funas__Line_Number__c":6}},{"item":{"attributes":{"type":"funas__Amortization_Schedule_Line_Item__c"},"funas__Line_Type__c":"TVPaymentLine","funas__Date__c":"2022-03-09","funas__Amount__c":5146,"funas__Interest__c":226.42,"funas__Principal__c":4919.58,"funas__Balance__c":70446.39,"funas__Rate__c":null,"funas__Line_Number__c":7}},{"item":{"attributes":{"type":"funas__Amortization_Schedule_Line_Item__c"},"funas__Line_Type__c":"TVPaymentLine","funas__Date__c":"2022-03-16","funas__Amount__c":5146,"funas__Interest__c":211.64,"funas__Principal__c":4934.36,"funas__Balance__c":65512.03,"funas__Rate__c":null,"funas__Line_Number__c":8}},{"item":{"attributes":{"type":"funas__Amortization_Schedule_Line_Item__c"},"funas__Line_Type__c":"TVPaymentLine","funas__Date__c":"2022-03-23","funas__Amount__c":5146,"funas__Interest__c":196.81,"funas__Principal__c":4949.19,"funas__Balance__c":60562.84,"funas__Rate__c":null,"funas__Line_Number__c":9}},{"item":{"attributes":{"type":"funas__Amortization_Schedule_Line_Item__c"},"funas__Line_Type__c":"TVPaymentLine","funas__Date__c":"2022-03-30","funas__Amount__c":5146,"funas__Interest__c":181.95,"funas__Principal__c":4964.05,"funas__Balance__c":55598.79,"funas__Rate__c":null,"funas__Line_Number__c":10}},{"item":{"attributes":{"type":"funas__Amortization_Schedule_Line_Item__c"},"funas__Line_Type__c":"TVPaymentLine","funas__Date__c":"2022-04-06","funas__Amount__c":5146,"funas__Interest__c":167.03,"funas__Principal__c":4978.97,"funas__Balance__c":50619.82,"funas__Rate__c":null,"funas__Line_Number__c":11}},{"item":{"attributes":{"type":"funas__Amortization_Schedule_Line_Item__c"},"funas__Line_Type__c":"TVPaymentLine","funas__Date__c":"2022-04-13","funas__Amount__c":5146,"funas__Interest__c":152.07,"funas__Principal__c":4993.93,"funas__Balance__c":45625.89,"funas__Rate__c":null,"funas__Line_Number__c":12}},{"item":{"attributes":{"type":"funas__Amortization_Schedule_Line_Item__c"},"funas__Line_Type__c":"TVPaymentLine","funas__Date__c":"2022-04-20","funas__Amount__c":5146,"funas__Interest__c":137.07,"funas__Principal__c":5008.93,"funas__Balance__c":40616.96,"funas__Rate__c":null,"funas__Line_Number__c":13}},{"item":{"attributes":{"type":"funas__Amortization_Schedule_Line_Item__c"},"funas__Line_Type__c":"TVPaymentLine","funas__Date__c":"2022-04-27","funas__Amount__c":5146,"funas__Interest__c":122.02,"funas__Principal__c":5023.98,"funas__Balance__c":35592.98,"funas__Rate__c":null,"funas__Line_Number__c":14}},{"item":{"attributes":{"type":"funas__Amortization_Schedule_Line_Item__c"},"funas__Line_Type__c":"TVPaymentLine","funas__Date__c":"2022-05-04","funas__Amount__c":5146,"funas__Interest__c":106.93,"funas__Principal__c":5039.07,"funas__Balance__c":30553.91,"funas__Rate__c":null,"funas__Line_Number__c":15}},{"item":{"attributes":{"type":"funas__Amortization_Schedule_Line_Item__c"},"funas__Line_Type__c":"TVPaymentLine","funas__Date__c":"2022-05-11","funas__Amount__c":5146,"funas__Interest__c":91.79,"funas__Principal__c":5054.21,"funas__Balance__c":25499.7,"funas__Rate__c":null,"funas__Line_Number__c":16}},{"item":{"attributes":{"type":"funas__Amortization_Schedule_Line_Item__c"},"funas__Line_Type__c":"TVPaymentLine","funas__Date__c":"2022-05-18","funas__Amount__c":5146,"funas__Interest__c":76.61,"funas__Principal__c":5069.39,"funas__Balance__c":20430.31,"funas__Rate__c":null,"funas__Line_Number__c":17}},{"item":{"attributes":{"type":"funas__Amortization_Schedule_Line_Item__c"},"funas__Line_Type__c":"TVPaymentLine","funas__Date__c":"2022-05-25","funas__Amount__c":5146,"funas__Interest__c":61.38,"funas__Principal__c":5084.62,"funas__Balance__c":15345.69,"funas__Rate__c":null,"funas__Line_Number__c":18}},{"item":{"attributes":{"type":"funas__Amortization_Schedule_Line_Item__c"},"funas__Line_Type__c":"TVPaymentLine","funas__Date__c":"2022-06-01","funas__Amount__c":5146,"funas__Interest__c":46.1,"funas__Principal__c":5099.9,"funas__Balance__c":10245.79,"funas__Rate__c":null,"funas__Line_Number__c":19}},{"item":{"attributes":{"type":"funas__Amortization_Schedule_Line_Item__c"},"funas__Line_Type__c":"TVPaymentLine","funas__Date__c":"2022-06-08","funas__Amount__c":5146,"funas__Interest__c":30.78,"funas__Principal__c":5115.22,"funas__Balance__c":5130.57,"funas__Rate__c":null,"funas__Line_Number__c":20}},{"item":{"attributes":{"type":"funas__Amortization_Schedule_Line_Item__c"},"funas__Line_Type__c":"TVPaymentLine","funas__Date__c":"2022-06-15","funas__Amount__c":5145.98,"funas__Interest__c":15.41,"funas__Principal__c":5130.57,"funas__Balance__c":0,"funas__Rate__c":null,"funas__Line_Number__c":21}}],"HasInterestOnly":null,"events":[{"locked":false,"event":{"attributes":{"type":"funas__Amortization_Schedule_Event__c"},"funas__Amortization_Schedule_Setup__c":null,"funas__Event_Number__c":5,"funas__Start_Date__c":"2022-02-01","funas__Period__c":"TVWeeklyCompound","funas__Number_of_Repeats__c":1,"funas__Event_Type__c":"TVLoanEvent","funas__Amount__c":100000.0}},{"locked":false,"event":{"attributes":{"type":"funas__Amortization_Schedule_Event__c"},"funas__Amortization_Schedule_Setup__c":null,"funas__Event_Number__c":5,"funas__Start_Date__c":"2022-02-02","funas__Period__c":"TVWeeklyCompound","funas__Number_of_Repeats__c":20,"funas__Event_Type__c":"TVPaymentEvent","funas__Amount__c":5146.0}}],"errorMessage":null,"amortizationSchedule":{"attributes":{"type":"funas__Amortization_Schedule_Setup__c"},"funas__Year_Length__c":"360","funas__Version_No__c":null,"funas__TargetObjectId__c":"RPMT-0000049","funas__Remaining_Amount_Rounding_Method__c":"TVRoundingSystemDefault","funas__Is_Active__c":true,"funas__Nominal_Rate__c":null,"funas__Compounding__c":"TVWeeklyCompound","funas__Compute_Method__c":"TVNormalAmortization","funas__Specific_Line_Rounding_Adjust_Type__c":"TVSpecificLineAdjustAllAmounts"}}';
    public static Map<String, funas__Amortization_Schedule_Setup__c> getAmortizationScheduleSetup(List<cmbls__Repayment__c> repayments){

        Map<String, cmbls__Repayment__c> repByNames = new Map<String, cmbls__Repayment__c>();
        Map<String, cmbls__Repayment__c> repByIds = new Map<String, cmbls__Repayment__c>();
        for(cmbls__Repayment__c rep : repayments){
            repByNames.put(rep.Name, rep);
            repByIds.put(rep.Id, rep);
        }

        Map<String, funas__Amortization_Schedule_Setup__c> mapAmortScheduleFromDB = new Map<String, funas__Amortization_Schedule_Setup__c>();
        for(funas__Amortization_Schedule_Setup__c amortScheduleSetup : [SELECT Id, funas__Year_Length__c, funas__Version_No__c, funas__TargetObjectId__c,
                funas__Remaining_Amount_Rounding_Method__c, funas__Nominal_Rate__c, funas__Is_Active__c
        FROM funas__Amortization_Schedule_Setup__c
        WHERE (funas__TargetObjectId__c IN : repByNames.keySet() OR funas__TargetObjectId__c IN : repByIds.keySet()) AND funas__Is_Active__c = TRUE]){
            mapAmortScheduleFromDB.put(amortScheduleSetup.funas__TargetObjectId__c, amortScheduleSetup);
        }

        Map<String, funas__Amortization_Schedule_Setup__c> mapRetAmortSchedule = new Map<String, funas__Amortization_Schedule_Setup__c>();
        for(cmbls__Repayment__c repayment : repayments){
            funas__Amortization_Schedule_Setup__c amortizationScheduleSetup = mapAmortScheduleFromDB.get(repayment.Id);
            if(amortizationScheduleSetup == null) amortizationScheduleSetup = mapAmortScheduleFromDB.get(repayment.Name);
            amortizationScheduleSetup = setAmortizationScheduleSetupWithRepayment(amortizationScheduleSetup, repayment);
            mapRetAmortSchedule.put(amortizationScheduleSetup.funas__TargetObjectId__c, amortizationScheduleSetup);
        }

        return mapRetAmortSchedule;
    }

    public static Map<String, List<funas__Amortization_Schedule_Event__c>> getAmortizationScheduleEvents(List<cmbls__Repayment__c> repayments){
        Map<String, List<funas__Amortization_Schedule_Event__c>> mapAmortScheduleEventsByRepayment = new Map<String, List<funas__Amortization_Schedule_Event__c>>();
        for(cmbls__Repayment__c repayment : repayments){
            List<funas__Amortization_Schedule_Event__c> events = new List<funas__Amortization_Schedule_Event__c>();
            // Loan Event
            events.add(createAmortizationScheduleEvent(Constant.FUNAS_EVENT_TYPE_LOAN, repayment.cmbls__Funding_Amount__c,
                    repayment.cmbls__Loan_Start_Date__c, getEventPeriod(repayment.cmbls__Interest_Accrual_Frequency__c), 1, 1));

            Integer eventNumber = 2;
            // Events based on invoices
            if(repayment.cmbls__Invoices__r != null && !repayment.cmbls__Invoices__r.isEmpty()){
                for(cmbls__Invoice__c invoice : repayment.cmbls__Invoices__r){
                    events.add(createAmortizationScheduleEvent(Constant.FUNAS_EVENT_TYPE_PAYMENT, invoice.cmbls__Total__c,
                        invoice.cmbls__Invoice_Date__c, getEventPeriod(repayment.cmbls__Interest_Accrual_Frequency__c), eventNumber, 1));
                    eventNumber++;
                }
            }

            // Event for payment to be calculated
            events.add(createAmortizationScheduleEvent(Constant.FUNAS_EVENT_TYPE_PAYMENT, repayment.cmbls__Payment_Amount__c,
                        repayment.cmbls__Next_Invoice_Date__c, getEventPeriod(repayment.cmbls__Interest_Accrual_Frequency__c), eventNumber, null));

            mapAmortScheduleEventsByRepayment.put(repayment.Name, events);
        }

        return mapAmortScheduleEventsByRepayment;
    }

    public static void deleteAmortizationScheduleByParent(List<cmbls__Repayment__c> repayments){
        delete [SELECT Id FROM cmbls__Amortization_Schedule__c WHERE cmbls__Repayment__c IN : repayments];
    }

    public static String calculateFunasAmortization(String asSetup) {
        FunasCallableAdapter adapterController = FunasCallableAdapter.getController();
        Map<String, Object> asSetupMap = new Map<String, Object>();
        //System.debug('Data sent to FUNAS: ' + JSON.serialize(asSetup));
        asSetupMap.put('asSetup', asSetup);
        return !Test.isRunningTest() ? (String)adapterController.call('calculate', asSetupMap) : testCalloutResponse;
    }

    public static cmbls__Amortization_Schedule__c[] parseAmortizationSchedules(String setupString, cmbls__Repayment__c repayment) {

        cmbls__Amortization_Schedule__c[] aSchedules = new cmbls__Amortization_Schedule__c[]{};
        Map<String, Object> serviceResponse = (Map<String, Object>)JSON.deserializeUntyped(setupString);

        // Sets Repayment data
        Database.DMLOptions dmlOptions = new Database.DMLOptions();
        dmlOptions.allowFieldTruncation = true;
        repayment.setOptions(dmlOptions);
        Double nominalRate = (Double)serviceResponse.get('nominalRate');
        repayment.cmbls__Current_Interest_Rate__c = nominalRate != null ? nominalRate * 100 : repayment.cmbls__Current_Interest_Rate__c;

        String statusCode = (String)serviceResponse.get('statusCode');
        String errorMessage = (String)serviceResponse.get('errorMessage');
        String header = 'FUNAS Amortization execution on ' + Date.today().format();
        Boolean amortResponseWithErrors = String.isNotBlank(statusCode) || String.isNotBlank(errorMessage);
        header += amortResponseWithErrors ? (' with errors: Status Code (' + statusCode + '), error message (' + errorMessage) + ')' : ' successfully.';
        repayment.FUNAS_Execution_Result__c = header  + ' \n Callout response: ' + JSON.serializePretty(serviceResponse);
        // If no errors, then we set the flag to false so it's not pulled again by the next job run.
        if(!amortResponseWithErrors) repayment.Generate_FUNAS_Amortization_Schedule__c = false;

        List<Object> lineItems = (List<Object>)serviceResponse.get('lineItems');
        if (lineItems != null) {
            for (Object lineItem : lineItems) {
                aSchedules.add(getASchedule((Map<String, Object>)lineItem, repayment));
            }
        }

        if(!aSchedules.isEmpty()) repayment.cmbls__Maturity_Date__c = aSchedules.get(aSchedules.size() - 1).cmbls__Date__c;
        return aSchedules;
    }

    public static cmbls__Amortization_Schedule__c getASchedule(Map<String, Object> lineItem, cmbls__Repayment__c repayment) {
        Map<String, Object> item = (Map<String, Object>)lineItem.get('item');
        cmbls__Amortization_Schedule__c aSchedule = new cmbls__Amortization_Schedule__c();
        aSchedule.cmbls__Repayment__c = repayment.Id;
        aSchedule.cmbls__Balance__c = (Double)item.get('funas__Balance__c');
        aSchedule.cmbls__Date__c = Date.valueOf((String)item.get('funas__Date__c'));
        aSchedule.cmbls__Interest_Payment__c = (Double)item.get('funas__Interest__c');
        aSchedule.cmbls__Type__c = (String)item.get('funas__Line_Type__c');
        aSchedule.cmbls__Payment_Amount__c = (Double)item.get('funas__Amount__c');
        aSchedule.cmbls__Principal_Payment__c = (Double)item.get('funas__Principal__c');
        aSchedule.cmbls__Payment_Number__c = (Integer)item.get('funas__Line_Number__c') == null ? 0 : (Integer)item.get('funas__Line_Number__c') - 1;
        return aSchedule;
    }

    private static funas__Amortization_Schedule_Event__c createAmortizationScheduleEvent(String eventType, Decimal amount, Date startDate,
            String period, Integer eventNumber, Integer numberOfRepeats){
        funas__Amortization_Schedule_Event__c amortizationScheduleEvent = new funas__Amortization_Schedule_Event__c(
            funas__Start_Date__c = startDate,
            funas__Event_Type__c = eventType,
            funas__Period__c = period,
            funas__Number_of_Repeats__c = numberOfRepeats,
            funas__Amount__c = amount,
            funas__Event_Number__c = eventNumber
        );
        return amortizationScheduleEvent;
    }

    private static String getEventPeriod(String accrualFrequency){
        // Daily doesn't have its own value so it must be TVWeeklyCompound and do a hack around events creation per each payment day.
        //TODO: Ask BA if we want to support daily, if so, we need to create a payment event for each day?
        if (accrualFrequency == Constant.INTEREST_ACCRUAL_FREQUENCY_DAILY || accrualFrequency == Constant.INTEREST_ACCRUAL_FREQUENCY_WEEKLY) {
            return Constant.FUNAS_EVENT_PERIOD_WEEKLY;
        }
        return Constant.FUNAS_EVENT_PERIOD_MONTHLY;
    }

    private static funas__Amortization_Schedule_Setup__c setAmortizationScheduleSetupWithRepayment(funas__Amortization_Schedule_Setup__c amortiScheduleSetup, cmbls__Repayment__c repayment){
        if(amortiScheduleSetup == null) amortiScheduleSetup = new funas__Amortization_Schedule_Setup__c();
        amortiScheduleSetup.funas__TargetObjectId__c = repayment.Name;
        amortiScheduleSetup.funas__Year_Length__c = Constant.FUNAS_YEAR_LENGTH_365;
        if (repayment.cmbls__Interest_Accrual_Method__c == Constant.INTEREST_ACCRUAL_METHOD_360 || repayment.cmbls__Interest_Accrual_Method__c == Constant.INTEREST_ACCRUAL_METHOD_365_360) {
            amortiScheduleSetup.funas__Year_Length__c = Constant.FUNAS_YEAR_LENGTH_360;
        }
        amortiScheduleSetup.funas__Compounding__c = getEventPeriod(repayment.cmbls__Interest_Accrual_Frequency__c);
        // Any Rounding will be a balloon payment
        amortiScheduleSetup.funas__Remaining_Amount_Rounding_Method__c = Constant.FUNAS_REMAINING_AMOUNT_ROUNDING_METHOD_BALLOON;
        amortiScheduleSetup.funas__Nominal_Rate__c = repayment.cmbls__Current_Interest_Rate__c;
        amortiScheduleSetup.funas__Is_Active__c = true;
        return amortiScheduleSetup;
    }

}