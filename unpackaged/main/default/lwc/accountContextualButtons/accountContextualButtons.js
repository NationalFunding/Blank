import {LightningElement,wire,api,track} from 'lwc';
import {getRecord,getFieldValue,updateRecord} from 'lightning/uiRecordApi';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import {NavigationMixin} from 'lightning/navigation';
import { refreshApex } from '@salesforce/apex';
import Id from '@salesforce/user/Id';

import getContactList from '@salesforce/apex/GetAccountContacts.getContactList';
import contactSMSInfo from '@salesforce/apex/GetAccountContacts.getContactInfo';
import dlpEmail from '@salesforce/apex/SendDLPEmail.sendDLPEmail';
import dlpText from '@salesforce/apex/SendDLPText.sendDLPText';
import invokeOptInFlow from '@salesforce/apex/InvokeTwilioMessageFlow.start';
import recordingWarningStates from '@salesforce/label/c.recordingWarningStates';
import recordingWarningProfiles from '@salesforce/label/c.recordingWarningProfiles';
import recordingWarningAgentState from '@salesforce/label/c.recordingWarningAgentState';
import recordingWarningAccountType from '@salesforce/label/c.recordingWarningAccountType';

const FIELDS = [
    'Account.Name',
    'Account.Status__c',
    'Account.Type',
    'Account.Sales_Status__c',
    'Account.BillingState'
];

const USERFIELDS = [
    'User.ProfileId',
    'User.Profile.Name',
    'User.State'

];

export default class AccountContextualButtons extends NavigationMixin(LightningElement) {

    
    @api recordId; // Grab the Record Id
    @api objectApiName; // Grab the Objects API Name
    currentStage; // Track changes to the value of currentStage
    dlpEmail;
    dlpText;
    webSearch;
    app;
    appComplete = false;
    appDisabled = true;
    dlpEmailModal = false;
    dlpTextModal = false;
    textmodal = false;
    optInText;
    userId = Id; // User Id
  
    // Variables for Data Refresh
    contacts;
    error;
    wiredContactsResult;
    
    stage;
    accountName;
    accountId;
    accountType;
    billingState;

    // Texting Fields
    contactOptIn;
    contactOptOut;
    contactSMSRequested;
    contactLastOptInMessage;
    contactOptInDateTime;
    contactRequestedDateTime;
    contactMobilePhone;

    currentUserProfileId;
    currentUserProfileName;
    currentUserState;


    // Twilio Modal Fields
    TwilioModal = false;
    value = [];
    optInRecord;

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


    @wire(getRecord, { recordId: Id, fields: USERFIELDS}) 
    userDetails({error, data}) {

        
        console.log('Users Data Result:');
        console.log(data);
        if (data) {
            this.currentUserProfileId = data.fields.ProfileId.value;
            this.currentUserProfileName = data.fields.Profile.displayValue;
            this.currentUserState = data.fields.State.value; 
           
        } else if (error) {
            this.error = error ;
        }
    }


