import { LightningElement, wire, api, track } from 'lwc';
import getOppList from '@salesforce/apex/GetOpportunities.lostOpportunities';
import { NavigationMixin } from 'lightning/navigation';

export default class AccountLostOpportunities extends NavigationMixin(LightningElement) {

    
    @api recordId;
    @api objectApiName;
    
    activeSections; //Default Open Accordion Sections 
    title = 'Lost Opportunities';
    opportunities;
    error;
    wiredOpportunitiesResult;

    @wire(getOppList, {recordId: '$recordId'})
    opportunitiesResult(result){

        console.log('Get Lost Opportunities Result:');
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
            this.title = count + " Lost Opportunities";
            console.log('Title: ', this.title);

            this.activeSections = opportunityRecords;

        } else if(result.error){

            console.log('Error:');
            this.error = result.error;

        }
    }

    navigateToRecordViewPage(event) {
        console.log('Clicked - Open Opp!');
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