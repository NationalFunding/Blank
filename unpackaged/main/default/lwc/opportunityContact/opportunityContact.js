import { LightningElement, wire, api, track } from 'lwc';
import { getRecord, getFieldValue, updateRecord , createRecord } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import getMainOppContactRole from '@salesforce/apex/ContactListOpportunity.getMainOppContactRole';

import ACC_ID from '@salesforce/schema/Opportunity.AccountId';
import ID_FIELD from '@salesforce/schema/Contact.Id';
import TITLE_FIELD from '@salesforce/schema/Contact.Title';
import EMAIL_FIELD from '@salesforce/schema/Contact.Email';
import MOBILE_FIELD from '@salesforce/schema/Contact.MobilePhone';
import FIRSTNAME_FIELD from '@salesforce/schema/Contact.FirstName';
import LASTNAME_FIELD from '@salesforce/schema/Contact.LastName';
import ACCOUNT_FIELD from '@salesforce/schema/Contact.AccountId';
import CONTACT_OBJECT from '@salesforce/schema/Contact';
import HOME_PHONE_FIELD from '@salesforce/schema/Contact.HomePhone';
import SSN_FIELD from '@salesforce/schema/Contact.SSN_Encrypted__c';
import DOB_FIELD from '@salesforce/schema/Contact.Birthdate';
import OWNERSHIP_FIELD from '@salesforce/schema/Contact.Ownership_Percentage__c';
import STREET_FIELD from '@salesforce/schema/Contact.OtherStreet';
import CITY_FIELD from '@salesforce/schema/Contact.OtherCity';
import ZIP_FIELD from '@salesforce/schema/Contact.OtherPostalCode';
import STATE_FIELD from '@salesforce/schema/Contact.OtherState';

import { CurrentPageReference } from 'lightning/navigation';
import { registerListener, unregisterAllListeners, fireEvent } from 'c/pubsub';

import opportunityContactRoleFlow from '@salesforce/apex/InvokeOpportunityContactRoleUpdate.start';
import getContactList from '@salesforce/apex/ContactListOpportunity.getOpportunityContacts';

export default class OpportunityContact extends NavigationMixin(LightningElement) {

    @api
    get recordId() {
        return this._recordId;
    }
    set recordId(value) {
        if (value === undefined || value === null) return;

        this._recordId = value
        getMainOppContactRole()
            .then((result) => {
                this.uniqueRoles = result;
            })
            .catch((error) => {
                console.error('Error fetching main role:', error);
            });
    }

    @api objectApiName; // Grab the Objects API Name
    @track accId; // Account Id
    @track contactModal = false;

    @track contactCreateModal = false;

    @track myMessage;
    @wire(CurrentPageReference) pageRef;

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

    contactTitle;
    contactEmail;
    contactRole;
    contactMobile;
    contactDOB;
    contactSSN;
    contactFirstName;
    contactLastName;
    contactMailingAddress;
    contactOwnerhsip;

    recordEditId;
    contactRecordId;
    fullName;
    
    contacts;
    error;
    wiredContactsResult;

    disabled = false; // disable the create/update contact button
    mainRole;
    uniqueRoles;

    get options() {
        return [
            { label: 'None', value: ""},
            { label: 'Signor', value: 'Signor' },
            { label: 'Guarantor 2', value: 'Guarantor 2' },
            { label: 'Guarantor 3', value: 'Guarantor 3' },
            { label: 'Guarantor 4', value: 'Guarantor 4' },
            { label: 'Guarantor 5', value: 'Guarantor 5' },
            { label: 'Guarantor 6', value: 'Guarantor 6' },
            { label: 'Co-Lessee', value: 'Co-Lessee' },
            { label: 'Assistant', value: 'Assistant' },
            { label: 'Gatekeeper', value: 'Gatekeeper' },
            { label: 'Spouse of Signor / Guarantor', value: 'Spouse of Signor / Guarantor' },
            { label: 'Contact- Without Ownership', value: 'Contact- Without Ownership' },
        ];
    }

    get disableButton(){
        return this.disabled;
    }

    connectedCallback() {
        registerListener('newContact', this.addContact , this);
    };
    
	disconnectedCallback() {
		unregisterAllListeners(this);
    };

    @wire(getRecord, {recordId: '$recordId', fields: [ACC_ID] })
    account({error, data}) {
        if(data) {
            this.accId = getFieldValue(data, ACC_ID);
        } else if (error) {
            console.log(error);
        }
    }

