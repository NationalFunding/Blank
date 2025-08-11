import { LightningElement, wire, api, track } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { getRecord} from 'lightning/uiRecordApi';
import { registerListener, fireEvent } from 'c/pubsub';

import getOppContRoles from '@salesforce/apex/ApplicationCheck.getOCR';
import getAccountFields from '@salesforce/apex/ApplicationCheck.getAccountFields';
import getFilesAndAttachments from '@salesforce/apex/ApplicationCheck.getFileAndAttachmentNames';
import getContacts from '@salesforce/apex/ApplicationCheck.getContactInformation';
import getApplicationSettingsCMDT from '@salesforce/apex/ApplicationCheck.getApplicationSettingsCMDT';

const FIELDS = [
    'Opportunity.AccountId',
    'Opportunity.StageName',
    'Opportunity.Type'
];

export default class ApplicationPage extends LightningElement {
 
    @api recordId;
    @api objectApiName;

    // @track notation no longer needed for primative types per:
    // https://help.salesforce.com/s/articleView?id=release-notes.rn_lwc_track.htm&release=224&type=5
    // But is needed for complex objects per:
    // https://developer.salesforce.com/docs/platform/lwc/guide/reactivity-fields.html
    error; // originally was @track error;
    accountId; // originally was @track accountId;
    stage; // originally was @track stage;
    myMessage; // originally was @track myMessage;

    @wire(CurrentPageReference) pageRef;

    // Validation Checkbox Values
    CBSPVal = false; // There is a signor
    CBNDRVal = false; // No Duplicates
    CBCFVal = false; // Contact Data Populated
    CBFPVal = false; // App & BS Present
    CBAFVal = false; // Account Data Present

    // Contacts Presented on UI
    @track contacts = [];

    // Application Validations
    signor = false;
    noDuplicates = false;
    @track accountValidationErrors = [];
    @track contactValidationErrors = [];
    @track validationErrors = [];
    appPresent = false;
    bankStatementPresent = false;
    contactDataComplete = false;

    // Enable Submission Button
    enableApp(event){
        console.log('Dispatching Event to enable App Button...');
        fireEvent(this.pageRef, 'AppValid', this.myMessage);
    }

    // Disable Submission Button
    disableApp(event){
        console.log('Dispatching Event to Disable App Button...');
        fireEvent(this.pageRef, 'DisableApp', this.myMessage);
    }

    // Check if Application can be submitted
    connectedCallback() {
		registerListener('AppCheck', this.isAppComplete, this);
    }
        
    // Call Account Modal to open
    popAccountModal(){
        console.log('Calling Account LWC...');
        fireEvent(this.pageRef, 'accountEdit', this.myMessage);
    }

    // Check if there are duplicate roles
    hasDuplicates(arr){
        return new Set(arr).size !== arr.length;
    }
       
    @wire(getRecord, { recordId: '$recordId', fields: FIELDS})
    account({ error, data}) {
        if (data) {

            this.accountId = data.fields.AccountId.value;
            this.stage = data.fields.StageName.value;
            this.oppType = data.fields.Type.value;

            console.log('Application Data Results:');
            console.log(data);
            console.log('Data Fields:');
            console.log(data.fields);

            this.getContactData();

        } else if (error) {
            console.log(error);
            this.getContactData();
        } else {
            console.log("Nothing was returned");
            this.getContactData();
        }

        if(this.stage == 'Identified'){

            //Checking Application Completion
            this.isAppComplete();
        };
    }

    cmdt = null
    async grabCMDT() {
        return getApplicationSettingsCMDT().then((value) => {
            console.log('grabCMDT() - ', value)
            if (value) this.cmdt = value
        })
    }

    getContactData(){
        console.log('Retrieving Contact Data for Application:');

        getContacts({OpportunityId: this.recordId})
        .then(result => {
            console.log('Application Contact Result:');
            console.log(result);
            this.contacts = result;

        })
        .catch(error => {
            console.error('Application Contact Error:');
            console.error(error);
        })

    }

