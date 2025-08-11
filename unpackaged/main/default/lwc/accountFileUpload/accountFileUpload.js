import { LightningElement, wire, api, track } from 'lwc';
import { getRecord, getFieldValue, updateRecord, createRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';

import getContactList from '@salesforce/apex/GetAccountContacts.getContactList';
import getOppList from '@salesforce/apex/GetOpportunities.openOpportunities';
import CreateContentDocumentLink from '@salesforce/apex/CreateContentDocumentLink.createLinkRecord';

import DOCUMENT_ID from '@salesforce/schema/ContentDocument.Id';
import DOCUMENT_TITLE from '@salesforce/schema/ContentDocument.Title';

export default class AccountFileUpload extends LightningElement {


    @api recordId; // Grab the Record Id
    @api objectApiName; // Grab the Objects API Name
    typeModal = false;
    contactModal = false;
    oppModal = false;

    contactList = [];
    oppList = [];
    
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
            { label: 'Other', value: 'Other'}
        ];
    };

    handleChange(e) {
        this.value = e.detail.value;
        console.log(this.value);
    };

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
    };

    saveForm(){

        this.errorMessage = null;
        
        console.log('Number of Values choosen: ', this.value.length);
    
        this.updateDocument();

    };

    updateDocument(){
    
        let name = "[" + this.value + "] " + this.documentName;

        const fields = {};
        fields[DOCUMENT_ID.fieldApiName] = this.documentId;
        fields[DOCUMENT_TITLE.fieldApiName] = name;

        const recordInput = {fields};

        console.log('Updating Document: ', recordInput);

        updateRecord(recordInput)
        .then(() => {
            console.log('Record Updated');
        })
        .catch(error => {
            console.error(error);
        });

        this.docType();
    };

    docType(){

        this.typeModal = false

        console.log('Value: ', this.value);

        if(this.value == 'Credit Application') {
    
            console.log('Type is CA');
            // Associate Contact & Open Opp

            getContactList({accountId: this.recordId})
            .then(result =>{
                console.log(result);

                var i;
                for (i = 0; i < result.length; i++){
                    let tempObj = { label: result[i].Name, value: result[i].Id};
                    this.contactList.push(tempObj);
                }
                console.log(this.contactList);

                this.contactModal = true;
            })
            .catch(error => {
                console.error(error);
            });
        
        } 
        else if (this.value == 'Bank Statement') {
        
            console.log('Type is BA');
            // Associate to Acc & Open Opp

            getOppList({recordId: this.recordId})
            .then(result => {
                console.log(result);

                var i;
                for (i = 0; i < result.length; i++){
                    let tempObj = { label: result[i].Name, value: result[i].Id};
                    this.oppList.push(tempObj);
                }
                console.log(this.oppList);

                if(result.length == 0){
                    console.log('No Open Opportunities');
                    return
                }

                this.oppModal = true;
            })
            .catch(error => {
                console.error(error);
            });

        }
        else if (this.value == 'Identification') {
        
            console.log('Type is Iden');
            // Associate Contact & Open Opp

            getContactList({accountId: this.recordId})
            .then(result =>{
                console.log(result);

                var i;
                for (i = 0; i < result.length; i++){
                    let tempObj = { label: result[i].Name, value: result[i].Id};
                    this.contactList.push(tempObj);
                }
                console.log(this.contactList);

                this.contactModal = true;
            })
            .catch(error => {
                console.error(error);
            })
        
    
        }
        else if (this.value == 'Other') {
        
            console.log('Type is Other')
            // Associate to Acc & Open Opp

            getOppList({recordId: this.recordId})
            .then(result => {
                console.log(result);

                var i;
                for (i = 0; i < result.length; i++){
                    let tempObj = { label: result[i].Name, value: result[i].Id};
                    this.oppList.push(tempObj);
                }
                console.log(this.oppList);

                if(result.length == 0){
                    console.log('No Open Opportunities');
                    return
                }

                this.oppModal = true;
            })
            .catch(error => {
                console.error(error);
            });
        
        }
        else if (this.value == 'Voided Check') {
        
            console.log('Type is Voided Check')
            // Associate to Acc & Open Opp

            getOppList({recordId: this.recordId})
            .then(result => {
                console.log(result);

                var i;
                for (i = 0; i < result.length; i++){
                    let tempObj = { label: result[i].Name, value: result[i].Id};
                    this.oppList.push(tempObj);
                }
                console.log(this.oppList);

                if(result.length == 0){
                    console.log('No Open Opportunities');
                    return
                }

                this.oppModal = true;
            })
            .catch(error => {
                console.error(error);
            });
        
        }
    };

    relateDocument(){

        let selectedRecord = this.value;
        let entityId = JSON.stringify(selectedRecord);

        console.log('Creating Share Record');
        console.log('Selected Id: ', selectedRecord);
        console.log('Entity Id: ', entityId);
        console.log('Doc Id: ', this.documentId);

        CreateContentDocumentLink({entityId: selectedRecord, documentId: this.documentId})
        .then(result => {
            console.log('Success');
            console.log(result);
        })
        .catch(error => {
            console.error('Error');
            console.error(error);
        })

        // Clear Values
        this.value = [];
        this.contactList = [];
        this.oppList = [];

        this.contactModal = false;
        this.oppModal = false;

    };

}