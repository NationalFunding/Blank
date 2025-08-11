import { LightningElement, wire, api, track } from 'lwc';
import { getRecord, getFieldValue, updateRecord } from 'lightning/uiRecordApi';
// import leadConvert from '@salesforce/apex/AutoConvertLeads.convertLead';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { CurrentPageReference } from 'lightning/navigation';

// Related Lead Fields
const FIELDS = [
    'Lead.FirstName',
    'Lead.LastName',
    'Lead.Title',
    'Lead.Email',
    'Lead.MobilePhone',
    'Lead.Salutation',
    'Lead.Birth_Date__c',
    'Lead.SSN_Encrypted__c',
    'Lead.Ownership_Percentage__c',
    'Lead.City__c',
    'Lead.State__c',
    'Lead.Home_Address__c',
    'Lead.Zip_Code__c',
    'Lead.Response_Channel__c',
    'Lead.NickName__c',
    // 'Lead.DLP_Status__c',
]

export default class LeadContact extends NavigationMixin(LightningElement) {

    
    @api recordId; // Grab the Record Id
    @api objectApiName; // Grab the Objects API Name
    @track openmodel = false; // Default Modal to Closed

    homeAddress = {
        street: '',
        city: '',
        state: '',
        postal: '',
        country: ''
    }

    @wire(CurrentPageReference) pageRef; //PubSub
    
    // Query Lead Data
    @wire(getRecord, {recordId: '$recordId', fields: FIELDS})
    leadContact;
   
    // Lead First Name
    get firstName(){
        return getFieldValue(this.leadContact.data, 'Lead.FirstName');
    }

    // Lead Last Name
    get lastName(){
        return getFieldValue(this.leadContact.data, 'Lead.LastName');
    }

    // Lead Title
    get title(){
        return getFieldValue(this.leadContact.data, 'Lead.Title');
    }

    // Lead Email
    get email(){
        return getFieldValue(this.leadContact.data, 'Lead.Email');
    }

    // Lead Mobile Phone
    get mobilePhone(){
        return getFieldValue(this.leadContact.data, 'Lead.MobilePhone');
    }

    get ownershipPercentage(){
        return getFieldValue(this.leadContact.data, 'Lead.Ownership_Percentage__c');
    }

    get homeStreet(){
        return getFieldValue(this.leadContact.data, 'Lead.Home_Address__c');
    }

    get homeCity(){
        return getFieldValue(this.leadContact.data, 'Lead.City__c');
    }

    get homeState(){
        return getFieldValue(this.leadContact.data, 'Lead.State__c');
    }

    get homeZip(){
        return getFieldValue(this.leadContact.data, 'Lead.Zip_Code__c');
    }

    get responseChannel(){
        return getFieldValue(this.leadContact.data, 'Lead.Response_Channel__c');
    }

    get nickName(){
        return getFieldValue(this.leadContact.data, 'Lead.NickName__c');
    }

    // get dlpStatus(){
    //     return getFieldValue(this.leadContact.data, 'Lead.DLP_Status__c');
    // }

    // Lead Full
    get fullName() {
        if(this.firstName) {
            return `${this.firstName} ${this.lastName}`
        } 
        return `${this.lastName}`
    }

    // handleChange(event){
    //     this.companyAddress.street = event.detail.street;
    //     this.companyAddress.city = event.detail.city;
    //     this.companyAddress.postal = event.detail.postalCode;
    //     this.companyAddress.state = event.detail.province;
    //     this.companyAddress.country = event.detail.country;
    //     console.log(this.companyAddress);
    // }

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

    // Lead Convert
    convert(){

        // Log Convert Information
        console.log('Convert Button Clicked');
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
        leadConvert({leadId : this.recordId, createOpportunity: false})
            .then(result => {

                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'One Moment: Redirecting',
                        message: 'Redirecting to Lead to add new Contact',
                        variant: 'info',
                        mode: 'dismissable'
                    })
                );

                // Log Results
                console.log('Convert Result:');
                console.log(result);

                // Define New Account Id
                let accountId = result.accountId;
                console.log('AccountId: ', accountId);

                // Communicates with Aura component that houses the LWC
                // Aura Components are able to open/close SF Console Tabs
                const value = accountId;
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
                        title: 'Error Updating record',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            })

    }
  
    // Open Modal
    openmodal() {
        this.openmodel = true
        console.log(1);
        // this.template.querySelector(`[data-id="contact-edit"]`).focus();
        console.log(2);
    }

    // Close Modal
    closeModal() {
        this.openmodel = false
    }
 
    // Update Fields on Form
    handleLoad(event) {
        if (!this.loadedForm) {
            let fields = Object.values(event.detail.records)[0].fields;
            const recordId = Object.keys(event.detail.records)[0];
            this.leadRecord = {
                Id: recordId,
                ...Object.keys(fields)
                    .filter((field) => !!this.template.querySelector(`[data-field=${field}]`))
                    .reduce((total, field) => {
                        total[field] = fields[field].value;
                        return total;
                    }, {})
            };
            this.loadedForm = true;
        }
    }

    // Handle Field Change
    handleFieldChange(e) {
        this.leadRecord[e.currentTarget.dataset.field] = e.target.value;
    }

    // Save/Update Form
    saveForm() {
        console.log('Contact for save => ', JSON.stringify(this.leadRecord));
        updateRecord({ fields: this.leadRecord })
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Lead updated',
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
        this.closeModal();
    }
  
}