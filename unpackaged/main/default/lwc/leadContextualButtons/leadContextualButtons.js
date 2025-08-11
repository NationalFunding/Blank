import { LightningElement, wire, api } from 'lwc';
import { getRecord, updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import Id from '@salesforce/user/Id';

import invokeOptInFlow from '@salesforce/apex/InvokeTwilioMessageFlow.start';
// import leadConvert from '@salesforce/apex/AutoConvertLeads.convertLead';
import dlpEmail from '@salesforce/apex/SendDLPEmail.sendDLPEmail';
import dlpText from '@salesforce/apex/SendDLPText.calloutSendDLPText';

const FIELDS = [
    'Lead.Company',
    'Lead.SMS_Opt_In__c',
    'Lead.SMS_Opt_Out__c',
    'Lead.SMS_Requested__c',
    'Lead.Last_Opt_In_Message_Sent__c',
    'Lead.SMS_Opt_In_Date_Time__c',
    'Lead.SMS_Requested_Date_Time__c',
    'Lead.Status',
    'Lead.HasOptedOutOfEmail',
    'Lead.Sales_Status__c',
    'Lead.Signed_Agreement__c',
    'Lead.MobilePhone',
]


export default class LeadContextualButtons extends NavigationMixin(LightningElement) {

    
    @api recordId; // Grab the Record Id
    @api objectApiName; // Grab the Objects API Name
    currentStage; // Track changes to the value of currentStage
    stage0; // Track if Current Stage is :0
    userId = Id; // User Id
    companyName; // Company Name of Lead
    signedAgreement; // Is there a signed Agreement?

    // Texting Fields
    leadOptIn;
    leadOptOut;
    leadSMSRequested;
    leadLastOptInMessage;
    leadOptInDateTime;
    leadRequestedDateTime;
    leadMobilePhone;

    // Email Fields
    leadEmailOptOut;

    // Twilio Modal Fields
    TwilioModal = false;
    value = [];

    get options() {
        return [{
                label: 'Yes',
                value: 'Yes'
            },
            {
                label: 'No',
                value: 'No'
            },
        ];
    }

    get selectedValues() {
        return this.value.join(',');
    }

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS})
    leadResult(result) {

        // Clear Contextual Button Data
        this.currentStage = null;
        this.stage0 = null

        console.groupCollapsed('Contextual Buttons - Lead get Record Result:');
            console.log(result);
            console.log(result.data);
            console.log(this.currentStage);
            console.log(this.stage0);
        console.groupEnd('Contextual Buttons - Lead get Record Result:');

        if (result.data) {

            // Is there a signed Agreement?
            this.signedAgreement = result.data.fields.Signed_Agreement__c.value;
            console.log('There is a signed Agreement: ' + this.signedAgreement);	

            // Update Variable Values
            this.companyName = result.data.fields.Company.value;
            this.leadOptIn = result.data.fields.SMS_Opt_In__c.value;
            this.leadOptOut = result.data.fields.SMS_Opt_Out__c.value;
            this.leadSMSRequested = result.data.fields.SMS_Requested__c.value;
            this.leadLastOptInMessage = result.data.fields.Last_Opt_In_Message_Sent__c.value;
            this.leadOptInDateTime = result.data.fields.SMS_Opt_In_Date_Time__c.value;
            this.leadRequestedDateTime = result.data.fields.SMS_Requested_Date_Time__c.value;
            this.leadEmailOptOut = result.data.fields.HasOptedOutOfEmail.value;
            this.leadMobilePhone = result.data.fields.MobilePhone.value;

            console.groupCollapsed('SMS Values');
                console.log('Opt In:', this.leadOptIn);
                console.log('Opt Out:', this.leadOptOut);
                console.log('SMS Requested:', this.leadSMSRequested);
                console.log('Last Opt In Message Date/Time:', this.leadLastOptInMessage);
                console.log('Opt In Date/Time:', this.leadOptInDateTime);
                console.log('SMS Requested Date/Time:', this.leadRequestedDateTime);
                console.log('Email Opt Out: ', this.leadEmailOptOut);
                console.log('MobilePhone: ', this.leadMobilePhone);
            console.groupEnd('SMS Values');

            console.log('Sales Status: ', result.data.fields.Sales_Status__c.value);

            // Update Data for Contextual Buttons
            switch (result.data.fields.Sales_Status__c.value) {
                case '0: Contact':

                    // Define Values for Current Stage 0
                    console.log('Current Stage: 0: Contact');
                    this.currentStage = 0;
                    this.stage0 = "0";
                    console.log('this.stage0: ', this.stage0);

                    break;

                default:

                    console.warn('Current Stage: Default/Unknown');
                    // If there is no status, Still show Stage 0 Contextual Buttons
                    this.currentStage = 0;
                    this.stage0 = "0";
                    break;
            }

        } else if (result.data) {

            console.error('Error retrieving Lead Data - Contextual Buttons')
            console.error(result.error);

        } else {

            console.warn('Unknown result from Contextual Button for Lead');

        }
    }

    // Web Search Function
    webSearch() {
        console.log('Opening New Tab: ', 'https://www.google.com/search?q=' + this.companyName, '_blank');
        window.open('https://www.google.com/search?q=' + this.companyName, '_blank');
    }

    openTwilioModal() {
        if(this.leadMobilePhone == undefined || this.leadMobilePhone == null){
            console.warn('No MobilePhone - Cannot Proceed');

            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Cannot Send Opt-In Message',
                    message: 'Please provide a Mobile Phone',
                    variant: 'info',
                    mode: 'dismissible'
                })
            );

            return;

        }

        if(this.leadSMSRequested == true){
            this.sendOptIn();
        } else {
            this.TwilioModal = true;
        }
    }

    closeTwilioModal() {
        this.TwilioModal = false;
    }

    handleChange(e) {
        this.value = e.detail.value;
    }

    sendOptIn() {

        console.groupCollapsed('Send Opt In Message');
        console.log('Last Opt In Message: ', this.leadLastOptInMessage);
        console.log('Lead Opt In: ', this.leadOptIn);
        console.log('Lead Opt Out: ', this.leadOptOut);
        var date = new Date();
        var fdate = date.toISOString();
        console.log('Today: ', fdate);
        console.log('Confirm Value: ', this.value);
        console.groupEnd('Send Opt In Message');

        let optInDate = new Date(this.leadLastOptInMessage);
        let today = new Date(fdate);
        let diff = today - optInDate;
        let days = diff / 86400000;
        console.log('Difference: ', diff, ' ms');
        console.log('Difference: ', days, ' days');

        // Confirm Customers wants to be reached out
        if ((this.value.length == 2 || this.value.includes('No') || this.value.length == 0) && this.leadSMSRequested == false) {
            console.warn('Cannot Continue because 2 Options were chosen or No was picked');
            console.warn('Options Chosen: ', this.value.length);
            console.warn('No Picked: ', this.value.includes('No'));
        } else {

            console.log('Attempting to Opt In Lead');
            console.log('SMS Has been Requested Previously: ', this.leadSMSRequested);

            if(this.leadSMSRequested == false){

                console.log('something...');
                let now = new Date().toISOString();
                console.log(now);

                // Update SMS Requested Fields
                let leadRecordUpdate = {
                    fields: {
                        Id: this.recordId,
                        SMS_Requested_Date_Time__c: now,
                        SMS_Requested__c: true,
                    },
                };

                console.log(leadRecordUpdate);

                updateRecord(leadRecordUpdate)
                .then(() =>{

                })
                .catch(error => {
                    console.log(error);
                });

            };

            // Determine if Lead has Opted-Out
            if (this.leadOptOut == true) {
                console.warn('Lead has Opted Out to Messaging');

                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Cannot Send Opt-In Message',
                        message: 'Person has Opted-Out of Messaging',
                        variant: 'info',
                        mode: 'dismissable'
                    })
                );

            } else if (this.leadOptIn == true) {
                console.warn('Lead has already Opted In to Messaging');

                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Cannot Send Opt-In Message',
                        message: 'Person is already Opted-In to Messaging',
                        variant: 'info',
                        mode: 'dismissable'
                    })
                );

            } else if (this.leadOptOut == false & this.leadOptIn == false) {
                console.log('Lead can continue');

                // Determine if Eligible for Opt-In Message

                if (optInDate == undefined) {
                    console.log('Eligible to Send Opt In Message - Never Sent Message');
                    invokeOptInFlow({
                        recordId: this.recordId,
                        userId: this.userId,
                        objectType: this.objectApiName,
                        messageType: 'SendOptIn'
                    });
                    console.log('Opt In Message Invoked');

                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Opt-In Message Sent',
                            message: 'Attempting to Send Opt-In Message',
                            variant: 'success',
                            mode: 'dismissable'
                        })
                    );

                    // Used to Refresh the Page
                    updateRecord({
                        fields: {
                            Id: this.recordId
                        }
                    });

                } else if (days > 30) {
                    console.log('Eligible to Send Opt In Message - Greater than 30 Days');
                    invokeOptInFlow({
                        recordId: this.recordId,
                        userId: this.userId,
                        objectType: this.objectApiName,
                        messageType: 'SendOptIn'
                    });
                    console.log('Opt In Message Invoked');

                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Opt-In Message Sent',
                            message: 'Attempting to Send Opt-In Message',
                            variant: 'success',
                            mode: 'dismissable'
                        })
                    );

                    // Used to Refresh the Page
                    updateRecord({
                        fields: {
                            Id: this.recordId
                        }
                    });

                } else if (days < 30) {
                    console.warn('Not Eligible to Send Opt In Message - Less than 30 Days');


                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Cannot Send Opt-In Message',
                            message: 'Opt-In Message has been sent within the last 30 Days',
                            variant: 'info',
                            mode: 'dismissable'
                        })
                    );

                } else {
                    console.warn('Unknown result attempting to Send Opt In Message');


                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Cannot Send Opt-In Message',
                            message: 'Unknown result has happened. Please reach out to Support',
                            variant: 'info',
                            mode: 'dismissable'
                        })
                    );

                }
            }

            this.closeTwilioModal();

        }



    }

    sendDLPEmail() {

        console.log('Sending DLP Email...');
        console.log('RecordId: ', this.recordId);
        console.log('Email Opt Out: ', this.leadEmailOptOut);

        // Customer Opted-In to Emails
        if (!this.leadEmailOptOut) {
            dlpEmail({recordId: this.recordId})
                .then(result => {
                    console.log('DLP Email Triggered');
                    console.log(result);
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'DLP Email Sent',
                            variant: 'success'
                        })
                    );
                })
                .catch(error => {
                    console.error(error);
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error sending DLP Email',
                            message: error.body.message,
                            variant: 'error'
                        })
                    );
                })
        }
        // Customer NOT Opted-In to Emails
        else {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'DLP Email not Sent',
                    message: 'Customer needs to be opted in to emails',
                    variant: 'warning'
                })
            );
        }
    }

    sendDLPText(){

        if(this.leadMobilePhone == undefined || this.leadMobilePhone == null){
            console.warn('No MobilePhone - Cannot Procceed');

            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Cannot Send DLP Message',
                    message: 'Please provide a Mobile Phone',
                    variant: 'info',
                    mode: 'dismissable'
                })
            );

            return;

        }

        console.log('Sending DLP Text...');
        console.log('Text Opt Out: ', this.leadOptOut);
        console.log('RecordId: ', this.recordId, " & UserId: ", this.userId);

        if(!this.leadOptOut){
            dlpText({recordId: this.recordId, ownerId: this.userId})
            .then(result => {
                console.log('DLP Text Triggered');
                console.log(result);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'DLP Text Sent',
                        variant: 'success'
                    })
                );
            })
            .catch(error => {
                console.error(error);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error sending DLP Text',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            })
        }
        // Customer NOT Opted-In to Emails
        else {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'DLP Text not Sent',
                    message: 'Customer needs to be opted in to Texts',
                    variant: 'warning'
                })
            );
        }
        
    }

    convertToOpp(){
        console.log('Convert Lead with Opportunity');
        console.log('Record Id: ', this.recordId);

        // Notify user of conversion
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'One Moment',
                message: 'Salesforce is making some Updates, One Moment',
                variant: 'info',
                mode: 'dismissable'
            })
        );

            // Call Lead Convert Apex
    leadConvert({leadId: this.recordId, createOpportunity: true})
    .then(result => {

        this.dispatchEvent(
            new ShowToastEvent({
                title: 'One Moment: Redirecting',
                message: 'Redirecting from Lead to new Opportunity',
                variant: 'info',
                mode: 'dismissable'
            })
        );

        // Log Results
        console.log('Convert Result:');
        console.log(result);

        let opportunity = result.opportunityId;
        console.log('OpportunityId: ', opportunity);

        // Communicates with Aura component that houses the LWC
        // Aura Components are able to open/close SF Console Tabs
        const value = opportunity;
        const openTabEvent = new CustomEvent('convert', {
            detail: { value }
        });
        this.dispatchEvent(openTabEvent);
        
    })
        .catch(error => {
            console.error('There was an Error Converting the Lead :( ...');
            this.error = error;
            console.error(error);

            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error Converting Lead',
                    message: error,
                    variant: 'error',
                })
            );
        })
    }

}