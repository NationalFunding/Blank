import { LightningElement, wire, api, track } from 'lwc';
import { getRecord, getFieldValue, updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';

import ACCOUNTID_FIELD from '@salesforce/schema/Account.Id';
import ACCOUNTNAME_FIELD from '@salesforce/schema/Account.Legal_Name__c';
import ACCOUNTPHONE_FIELD from '@salesforce/schema/Account.Phone';
import ACCOUNTWEBSITE_FIELD from '@salesforce/schema/Account.Website';
import BILLINGSTREET_FIELD from '@salesforce/schema/Account.BillingStreet';
import BILLINGCITY_FIELD from '@salesforce/schema/Account.BillingCity';
import BILLINGSTATE_FIELD from '@salesforce/schema/Account.BillingState';
import BILLINGPOSTAL_FIELD from '@salesforce/schema/Account.BillingPostalCode';
import BILLINGCOUNTRY_FIELD from '@salesforce/schema/Account.BillingCountry';
import ACCOUNTTIMEZONE_FIELD from '@salesforce/schema/Account.Time_Zone__c';
import ACCOUNTFEDTAXID_FIELD from '@salesforce/schema/Account.Fed_Tax_ID__c';
import ACCOUNTANNUALREV_FIELD from '@salesforce/schema/Account.AnnualRevenue';
import ACCOUNTDATEEST_FIELD from '@salesforce/schema/Account.Date_Established__c';

import ACCOUNTSIC_FIELD from '@salesforce/schema/Account.Sic';
import ACCOUNTLEGALSTATUS_FIELD from '@salesforce/schema/Account.Legal_Status__c';
import ACCOUNTDBA_FIELD from '@salesforce/schema/Account.Company_DBA__c';
import ACCOUNTSTATEOFINCORP_FIELD from '@salesforce/schema/Account.State_of_Incorporation__c';
import SHIPPINGSTREET_FIELD from '@salesforce/schema/Account.ShippingStreet';
import SHIPPINGCITY_FIELD from '@salesforce/schema/Account.ShippingCity';
import SHIPPINGSTATE_FIELD from '@salesforce/schema/Account.ShippingState';
import SHIPPINGPOSTAL_FIELD from '@salesforce/schema/Account.ShippingPostalCode';
import SHIPPINGCOUNTRY_FIELD from '@salesforce/schema/Account.ShippingCountry';


// Define Fields to Query
const FIELDS = [
    'Account.Name',
    'Account.Legal_Name__c',
    'Account.Phone',
    'Account.Website',
    'Account.BillingStreet',
    'Account.BillingCity',
    'Account.BillingState',
    'Account.BillingPostalCode',
    'Account.BillingCountry',
    'Account.AccountSource',
    'Account.Owner.Name',
    'Account.Time_Zone__c',
    'Account.Fed_Tax_ID__c',
    'Account.AnnualRevenue',
    'Account.Date_Established__c',
    'Account.Activation_Date__c',
    'Account.Sic',
    'Account.ShippingStreet',
    'Account.ShippingCity',
    'Account.ShippingState',
    'Account.ShippingPostalCode',
    'Account.ShippingCountry',
    'Account.Company_DBA__c',
    // 'Account.SicDesc',
]

export default class AccountCompany extends NavigationMixin(LightningElement) {

    @api recordId; // Grab the Record Id
    @api objectApiName; // Grab the Objects API Name
    @api accountEditModal = false;

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
    leadResult(result){
        console.log('Account Result:');
        console.log(result);

        if(result.data){
            // Billing Address
            this.billingAddress.street = result.data.fields.BillingStreet.value;
            this.billingAddress.city = result.data.fields.BillingCity.value;
            this.billingAddress.state = result.data.fields.BillingState.value;
            this.billingAddress.postal = result.data.fields.BillingPostalCode.value;
            this.billingAddress.country = result.data.fields.BillingCountry.value;

            // Shipping Address
            this.shippingAddress.street = result.data.fields.ShippingStreet.value;
            this.shippingAddress.city = result.data.fields.ShippingCity.value;
            this.shippingAddress.state = result.data.fields.ShippingState.value;
            this.shippingAddress.postal = result.data.fields.ShippingPostalCode.value;
            this.shippingAddress.country = result.data.fields.ShippingCountry.value;
        }
    };

    @wire(getRecord, {recordId: '$recordId', fields: FIELDS})
    account;
   
    get companyName(){
        console.log('Account Data:');
        console.log(this.account.data);
        return getFieldValue(this.account.data, 'Account.Legal_Name__c');
    }
    
    get name(){
        return getFieldValue(this.account.data, 'Account.Name');
    }
    
    get accountPhone(){
        return getFieldValue(this.account.data, 'Account.Phone');
    }
    
    get accountWebsite(){
        return getFieldValue(this.account.data, 'Account.Website');
    }

    get accountStreet(){
        return getFieldValue(this.account.data, 'Account.BillingStreet');
    }

    get accountCity(){
        return getFieldValue(this.account.data, 'Account.BillingCity');
    }

    get accountPostal(){
        return getFieldValue(this.account.data, 'Account.BillingPostalCode');
    }

    get accountCountry(){
        return getFieldValue(this.account.data, 'Account.BillingCountry');
    }

    get accountState(){
        return getFieldValue(this.account.data, 'Account.BillingState');
    }

    get accountOwner(){
        return getFieldValue(this.account.data, 'Account.Owner.Name');
    }

    get accountSource(){
        return getFieldValue(this.account.data, 'Account.AccountSource');
    }

    get timeZone(){
        return getFieldValue(this.account.data, 'Account.Time_Zone__c');
    }

    get activationDate(){
        return getFieldValue(this.account.data, 'Account.Activation_Date__c');
    }

    get dateEstablished(){
        return getFieldValue(this.account.data, 'Account.Date_Established__c');
    }

    get annualRevenue(){
        return getFieldValue(this.account.data, 'Account.AnnualRevenue');
    }

    get shippingStreet(){
        return getFieldValue(this.account.data, 'Account.ShippingStreet');
    }

    get shippingCity(){
        return getFieldValue(this.account.data, 'Account.ShippingCity');  
    }

    get shippingState(){
        return getFieldValue(this.account.data, 'Account.ShippingState');    
    }

    get shippingPostal(){
        return getFieldValue(this.account.data, 'Account.ShippingPostalCode');       
    }

    get shippingCountry(){
        return getFieldValue(this.account.data, 'Account.ShippingCountry');     
    }

    get dbaName(){
        return getFieldValue(this.account.data, 'Account.Company_DBA__c');
    }

    get sicDesc(){
        return getFieldValue(this.account.data, 'Account.SicDesc');
    }

    get accountTitle() {
        if(this.dbaName && this.companyName) {
            return `${this.companyName} DBA ${this.dbaName}`
        } else if(this.companyName && !this.dbaName){
            return `${this.companyName}`
        } else if(this.dbaName && !this.companyName){
            return `DBA ${this.dbaName}`
        } else {
            return `${this.name}`
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
//
    // get billingAddressData(){

    //     this.billingAddress = {
    //         street: getFieldValue(this.account.data, 'Account.BillingStreet'),
    //         city: getFieldValue(this.account.data, 'Account.BillingCity'),
    //         state: getFieldValue(this.account.data, 'Account.BillingState'),
    //         postal: getFieldValue(this.account.data, 'Account.BillingPostalCode'),
    //         country: getFieldValue(this.account.data, 'Account.BillingCountry')
    //     }
    // }

    // get shippingAddressData(){

    //     this.shippingAddress = {
    //         street: getFieldValue(this.account.data, 'Account.ShippingStreet'),
    //         city: getFieldValue(this.account.data, 'Account.ShippingCity'),
    //         state: getFieldValue(this.account.data, 'Account.ShippingPostalCode'),
    //         postal: getFieldValue(this.account.data, 'Account.ShippingPostalCode'),
    //         county: getFieldValue(this.account.data, 'Account.ShippingCountry')
    //     }
    // }
//
    billingChanges(event){
        this.billingAddress.street = event.detail.street;
        this.billingAddress.city = event.detail.city;
        this.billingAddress.postal = event.detail.postalCode;
        this.billingAddress.state = event.detail.province;
        this.billingAddress.country = event.detail.country;
        console.log(this.billingAddress);
    }

    shippingChanges(event){
        this.shippingAddress.street = event.detail.street;
        this.shippingAddress.city = event.detail.city;
        this.shippingAddress.postal = event.detail.postalCode;
        this.shippingAddress.state = event.detail.province;
        this.shippingAddress.country = event.detail.country;
        console.log(this.shippingAddress);
    }

    updateAccount(){
        this.accountEditModal = true;
    }

    closeAccountModal(){
        this.accountEditModal = false;
    }

    // Save/Update Form
    saveForm() {

        console.log('Updating Account');
        const fields = {};

        fields[ACCOUNTID_FIELD.fieldApiName] = this.recordId;
        fields[ACCOUNTNAME_FIELD.fieldApiName] = this.template.querySelector("[data-field='Legal_Name__c']").value;
        fields[ACCOUNTPHONE_FIELD.fieldApiName] = this.template.querySelector("[data-field='Phone']").value;
        fields[ACCOUNTWEBSITE_FIELD.fieldApiName] = this.template.querySelector("[data-field='Website']").value;
        fields[ACCOUNTTIMEZONE_FIELD.fieldApiName] = this.template.querySelector("[data-field='Time_Zone__c']").value;
        fields[ACCOUNTFEDTAXID_FIELD.fieldApiName] = this.template.querySelector("[data-field='Fed_Tax_ID__c']").value;  
        fields[ACCOUNTANNUALREV_FIELD.fieldApiName] = this.template.querySelector("[data-field='AnnualRevenue']").value;   
        fields[ACCOUNTDATEEST_FIELD.fieldApiName] = this.template.querySelector("[data-field='Date_Established__c']").value;        
        fields[ACCOUNTLEGALSTATUS_FIELD.fieldApiName] = this.template.querySelector("[data-field='Legal_Status__c']").value;
        fields[ACCOUNTDBA_FIELD.fieldApiName]  = this.template.querySelector("[data-field='Company_DBA__c']").value;
        fields[ACCOUNTSTATEOFINCORP_FIELD.fieldApiName] = this.template.querySelector("[data-field='State_of_Incorporation__c']").value;  
        
        fields[BILLINGSTREET_FIELD.fieldApiName] = this.billingAddress.street;
        fields[BILLINGCITY_FIELD.fieldApiName] = this.billingAddress.city;
        fields[BILLINGSTATE_FIELD.fieldApiName] = this.billingAddress.state;
        fields[BILLINGPOSTAL_FIELD.fieldApiName] = this.billingAddress.postal;
        fields[BILLINGCOUNTRY_FIELD.fieldApiName] = this.billingAddress.country;
        
        fields[SHIPPINGSTREET_FIELD.fieldApiName] = this.shippingAddress.street;
        fields[SHIPPINGCITY_FIELD.fieldApiName] = this.shippingAddress.city;
        fields[SHIPPINGSTATE_FIELD.fieldApiName] = this.shippingAddress.state;
        fields[SHIPPINGPOSTAL_FIELD.fieldApiName] = this.shippingAddress.postal;
        fields[SHIPPINGCOUNTRY_FIELD.fieldApiName] = this.shippingAddress.country;

        const recordInput = {
            fields
        };

        console.log('Record Input: ', recordInput);

        updateRecord(recordInput)
            .then(() => {
                console.log('Account Information Updated');
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Account updated',
                        variant: 'success'
                    })
                );
            })
            .catch((error) => {
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
            }
        );
        // Close Modal
        this.closeAccountModal();
    }
}