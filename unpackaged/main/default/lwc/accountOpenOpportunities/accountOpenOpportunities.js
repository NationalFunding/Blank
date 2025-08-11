import {LightningElement,wire,api,track} from 'lwc';
import getOppList from '@salesforce/apex/GetOpportunities.openOpportunities';
import {NavigationMixin} from 'lightning/navigation';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import OPP_OBJECT from '@salesforce/schema/Opportunity';
import PROFILE_NAME_FIELD from '@salesforce/schema/User.Profile.Name';
import USER_ID from '@salesforce/user/Id';
import OppCreationFlow from '@salesforce/apex/InvokeOpportunityCreationFlow.start';
import { refreshApex } from '@salesforce/apex';
import { getRecord } from 'lightning/uiRecordApi';

export default class AccountOpenOpportunities extends NavigationMixin(LightningElement) {

    
    @api recordId;
    @api objectApiName;
    
    activeSections; //Default Open Accordion Sections 
    title = 'Open Opportunities';
    oppModal = false;
    createOpportunity = true;

    oppRecordTypes;
    defaultRecordTypeId;
    oppTypes = [
        { label: 'New', value: 'New'},
        { label: 'Renewal', value: 'Renewal'},
        { label: 'Concurrent', value: 'Concurrent'},
        { label: 'Renewal Concurrent', value: 'Renewal Concurrent'},
    ];
    rtValue = '';
    typeValue = '';
    amount = '';

    opportunities;
    error;
    wiredOpportunitiesResult;

    @wire(getRecord, {recordId: USER_ID, fields:[PROFILE_NAME_FIELD]})
    wireUser({data,error}){
        if(data){
            console.log('Get User Data:');
            console.log(data);
        }
        if(error){
            console.error('Error getting user info for Opp Creation');
            console.error(error);
        }
    }

    @wire(getObjectInfo, {objectApiName:OPP_OBJECT})
    getObjectData({data,error}){
        if(data){
            console.log('Opportunity Obj Info Result:');
            console.log(data);

            this.defaultRecordTypeId = data.defaultRecordTypeId;

            // Loop Record Types and Create a List            
            let recordTypeInfo = data.recordTypeInfos;
            console.log('Record Type Info: ', recordTypeInfo);
            let recordTypeValues = [];
            console.log('RecordTypes: ', recordTypeValues);

            for(var eachRecordType in recordTypeInfo){
                console.log('RT Name: ', recordTypeInfo[eachRecordType].name);
                if(recordTypeInfo.hasOwnProperty(eachRecordType) && recordTypeInfo[eachRecordType].name != 'Master')
                recordTypeValues.push({label: recordTypeInfo[eachRecordType].name, value: recordTypeInfo[eachRecordType].recordTypeId})
            }

            console.log('RecordTypeValues: ', recordTypeValues);
            this.oppRecordTypes = recordTypeValues;

            // Reorder Array
            var elementPos = this.oppRecordTypes.map(function(x) {return x.label; }).indexOf("Working Capital Oppty");
            this.moveInArray(this.oppRecordTypes,elementPos,0);

            var elementPos = this.oppRecordTypes.map(function(x) {return x.label; }).indexOf("Broker WC Oppty");
            this.moveInArray(this.oppRecordTypes,elementPos,1);

            var elementPos = this.oppRecordTypes.map(function(x) {return x.label; }).indexOf("Lease Oppty");
            this.moveInArray(this.oppRecordTypes,elementPos,2);

            var elementPos = this.oppRecordTypes.map(function(x) {return x.label; }).indexOf("Direct MLP");
            this.moveInArray(this.oppRecordTypes,elementPos,3);

        } else if (error){
            console.error('Error Retrieving Opp Info');
            console.error(error);
        }

        else {
            console.warn('Unknown result attempting to retrieve Opportunity Obj Info');
        }
    }

    @wire(getOppList, {recordId: '$recordId'})
    opportunitiesResult(result){

        console.log('Get Open Opportunities Result:');
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

    openModal(){
        this.oppModal = true;
    }

    closeModal(){
        this.oppModal = false;
    }

    handleTypeChange(event){
        this.typeValue = event.detail.value;
    }

    handleProductChange(event){
        this.rtValue = event.detail.value;
    }

    handleAmountChange(event){
        this.amount = event.detail.value;
    }

    createOpp(){
        console.log('Attempting to Create a new Opportunity with the Following Values:');
        console.log('Type: ', this.typeValue);
        console.log('RecordType: ', this.rtValue);
        console.log('Amount: ', this.amount);

        //Validate all data is populated
        if(!this.typeValue || !this.rtValue || !this.amount){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Invalid Input',
                    message: 'Please ensure all values are populated',
                    variant: 'warning',
                    mode: 'dismissable'
                }),
            );
            return;
        }

        OppCreationFlow({RecordTypeId: this.rtValue, Amount: this.amount, Type: this.typeValue, AccountId: this.recordId})
        .then(result => {

            console.log('New Opportunity Creation Result:');
            console.log(result);

            var resultOppId = result.NewOpportunityId;
            console.log(resultOppId);

            var resultErr = result.ErrResult;
            console.log(resultErr);

            if(resultOppId){
                console.log('Opportunity was created with the Id: ', resultOppId);
                
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success - New Opportunity created',
                        message: 'A new Opportunity was created for this Account - Id: ' + resultOppId,
                        variant: 'success',
                        mode: 'dismissable'
                    }),
                );
            } else if (resultErr){
                console.warn('Opportunity was not Created');
                console.warn('Returned Response: ' + resultErr);
                
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'New Opportunity was NOT created',
                        message: resultErr,
                        variant: 'warning',
                        mode: 'dismissable'
                    }),
                );
            } else {
                console.warn('Unknown Response from Flow');
            }
            
            return refreshApex(this.wiredOpportunitiesResult);
        })
        .catch(error => {

            console.error('Error Creating New Opportunity');
            console.error(error);

            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error Creating Opportunity',
                    message: error.body.message,
                    variant: 'error',
                }),
            );
            
        })

        this.closeModal();
    }

    // Helper Function
    moveInArray(arr, from, to){

        if(Object.prototype.toString.call(arr) !== '[object Array]') {
            throw new Error('Please provide a valid array');
        }

        // Delete the item from its current position
        var item = arr.splice(from, 1);

        // Move the item to its new position
        arr.splice(to,0,item[0]);

    }

}