    @wire(getContactList, {accountId: '$accId', opportunityId: '$recordId'})
    contactsResult(result){
        this.wiredContactsResult = result;
        if(result.data){
            this.contacts = result.data;
            var i;
            var iteration;
            var tempArray = [];
            for(i = 0; i < result.data.length; i++) {
                var oppContactRoleId = undefined;
                var oppRole = undefined;
                var oppRolePrimary = undefined;

                if(result.data[i].OpportunityContactRoles != undefined) {
                    oppContactRoleId = result.data[i].OpportunityContactRoles[0].Id;
                    oppRole = result.data[i].OpportunityContactRoles[0].Role;
                    oppRolePrimary = result.data[i].OpportunityContactRoles[0].IsPrimary;
                }

                iteration = {
                    Id: result.data[i].Id,
                    Name: result.data[i].Name,
                    Title: result.data[i].Title,
                    Email: result.data[i].Email,
                    MobilePhone: result.data[i].MobilePhone,
                    SSN: result.data[i].SSN_Encrypted__c,
                    DOB: result.data[i].Birthdate,
                    Address: result.data[i].OtherAddress,
                    Ownership: result.data[i].Ownership_Percentage__c,
                    OpportunityContactRoleId: oppContactRoleId,
                    OpportunityContactRoleIsPrimary: oppRolePrimary,
                    OpportunityContactRoleRole: oppRole,
                    MailingStreet: result.data[i].OtherStreet,
                    MailingCity: result.data[i].OtherCity,
                    MailingState: result.data[i].OtherState,
                    MailingPostal: result.data[i].OtherPostalCode,
                    MailingCountry: result.data[i].OtherCountry,
                    ResponseChannel: result.data[i].Response_Channel__c,
                    Nickname: result.data[i].Nickname__c,
                    SMS_Opt_In__c : result.data[i].SMS_Opt_In__c
                }
                tempArray.push(iteration);
            }
            this.contacts = tempArray;
            console.table(this.contacts);

        } else if(result.error){
            this.error = result.error;
        }
    }

    openContactModal(event){
        this.contactModal = true;
        this.recordEditId = event.target.dataset.role;
        this.fullName = event.target.dataset.name;
        this.contactRecordId = event.target.dataset.id;
        this.contactRole = event.target.dataset.type;
        this.mailingAddress.street = event.target.dataset.street;
        this.mailingAddress.city = event.target.dataset.city;
        this.mailingAddress.state = event.target.dataset.province;
        this.mailingAddress.postal = event.target.dataset.postal;
        this.mailingAddress.country = event.target.dataset.country;
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
    }

    mailingCreate(event){
        this.mailingAddress.street = event.detail.street;
        this.mailingAddress.city = event.detail.city;
        this.mailingAddress.postal = event.detail.postalCode;
        this.mailingAddress.state = event.detail.province;
        this.mailingAddress.country = event.detail.country;
    }

    closeContactModal(){
        this.contactModal = false;
        this.disabled = false;
    }

    contactTitleChange(event){
        this.contactTitle = event.target.value;
    }

    contactMobileChange(event){
        this.contactMobile = event.target.value;
    }

    contactEmailChange(event){
        this.contactEmail = event.target.value;
    }

