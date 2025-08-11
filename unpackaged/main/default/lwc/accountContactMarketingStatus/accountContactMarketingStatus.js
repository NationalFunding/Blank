import {LightningElement, wire, api, track} from 'lwc';
import getContactMarketingData from '@salesforce/apex/GetAccountContacts.getContactMarketingStatus'

export default class AccountContactMarketingStatus extends LightningElement {

    
    @api recordId;
    @api objectApiName;
    marketingData;
    error;

    wiredMarketingData;
    data=[];

    marketingColumns = [
        { 
            label: 'Contact',
            fieldName: 'contact', 
            type: 'text', 
        },
        {
            label: 'Campaign',
            fieldName: 'campaign',
            type: 'text',
        },
        {
            label: 'Account Number',
            fieldName: 'accountNumber',
            type: 'text',
        },
        {
            label: 'Status',
            fieldName: 'status',
            type: 'text',
        },
        {
            label: 'Responded Date',
            fieldName: 'respondedDate',
            type: 'text',
        }
    ];

    @wire(getContactMarketingData, {accountId: '$recordId'})
    activityResult(result){

        console.log('Marketing Data Result:');
        console.log(result);

        this.wiredMarketingData = result;

        if(result.data){

            console.log('Contact Marketing Data Retrieved');
            console.log(result.data);
            this.marketingData = result.data;
            console.log(this.marketingData);
                        
            // Loop Data and format for Table
            for(var i=0; i<result.data.length; i++){
                var iteration = {
                    contact: result.data[i].Contact.Name,
                    campaign: result.data[i].Campaign.Name,
                    status: result.data[i].Status,
                    respondedDate: result.data[i].FirstRespondedDate,
                    accountNumber: result.data[i].Account_Number__c
                }
                console.log('Iteration ', i , ":");
                console.log(iteration);

                this.data.push(iteration);
            }

            console.log('Data Result');
            console.log(this.data);

        } else if(result.error) {
            
            console.error('Marketing Data Error');
            console.log(result.error);
            this.error = result.error;

        } else {

            console.log('Unknown Marketing Data Result');
        
        }
    
    }

}