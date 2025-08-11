import { LightningElement, wire, api, track } from 'lwc';
import { getRecord, getFieldValue, updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import DOCUMENT_ID from '@salesforce/schema/ContentDocument.Id';
import DOCUMENT_TITLE from '@salesforce/schema/ContentDocument.Title';
import SIGNED_AGREEMENT from '@salesforce/schema/Lead.Signed_Agreement__c';
import LEAD_ID_FIELD from '@salesforce/schema/Lead.Id';

export default class LeadFileUpload extends NavigationMixin(LightningElement) {

    @api recordId; // Grab the Record Id
    @api objectApiName; // Grab the Objects API Name
    typeModal = false;

    errorMessage;

    value = [];

    documentName;
    documentId;

    get options() {
        return [
            { label: 'Credit Application', value: 'Credit Application' },
            { label: 'Bank Statement', value: 'Bank Statement' },
            { label: 'Identification', value: 'Identification'},
            { label: 'Voided Check', value: 'Voided Check'},
            { label: 'Other', value: 'Other'},
        ];
    }

    handleChange(e) {
        this.value = e.detail.value;
        console.log(this.value);
    }


    get acceptedFormats() {
        return ['.pdf', '.png','.jpg','.jpeg'];
    };

    handleUploadFinished(event) {

        console.log('Event: ', event.detail.files[0]);

        this.documentName = event.detail.files[0].name;
        this.documentId = event.detail.files[0].documentId;

        console.log('Document Id: ', this.documentId);
        console.log('Document Name: ', this.documentName);

        this.typeModal = true;
        console.log('Done');
    }

    saveForm(){

        this.errorMessage = null;

        console.log(this.value.length);
        console.log('Document Type: ', this.value);


            let name = "[" + this.value + "] " + this.documentName;

            const fields = {};
            fields[DOCUMENT_ID.fieldApiName] = this.documentId;
            fields[DOCUMENT_TITLE.fieldApiName] = name;
    
            const recordInput = {fields};
    
            console.log('Updating Document: ', recordInput);
    
            updateRecord(recordInput)
            .then(() => {
                console.log('Record Updated');
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Document Uploaded',
                        variant: 'success'
                    })
                );
                if(this.value == 'Credit Application'){
                    this.updateLead();
                } else {
                    this.typeModal = false;
                }
            })
            .catch(error => {
                console.error(error);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'There was an error uploading the Document',
                        variant: 'error'
                    })
                );
                this.typeModal = false;
            });
   
    }

    updateLead(){
        console.log('Document Type == Credit Application');

        const fields = {};
        fields[LEAD_ID_FIELD.fieldApiName] = this.recordId;
        fields[SIGNED_AGREEMENT.fieldApiName] = true;

        const recordInput = {fields};

        console.log('Update Lead: ', recordInput);

        updateRecord(recordInput)
        .then(() =>{
            console.log('Lead Record Update - Success');
            this.typeModal = false;
        }).catch(error => {
            console.error('Error Updating Lead Record');
            console.error(error);
            this.typeModal = false;
        })
    }
}