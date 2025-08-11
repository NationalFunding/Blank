import { LightningElement, wire, api, track } from 'lwc';
import getActivityAndNotes from '@salesforce/apex/viewAllActivityNotesOnAccountLEX.getActivityAndNotes'
import getActivityAndNotesAll from '@salesforce/apex/viewAllActivityNotesOnAccountLEX.getActivityAndNotesAll'
import { refreshApex } from '@salesforce/apex';
import { NavigationMixin } from 'lightning/navigation';
import Id from '@salesforce/user/Id';
import insertTask from '@salesforce/apex/InsertRecord.createTask';

const actions = [
    { label: 'View', name: 'view' },
];

export default class AccountActivityAll extends NavigationMixin(LightningElement) {

    // Variables
    @api recordId;
    @api objectApiName;
    @track activityList;
    @track error;
    @track currentPage = 1;
    @track itemsPerPage = 25;

    pageSizeOptions = [25, 50, 75, 100]; //Page size options
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
    @wire(getActivityAndNotesAll, { accountId: '$recordId', pageNumber: '$currentPage', pageSize: '$itemsPerPage' })
    activityTotalResult(result) {

        if (result.data) {

            this.haveActivityRecords = true;
            this.totalRecords = result.data.TotalActivities;
            this.totalPages = Math.ceil(this.totalRecords / this.itemsPerPage);
            

            this.activity = result.data;
            

            this.activityList = result.data.Activities;
            this.wiredActivityResult = result;

        } else if (result.error) {

            console.error('Activity Data total Error');
            console.log(result.error);
            this.error = result.error;
        } else {

            console.log('Unknown Activity Data Result');

        }
    }

    refreshActivity() {
        console.log('Refreshing Activity Data');
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
        console.log('Subject: ', this.activitySubject);
    }

    handleDescriptionChange(event) {
        this.activityDescription = event.target.value;
        console.log('Description: ', this.activityDescription);
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

        const actionName = event.detail.action.name;
        const row = event.detail.row;
        
        switch ( actionName ) {
            case 'view':
                this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: row.sId,
                        objectApiName: 'Task',
                        actionName: 'view'
                    }
                });
                break;
       
            default:
        }

    }



}