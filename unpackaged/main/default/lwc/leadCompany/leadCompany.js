import { LightningElement, wire, api } from 'lwc';
import { getRecord, getFieldValue, updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';

import LEAD_ID_FIELD from '@salesforce/schema/Lead.Id';
import COMPANY_FIELD from '@salesforce/schema/Lead.Company';
import DBA_FIELD from '@salesforce/schema/Lead.DBA__c';
import LEGAL_STATUS_FIELD from '@salesforce/schema/Lead.Ownership__c';
import DATE_ESTABLISHED_FIELD from '@salesforce/schema/Lead.Date_Established__c';
import WEBSITE_FIELD from '@salesforce/schema/Lead.Website';
import PHONE_FIELD from '@salesforce/schema/Lead.Phone';
import FED_TAX_ID_FIELD from '@salesforce/schema/Lead.Federal_Tax_ID__c';
import STATE_OF_INCORP_FIELD from '@salesforce/schema/Lead.State_of_Incorporation__c';
import ANNUAL_REV_FIELD from '@salesforce/schema/Lead.AnnualRevenue';
import TIME_ZONE_FIELD from '@salesforce/schema/Lead.Time_Zone__c';
// import ALTERNATE_PHONE_FIELD from '@salesforce/schema/Lead.Alternate_Phone__c';
// import ALTERNATE_PHONE_2 from '@salesforce/schema/Lead.Alternate_Phone_2__c';
import STREET_FIELD from '@salesforce/schema/Lead.Street';
import CITY_FIELD from '@salesforce/schema/Lead.City';
import POSTALCODE_FIELD from '@salesforce/schema/Lead.PostalCode';
import STATE_FIELD from '@salesforce/schema/Lead.State';
// import SIC_FIELD from '@salesforce/schema/Lead.Sic__c';
import COUNTRY_FIELD from '@salesforce/schema/Lead.Country';
// import LANDLORDNAME_FIELD from '@salesforce/schema/Lead.Landlord_Name__c';
// import LANDLORDPHONE_FIELD from '@salesforce/schema/Lead.Landlord_Phone__c';
// import BUSINESSPROPERTY_FIELD from '@salesforce/schema/Lead.Business_Property_Status__c';

// Define Fields to Query
const FIELDS = [
    'Lead.Company',
    'Lead.Phone',
    'Lead.Website',
    'Lead.Street',
    'Lead.City',
    'Lead.State',
    'Lead.PostalCode',
    'Lead.Country',
    'Lead.LeadSource',
    'Lead.Owner.Name',
    'Lead.Time_Zone__c',
    'Lead.Date_Established__c',
    'Lead.AnnualRevenue',
    'Lead.Activation_Date__c',
    // 'Lead.Alternate_Phone__c',
    // 'Lead.Alternate_Phone_2__c',
    // 'Lead.SICCODE__c',
    'Lead.DBA__c',
    // 'Lead.SicDesc__c',
    'Lead.Street',
    'Lead.City',
    'Lead.State',
    'Lead.PostalCode',
    'Lead.Country',
    'Lead.Annual_Sales__c',
]

export default class LeadCompany extends NavigationMixin(LightningElement) {

    @api recordId; // Grab the Record Id
    @api objectApiName; // Grab the Objects API Name
    @api accountEditModal = false;

    companyAddress = {
        street: '',
        city: '',
        state: '',
        postal: '',
        country: ''
    };

    @wire(getRecord, {recordId: '$recordId', fields: FIELDS})
    leadResult(result){
        console.log('Lead Result:');
        console.log(result);

        if(result.data){
            this.companyAddress.street = result.data.fields.Street.value;
            this.companyAddress.city = result.data.fields.City.value;
            this.companyAddress.state = result.data.fields.State.value;
            this.companyAddress.postal = result.data.fields.PostalCode.value;
            this.companyAddress.country = result.data.fields.Country.value;
        }
    };

    // Query Lead Data based on Record Id
    @wire(getRecord, {recordId: '$recordId', fields: FIELDS})
    lead;
   
    get companyName(){
        return getFieldValue(this.lead.data, 'Lead.Company');
    }
    
    get accountPhone(){
        return getFieldValue(this.lead.data, 'Lead.Phone');
    }
    
    get accountWebsite(){
        return getFieldValue(this.lead.data, 'Lead.Website');
    }

    get accountStreet(){
        return getFieldValue(this.lead.data, 'Lead.Street');
    }

    get accountCity(){
        return getFieldValue(this.lead.data, 'Lead.City');
    }

    get accountPostal(){
        return getFieldValue(this.lead.data, 'Lead.PostalCode');
    }

    get accountCountry(){
        return getFieldValue(this.lead.data, 'Lead.Country');
    }

    get accountState(){
        return getFieldValue(this.lead.data, 'Lead.State');
    }
    
    get leadSource(){
        return getFieldValue(this.lead.data, 'Lead.LeadSource');
    }

    get leadOwner(){
        return getFieldValue(this.lead.data, 'Lead.Owner.Name');
    }

    get timeZone(){
        return getFieldValue(this.lead.data, 'Lead.Time_Zone__c');
    }

    get activationDate(){
        return getFieldValue(this.lead.data, 'Lead.Activation_Date__c');
    }

    get dateEstablished(){
        return getFieldValue(this.lead.data, 'Lead.Date_Established__c');
    }

    get annualRevenue(){
        return getFieldValue(this.lead.data, 'Lead.AnnualRevenue');
    }

    get distributionTier(){
        return getFieldValue(this.lead.data, 'Lead.Annual_Sales__c');
    }

    // get altPhone(){
    //     return getFieldValue(this.lead.data, 'Lead.Alternate_Phone__c');
    // }

    // get altPhone2(){
    //     return getFieldValue(this.lead.data, 'Lead.Alternate_Phone_2__c');
    // }

    get dbaName(){
        return getFieldValue(this.lead.data, 'Lead.DBA__c');
    }

    // get sicDesc(){
    //     return getFieldValue(this.lead.data, 'Lead.SicDesc__c');
    // }

    get accountTitle() {

        if(this.dbaName) {
            return `${this.companyName} DBA ${this.dbaName}`
        } 
        return `${this.companyName}`
    }

    handleChange(event){
        this.companyAddress.street = event.detail.street;
        this.companyAddress.city = event.detail.city;
        this.companyAddress.postal = event.detail.postalCode;
        this.companyAddress.state = event.detail.province;
        this.companyAddress.country = event.detail.country;
        console.log(this.companyAddress);
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

    updateAccount(){
        this.accountEditModal = true;
        console.log(this.accountWebsite);
    }

    closeAccountModal(){
        this.accountEditModal = false;
    }

    saveForm(){
        
        console.log('DE: ', this.dateEstablished);
        console.log('AR: ', this.annualRevenue);
        console.log('LO: ', this.leadOwner);

        console.log('something cheeky...');

        const allValid = [...this.template.querySelectorAll('lightning-input')]
            .reduce((validSoFar, inputFields) => {
                inputFields.reportValidity();
                return validSoFar && inputFields.checkValidity();
        }, true);

        console.log('Updating Leads "Account Information"...');

        const fields = {};
        fields[LEAD_ID_FIELD.fieldApiName] = this.recordId;
        fields[COMPANY_FIELD.fieldApiName] = this.template.querySelector("[data-field='Company']").value;
        fields[DBA_FIELD.fieldApiName] = this.template.querySelector("[data-field='DBA__c']").value;
        fields[LEGAL_STATUS_FIELD.fieldApiName] = this.template.querySelector("[data-field='Ownership__c']").value;
        fields[DATE_ESTABLISHED_FIELD.fieldApiName] = this.template.querySelector("[data-field='Date_Established__c']").value;
        fields[WEBSITE_FIELD.fieldApiName] = this.template.querySelector("[data-field='Website']").value;
        fields[PHONE_FIELD.fieldApiName] = this.template.querySelector("[data-field='Phone']").value;
        fields[FED_TAX_ID_FIELD.fieldApiName] = this.template.querySelector("[data-field='Federal_Tax_ID__c']").value;
        fields[STATE_OF_INCORP_FIELD.fieldApiName] = this.template.querySelector("[data-field='State_of_Incorporation__c']").value;
        fields[ANNUAL_REV_FIELD.fieldApiName] = this.template.querySelector("[data-field='AnnualRevenue']").value;
        fields[TIME_ZONE_FIELD.fieldApiName] = this.template.querySelector("[data-field='Time_Zone__c']").value;
        // fields[ALTERNATE_PHONE_FIELD.fieldApiName] = this.template.querySelector("[data-field='Alternate_Phone__c']").value;
        // fields[SICCODE__c.fieldApiName] = this.template.querySelector("[data-field='SICCODE__c']").value;
        // fields[LANDLORDNAME_FIELD.fieldApiName] = this.template.querySelector("[data-field='Landlord_Name__c']").value;
        // fields[LANDLORDPHONE_FIELD.fieldApiName] = this.template.querySelector("[data-field='Landlord_Phone__c']").value;
        // fields[BUSINESSPROPERTY_FIELD.fieldApiName] = this.template.querySelector("[data-field='Business_Property_Status__c']").value;
        // fields[ALTERNATE_PHONE_2.fieldApiName] = this.template.querySelector("[data-field='Alternate_Phone_2__c']").value;

        fields[STREET_FIELD.fieldApiName] = this.companyAddress.street;
        fields[CITY_FIELD.fieldApiName] =  this.companyAddress.city;
        fields[POSTALCODE_FIELD.fieldApiName] = this.companyAddress.postal;
        fields[STATE_FIELD.fieldApiName] = this.companyAddress.state;
        fields[COUNTRY_FIELD.fieldApiName] = 'United States';

        console.log('Fields: ', fields);

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
                            message: 'Lead updated',
                            variant: 'success'
                        })
                    );
                    console.log('Update Successful');
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

}