    validateAccountData(){

        // **************************************************************
        // Must have Account fields Populated
        // **************************************************************    

        return new Promise((resolve, reject) => {

            if(this.accountId === undefined){
                console.warn('Cannot check Account Application status, No Account Id Provided');
                reject(
                    new Error('Cannot check Account Application status, No Account Id Provided')
                )
            }
            else{
                getAccountFields({AccountId: this.accountId})
                .then(result => {
                    console.log('Application Account Data:');
                    console.log(result);
                    
                    let accountValidation = [
                        {"field": "Federal Tax Id", "value": result[0].Fed_Tax_ID__c,},
                        {"field": "Date Established","value": result[0].Date_Established__c},
                        {"field": "Annual Revenue","value": result[0].AnnualRevenue},
                        {"field": "Billing Street","value": result[0].BillingStreet},
                        {"field": "Billing City","value": result[0].BillingCity},
                        {"field": "Billing State","value": result[0].BillingState},
                        {"field": "Billing Postal","value": result[0].BillingPostalCode},
                        {"field": "Legal Name","value": result[0].Legal_Name__c},
                        {"field": "Phone","value": result[0].Phone}
                    ];
    
                    console.log('Account Validation Values:');
                    console.log(accountValidation);
    
                    for (let index = 0; index < accountValidation.length; index++) {
                        
                        const element = accountValidation[index];
                        
                        if(element.value === undefined){
    
                            console.warn(element.field + ' is undefined');
                            
                            // push element into validation error array
                            this.accountValidationErrors.push(element);
                            this.validationErrors.push(element);
                        }

                        // Additional Validation to check if Annual Revenue is $0
                        if(element.field === "Annual Revenue" && element.value === 0){
                            console.warn (element.field + ' is set to $0');

                            this.accountValidationErrors.push(element);
                            this.validationErrors.push(element);
                        }
    
                    }

                    
    
                    if(this.accountValidationErrors.length === 0){
                        console.log('Account Data Present');
                        this.CBAFVal = true;
                    }
    
                })
                .catch(error => {
                    console.error('Application Account Error:');
                    console.error(error);
                })
                .finally(() => resolve('Account Data Validated'));
            }
        });
    }

    validateRoles(){

        // **************************************************************
        // There must be at least 1 Opp Contact Role w/ Signor
        // There cannot be duplicate Roles of Signor -> Guarantor
        // **************************************************************

        return new Promise ((resolve, reject) => {
            console.log('Validating Signor and Role Requirements');
            getOppContRoles({opportunityId : this.recordId})
            .then(result => {
    
                console.log('OppContactRole Result:');
                console.log(result);
    
                // Loop Results
                let i;
                let roles = [];
    
                for (i = 0; i < result.length; i++){
    
                    console.log(result[i]);
                    roles.push(result[i].Role);
    
                    // Check if there is a Signor
                    if(result[i].Role == 'Signor'){
                        console.log('Signor Exists');
                        this.signor = true;
                        this.CBSPVal = true;
                    }
    
                }
                //Check if Signor is Present
                if(this.signor === false){
                    this.validationErrors.push({"field": "No Signor","value": "No Signor"});
                }

                // Check for Duplicate Roles
                if(this.hasDuplicates(roles)) {
                    console.warn('Duplicates Found!');
                    this.validationErrors.push({"field": "Duplicate Roles","value": "Duplicate Roles"});
    
                } else {
                    console.log('No Duplicates Found');
                    this.noDuplicates = true;
                    this.CBNDRVal = true;
                }
            })
            .catch(error => {
                console.error('OppContactRole Error:');
                console.error(error);
            }).finally(() => resolve('Roles Validated'));
        })

    }

    validateContacts(){

        // **************************************************************
        // Must have Contact fields Populated
        // **************************************************************

        return new Promise((resolve, reject) => {

            console.log('Validating Application Contact Requirements');

            getContacts({OpportunityId: this.recordId})
            .then(result => {
    
                console.log('Application Contact Result:');
                console.log(result);
    
                for (let index = 0; index < result.length; index++) {
                    
                    const element = result[index].Contact;
                    console.log(element);
    
                    let contactValidation = [
                        {"field": "First Name","value": element.FirstName},
                        {"field": "Last Name","value": element.LastName},
                        {"field": "Mobile Phone", "value": element.MobilePhone},
                        {"field": "Home Phone", "value": element.HomePhone},
                        {"field": "Email","value": element.Email},
                        {"field": "Birthdate","value": element.Birthdate},
                        {"field": "Social Security Number","value": element.SSN_Encrypted__c},
                        {"field": "Ownership Percentage","value": element.Ownership_Percentage__c},
                        {"field": "Street","value": element.OtherStreet},
                        {"field": "State","value": element.OtherState},
                        {"field": "Postal Code","value": element.OtherPostalCode},
                        {"field": "City","value": element.OtherCity}
                    ];
    
                    console.log('Contact Validation Values:');
                    console.log(contactValidation);
    
                    for (let index = 0; index < contactValidation.length; index++) {
                        
                        const element = contactValidation[index];
                                            
                        if(element.value === undefined){
    
                            console.warn(element.field + ' is undefined');
                            
                            // push element into validation error array
                            this.contactValidationErrors.push(element);
                            this.validationErrors.push(element);
                        }
    
                    }                
                }

                if(result.length === 0){
                    console.warn('No Contacts to Validate');
                } else if(this.contactValidationErrors.length === 0){
                    console.log('Contact Data Present');
                    this.contactDataComplete = true;
                    this.CBCFVal = true;
                }
    
                // if(this.contactValidationErrors.length === 0){
                //     console.log('Contact Data Present');
                //     this.contactDataComplete = true;
                //     this.CBCFVal = true;
                // }
    
            })
            .catch(error => {
                console.error('Application Contact Error:');
                console.error(error);
            }).finally(() => resolve('Contact Data Validated'));
        })
    }

