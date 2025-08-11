/**
 * WellsFargo class
 * @author CloudMyBiz (r)
 * @date 18/07/2022
 * @description
 * @group 
 */

public with sharing class WellsFargo {

    public SObject record;
    public String token;
    public Boolean doResubmission;
    public ACHTransactionLog achLog;
    public Boolean processRecord;
    public Boolean failedRecord;
    public String rawResponse;
    public Boolean hasErrors;

    public static final String PAYMENT_STATUS_PROCESSED = 'PROCESSED';
    public static final String PAYMENT_STATUS_PENDING = 'PENDING';
    public static final String PAYMENT_STATUS_EXCEPTION = 'EXCEPTION';

    public WellsFargo(){
        this.doResubmission = false;
        this.hasErrors = false;
        this.processRecord = false;
        this.failedRecord = false;
        this.achLog = new ACHTransactionLog();
    }

    //Payment Object send to Wells Fargo API Service
    public class PaymentRequestBody {
        public String debit_credit_indicator{get;set;}
        public Double payment_amount{get;set;}
        public String payment_description{get;set;}
        public String payment_format{get;set;}
        public String payment_id{get;set;}
        public String payment_method{get;set;}
        public String payment_date{get;set;}
        public Payee payee{get;set;}
        public Payer payer{get;set;}

        public PaymentRequestBody(){
            payee = new Payee();
            payer = new Payer();
        }
    }

    public class Payee{
        public String name{get;set;}
        public BankInformation bank_information{get;set;}

        public Payee(){
            bank_information = new BankInformation();
        }
    }

    public class Payer{
        public String name {get;set;}
        public BankInformation bank_information {get;set;}

        public Payer(){
            bank_information = new BankInformation();
        }
    }

    public class BankInformation {
        public String bank_account_number{get;set;}
        public String bank_account_type{get;set;}
        public String bank_id{get;set;}
        public String bank_id_type{get;set;}

    }

    public class PaymentCheck{
        public String payment_status;
        public String payee_name;
        public String payment_date;
        public Double payment_amount;
        public String trace_number;
        public Error[] errors;

        public String getErrors(){
            String errRet = '';
            for(Error err: errors){
                errRet += err.description + '\n';
            }
            return errRet;
        }
    }

    public class WFErrors{
        public Error[] errors;
    }

    public class Error {
        public String error_code;
        public String description;
        public String api_specification_url;
        public String field_name;
    }

    public class ACHPaymentStatusResponse {
        public String payment_status {get;set;}
        public String payee_name {get;set;}
        public String payment_date {get;set;}
        public Decimal payment_amount {get;set;}
        public String trace_number {get;set;}
    }

    public class WebhookReturn{
        public String notification_id;  //{notification_id}
        public Boolean additional_data_available;
        public String create_datetime;  //2019-10-19T00:41:08+0000
        public WebhookData data;
        public WebhookEvent event;
        public WebhookLink[] links;

        public String getReturnReasonCode(){
            if(this.data != null) return this.data.return_reason_code;
            return '';
        }

        public String getReturnReasonDescription(){
            if(this.data != null) return this.data.return_reason_description;
            return '';
        }

        public String getRecipientId(){
            if(this.data != null) return this.data.recipient_id;
            return '';
        }
    }

    public class WebhookData {
        public String return_reason_code;   //R01
        public String recipient_id; //XYZ
        public String return_reason_description;    //INSUFFICIENT FUNDS

        public String return_trace_number;  //111111111111111
        public String original_return_reason_description;
        public String dishonored_refused_noc_return_reason_code;
        public String dishonored_refused_noc_return_reason_description;
        public String comments_corrections;
        public String ach_company_id;   //ABCXYZ1111
        public String ach_file_originator_id;   //1111111111
        public String payment_currency; //USDUSD
        public String bank_account_number_masked;   //...1111
        public String original_trace_number;    //111111111111111
        public String ach_transaction_code; //27
        public String bank_id;  //111111111
        public String tir_company_name; //ABCXYZ ABC
        public String batch_sequence_number;    //00000
        public String ach_file_key; //000000000
        public String found_not_found_return_indicator; //F
        public String descriptive_date; //190823
        public String exception_report_created_datetime;    //2018-11-16T16:05:37Z
        public Double payment_amount;   //7.65
        public String entry_class_code; //ARC
        public String calculated_effective_date;    //2018-11-15
        public String return_type_code_description; //Return
        public String original_dfi_routing_number;  //11111111
        public String ach_company_name; //ABCXYZ
        public String original_return_reason_code;  //R01
        public String return_type_code; //10
        public String company_entry_description;    //RETRY PYMT
        public String recipient_name;   //FIRST_NAME LAST_NAME
        public String redeposit;    //1
        public String received_returned_comment_code;   //o
    }

    class WebhookEvent {
        public String name; //ach.payment.exception-action-required.v1
        public String description;  //Notification of ACH Exception Returns that require an action to be taken
        public String category; //ACH Payments
    }

    class WebhookLink {
        public String method;   //GET
        public String rel;  //SELF
        public String href; //https://api-sit.wellsfargo.com/webhook-services/v1/notifications/WH291-0010345
    }
    
    
    public class NotificationsResponse{
        public Integer item_count;
        public Notification[] notifications;
        
        public Integer getPages(){
            Decimal raw = NumberUtils.getDecimal(NumberUtils.getInteger(this.item_count)).divide(100, 3);
            return NumberUtils.getInteger(raw.round(System.RoundingMode.UP));
        }
    }
    
    public class Link {
        public String method;
        public String rel;
        public String href;
    }
    
    public class Event {
        public String name;
        public String description;
        public String category;
    }
    
    public class Data {
        public String return_trace_number;
        public String ach_company_id;
        public String return_reason_code;
        public String ach_file_originator_id;
        public String payment_currency;
        public String bank_account_number_masked;
        public String original_trace_number;
        public String ach_transaction_code;
        public String bank_id;
        public String tir_company_name;
        public String batch_sequence_number;
        public String ach_file_key;
        public String found_not_found_return_indicator;
        public String recipient_id;
        public String exception_report_created_datetime;
        public Double payment_amount;
        public String entry_class_code;
        public String calculated_effective_date;
        public String comments_corrections;
        public String return_type_code_description;
        public String original_dfi_routing_number;
        public String return_reason_description;
        public String ach_company_name;
        public String return_type_code;
        public String company_entry_description;
        public String recipient_name;
    }
    
    public class Notification {
        public Data data;
        public String create_datetime;
        public Link[] links;
        public Boolean additional_data_available;
        public String notification_id;
        public Event event;
        
        public String getReturnReasonCode(){
            if(this.data != null) return this.data.return_reason_code;
            return '';
        }
        
        public String getReturnReasonDescription(){
            if(this.data != null) return this.data.return_reason_description;
            return '';
        }
        
        public String getRecipientId(){
            if(this.data != null) return this.data.recipient_id;
            return '';
        }
    }

}