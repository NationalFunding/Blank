/**
 * Constant class
 * @author CloudMyBiz (r)
 * @date 14/06/2022
 * @description
 * @group 
 */

public with sharing class Constant {

    public static final String FUNAS_YEAR_LENGTH_365 = '365';
    public static final String FUNAS_YEAR_LENGTH_360 = '360';
    public static final String FUNAS_REMAINING_AMOUNT_ROUNDING_METHOD_BALLOON = 'TVRoundingBallonAddNewPayment';

    public static final String FUNAS_EVENT_TYPE_LOAN = 'TVLoanEvent';
    public static final String FUNAS_EVENT_TYPE_PAYMENT = 'TVPaymentEvent';
    public static final String FUNAS_EVENT_PERIOD_MONTHLY = 'TVMonthlyCompound';
    public static final String FUNAS_EVENT_PERIOD_WEEKLY = 'TVWeeklyCompound';

    public static final String INTEREST_ACCRUAL_METHOD_360 = '30/360';
    public static final String INTEREST_ACCRUAL_METHOD_365_360 = '365/360';
    public static final String INTEREST_ACCRUAL_FREQUENCY_DAILY = 'Daily';
    public static final String INTEREST_ACCRUAL_FREQUENCY_WEEKLY = 'Weekly';
    public static final String INTEREST_ACCRUAL_FREQUENCY_MONTHLY = 'Monthly';

    public static final String STATUS_PENDING = 'Pending';
    public static final String STATUS_SETTLED = 'Settled';
    public static final String STATUS_SCHEDULED = 'Scheduled';
    public static final String STATUS_FAILED = 'Failed';

    public static final String ACH_BATCH_STATUS_SUCCESS = 'Success';
    public static final String ACH_BATCH_STATUS_RESUBMISSION = 'Resubmission';

    public static final String DISBURSEMENT_BATCH_STATUS_SUCCESS = 'Success';
    public static final String DISBURSEMENT_BATCH_STATUS_RESUBMISSION = 'Resubmission';

    public static final String ACH_TRANSACTION_LOG_STATUS_PENDING = 'Pending';
    public static final String ACH_TRANSACTION_LOG_STATUS_FAILED = 'Failed';
    public static final String ACH_TRANSACTION_LOG_STATUS_NOTIFICATION = 'Notification of Change';
    public static final String ACH_TRANSACTION_LOG_STATUS_COMPLETED = 'Completed';
    public static final String ACH_TRANSACTION_LOG_WF_SENT = 'Sent to Wells Fargo';
    
    public static final String ACH_PROCESSOR_NF_FUNDING = 'Wells Fargo - NF Funding';

}