    validateDocuments(){

        // **************************************************************
        // Must have 1 App Doc & 1 BankStatement Doc
        // **************************************************************

        return new Promise((resolve,reject) => {

            console.log('Validating Application & Bank Statement Requirements');

            this.appPresent = false;
            this.bankStatementPresent = false;
    
            // Get Files associated to the Opportunity 
            getFilesAndAttachments({ OpportunityId: this.recordId })
            .then(result => {
    
                console.log('Application Document Data:');
                console.log(result);

                for (let index = 0; index < result.length; index++) {
                    const element = result[index];
                    
                    if(element.includes('[Credit Application]')){
                        console.log('Application Present');
                        this.appPresent = true;
                    } else if (element.includes('[Bank Statement]') || element.includes('[Business Bank Statements]') || element.includes('Plaid_Bank_Data_Present')) {
                        console.log('Bank Statement Present');
                        this.bankStatementPresent = true;
                    }
                    
                    // Can break loop if both required files are already present -- not tested but might make it more effecient
                    // if(this.appPresent === true && this.bankStatementPresent === true){
                    //     break;
                    // }
                }
    
                // find signor ocr and use it to check  FCRA date
                const signorContact = this.contacts?.find((ocr) => ocr.Role === 'Signor')
                console.log('validateDocuments() signorContact 1- ', JSON.stringify(signorContact))
                const fcraDate = signorContact?.Contact?.FCRA_Accepted_Date_Time__c
                const today = new Date()
                const withinDays = this.cmdt?.FCRA_Date_Limit__c || 30 // default to 30 days if there's no settings
                const withinDaysInMS = withinDays * 24 * 60 * 60 * 1000; // days in MS
                const dateWithinCMDT = fcraDate ? Math.abs(today - new Date(fcraDate)) <= withinDaysInMS : false
                console.log('validateDocuments() signorContact 2- ', dateWithinCMDT, ' : ', this.cmdt?.FCRA_Date_Limit__c)

                // Check of all required documents are present
                if (this.bankStatementPresent && (this.appPresent || dateWithinCMDT)) {
                    console.log('All Documents Present');
                    this.CBFPVal = true;
                } else {
                    console.warn('Not all Documents that are required are present');
                    if (this.appPresent === false && !dateWithinCMDT) {
                        console.warn('Application not present');
                        this.validationErrors.push({ "field": "Application/Consent Missing", "value": "Application" }); 
                    }
                    if(this.bankStatementPresent === false){
                        console.warn('Bankstatements and/or Plaid documents not present');
                        this.validationErrors.push({"field": "Bank Statements Missing","value": "Bank Statements"});
                    }
                }
            })
            .catch(error => {
                console.error('Apllication Files Error:');
                console.error(error);
            }).finally(()=> resolve('Files Validated'));
        })
    }

    validationApplicationData(){

        console.log('Validating Application Requirements');

        const dependsPromise = async () => {
            await Promise.allSettled([
                this.validateContacts(),
                this.grabCMDT()
            ])

            console.log('inside depends - cmdt ', this.cmdt)
            await this.validateDocuments()
        }

        Promise.allSettled([
            this.validateAccountData(),
            this.validateRoles(),
            dependsPromise()
        ])
            .then(() => {
                this.updateApplicationResult()
            })
            .catch(console.error);
        
    }

    isAppComplete(){

        // Validate that the Application Requirements are complete in order to submit - Requirements are as follow:
        
        // Reset Status Checkbox Values
        this.CBSPVal = false; // Signor Present
        this.CBNDRVal = false; // No Duplicate Roles
        this.CBCFVal = false; // Contact Fields Populated
        this.CBFPVal = false; // Files Present
        this.CBAFVal = false; // Account Fields Populated

        // Reset Validation Error Values
        this.accountValidationErrors = [];
        this.contactValidationErrors = [];
        this.validationErrors = [];

        //Get updated values to Display to user
        this.getContactData();
        
        // Validate Application
        this.validationApplicationData();
    }

    updateApplicationResult(){

        console.log('Determining Application Status');
        console.groupCollapsed('Application Status');
            if(this.CBSPVal == false){console.log('There is no Signor')};
            if(this.CBNDRVal == false){console.log('There are Duplicate Roles')};
            if(this.CBCFVal == false){console.log('Contact Data is Not Populated')};
            if(this.CBFPVal == false){console.log('There is not an App & BankStatement')};
            if(this.CBAFVal == false){console.log('Account Data is Not Populated')};
        console.groupEnd('Application Status');

        if(
            this.CBSPVal == true &&  // There is a signor
            this.CBNDRVal == true && // No Duplicates
            this.CBCFVal == true && // Contact Data Populated
            this.CBFPVal == true && // App & BS Present
            this.CBAFVal == true // Account Data Present
        ) {

            console.log('APPLICATION COMPLETE');
            this.enableApp();

        } else {

            console.warn('APPLICATION NOT COMPLETE');
            this.disableApp();
        }

    }

}