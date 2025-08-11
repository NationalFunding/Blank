import { LightningElement, wire, api, track } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';
import { updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import ACC_ID_FIELD from '@salesforce/schema/Account.Id';
import ACC_WEBSITE_FIELD from '@salesforce/schema/Account.Website';
import ACC_NAME_FIELD from '@salesforce/schema/Account.Legal_Name__c';
import ACC_DBA_FIELD from '@salesforce/schema/Account.Company_DBA__c';
import ACC_LEGALSTATUS_FIELD from '@salesforce/schema/Account.Legal_Status__c';
import ACC_DATEESTABLISHED_FIELD from '@salesforce/schema/Account.Date_Established__c';
import ACC_FEDTAXID_FIELD from '@salesforce/schema/Account.Fed_Tax_ID__c';
import ACC_STATEOFINCORP_FIELD from '@salesforce/schema/Account.State_of_Incorporation__c';
import ACC_ANNUALREV_FIELD from '@salesforce/schema/Account.AnnualRevenue';
import ACC_PHONE_FIELD from '@salesforce/schema/Account.Phone';
import ACC_TIME_ZONE_FIELD from '@salesforce/schema/Account.Time_Zone__c';
import ACC_SICNAME_FIELD from '@salesforce/schema/Account.Sic';

import ACC_S_STREET_FIELD from '@salesforce/schema/Account.ShippingStreet';
import ACC_S_CITY_FIELD from '@salesforce/schema/Account.ShippingCity';
import ACC_S_ZIP_FIELD from '@salesforce/schema/Account.ShippingPostalCode';
import ACC_S_STATE_FIELD from '@salesforce/schema/Account.ShippingState';
import ACC_S_COUNTRY_FIELD from '@salesforce/schema/Account.ShippingCountry';

import ACC_B_STREET_FIELD from '@salesforce/schema/Account.BillingStreet';
import ACC_B_CITY_FIELD from '@salesforce/schema/Account.BillingCity';
import ACC_B_ZIP_FIELD from '@salesforce/schema/Account.BillingPostalCode';
import ACC_B_STATE_FIELD from '@salesforce/schema/Account.BillingState';
import ACC_B_COUNTRY_FIELD from '@salesforce/schema/Account.BillingCountry';

import { CurrentPageReference } from 'lightning/navigation';
import { registerListener, unregisterAllListeners, fireEvent } from 'c/pubsub';

const FIELDS = [
    'Opportunity.Account.Name',
    'Opportunity.AccountId',
    'Opportunity.Account.Legal_Name__c',
    'Opportunity.Account.Phone',
    'Opportunity.Account.Website',
    'Opportunity.Account.BillingStreet',
    'Opportunity.Account.BillingCity',
    'Opportunity.Account.BillingState',
    'Opportunity.Account.BillingPostalCode',
    'Opportunity.Account.BillingCountry',
    'Opportunity.Account.AccountSource',
    'Opportunity.Account.Owner.Name',
    'Opportunity.Owner.Name',
    'Opportunity.Account.Time_Zone__c',
    'Opportunity.Account.AnnualRevenue',
    'Opportunity.Account.Date_Established__c',
    'Opportunity.Account.Activation_Date__c',
    'Opportunity.Account.Sic',
    'Opportunity.Account.ShippingStreet',
    'Opportunity.Account.ShippingCity',
    'Opportunity.Account.ShippingState',
    'Opportunity.Account.ShippingPostalCode',
    'Opportunity.Account.ShippingCountry',
    'Opportunity.Account.Company_DBA__c',
    'Opportunity.Account.NF_Renewal_Rep__r.Name'
    // 'Opportunity.Account.SicDesc',
]

export default class OpportunityCompany extends NavigationMixin(LightningElement) {

    
    @api recordId; // Grab the Record Id
    @api objectApiName; // Grab the Objects API Name
    @api accountEditModal = false;

    myMessage;
    @wire(CurrentPageReference) pageRef; // pub sub

    billingAddress = {
        street: '',
        city: '',
        state: '',
        postal: '',
        country: ''
    }

    shippingAddress = {
        street: '',
        city: '',
        state: '',
        postal: '',
        country: ''
    }

    @wire(getRecord, {recordId: '$recordId', fields: FIELDS})
    opportunity;

    get accountId(){
        return getFieldValue(this.opportunity.data, 'Opportunity.AccountId');
    }

    get accountName(){
        return getFieldValue(this.opportunity.data, 'Opportunity.Account.Legal_Name__c');
    }

    get accName(){
        return getFieldValue(this.opportunity.data, 'Opportunity.Account.Name');
    }

    get accountPhone(){
        return getFieldValue(this.opportunity.data, 'Opportunity.Account.Phone');
    }

    get accountWebsite(){
        return getFieldValue(this.opportunity.data, 'Opportunity.Account.Website');
    }

    get accountStreet(){
        return getFieldValue(this.opportunity.data, 'Opportunity.Account.BillingStreet');
    }

    get accountCity(){
        return getFieldValue(this.opportunity.data, 'Opportunity.Account.BillingCity');
    }

    get accountPostal(){
        return getFieldValue(this.opportunity.data, 'Opportunity.Account.BillingPostalCode');
    }

    get accountCountry(){
        return getFieldValue(this.opportunity.data, 'Opportunity.Account.BillingCountry');
    }

    get accountState(){
        return getFieldValue(this.opportunity.data, 'Opportunity.Account.BillingState');
    }

    get accountOwner(){
        return getFieldValue(this.opportunity.data, 'Opportunity.Account.Owner.Name');
    }

    get opportunityOwner(){
        return getFieldValue(this.opportunity.data, 'Opportunity.Owner.Name');
    }

    get renewalRep() {
        return getFieldValue(this.opportunity.data, 'Opportunity.Account.NF_Renewal_Rep__r.Name')
    }

    get accountSource(){
        return getFieldValue(this.opportunity.data, 'Opportunity.Account.AccountSource');
    }

    get timeZone(){
        return getFieldValue(this.opportunity.data, 'Opportunity.Account.Time_Zone__c');
    }

    get activationDate(){
        return getFieldValue(this.opportunity.data, 'Opportunity.Account.Activation_Date__c');
    }

    get dateEstablished(){
        return getFieldValue(this.opportunity.data, 'Opportunity.Account.Date_Established__c');
    }

    get annualRevenue(){
        return getFieldValue(this.opportunity.data, 'Opportunity.Account.AnnualRevenue');
    }

    get shippingStreet(){
        return getFieldValue(this.opportunity.data, 'Opportunity.Account.ShippingStreet');
    }

    get shippingCity(){
        return getFieldValue(this.opportunity.data, 'Opportunity.Account.ShippingCity');  
    }

    get shippingState(){
        return getFieldValue(this.opportunity.data, 'Opportunity.Account.ShippingState');    
    }

    get shippingPostal(){
        return getFieldValue(this.opportunity.data, 'Opportunity.Account.ShippingPostalCode');       
    }

    get shippingCountry(){
        return getFieldValue(this.opportunity.data, 'Opportunity.Account.ShippingCountry');     
    }

    get dbaName(){
        return getFieldValue(this.opportunity.data, 'Opportunity.Account.Company_DBA__c');
    }

    get sicDesc(){
        return getFieldValue(this.opportunity.data, 'Opportunity.Account.SicDesc');   
    }

    get accountTitle() {
        if(this.dbaName && this.accountName) {
            return `${this.accountName} DBA ${this.dbaName}`
        } else if(this.accountName && !this.dbaName){
            return `${this.accountName}`
        } else if(this.dbaName && !this.accountName){
            return `DBA ${this.dbaName}`
        } else {
            return `${this.accName}`
        }
    }

    get countryOptions(){
        return [
            { label: 'US', value: 'US'}
        ]
    }

    get stateOptions() {
        return [
            { label: 'AL', value: 'AL'},
            { label: 'AK', value: 'AK'},
            { label: 'AZ', value: 'AZ'},
            { label: 'AR', value: 'AR'},
            { label: 'CA', value: 'CA'},
            { label: 'CO', value: 'CO'},
            { label: 'CT', value: 'CT'},
            { label: 'DE', value: 'DE'},
            { label: 'DC', value: 'DC'},
            { label: 'FL', value: 'FL'},
            { label: 'GA', value: 'GA'},
            { label: 'HI', value: 'HI'},
            { label: 'ID', value: 'ID'},
            { label: 'IL', value: 'IL'},
            { label: 'IN', value: 'IN'},
            { label: 'IA', value: 'IA'},
            { label: 'KS', value: 'KS'},
            { label: 'KY', value: 'KY'},
            { label: 'LA', value: 'LA'},
            { label: 'ME', value: 'ME'},
            { label: 'MD', value: 'MD'},
            { label: 'MA', value: 'MA'},
            { label: 'MI', value: 'MI'},
            { label: 'MN', value: 'MN'},
            { label: 'MS', value: 'MS'},
            { label: 'MO', value: 'MO'},
            { label: 'MT', value: 'MT'},
            { label: 'NE', value: 'NE'},
            { label: 'NV', value: 'NV'},
            { label: 'NH', value: 'NH'},
            { label: 'NJ', value: 'NJ'},
            { label: 'NM', value: 'NM'},
            { label: 'NY', value: 'NY'},
            { label: 'NC', value: 'NC'},
            { label: 'ND', value: 'ND'},
            { label: 'OH', value: 'OH'},
            { label: 'OK', value: 'OK'},
            { label: 'OR', value: 'OR'},
            { label: 'PA', value: 'PA'},
            { label: 'RI', value: 'RI'},
            { label: 'SC', value: 'SC'},
            { label: 'SD', value: 'SD'},
            { label: 'TN', value: 'TN'},
            { label: 'TX', value: 'TX'},
            { label: 'UT', value: 'UT'},
            { label: 'VT', value: 'VT'},
            { label: 'VI', value: 'VI'},
            { label: 'VA', value: 'VA'},
            { label: 'WA', value: 'WA'},
            { label: 'WV', value: 'WV'},
            { label: 'WI', value: 'WI'},
            { label: 'WY', value: 'WY'},
        ];
    }

    billingChanges(event){
        this.billingAddress.street = event.detail.street;
        this.billingAddress.city = event.detail.city;
        this.billingAddress.postal = event.detail.postalCode;
        this.billingAddress.state = event.detail.province;
        this.billingAddress.country = event.detail.country;
        console.log('New Billing Address: ', this.billingAddress);
    }

    shippingChanges(event){
        this.shippingAddress.street = event.detail.street;
        this.shippingAddress.city = event.detail.city;
        this.shippingAddress.postal = event.detail.postalCode;
        this.shippingAddress.state = event.detail.province;
        this.shippingAddress.country = event.detail.country;
        console.log('New Shipping Address: ', this.shippingAddress);
    }

    updateAccount(){
        this.accountEditModal = true;

        this.billingAddress.street = this.accountStreet;
        this.billingAddress.city = this.accountCity;
        this.billingAddress.state = this.accountState;
        this.billingAddress.postal = this.accountPostal;
        this.billingAddress.country = this.accountCountry;

        this.shippingAddress.street = this.shippingStreet;
        this.shippingAddress.city = this.shippingCity;
        this.shippingAddress.state = this.shippingState;
        this.shippingAddress.postal = this.shippingPostal;
        this.shippingAddress.country = this.shippingCountry;
    }

    closeAccountModal(){
        this.accountEditModal = false;
    }

    saveForm() {

        const allValid = [...this.template.querySelectorAll('lightning-input')]
            .reduce((validSoFar, inputFields) => {
                inputFields.reportValidity();
                return validSoFar && inputFields.checkValidity();
            }, true);

        var accId = getFieldValue(this.opportunity.data, 'Opportunity.AccountId');
        console.log('Updating Account with Id: ', accId);

        const fields = {};
        // Fields
        fields[ACC_ID_FIELD.fieldApiName] = accId;
        fields[ACC_NAME_FIELD.fieldApiName] = this.template.querySelector("[data-field='Legal_Name__c']").value;
        fields[ACC_WEBSITE_FIELD.fieldApiName] = this.template.querySelector("[data-field='Website']").value;
        fields[ACC_DBA_FIELD.fieldApiName] = this.template.querySelector("[data-field='Company_DBA__c']").value;
        fields[ACC_LEGALSTATUS_FIELD.fieldApiName] = this.template.querySelector("[data-field='Legal_Status__c']").value;
        fields[ACC_DATEESTABLISHED_FIELD.fieldApiName] = this.template.querySelector("[data-field='Date_Established__c']").value;
        fields[ACC_FEDTAXID_FIELD.fieldApiName] = this.template.querySelector("[data-field='Fed_Tax_ID__c']").value;
        fields[ACC_STATEOFINCORP_FIELD.fieldApiName] = this.template.querySelector("[data-field='State_of_Incorporation__c']").value;
        fields[ACC_ANNUALREV_FIELD.fieldApiName] = this.template.querySelector("[data-field='AnnualRevenue']").value;
        fields[ACC_PHONE_FIELD.fieldApiName] = this.template.querySelector("[data-field='Phone']").value;
        fields[ACC_TIME_ZONE_FIELD.fieldApiName] = this.template.querySelector("[data-field='Time_Zone__c']").value;

        // Shipping/Physical Address
        fields[ACC_S_STREET_FIELD.fieldApiName] = this.shippingAddress.street;
        fields[ACC_S_CITY_FIELD.fieldApiName] = this.shippingAddress.city;
        fields[ACC_S_ZIP_FIELD.fieldApiName] = this.shippingAddress.postal;
        fields[ACC_S_STATE_FIELD.fieldApiName] = this.shippingAddress.state;
        fields[ACC_S_COUNTRY_FIELD.fieldApiName] = this.shippingAddress.country;

        // Billing/Mailing Address
        fields[ACC_B_STREET_FIELD.fieldApiName] = this.billingAddress.street;
        fields[ACC_B_CITY_FIELD.fieldApiName] = this.billingAddress.city;
        fields[ACC_B_ZIP_FIELD.fieldApiName] = this.billingAddress.postal;
        fields[ACC_B_STATE_FIELD.fieldApiName] = this.billingAddress.state;
        fields[ACC_B_COUNTRY_FIELD.fieldApiName] = this.billingAddress.country;
   
        const recordInput = {
            fields
        };

        console.log('Record Input: ', recordInput);

        if (allValid) {

            console.log('Update Valid');

            updateRecord(recordInput)
                .then(() => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Account updated',
                            variant: 'success'
                        })
                    );
                    console.log('Account Update Successful');
                    console.log('Dispatching Event to Application');
                    fireEvent(this.pageRef, 'AppCheck', this.myMessage);
                    console.log('Dispatched Event to Application');
                })
                .catch(error => {
                    // Error Handling
                    var errors = error.body.output.errors;
                    var fieldErrors = error.body.output.fieldErrors;
                    
                    console.log('Errors: ');
                    console.log(errors);
                    console.log('Field Errors: ');
                    console.log(fieldErrors);
                    console.log('Generic Errors: '+ error.body.message);
                    
                    if(error.body.output.errors != null){
                        console.log('Displaying Errors')
                        // Loop & Display Errors
                        for (let index = 0; index < error.body.output.errors.length; index++) {
                            console.log('Displaying Errors');
                            this.dispatchEvent(
                                new ShowToastEvent({
                                title: "Error on update",
                                message: error.body.output.errors[index].errorCode + '- '+ error.body.output.errors[index].message,
                                variant: "error"
                                })
                            );
                        }
                    } 
                    if(error.body.output.fieldErrors != null){
                        console.log('Displaying Field Errors');
                        for(var prop in fieldErrors){
                            console.log(Object.keys(fieldErrors));
                            var val = Object.values(fieldErrors);
                            console.log(val[0][0]["message"]);
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'Error Updating record',
                                    message: val[0][0]["message"],
                                    variant: 'error'
                                })
                            );
                        }
                    }
                    else{
                        console.log('Displaying Generic Errors')
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Error Updating record',
                                message: error.body.message,
                                variant: 'error'
                            })
                        );
                    }
                    console.error('Error Updating Information');
                    console.error(error);
                    // End of Error Handling
                });

            this.closeAccountModal();
        } 
        else {
            // The form is not valid
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Something is wrong',
                    message: 'Check your input and try again.',
                    variant: 'error'
                })
            );
        }

        
    }

	connectedCallback() {
        console.log('Account Info Connected Callback...');
        registerListener('accountEdit', this.updateAccount , this);
    };
    
	disconnectedCallback() {
		unregisterAllListeners(this);
    };
    
    openAccount() {
        // Navigate to Page
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.accountId,
                actionName: 'view'
            }
        });
    }


}