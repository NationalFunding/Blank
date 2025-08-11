import {LightningElement, wire, api, track} from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';
import { refreshApex } from '@salesforce/apex';
import Id from '@salesforce/user/Id';

import getActivityAndNotes from '@salesforce/apex/viewAllActivityNotesOnAccountLEX.getActivityAndNotes';
import insertTask from '@salesforce/apex/InsertRecord.createTask';

const FIELDS = [
    'Opportunity.AccountId',
]

const actions = [
    { label: 'View', name: 'view' },
];

export default class OpportunityActivity extends NavigationMixin(LightningElement) {

    
    // Variables
    @api recordId;
    @api objectApiName;
    @track activityList;
    @track error;
    @track accountId;
    userId = Id;

    activityModal = false;
    activitySubject;
    activityDescription;

    activity;
    wiredActivityResult;

    activityColumns = [
        { 
            label: 'Subject', 
            fieldName: 'sActivitySubject', 
            type: 'text',
            // initialWidth: 250
        },
        { 
            label: 'Comments', 
            fieldName: 'sActivityComments',
            type: 'text',
            // initialWidth: 600            
        },
        { 
            label: 'Type', 
            fieldName: 'sActivityType', 
            type: 'text',
            initialWidth: 75
        },
        { 
            label: 'Activity Date', 
            fieldName: 'sActivityDate', 
            type: 'date-local', 
            initialWidth: 100
        },
        { 
            label: 'Assigned To', 
            fieldName: 'sActivityOwner', 
            type: 'text', 
            initialWidth: 175
        },
        {
            type: 'action',
            typeAttributes: { rowActions: actions },
        },
    ];


    @wire(getRecord, { recordId: '$recordId', fields: FIELDS})
    account({ error, data}) {
        if (data) {

            this.accountId = data.fields.AccountId.value;

            console.groupCollapsed('Activity Bar');
                console.log(data);
                console.log('Account Id: ', this.accountId);
            console.groupEnd('Activity Bar');
        
        } else if (error) {
            console.log(error);
        } else {
            console.log("Request #1 - Nothing was returned")
        }
    }

    @wire(getActivityAndNotes, {accountId: '$accountId'})
    activityResult(result){

        console.log('Activity Result:');
        console.log(result);

        this.wiredActivityResult = result;

        if(result.data){

            console.log('Activity Data Retrieved');
            this.activity = result.data;
            console.log(this.activity);
            console.log('Activities Data: ', result.data.Activities);
   
            this.activityList = result.data.Activities;

        } else if(result.error) {
            
            console.error('Activity Data Error');
            console.log(error);
            this.error = error;
        } else {

            console.log('Unknown Activity Data Result');
        
        }
    }

    refreshActivity(){
        console.log('Refreshing Activity Data');
        return refreshApex(this.wiredActivityResult);
    }

    addActivity(){
        this.activityModal = true;
    }

    closeActivity(){
        this.activityModal = false;
    }

    handleSubjectChange(event){
        this.activitySubject = event.target.value;
        console.log('Subject: ', this.activitySubject);
    }

    handleDescriptionChange(event){
        this.activityDescription = event.target.value;
        console.log('Description: ', this.activityDescription);
    }

    activityCreate(){
        console.log('Attempting to insert a new Task with the following Values:');
        console.log('Subject: ', this.activitySubject);
        console.log('Description: ', this.activityDescription);
        console.log('ParentId: ', this.recordId);
        console.log('OwnerId: ', this.userId);
        console.log('RecordType: ', this.objectApiName);

        insertTask({TSubject: this.activitySubject, TDescription: this.activityDescription, TParentId: this.recordId, TOwnerId: this.userId, RecordType: this.objectApiName})
        .then(result => {
            console.log('Insert Task Result');
            console.log(result);
            return refreshApex(this.wiredActivityResult);
        })
        .catch(error => {
            console.error('Error inserting Task');
            console.error(error); 
        })

        this.closeActivity();
    }
    
    handleRowAction( event ) {
        console.log('Action clicked');
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        switch ( actionName ) {
            case 'view':
                this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: row.sId,
                        actionName: 'view'
                    }
                });
                break;
            // case 'edit':
            //     this[NavigationMixin.Navigate]({
            //         type: 'standard__recordPage',
            //         attributes: {
            //             recordId: row.sId,
            //             objectApiName: 'Task',
            //             actionName: 'edit'
            //         }
            //     });
            //     break;
            default:
        }

    }

}