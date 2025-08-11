/**
 * Created by oporter on 7/18/2018.
* _________________________________________________________________________________________________
* TITLE: CreatePaymentSchedule
* DESCRIPTION:
* _________________________________________________________________________________________________
* @author         Olivia Porter       <oporter@nationalfunding.com>
* @modifiedBy     Olivia Porter       <oporter@nationalfunding.com>
* @maintainedBy   Olivia Porter       <oporter@nationalfunding.com>
* @version        1.0
* @created        2018-07-18
* @modified       0000-00-00
* _________________________________________________________________________________________________
* v1              oporter@nationalfunding.com
* 0000-00-00      Explanation of the change.  Multiple lines can be used to explain the change, but
*                 each line should be indented till left aligned with the previous description text.
*
* v2              oporter@nationalfunding.com
* 0000-00-00      Explanation of the change.  Multiple lines can be used to explain the change, but
*                 each line should be indented till left aligned with the previous description text.
*
*/

public with sharing class CreatePaymentSchedule implements Process.Plugin {
    public Boolean isHoliday = false;

    public Process.PluginResult invoke(Process.PluginRequest request) {
        Map<String, Object> result = new Map<String, Object>();

        //Gathering user input
        Decimal varAmount = (Decimal) request.inputParameters.get('varAmount'); //dollar amount to be charged
        String varFrequency = (String) request.inputParameters.get('varFrequency'); //monthly, weekly, yearly
        Decimal varPaymentTotal = (Decimal) request.inputParameters.get('varPaymentTotal'); // total number of payments
        Datetime varStartDateTime = (Datetime) request.inputParameters.get('varStartDate'); //when the payments need to start
        String inputPaymentAgreementId = (String) request.inputParameters.get('inputPaymentAgreementId'); //parent object
        String varPaymentScheduleIndex = (String) request.inputParameters.get('varPaymentScheduleIndex'); //PaymentScheduleIndex

        createPaymentSchedule(varAmount, varFrequency, varPaymentTotal, varStartDateTime, inputPaymentAgreementId, varPaymentScheduleIndex);

        return new Process.PluginResult(result);
    }

    public void createPaymentSchedule(Decimal varAmount, String varFrequency, Decimal varPaymentTotal, Datetime varStartDateTime, String inputPaymentAgreementId, String varPaymentScheduleIndex){
        List<Scheduled_Payment__c> paymentList = new List<Scheduled_Payment__c>();

        //flow is passing in a datetime but we only need the date. convert dt to date
        final DateTime scheduledDateTime = varStartDateTime;
        Date referenceDate = date.newinstance(varStartDateTime.year(), varStartDateTime.month(), varStartDateTime.day());

        //we only want to create the number of payments the user requested
        for (Integer paymentIndex = 0; paymentIndex < varPaymentTotal; paymentIndex++){
            //currentPaymentCandidateDate is the next scheduled date. this date is a business day
            Date currentPaymentCandidateDate;
            if(paymentIndex == 0) {
                currentPaymentCandidateDate = referenceDate;
            }
            else {
                currentPaymentCandidateDate = GenerateTheNextScheduleDate(referenceDate, paymentIndex, varFrequency, scheduledDateTime);
            }

            //currentPaymendActualDate is the next scheduled date
            Date currentPaymendActualDate = MakeDateValidForPayment(currentPaymentCandidateDate);

            system.debug('OG date: currentPaymentCandidateDate:: ' + currentPaymentCandidateDate);
            system.debug('Updated Date: currentPaymendActualDate:: ' + currentPaymendActualDate);

            paymentList.add(new Scheduled_Payment__c(Amount__c = varAmount, Payment_Agreement__c = inputPaymentAgreementId, Scheduled_Date__c = currentPaymendActualDate, Payment_Schedule_Index__c = varPaymentScheduleIndex));

            //if it is a daily payment, we need to set the reference date to the actual payment date and not the canidate date
            if(varFrequency == 'Daily'){
                referenceDate = currentPaymendActualDate;
            }
            //else we need to set the reference date back to the canidate payment date
            else{
                referenceDate = currentPaymentCandidateDate;
            }
        }
        system.debug('paymentList:: ' + paymentList);
        insert paymentList;
    }

    public Date GenerateTheNextScheduleDate(Date referenceDate, Integer paymentIndex, String paymentFrequency, DateTime scheduledDateTime){
        if (paymentFrequency == 'Daily'){
            return referenceDate.addDays(1);
        }
        else if(paymentFrequency == 'Weekly'){
            return referenceDate.addDays(7);
        }
        else if(paymentFrequency == 'Bi-Weekly'){
            return referenceDate.addDays(14);
        }
        else if(paymentFrequency == 'Monthly'){
            return referenceDate.addMonths(1);
        }
        else{
            throw new GenericException('Invalid Enum Argument Exception');
        }
    }

    public Date MakeDateValidForPayment(Date currentPaymentDate){
        while (IsInvalidPaymentDate(currentPaymentDate)){
            currentPaymentDate = currentPaymentDate.addDays(1);
        }
        system.debug('final updated currentPaymentDate:: ' + currentPaymentDate);
        return currentPaymentDate;
    }

    public Boolean IsInvalidPaymentDate(Date candidateDate){
        // return (IsDateWeekend(candidateDate)) || (IsDateHoliday(candidateDate)); - this is the original logic 
        return (IsDateWeekend(candidateDate));
    }

    //if it's either day of the weekend, we return "true"
    public Boolean IsDateWeekend(Date candidateDate){
        DateTime dt=DateTime.newInstance(candidateDate, Time.newInstance(0, 0, 0, 0));
        String dayOfWeek = dt.format('EEEE');
        return dayOfWeek == 'Saturday' || dayOfWeek == 'Sunday';
    }

    //private Boolean IsDateHoliday(Date candidateDate){
    //    isHoliday = ObservedHolidays.isHoliday(candidateDate);
    //    return isHoliday;
    // }

    // Returns the describe information for the interface
    public Process.PluginDescribeResult describe() {
        Process.PluginDescribeResult result = new Process.PluginDescribeResult();
        result.Name = 'CreatePaymentSchedule';
        result.Tag = 'CreatePaymentSchedule';
        result.inputParameters = new
                List<Process.PluginDescribeResult.InputParameter>{
                new Process.PluginDescribeResult.InputParameter('varAmount',
                        Process.PluginDescribeResult.ParameterType.DECIMAL, true)
                ,
                new Process.PluginDescribeResult.InputParameter('varFrequency',
                        Process.PluginDescribeResult.ParameterType.STRING, true)
                ,
                new Process.PluginDescribeResult.InputParameter('varPaymentTotal',
                        Process.PluginDescribeResult.ParameterType.DECIMAL, true)
                ,
                new Process.PluginDescribeResult.InputParameter('inputPaymentAgreementId',
                        Process.PluginDescribeResult.ParameterType.STRING, true)
                ,
                new Process.PluginDescribeResult.InputParameter('varStartDate',
                        Process.PluginDescribeResult.ParameterType.Datetime, true)
                ,
                new Process.PluginDescribeResult.InputParameter('varPaymentScheduleIndex',
                        Process.PluginDescribeResult.ParameterType.STRING, true)
        };
        result.outputParameters = new
                List<Process.PluginDescribeResult.OutputParameter>{
                new Process.PluginDescribeResult.OutputParameter(
                        'varBunkData',
                        Process.PluginDescribeResult.ParameterType.String)
        };
        system.debug('result2: ' + result);
        return result;
    }
}