    @wire(getRecord, {
        recordId: '$recordId',
        fields: FIELDS
    })
    accountResult(result) {

        console.log('Account Data Result:');
        console.log(result);
        console.log(result.data);

        if (result.data) {

            // Clear Contextual Buttons Data
            this.currentStage = null;
            this.dlpEmail = null;
            this.dlpText = null;
            this.webSearch = null;
            this.app = null;
            this.optInText = null;

            // Populate Fields
            this.stage = result.data.fields.Sales_Status__c.value;
            this.accountName = result.data.fields.Name.value;
            this.billingState = result.data.fields.BillingState.value;
            this.accountType = result.data.fields.Type.value;
          
            console.log('Showing Toast Message');
            console.log(recordingWarningStates);
            if ( this.currentUserState != null && this.currentUserState != undefined && this.currentUserState != '' &&
                this.billingState != null && this.billingState != undefined && this.billingState != '' &&
                recordingWarningAgentState.includes(this.currentUserState) &&
                recordingWarningAccountType.includes(this.accountType)  &&
                recordingWarningProfiles.includes(this.currentUserProfileName) &&
                recordingWarningStates.includes(this.billingState)) {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Important Notice regarding the recording of calls!',
                        message: 'This account is in the state of : '  + this.billingState + '. You may NOT initiate call recording! ' ,
                        variant: 'warning',
                        mode: 'sticky'
                    })
                ); 
            }

            console.groupCollapsed('Account Contextual Buttons Values');
            console.log('Stage: ', this.stage);
            console.log('Account Name: ', this.accountName);
            console.groupEnd('Account Contextual Buttons Values');

            switch (result.data.fields.Sales_Status__c.value) {
                case '0: Contact':

                    // Define Value for Current Stage 0
                    console.log('Current Stage: ', result.data.fields.Sales_Status__c.value);
                    this.currentStage = 0;
                    this.dlpEmail = 1;
                    this.dlpText = 1;
                    this.webSearch = 1;
                    this.optInText = 1;

                    console.log(this.currentStage);
                    console.log(this.dlpEmail);
                    console.log(this.dlpText);
                    console.log(this.webSearch);

                    break;

                case '1: Submit':

                    // Define Values for Current Stage 1
                    console.log('Current Stage: ', result.data.fields.Sales_Status__c.value);
                    this.currentStage = 1;
                    this.webSearch = 1;
                    this.app = 1;
                    this.optInText = 1;
                    this.dlpEmail = 1;
                    this.dlpText = 1;

                    console.log(this.currentStage);
                    console.log(this.webSearch);
                    console.log(this.app);

                    break;

                case '2: Underwrite':

                    // Define Values for Current Stage 2
                    console.log('Current Stage: ', result.data.fields.Sales_Status__c.value);
                    this.currentStage = 2;
                    this.webSearch = 1;
                    this.optInText = 1;
                    this.dlpEmail = 1;
                    this.dlpText = 1;

                    break;

                case '3: Sell':

                    // Define Values for Current Stage 3
                    console.log('Current Stage: ', result.data.fields.Sales_Status__c.value);
                    this.currentStage = 3;
                    this.webSearch = 1;
                    this.optInText = 1;
                    this.dlpEmail = 1;
                    this.dlpText = 1;

                    break;

                case '4: Fund':

                    // Define Values for Current Stage 3
                    console.log('Current Stage: ', result.data.fields.Sales_Status__c.value);
                    this.currentStage = 4;
                    this.webSearch = 1;
                    this.optInText = 1;
                    this.dlpEmail = 1;
                    this.dlpText = 1;

                    break;

                case 'Closed Won':

                    // Define Values for Current Stage 3
                    console.log('Current Stage: ', result.data.fields.Sales_Status__c.value);
                    this.currentStage = 5;
                    this.dlpEmail = 1;
                    this.dlpText = 1;

                    break;

                case 'Close Lost':

                    // Define Values for Current Stage 3
                    console.log('Current Stage: ', result.data.fields.Sales_Status__c.value);
                    this.currentStage = 6;
                    this.dlpEmail = 1;
                    this.dlpText = 1;

                    break;

                default:

                    console.warn('Current Stage: Default/Unkown');
                    // Show these buttons when no sales status is defined
                    this.dlpEmail = 1;
                    this.dlpText = 1;
                    this.webSearch = 1;
                    this.optInText = 1;
                    break
            }
        } else if (result.error) {

            console.error(result.error);

        }
    }

    // Web Search Function
    searchWeb() {
        console.log('Opening New Tab: ', 'https://www.google.com/search?q=' + this.accountName, '_blank');
        window.open('https://www.google.com/search?q=' + this.accountName, '_blank');
    };

    @wire(getContactList, {
        accountId: '$recordId'
    })
    contactResult(result) {

        console.log('Contact List Result - CB:');
        console.log(result);
        this.wiredContactsResult = result;

        if(result.data){
            console.log('data');
            console.log(result.data);
            this.contacts = result.data;
        } 
        else if (result.error) {
            console.log('error');
            console.log(error);
        }
        else {
            console.warn('Unknown Result from getContactList');
            console.log(result);
        }
        
    }


    openDLPEmailModal() {
        console.log(this.accountId);
        this.dlpEmailModal = true;
    }

    closeDLPEmailModal() {
        this.dlpEmailModal = false;
    }

    sendDLPEmail(event) {

        console.log('Sending DLP Email...');
        var record = event.target.dataset.id;
        var optOut = event.target.dataset.optout;
        console.log('Record: ', record);
        console.log('Email Opt Out: ', optOut);

        if (optOut == 'false') {
            dlpEmail({
                    recordId: record
                })
                .then(result => {
                    console.log('DLP Email Triggered');
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
        } else {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'DLP Email not Sent',
                    message: 'Customer needs to be opted in to emails',
                    variant: 'warning'
                })
            );
        }
    }

    openTwilioModal(event) {

        this.contactOptIn = '';
        this.contactOptOut = '';
        this.contactSMSRequested = '';
        this.contactLastOptInMessage = '';
        this.contactOptInDateTime = '';
        this.contactRequestedDateTime = '';
        this.contactMobilePhone = '';

        this.textmodal = false;
        this.optInRecord = event.target.dataset.id;
        this.contactMobilePhone = event.target.dataset.mobile;

        console.log(this.optInRecord);

        // Check if Mobile is Present
        if(this.contactMobilePhone == undefined || this.contactMobilePhone == null){
            console.warn('No MobilePhone - Cannot Procceed');

            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Cannot Send Opt-In Message',
                    message: 'Please provide a Mobile Phone',
                    variant: 'info',
                    mode: 'dismissable'
                })
            );

            return;

        }

        contactSMSInfo({
                contactId: this.optInRecord
            })
            .then(result => {
                console.log('Result:');
                console.log(result);

                this.contactOptIn = result[0].SMS_Opt_In__c;
                this.contactOptOut = result[0].SMS_Opt_Out__c;
                this.contactSMSRequested = result[0].SMS_Requested__c;
                this.contactLastOptInMessage = result[0].Last_Opt_In_Message_Sent__c;
                this.contactOptInDateTime = result[0].SMS_Opt_In_Date_Time__c;
                this.contactRequestedDateTime = result[0].SMS_Requested_Date_Time__c;

                console.log('Contact Opt In: ', this.contactOptIn);
                console.log('Contact Opt Out: ', this.contactOptOut);
                console.log('Contact SMS Requested: ', this.contactSMSRequested);
                console.log('Contact Last Opt In: ', this.contactLastOptInMessage);
                console.log('Contact Opt In Date: ', this.contactOptInDateTime);
                console.log('Contact Requested Date: ', this.contactRequestedDateTime);

                if (this.contactSMSRequested == true) {
                    this.sendOptInText();
                } else {
                    this.TwilioModal = true;
                }
            })
            .catch(error => {
                console.error(error);
            })

    }

    closeTwilioModal() {
        this.TwilioModal = false;
    }

    handleChange(e) {
        this.value = e.detail.value;
    }

    openTextModal() {
        this.textmodal = true;
    }

    closeTextModal() {
        this.textmodal = false;
    }

    sendOptInText() {

        console.groupCollapsed('Send Opt In Message');
        console.log('Last Opt In Message: ', this.contactLastOptInMessage);
        console.log('Lead Opt In: ', this.contactOptIn);
        console.log('Lead Opt Out: ', this.contactOptOut);
        var date = new Date();
        var fdate = date.toISOString();
        console.log('Today: ', fdate);
        console.log('Confirm Value: ', this.value);
        console.groupEnd('Send Opt In Message');

        let optInDate = new Date(this.contactLastOptInMessage);
        let today = new Date(fdate);
        let diff = today - optInDate;
        let days = diff / 86400000;
        console.log('Difference: ', diff, ' ms');
        console.log('Difference: ', days, ' days');

        // Confirm Customers wants to be reached out
        if ((this.value.length == 2 || this.value.includes('No') || this.value.length == 0) && this.contactSMSRequested == false) {
            console.warn('Cannot Continue because 2 Options were chosen or No was picked');
            console.warn('Options Chosen: ', this.value.length);
            console.warn('No Picked: ', this.value.includes('No'));
        } else {

            console.log('Attempting to Opt In Lead');
            console.log('SMS Has been Requested Previously: ', this.contactSMSRequested);

            if (this.contactSMSRequested == false) {

                let now = new Date().toISOString();
                console.log(now);

                // Update SMS Requested Fields
                let contactRecordUpdate = {
                    fields: {
                        Id: this.optInRecord,
                        SMS_Requested_Date_Time__c: now,
                        SMS_Requested__c: true,
                    },
                };

                console.log(contactRecordUpdate);

                updateRecord(contactRecordUpdate)
                    .then(() => {

                    })
                    .catch(error => {
                        console.log(error);
                    });

            };

            // Determine if Lead has Opted-Out
            if (this.contactOptOut == true) {
                console.warn('Contact has Opted Out to Messaging');

                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Cannot Send Opt-In Message',
                        message: 'Person has Opted-Out of Messaging',
                        variant: 'info',
                        mode: 'dismissable'
                    })
                );

            } else if (this.contactOptIn == true) {
                console.warn('Contact has already Opted In to Messaging');

                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Cannot Send Opt-In Message',
                        message: 'Person is already Opted-In to Messaging',
                        variant: 'info',
                        mode: 'dismissable'
                    })
                );

            } else if (this.contactOptOut == false & this.contactOptIn == false) {
                console.log('Contact can continue');

                // Determine if Eligible for Opt-In Message
                console.log(optInDate);
                console.log(days);

                if (optInDate == undefined || this.contactLastOptInMessage == undefined) {
                    console.log('Eligible to Send Opt In Message - Never Sent Message');
                    invokeOptInFlow({
                        recordId: this.optInRecord,
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

                } else if (days > 30 || this.contactLastOptInMessage == undefined) {
                    console.log('Eligible to Send Opt In Message - Greater than 30 Days');
                    invokeOptInFlow({
                        recordId: this.optInRecord,
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

    openDLPTextModal(){
        this.dlpTextModal = true;
    }

    closeDLPTextModal(){
        this.dlpTextModal = false;
    }

    sendDLPText(event){

        console.log('Sending DLP Text');
        var record = event.target.dataset.id;
        var optOut = event.target.dataset.optout;
        var optIn = event.target.dataset.optin;
        var mobilePhone = event.target.dataset.mobile;

        console.log('Record: ', record);
        console.log('SMS Opt Out: ', optOut);
        console.log('SMS Opt In: ', optIn);
        console.log('Mobile Phone: ', mobilePhone);
        console.log(optOut);
        console.log(optIn);

        if(mobilePhone == undefined || mobilePhone == null){
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

        if(optIn == 'true'){
            dlpText({recordId: record, userId: this.userId})
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

    connectedCallback(){
        //Refresh contact list on load
        console.log('CB - Connected Callback');
        refreshApex(this.wiredContactsResult);
        console.log('WiredContacts Refreshed');
    }

}