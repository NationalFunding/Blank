import { LightningElement, wire, api, track } from 'lwc';
import getOppList from '@salesforce/apex/GetOpportunities.openOpportunities';
import { NavigationMixin } from 'lightning/navigation';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';

const FIELDS = [
    'Opportunity.AccountId',
]

export default class OpportunityOpenOpportunities extends NavigationMixin(LightningElement) {

    
    @api recordId;
    @api objectApiName;
    
    activeSections; //Default Open Accordion Sections 
    title = 'Open Opportunities';
    accountId;
    opportunities;
    error;
    wiredOpportunitiesResult;

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS})
    account({ error, data}) {
        if (data) {

            this.accountId = data.fields.AccountId.value;
            console.log('Account Id: ', this.accountId);

        } else if (error) {
            console.log(error);
        } else {
            console.log("Request #1 - Nothing was returned")
        }
    }

    @wire(getOppList, {recordId: '$accountId'})
    opportunitiesResult(result){

        console.log('Get Funded Opportunities Result:');
        console.log(result);
        console.log(result.data);

        var opportunityRecords = [];
        var count = 0;

        this.wiredOpportunitiesResult = result;

        if(result.data){

            console.log('Data:');
            console.log(result.data);
            this.opportunities = result.data;

            var i;
            for(i=0; i< result.data.length; i++) {
                console.log('Id: ', result.data[i].Id)
                opportunityRecords.push(result.data[i].Id);
                count ++;
            }
            
            console.log('opportunityRecords: ', opportunityRecords);
            console.log('Count: ', count);
            this.title = count + " Open Opportunities";
            console.log('Title: ', this.title);

            this.activeSections = opportunityRecords;

        } else if(result.error){

            console.log('Error:');
            this.error = result.error;

        }
    }

    // Open Opp Subtab
    navigateToRecord(event) {
        console.log('Clicked! - Open Opp');
        console.log(event.target.dataset.id);
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: event.target.dataset.id,
                objectApiName: 'Opportunity',
                actionName: 'view'
            },
        });
    }
}