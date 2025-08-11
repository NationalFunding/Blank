import { LightningElement, wire, api, track } from 'lwc';
import getOppList from '@salesforce/apex/GetOpportunities.wonOpportunities';
import { NavigationMixin } from 'lightning/navigation';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';

const FIELDS = [
    'Opportunity.AccountId',
]



export default class OpportunityWonOpportunities extends NavigationMixin(LightningElement) {

    
    @api recordId;
    @api objectApiName;
    
    activeSections; //Default Open Accordion Sections 
    title = 'Funded Opportunities';
    accountId;
    opportunities = [];
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

            var i;
            for(i=0; i< result.data.length; i++) {
                opportunityRecords.push(result.data[i].Id);
                count ++;

                let lenderAccount;

                if(result.data[i].Lender_Account__c == null){
                    lenderAccount = ""
                } else {
                    lenderAccount = result.data[i].Lender_Account__r.Name
                }

                let tempIt = {
                    Id: result.data[i].Id,
                    Name: result.data[i].Name,
                    Type: result.data[i].Type,
                    LenderAccount: lenderAccount,
                    FundedAmount: result.data[i].Funded_Amount__c,
                    FundedDate: result.data[i].Fund_Date__c
                }

                this.opportunities.push(tempIt);
            }
            
            console.log('opportunityRecords: ', opportunityRecords);
            console.log('Count: ', count);
            this.title = count + " Funded Opportunities";
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