    contactRoleChange(event) {
        // Check that the opportunity doesn't already have a Contact with the 'Signor' role
        this.contactRole = event.detail.value;
        const contactWithDupRole = this.contacts?.find(contact => contact.OpportunityContactRoleRole === this.contactRole)
        const uniqueRole = this.uniqueRoles.find(role => { return role === this.contactRole })
        const isSameContact = contactWithDupRole?.Id === this.contactRecordId
        if ((contactWithDupRole && !isSameContact) && uniqueRole) {
            this.disabled = true; 
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Warning',
                    message: 'There is already a contact with the role of ' + this.contactRole + '. \n\ Please ensure there is only one contact associated to this opportunity with the role of ' + this.contactRole + '.',
                    variant: 'warning',
                    mode: 'dismissable'
                })
            );
        } else {
            this.disabled = false;
        }
    }

    contactSSNChange(event){
        this.contactSSN = event.target.value;
    }

    contactDOBChange(event){
        this.contactDOB = event.target.value;
    }

    contactFirstNameChange(event){
        this.contactFirstName = event.target.value;
    }

    contactLastNameChange(event){
        this.contactLastName = event.target.value;
    }

    contactAddressChange(event){
        this.contactMailingAddress = event.target.value;
    }

    contactOwnershipChange(event){
        this.contactOwnerhsip = event.target.value;
    }

    contactHPChange(event){
        this.contactHomePhone = event.target.value;
    }

    saveForm() {
        // Contact Record Information
        const fields = {};
        fields[ID_FIELD.fieldApiName] = this.contactRecordId;
        fields[TITLE_FIELD.fieldApiName] = this.template.querySelector("[data-field='Title']").value;
        fields[EMAIL_FIELD.fieldApiName] = this.template.querySelector("[data-field='Email']").value;
        fields[MOBILE_FIELD.fieldApiName] = this.template.querySelector("[data-field='MobilePhone']").value;
        fields[SSN_FIELD.fieldApiName] = this.template.querySelector("[data-field='SSN']").value;
        fields[DOB_FIELD.fieldApiName] = this.template.querySelector("[data-field='DOB']").value;
        fields[FIRSTNAME_FIELD.fieldApiName] = this.template.querySelector("[data-field='FirstName']").value;
        fields[LASTNAME_FIELD.fieldApiName] = this.template.querySelector("[data-field='LastName']").value;
        fields[OWNERSHIP_FIELD.fieldApiName] = this.template.querySelector("[data-field='Ownership']").value;
        fields[HOME_PHONE_FIELD.fieldApiName] = this.template.querySelector("[data-field='HomePhone']").value;
        fields[STREET_FIELD.fieldApiName] = this.mailingAddress.street;
        fields[CITY_FIELD.fieldApiName] = this.mailingAddress.city;
        fields[ZIP_FIELD.fieldApiName] = this.mailingAddress.postal;
        fields[STATE_FIELD.fieldApiName] = this.mailingAddress.state;

        const recordInput = {fields};
        this.contactRole = this.template.querySelector("[data-field='Role']").value;

        // Update Contact Role
        // Logic: There is a OppContactRecId & its not undefined & there is a contactrole
        if(this.recordEditId && this.recordEditId !== undefined && this.recordEditId !== "undefined" && this.contactRole) {
            this.updateOppConRole(this.recordEditId, this.contactRole);
        // Create Contact Role
        // Logic: There is no OppContactRecId & its not undefined & there is a contactRole
        } else if ((!this.recordEditId || this.recordEditId === undefined || this.recordEditId === "undefined") && this.contactRole) {
            this.createOppConRole( this.contactRole, this.contactRecordId, this.recordId);
        // Delete Contact Role
        // Logic: There is an OppContactRecId & the ContactRole is Value is Blank (See picklist values above - None)
        } else if (this.recordEditId && this.contactRole === "") {
            this.deleteOppConRole(this.recordEditId, this.contactRole);
        }

        // Update Contact Record
        updateRecord(recordInput)
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Contact updated',
                        variant: 'success'
                    })
                );
                fireEvent(this.pageRef, 'AppCheck', this.myMessage);
                // Display fresh data in the form
                return refreshApex(this.wiredContactsResult);
            })
            .catch(error => {
                // Error Handling
                var fieldErrors = error.body.output.fieldErrors;
                if(error.body.output.errors != null){
                    // Loop & Display Errors
                    for (let index = 0; index < error.body.output.errors.length; index++) {
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
                    for(var prop in fieldErrors){
                        console.log(Object.keys(fieldErrors));
                        var val = Object.values(fieldErrors);
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
                
        // Close Modal and Reset Create button
        this.closeContactModal();
    }

    // Update Opp Contact Role Record
    updateOppConRole(rec, role, contact, opportunity){        
        // Call OppContactRoleUpdate Flow (Invoke Via Apex)
        opportunityContactRoleFlow({role : role, opportunityContactRoleId : rec, type : 'Update'})
        .then(result => {
            console.log('Update Result: ', result);
        })
        .catch(error => {
            console.error('Error Updating Record: ', error);
            this.error = error;
        })
    }

    createOppConRole(role, contact, opportunity){
        // Call OppContactRoleUpdate 
        opportunityContactRoleFlow({role : role, opportunityContactRoleId : "", contactId : contact, opportunityId : opportunity, type: 'Create'})
        .then(result => {
            console.log('Create Result: ', result);
        })
        .catch(error => {
            console.error('Error Updating Record: ', error);
            this.error = error;
        })
    }

    deleteOppConRole(rec, role) {
        // Call OppContactRoleUpdate 
        opportunityContactRoleFlow({role : role, opportunityContactRoleId : rec, type : 'Delete'})
        .then(result => {
            console.log('Create Result: ', result);
        })
        .catch(error => {
            console.error('Error Updating Record: ', error);
            this.error = error;
        })
    }

    // Contact Create
    addContact(){
        this.contactCreateModal = true;
        this.mailingAddress = {
            street: '',
            city: '',
            state: '',
            postal: '',
            country: ''
        };
    }

    closeCreateContactModal(){
        this.contactCreateModal = false;
        this.disabled = false;
    }

    handleFirstNameChange(event) {
        this.newContactFirstName = event.target.value;
    }

    handleTitleChange(event) {
        this.newContactTitle = event.target.value;
    }

    handleMobileChange(event) {
        this.newContactMobile = event.target.value;
    }

    handleLastNameChange(event) {
        this.newContactLastName = event.target.value;
    }

    handleEmailChange(event){
        this.newContactEmail = event.target.value;
    }

    handleSSNChange(event){
        this.newContactSSN = event.target.value;
    }

    handleDOBChange(event){
        this.newContactDOB = event.target.value;
    }

    handleHPChange(event){
        this.newContactHomePhone = event.target.value;
    }

    handleOPChange(event){
        this.newContactOwnership = event.target.value;
    }

    handleHStreetChange(event){
        this.newContactStreet = event.target.value;
    } 

    handleHCityChange(event){
        this.newContactCity = event.target.value;
    }

    handleHZipChange(event){
        this.newContactZip = event.target.value;
    }

    handleHStateChange(event){
        this.newContactState = event.target.value;
    } 

    createContact() {
        // Get Opp Contact Role Val if Applicable
        var contactCreateRole = this.template.querySelector("[data-field='RoleCreate']").value;
        if(contactCreateRole != "" && contactCreateRole != undefined) {
            if(this.contacts?.some(contact => contact.OpportunityContactRoleRole === contactCreateRole) &&
                this.uniqueRoles.find(role => { return role === contactCreateRole })) {
                //this.disabled = true; 
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Warning',
                        message: 'There is already a contact with the role of ' + contactCreateRole + '. \n\ Please ensure there is only one contact associated to this opportunity with the role of ' + contactCreateRole + '.',
                        variant: 'warning',
                        mode: 'dismissable'
                    })
                );
            }
            else {
                var newContactId;
                const fields = {};
                fields[TITLE_FIELD.fieldApiName] = this.newContactTitle;
                fields[EMAIL_FIELD.fieldApiName] = this.newContactEmail;
                fields[MOBILE_FIELD.fieldApiName] = this.newContactMobile;
                fields[FIRSTNAME_FIELD.fieldApiName] = this.newContactFirstName;
                fields[LASTNAME_FIELD.fieldApiName] = this.newContactLastName;
                fields[ACCOUNT_FIELD.fieldApiName] = this.accId;
                fields[SSN_FIELD.fieldApiName] = this.newContactSSN;
                fields[DOB_FIELD.fieldApiName] = this.newContactDOB;
                fields[HOME_PHONE_FIELD.fieldApiName] = this.newContactHomePhone;
                fields[OWNERSHIP_FIELD.fieldApiName] = this.newContactOwnership;
                fields[STREET_FIELD.fieldApiName] = this.mailingAddress.street;
                fields[CITY_FIELD.fieldApiName] = this.mailingAddress.city;
                fields[ZIP_FIELD.fieldApiName] = this.mailingAddress.postal;
                fields[STATE_FIELD.fieldApiName] = this.mailingAddress.state;

                const recordInput = { apiName: CONTACT_OBJECT.objectApiName, fields};

                createRecord(recordInput)
                    .then(contact => {
                        newContactId = contact.id;
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Success',
                                message: 'Contact Created',
                                variant: 'success',
                            }),
                        );
                        // Should an Opp Contact Role be created?
                        if(contactCreateRole != "" && contactCreateRole != undefined){
                            opportunityContactRoleFlow({role : contactCreateRole, opportunityContactRoleId : "", contactId : newContactId, opportunityId : this.recordId, type: 'Create'})
                            .then(result => {
                                fireEvent(this.pageRef, 'AppCheck', this.myMessage);
                                return refreshApex(this.wiredContactsResult);
                            })
                            .catch(error => {
                                console.error('Error Updating Record: ', error);
                                this.error = error;
                            })
                        } else {
                            fireEvent(this.pageRef, 'AppCheck', this.myMessage);
                            return refreshApex(this.wiredContactsResult);
                        }
                    })
                    .catch(error => {
                            // Error Handling
                            var errors = error.body.output.errors;
                            var fieldErrors = error.body.output.fieldErrors;
                            
                            if(error.body.output.errors != null){
                                // Loop & Display Errors
                                for (let index = 0; index < error.body.output.errors.length; index++) {
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
                                for(var prop in fieldErrors){
                                    var val = Object.values(fieldErrors);
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
                
                // Close Modal and Reset Create button
                this.closeCreateContactModal();
            }
        }
    };

    openContact(event){
        let contactId = event.target.dataset.id;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: contactId,
                actionName: 'view'
            }
        });
    }
}