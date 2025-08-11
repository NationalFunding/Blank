import { LightningElement, wire, api, track } from 'lwc';
import getActivityAndNotesAll from '@salesforce/apex/viewAllActivityNotesOnAccountLEX.getActivityAndNotesAll'
import { refreshApex } from '@salesforce/apex';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';
import Id from '@salesforce/user/Id';
import insertTask from '@salesforce/apex/InsertRecord.createTask';

const FIELDS = [
    'Opportunity.AccountId',
]

const actions = [
    { label: 'View', name: 'view' },
];

export default class OpportunityActivityAll extends NavigationMixin(LightningElement) {

    // Variables
    @api recordId;
    @api objectApiName;
    @track activityList;
    @track error;
    @track accountId;
    @track currentPage = 1;
    @track itemsPerPage = 25;

    pageSizeOptions = [25, 50, 75, 100]; 
    totalRecords;
    totalPages;
    userId = Id;
    activityModal = false;
    haveActivityRecords = false;
    activitySubject;
    activityDescription;
    activity;
    wiredActivityResult;

    activityColumns = [
        {
            label: 'Subject',
            fieldName: 'sActivitySubject',
            type: 'text',
        },
        {
            label: 'Comments',
            fieldName: 'sActivityComments',
            type: 'text',
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

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    account({ error, data }) {
        if (data) {

            this.accountId = data.fields.AccountId.value;

        } else if (error) {
            console.log(error);
        } else {
            console.log("Request #1 - Nothing was returned")
        }
    }

    @wire(getActivityAndNotesAll, { accountId: '$accountId', pageNumber: '$currentPage', pageSize: '$itemsPerPage' })
    activityTotalResult(result) {

        if (result.data) {

            this.haveActivityRecords = true;
            this.totalRecords = result.data.TotalActivities;
            this.totalPages = Math.ceil(this.totalRecords / this.itemsPerPage);
            this.activity = result.data;
            this.activityList = result.data.Activities;
            this.wiredActivityResult = result;
        } else if (result.error) {
            this.error = result.error;
        } else {
            console.log('Unknown Activity Data Result');
        }
    }


    refreshActivity() {
        return refreshApex(this.wiredActivityResult);
    }

    addActivity() {
        this.activityModal = true;
    }

    closeActivity() {
        this.activityModal = false;
    }

    handleSubjectChange(event) {
        this.activitySubject = event.target.value;
    }

    handleDescriptionChange(event) {
        this.activityDescription = event.target.value;
    }

    activityCreate() {

        insertTask({ TSubject: this.activitySubject, TDescription: this.activityDescription, TParentId: this.recordId, TOwnerId: this.userId, RecordType: this.objectApiName })
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
    get isFirstPage() {
        return this.currentPage === 1;
    }

    get isLastPage() {
        return this.currentPage === this.totalPages;
    }

    handlePrevious() {
        if (this.currentPage > 1) {
            this.currentPage -= 1;
            getActivityAndNotesAll({ accountId: '$recordId', pageNumber: '$currentPage', pageSize: '$itemsPerPage' });
        }
    }

    handleNext() {
        if (this.currentPage < this.totalPages) {
            this.currentPage += 1;
            getActivityAndNotesAll({ accountId: '$recordId', pageNumber: '$currentPage', pageSize: '$itemsPerPage' });
        }
    }

    handleRecordsPerPage(event) {
        this.itemsPerPage = event.target.value;
        this.currentPage = 1;
        getActivityAndNotesAll({ accountId: '$recordId', pageNumber: '$currentPage', pageSize: '$itemsPerPage' });
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
           
            default:
        }

    }
}