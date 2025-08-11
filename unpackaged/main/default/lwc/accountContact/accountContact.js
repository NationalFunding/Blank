import {LightningElement,wire,api,track} from 'lwc';
import getContactList from '@salesforce/apex/GetAccountContacts.getContactList';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import {NavigationMixin, CurrentPageReference} from 'lightning/navigation';
import {updateRecord, createRecord} from 'lightning/uiRecordApi';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import { registerListener, unregisterAllListeners, fireEvent } from 'c/pubsub';
import { refreshApex } from '@salesforce/apex';

import CONTACT_OBJECT from '@salesforce/schema/Contact';
import ACCOUNT_OBJECT from '@salesforce/schema/Account';
import ID_FIELD from '@salesforce/schema/Contact.Id';
import TITLE_FIELD from '@salesforce/schema/Contact.Title';
import EMAIL_FIELD from '@salesforce/schema/Contact.Email';
import MOBILE_FIELD from '@salesforce/schema/Contact.MobilePhone';
import FIRSTNAME_FIELD from '@salesforce/schema/Contact.FirstName';
import LASTNAME_FIELD from '@salesforce/schema/Contact.LastName';
import ACCOUNT_FIELD from '@salesforce/schema/Contact.AccountId';
import BIRTHDATE_FIELD from '@salesforce/schema/Contact.Birthdate';
import SSN_FIELD from '@salesforce/schema/Contact.SSN_Encrypted__c';
import OWNERSHIP_FIELD from '@salesforce/schema/Contact.Ownership_Percentage__c';
import HOME_PHONE_FIELD from '@salesforce/schema/Contact.HomePhone';
import STREET_FIELD from '@salesforce/schema/Contact.OtherStreet';
import CITY_FIELD from '@salesforce/schema/Contact.OtherCity';
import ZIP_FIELD from '@salesforce/schema/Contact.OtherPostalCode';
import STATE_FIELD from '@salesforce/schema/Contact.OtherState';

export default class AccountContact extends NavigationMixin(LightningElement) {
    
    @api recordId; // Grab the Record Id
    @api objectApiName; // Grab the Objects API Name
    openmodel = false; // Default Modal to Closed
    contactCreateModal = false; // Default Modal to closed
    recordEditId;
    objectInfo;

    defaultRecordType;

    @wire(CurrentPageReference) pageRef; //PubSub
    
    fullName;

    mailingAddress = {
        street: '',
        city: '',
        state: '',
        postal: '',
        country: ''
    }

    // New Contact Variables
    newContactFirstName = '';
    newContactLastName = '';
    newContactTitle = '';
    newContactEmail = '';
    newContactMobile = '';
    newContactSSN = '';
    newContactDOB = '';
    newContactAdd = '';
    newContactRole = '';
    newContactHomePhone = '';
    newContactOwnership ='';
    newContactStreet = '';
    newContactCity = '';
    newContactZip = '';
    newContactState = '';

    // Variables for Data Refresh
    contacts;
    error;
    wiredContactsResult;

    connectedCallback() {
        // subscribe to event
        console.log('Account Contacts Connected callback...');
        registerListener('AddContact', this.addContact, this);
        console.log('Event Listener Registered');
    }

