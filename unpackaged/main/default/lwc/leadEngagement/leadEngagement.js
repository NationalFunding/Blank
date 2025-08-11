import { LightningElement, wire, api,  } from 'lwc';
import { getRecord, updateRecord} from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import LEAD_STATUS from '@salesforce/schema/Lead.Sales_Status__c';
import NEXTACTIVITYDATE_FIELD from '@salesforce/schema/Lead.Next_Activity_Date__c';
import ENGAGEMENT_FIELD from '@salesforce/schema/Lead.Engagement_Status__c';
import REGARDING_FIELD from '@salesforce/schema/Lead.Regarding__c';
import ID_FIELD from '@salesforce/schema/Lead.Id';

export default class LeadEngagement extends LightningElement {

    
    @api recordId; // Grab the Record Id
    @api objectApiName; // Grab the Objects API Name
    currentStage;
    error;
    leadRecord = {}; 

    steps = [
        { label: '0: Contact', value: 0 },
        { label: '1: Submit', value: 1 },
        { label: '2: Underwrite', value: 2 },
        { label: '3: Sell', value: 3 },
        { label: '4: Fund', value: 4 },
        { label: 'Closed', value: 5 },
    ];

    @wire(getRecord, {recordId: '$recordId', fields: [LEAD_STATUS] })
    leadUtility({error, data}) {

        if(data) {
            console.log('Lead Engagement Result:');
            console.log(data);

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
                case 'Closed':
                    this.currentStage = 5;
                    console.log('Current Stage: Closed');
                    break;
                default:
                    console.log('Current Stage: Default/Unknown');
                    break;
            }

        } else if (error) {
            console.error('Lead Engagement error:');
            console.error(error);
        }

        else {
            console.warn('No Data for Lead Engagement');
        }
    }

    // Engagement Section Functionality
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

    handleFieldChange(e) {
        this.leadRecord[e.currentTarget.dataset.field] = e.target.value;
        //this.saveForm();
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

        console.log('Lead for save => ', recordInput);

        updateRecord(recordInput)
            .then(() => {
                console.log('Updated Lead Engagement');
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Engagement Updated',
                        variant: 'success'
                    })
                );
            })
            .catch((error) => {
                console.error('Error Updating Lead Engagement');
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
  
    // Error Handling
    errorCallback(error, stack){
        this.error = error;
        this.stack = stack;
        console.log('*******************************');
        console.log('Utility Bar Component Error:');
        console.log(this.error);
        console.log(this.stack);
        console.log('Log THIS for ErrorCallback:');
        console.log(this);
    }

}