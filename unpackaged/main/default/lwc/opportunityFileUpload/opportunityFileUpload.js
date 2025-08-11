import { LightningElement, wire, api, track } from 'lwc';
import { getRecord, getFieldValue, updateRecord, createRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';

import getContactList from '@salesforce/apex/GetAccountContacts.getContactList';
import getOppList from '@salesforce/apex/GetOpportunities.openOpportunities';
import CreateContentDocumentLink from '@salesforce/apex/CreateContentDocumentLink.createLinkRecord';
import { refreshApex } from '@salesforce/apex';

import DOCUMENT_ID from '@salesforce/schema/ContentDocument.Id';
import DOCUMENT_TITLE from '@salesforce/schema/ContentDocument.Title';

import relatableRecords from '@salesforce/apex/RelatedContentDocumentLinkRecords.getRelatedFiles';
import relatedExistingRecords from '@salesforce/apex/RelatedContentDocumentLinkRecords.shareFiles';
import filesQuery from '@salesforce/apex/RelatedContentDocumentLinkRecords.getOppfiles';

import { CurrentPageReference } from 'lightning/navigation';
import { registerListener, unregisterAllListeners, fireEvent } from 'c/pubsub';

const FIELDS = [
    'Opportunity.AccountId',
]


export default class OpportunityFileUpload extends NavigationMixin(LightningElement) {


    @api recordId; // Grab the Record Id
    @api objectApiName; // Grab the Objects API Name
    @track typeModal = false;
    @track contactModal = false;
    @track  shareFilesModal = false;

    @track myMessage;
    @wire(CurrentPageReference) pageRef;

    accountId;

    contactList = [];
    value = [];
    fileList = [];
    flvalue = [];
    filesData = [];
    // wiredDataResult;

    errorMessage;

    documentName;
    documentId;

    @wire(getRecord, {recordId: '$recordId', fields: FIELDS})
    opportunity(result) {

        console.log('Get Record Result');
        console.log(result);
        this.fileList = [];
        // this.wiredDataResult = result;

        if(result.data){
            this.accountId = result.data.fields.AccountId.value;
            console.log('Acc Id: ', this.accountId);

            this.getcurrentFiles();
        }
        else if(result.error){
            console.error('Error Receiving Doc Data');
            console.error(error);
        }
        else{
            console.log('Unknown result');
        }
    }
    

    // get accountId(){
    //     return getFieldValue(this.opportunity.data, 'Opportunity.AccountId');
    // }

    get options() {
        return [
            { label: 'Credit Application', value: 'Credit Application' },
            { label: 'Bank Statement', value: 'Bank Statement' },
            { label: 'Identification', value: 'Identification'},
            { label: 'Voided Check', value: 'Voided Check'},
            { label: 'Other', value: 'Other'}
        ];
    };

    // get selectedValues() {
    //     return this.value.join(',');
    // };

    handleChange(e) {
        this.value = e.detail.value;
        console.log(this.value);
    };

    flhandleChange(e){
        this.flvalue = e.detail.value;
        console.log(this.flvalue);
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
            console.log('Dispatching Event to Application');
            fireEvent(this.pageRef, 'AppCheck', this.myMessage);
            console.log('Dispatched Event to Application');
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

            getContactList({accountId: this.accountId})
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
            this.value = [];
            this.value.push(this.accountId);
            this.relateDocument();


        }
        else if (this.value == 'Identification') {
        
            console.log('Type is Iden');
            // Associate Contact & Open Opp

            getContactList({accountId: this.accountId})
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

                this.value = [];
                this.value.push(this.accountId);
                this.relateDocument();
        
        }
        else if (this.value == 'Voided Check') {
        
            console.log('Type is VC');
            // Associate to Acc & Open Opp
            this.value = [];
            this.value.push(this.accountId);
            this.relateDocument();

        }
    };

    relateDocument(){

        let selectedRecord = this.value[0];
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
        });

        // Clear Values
        this.value = [];
        this.contactList = [];

        this.contactModal = false;

    };

    getcurrentFiles(){
        filesQuery({recordId: this.recordId})
        .then(result => {

            console.log('Current Files Related to Opportunity');
            console.log(result);

            console.log('Data');
            console.log(result.data);
    
            this.files = result.data;
            console.table(this.files);
    
            let i;
            let iteration;
            let tempArray = [];
        
            for ( i=0; i < result.length; i ++){
    
                iteration = {
                    Id: result[i].Id,
                    ContentDocumentId: result[i].ContentDocumentId,
                    Title: result[i].ContentDocument.Title,
                    DocLinkId: result[i].Id,
                    FileType: result[i].ContentDocument.FileType,
                    CreatedDate: new Date(result[i].ContentDocument.CreatedDate).toDateString(),
                }
    
                console.log(iteration);
                tempArray.push(iteration);
    
            }
                
            this.filesData = tempArray;
                
            console.log('Result of Current Files Related to Opportunity');
            console.log(this.filesData);

            this.shareFiles();
    
        })
    }

    removeDuplicates(originalArray, prop) {
        var newArray = [];
        var lookupObject  = {};
   
        for(var i in originalArray) {
           lookupObject[originalArray[i][prop]] = originalArray[i];
        }
   
        for(i in lookupObject) {
            newArray.push(lookupObject[i]);
        }
         return newArray;
    }

    shareFiles(){
        relatableRecords({AccountId: this.accountId, OpportunityId: this.recordId})
        .then(result => {

            console.log('Shareable Files Result');
            console.log(result);

            var tempArr = [];
            this.fileList = [];

            for(var i=0; i<result.length; i++){

                console.log('Iteration of Shareable File: ', i );
                console.log(result[i]);
                let match = false;

                for(var j=0; j<this.filesData.length; j++){
                    console.log(this.filesData[i]);
                    console.log('Relatable File: ', result[i].ContentDocumentId);
                    console.log('ContentDocumentId: ', this.filesData[j].ContentDocumentId);
                    if(result[i].ContentDocumentId == this.filesData[j].ContentDocumentId) {
                        match = true;
                        console.log('There is a match! ',result[i].ContentDocumentId, ' = ',  this.filesData[j].ContentDocumentId);
                    }
                }
                if(match == false){
                    let iteration = { label: result[i].ContentDocument.Title, value: result[i].ContentDocumentId }
                    tempArr.push(iteration);
                }
            }

            console.log('List of shareable Files: ');
            console.log(tempArr);

            this.fileList = this.removeDuplicates(tempArr, "value");
            console.log(this.fileList);

            return
        })

        .catch(error => {
            console.error('Error Retreiving Files');
            console.error(error);
        })
    };

    openShareFilesModal(){
        this.shareFilesModal = true;
    }

    closeShareFilesModal(){
        this.shareFilesModal = false;
    };

    shareDocs(){
        console.log('Sharing Existing Records with: ', this.recordId);
        console.log('Records being Shared: ');
        console.log(this.flvalue);

        relatedExistingRecords({cdl: this.flvalue, OpportunityId: this.recordId})
        .then(result => {
            console.log('Result of Sharing Records:');
            console.log(result);
            this.closeShareFilesModal();

            console.log('Getting Updated Files List');
            this.getcurrentFiles();
            // return refreshApex(this.wiredDataResult);
        })
        .catch(error => {
            console.error('Error Sharing Records');
            console.error(error);
            console.error(error.body.fieldErrors.LinkedEntityId);

            if(error.body.fieldErrors.LinkedEntityId != null){
                var i;
                for(i =0; i<error.body.fieldErrors.LinkedEntityId.length; i++){
                    console.log('error.body.fieldErrors.LinkedEntityId[i].message');
                    if(error.body.fieldErrors.LinkedEntityId[i].message.includes('is already linked')){
                        console.log('Already Linked');
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Error Sharing one or more of the Files',
                                message: 'One of the Files you are sharing are already Present',
                                variant: 'error',
                                mode: 'dismissable'
                            }),
                        );
                    }
                    
                }
            };
            this.closeShareFilesModal();
            console.log('Getting Updated Files List');
            this.getcurrentFiles();
            // return refreshApex(this.wiredDataResult);
        })
    }

}