    @wire(getContactList, {accountId: '$recordId'})
    contactsResult(result) {
        console.log('result:');
        console.log(result);
        console.log(result.data);

        this.wiredContactsResult = result;
        if(result.data){
            console.log('data-->');
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

    // Open Modal
    openmodal(event) {
        
        this.openmodel = true;
        this.recordEditId = event.target.value;
        this.fullName = event.target.dataset.name;
        

        this.mailingAddress.street = event.target.dataset.street;
        this.mailingAddress.city = event.target.dataset.city;
        this.mailingAddress.state = event.target.dataset.province;
        this.mailingAddress.postal = event.target.dataset.postal;
        this.mailingAddress.country = event.target.dataset.country;

        console.log('Record Edit Id: ', this.recordEditId);
        console.log('Contact Name: ', this.fullName);
        console.log('Mailing Address: ', this.mailingAddress);

    }

    // Close Modal
    closeModal() {
        this.openmodel = false
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

    mailingChanges(event){
        this.mailingAddress.street = event.detail.street;
        this.mailingAddress.city = event.detail.city;
        this.mailingAddress.postal = event.detail.postalCode;
        this.mailingAddress.state = event.detail.province;
        this.mailingAddress.country = event.detail.country;
        console.log(this.mailingAddress);
    }

    mailingCreate(event){
        this.mailingAddress.street = event.detail.street;
        this.mailingAddress.city = event.detail.city;
        this.mailingAddress.postal = event.detail.postalCode;
        this.mailingAddress.state = event.detail.province;
        this.mailingAddress.country = event.detail.country;
        console.log(this.mailingAddress);  
    }

    saveForm() {

        console.log('Updating Contact');

        const allValid = [...this.template.querySelectorAll('lightning-input')]
            .reduce((validSoFar, inputFields) => {
                inputFields.reportValidity();
                return validSoFar && inputFields.checkValidity();
            }, true);

        const fields = {};
        fields[ID_FIELD.fieldApiName] = this.recordEditId;
        fields[FIRSTNAME_FIELD.fieldApiName] = this.template.querySelector("[data-field='FirstName']").value;
        fields[LASTNAME_FIELD.fieldApiName] = this.template.querySelector("[data-field='LastName']").value;
        fields[TITLE_FIELD.fieldApiName] = this.template.querySelector("[data-field='Title']").value;
        fields[EMAIL_FIELD.fieldApiName] = this.template.querySelector("[data-field='Email']").value;
        fields[MOBILE_FIELD.fieldApiName] = this.template.querySelector("[data-field='MobilePhone']").value;
        fields[BIRTHDATE_FIELD.fieldApiName] = this.template.querySelector("[data-field='Birthdate']").value;
        fields[SSN_FIELD.fieldApiName] = this.template.querySelector("[data-field='SSN_Encrypted__c']").value;
        fields[OWNERSHIP_FIELD.fieldApiName] = this.template.querySelector("[data-field='Ownership_Percentage__c']").value;
        fields[HOME_PHONE_FIELD.fieldApiName] = this.template.querySelector("[data-field='HomePhone']").value;
        fields[STREET_FIELD.fieldApiName] = this.mailingAddress.street;
        fields[CITY_FIELD.fieldApiName] = this.mailingAddress.city;
        fields[ZIP_FIELD.fieldApiName] = this.mailingAddress.postal;
        fields[STATE_FIELD.fieldApiName] = this.mailingAddress.state;
       
        const recordInput = {
            fields
        };

        console.log(recordInput);

        if (allValid) {

            updateRecord(recordInput)
                .then(() => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Contact updated',
                            variant: 'success'
                        })
                    );
                    console.log('Returning updated Contact List');
                    return refreshApex(this.wiredContactsResult);
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

            this.closeModal();
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


    // Create Contact Functions
    addContact() {
        this.contactCreateModal = true; 
        
        this.mailingAddress = {
            street: '',
            city: '',
            state: '',
            postal: '',
            country: ''
        };
    }

    closeCreateModal() {
        this.contactCreateModal = false;
    }

    handleFirstNameChange(event) {
        this.newContactFirstName = event.target.value;
        console.log('First Name: ', this.newContactFirstName);
    }

    handleTitleChange(event) {
        this.newContactTitle = event.target.value;
        console.log('Title: ', this.newContactTitle);
    }

    handleMobileChange(event) {
        this.newContactMobile = event.target.value;
        console.log('Mobile: ', this.newContactMobile);
    }

    handleLastNameChange(event) {
        this.newContactLastName = event.target.value;
        console.log('Last Name: ', this.newContactLastName); 
    }

    handleEmailChange(event){
        this.newContactEmail = event.target.value;
        console.log('Email: ', this.newContactEmail);
    }

    handleSSNChange(event){
        this.newContactSSN = event.target.value;
        console.log('SSN: ', this.newContactSSN);
    }

    handleDOBChange(event){
        this.newContactDOB = event.target.value;
        console.log('DOB: ', this.newContactDOB);
    }

    handleHPChange(event){
        this.newContactHomePhone = event.target.value;
        console.log('Home Phone: ', this.newContactHomePhone);
    }

    handleOPChange(event){
        this.newContactOwnership = event.target.value;
        console.log('Ownership %: ', this.newContactOwnership);
    }

    handleHStreetChange(event){
        this.newContactStreet = event.target.value;
        console.log('Home Street: ', this.newContactStreet);
    } 

    handleHCityChange(event){
        this.newContactCity = event.target.value;
        console.log('Home City: ', this.newContactCity);
    }

    handleHZipChange(event){
        this.newContactZip = event.target.value;
        console.log('Home Zip: ', this.newContactZip);
    }

    handleHStateChange(event){
        this.newContactState = event.target.value;
        console.log('Home State: ', this.newContactState);
    }


    createContact() {
        console.log('Attempting to create a new contact');

        const fields = {};
        fields[TITLE_FIELD.fieldApiName] = this.newContactTitle;
        fields[EMAIL_FIELD.fieldApiName] = this.newContactEmail;
        fields[MOBILE_FIELD.fieldApiName] = this.newContactMobile;
        fields[FIRSTNAME_FIELD.fieldApiName] = this.newContactFirstName;
        fields[LASTNAME_FIELD.fieldApiName] = this.newContactLastName;
        fields[ACCOUNT_FIELD.fieldApiName] = this.recordId;
        fields[SSN_FIELD.fieldApiName] = this.newContactSSN;
        fields[BIRTHDATE_FIELD.fieldApiName] = this.newContactDOB;
        fields[HOME_PHONE_FIELD.fieldApiName] = this.newContactHomePhone;
        fields[OWNERSHIP_FIELD.fieldApiName] = this.newContactOwnership;
        fields[STREET_FIELD.fieldApiName] = this.mailingAddress.street;
        fields[CITY_FIELD.fieldApiName] = this.mailingAddress.city;
        fields[ZIP_FIELD.fieldApiName] = this.mailingAddress.postal;
        fields[STATE_FIELD.fieldApiName] = this.mailingAddress.state;

        console.log(fields);

        const recordInput = { apiName: CONTACT_OBJECT.objectApiName, fields};

        console.log(recordInput);

        createRecord(recordInput)
            .then(contact => {
                console.log('Contact Created Result:');
                console.log(contact);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Contact Created',
                        variant: 'success',
                    }),
                );
                console.log('Returning updated Contact List');
                return refreshApex(this.wiredContactsResult);
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

        // Close Modal
        this.closeCreateModal();
    }

    openContact(event){

        console.log('Opening Contact');

        let contactId = event.target.dataset.id;
        console.log(contactId);
        console.log(this.mailingAddress);

        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: contactId,
                actionName: 'view'
            }
        });
    }

    connectedCallback(){
        //Refresh contact list on load
        refreshApex(this.wiredContactsResult);
    }
}