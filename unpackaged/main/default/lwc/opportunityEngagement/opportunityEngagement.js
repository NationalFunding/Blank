import { LightningElement, wire, api } from 'lwc';
import { getRecord, updateRecord} from 'lightning/uiRecordApi';
import OPPORTUNITY_STAGE from '@salesforce/schema/Opportunity.Sales_Status__c';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import NEXTACTIVITYDATE_FIELD from '@salesforce/schema/Opportunity.Next_Activity_Date__c';
import ENGAGEMENT_FIELD from '@salesforce/schema/Opportunity.Engagement_Status__c';
import REGARDING_FIELD from '@salesforce/schema/Opportunity.Regarding__c';
import ID_FIELD from '@salesforce/schema/Opportunity.Id';

export default class OpportunityEngagement extends LightningElement {

    
    @api recordId; // Grab the Record Id
    @api objectApiName; // Grab the Objects API Name
    currentStage; // Track changes to the value of currentStage
    error;
    opportunityRecord = {};

    steps = [
        { label: '0: Contact', value: 0, show: true, class: "" },
        { label: '1: Submit', value: 1, show: true, class: "" },
        { label: '2: Underwrite', value: 2, show: true, class: "" },
        { label: '3: Sell', value: 3, show: true, class: "" },
        { label: '4: Fund', value: 4, show: true, class: "" },
        { label: 'Closed', value: 5, show: true, class: "" },
        { label: 'Done', value: 6, show: false, class: "slds-hide"}
    ];

    @wire(getRecord, {recordId: '$recordId', fields: [OPPORTUNITY_STAGE] })
    AccountStatus({error, data}) {

        // reset values for steps:
        this.steps = [
            { label: '0: Contact', value: 0, show: true, class: "" },
            { label: '1: Submit', value: 1, show: true, class: "" },
            { label: '2: Underwrite', value: 2, show: true, class: "" },
            { label: '3: Sell', value: 3, show: true, class: "" },
            { label: '4: Fund', value: 4, show: true, class: "" },
            { label: 'Closed', value: 5, show: true, class: "" },
        ];

        if(data) {
            console.log('*******************************');
            console.log('Data for UtilityBar:');
            console.log(data);
            console.log('*******************************');
            console.log('Switch Result:');

            console.log(data.fields.Sales_Status__c.value);

            switch (data.fields.Sales_Status__c.value) {
                case '0: Contact':
                    this.currentStage = 0;
                    console.log('Current Stage: 0: Contact');
                    break;
                case '1: Submit':
                    this.currentStage = 1;
                    console.log('Current Stage: 1: Submit');
                    break;
                case '2: Underwrite':
                    this.currentStage = 2;
                    console.log('Current Stage: 2: Underwrite');
                    break;
                case '3: Sell':
                    this.currentStage = 3;
                    console.log('Current Stage: 3: Sell');
                    break;
                case '4: Fund':
                    this.currentStage = 4;
                    console.log('Current Stage: 4: Fund');
                    break;
                case 'Closed Won':
                    this.currentStage = 5;
                    this.steps[5].label = '5: Funded';
                    console.log('Current Stage: Closed Won');
                    break;
                case 'Closed Lost':
                    this.currentStage = 5;
                    this.steps[5].label = '5: Closed Lost';
                    console.log('Current Stage: Closed Lost');
                    break;
                default:
                    console.log('Current Stage: Default/Unknown');
                    break;
            }

        } else if (error) {

            console.log('*******************************');
            console.log('Error for UtilityBar:');
            console.log(error);
        }

        else {

            console.log('*******************************');
            console.log('No Account Status Data Found');
        }
    }

        // Engagement Section Functionality
        handleLoad(event) {
            if (!this.loadedForm) {
                let fields = Object.values(event.detail.records)[0].fields;
                const recordId = Object.keys(event.detail.records)[0];
                this.opportunityRecord = {
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
    
        handleFieldChange(e) {
            console.log('Event:');
            console.log(e);
            this.opportunityRecord[e.currentTarget.dataset.field] = e.target.value;
            // this.saveForm();
        }

        updateEngagement(e){
            console.log('Engagement Save');
            this.saveForm();
        }
    
        saveForm() {
            // if(this.validated())

            const fields = {};

            fields[ID_FIELD.fieldApiName] = this.recordId;
            fields[NEXTACTIVITYDATE_FIELD.fieldApiName] = this.template.querySelector("[data-field='Next_Activity_Date__c']").value;
            fields[ENGAGEMENT_FIELD.fieldApiName] = this.template.querySelector("[data-field='Engagement_Status__c']").value;
            fields[REGARDING_FIELD.fieldApiName] = this.template.querySelector("[data-field='Regarding__c']").value;

            const recordInput = {fields};

            console.log('Opportunity for save => ', recordInput);
            updateRecord(recordInput)
                .then(() => {
                    console.log('Updated Opportunity Engagement');
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Engagement Updated',
                            variant: 'success'
                        })
                    );
                })
                .catch((error) => {
                    console.error('Error Updating Opportunity Engagement');
                    console.error(error);
                    if (error.body.output.errors != null) {
                        // Loop & Display Errors
                        for (let index = 0; index < error.body.output.errors.length; index++) {
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: "Error on update",
                                    message: error.body.output.errors[index].errorCode + '- ' + error.body.output.errors[index].message,
                                    variant: "error"
                                })
                            );
                        }
                    }
                    if (error.body.output.fieldErrors != null) {
                        // loop & Display field Errors
                        for (var prop in fieldErrors) {
                            var val = Object.values(fieldErrors);
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'Error Updating record',
                                    message: val[0][0]["message"],
                                    variant: 'error'
                                })
                            );
                        }
                    } else {
                        // Display Generic Error
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Error Updating record',
                                message: error.body.message,
                                variant: 'error'
                            })
                        );
                    }
                });
        }

}