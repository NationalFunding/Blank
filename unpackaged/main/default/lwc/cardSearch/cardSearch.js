import { LightningElement, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import userIdImport from '@salesforce/user/Id';

// import accountSearch from '@salesforce/apex/CardSearch.retrieveAccounts';
import leadSearch from '@salesforce/apex/CardSearch.retrieveLeads';
import contactSearch from '@salesforce/apex/CardSearch.retrieveContacts';
import leadCMSearch2 from '@salesforce/apex/CardSearchCampaignMembers.retrieveLeadCMs';
import contactCMSearch2 from '@salesforce/apex/CardSearchCampaignMembers.retrieveContactCMs';
// import activationFlow from '@salesforce/apex/InvokeActivationFlow.start';

import leadActivation from '@salesforce/apex/cardSearchActivation.activateLead';
import contactActivation from '@salesforce/apex/cardSearchActivation.activateContact';


export default class CardSearch extends NavigationMixin(LightningElement) {

    accountData;
    leadData;
    contactData;
    errorMsg = '';
    userId = userIdImport;
    accountCount;
    leadCount;
    contactCount;
    searchRan = false;
    cardNumberFormating = '';
    
    isLoading = false;
    loadingSearchOne = false;
    loadingSearchTwo = false;

    strSearchTerm = '';
    cardSearchTerm = '';

    // @wire(CurrentPageReference) pageRef; //PubSub

    // ACCOUNT COLUMNS
    @track accountColumns = [
        {
            type:  'button-icon',
            initialWidth: 30,
            typeAttributes: 
            {
              iconName: 'utility:adduser',
              name: 'ActivateAccount', 
              disabled: false, 
              value: 'Activate',
              iconPosition: 'left',
              variant: 'bare',
              alternativeText: 'Activate'
            }
        },
        {
            label: 'Name',
            fieldName: 'Name',
            type: 'text'
        },{
            label: 'Phone',
            fieldName: 'Phone',
            type: 'text',
        }, {
            label: 'Owner',
            fieldName: 'Owner',
            type: 'text'
        },
    ];

    // LEAD COLUMNS
    @track leadColumns = [
        {
            type:  'button-icon',
            initialWidth: 30,
            typeAttributes: 
            {
              iconName: 'utility:adduser',
              name: 'ActivateLead', 
              disabled: false, 
              value: 'Activate',
              iconPosition: 'left',
              variant: 'bare',
              alternativeText: 'Activate'
            }
        },
        {
            label: 'Name',
            fieldName: 'Name',
            type: 'text'
        },
        {
            label: 'Company',
            fieldName: 'Company',
            type: 'text'
        },
        {
            label: 'Phone',
            fieldName: 'Phone',
            type: 'text'
        },
        {
            label: 'Owner',
            fieldName: 'Owner',
            type: 'text'
        },
    ];
    
    // CONTACT COLUMS
    @track contactColumns = [
        {
            type:  'button-icon',
            initialWidth: 30,
            typeAttributes: 
            {
              iconName: 'utility:adduser',
              name: 'ActivateContact', 
              disabled: false, 
              value: 'Activate',
              iconPosition: 'left',
              variant: 'bare',
              alternativeText: 'Activate'
            }
        },
        {
            label: 'Name',
            fieldName: 'Name',
            type: 'text'
        },
        {
            label: 'Account',
            fieldName: 'Account',
            type: 'text'
        },
        {
            label: 'Phone',
            fieldName: 'Phone',
            type: 'text'
        },
        {
            label: 'Owner',
            fieldName: 'Owner',
            type: 'text'
        }
    ];

    // Clear Search Values
    clearSearchValues(){

        console.log('Clear Search Values');

        // this.template.querySelector("lightning-input[data-id=ANS]").value = "";
        this.template.querySelector('input').value="";
        this.template.querySelector("lightning-input[data-id=WCS]").value = "";

        console.log('Clear Result Values');

        this.accountData = undefined;
        this.leadData = undefined;
        this.contactData = undefined;
        this.searchRan = false;

        this.errorMsg = undefined;
    };

    // Activate Record
    activateRecord(recId, object, campaignMemberId, activationDate){

        console.groupCollapsed('Activate Record');
            console.log('****************');
            console.log('Activate Record was Called!');
            console.log('Record Id: ', recId);
            console.log('Object: ', object);
            console.log('User Id: ', this.userId);
            console.log('Campaign Member Id: ', campaignMemberId);
            console.log('Activation Date: ', activationDate);
        console.groupEnd('Activate Record');

        this.dispatchEvent(
            new ShowToastEvent({
                title: 'One Moment Please - Attempting to Activate Record',
                message: 'This may take up to 10 Seconds',
                variant: 'info',
                mode: 'dismissible'
            })
        );

        // If Object Lead
        if(object == 'Lead'){

            console.log('Object Type == Lead');

            // Call Apex
            leadActivation({cmId: campaignMemberId, leadId : recId, userId: this.userId})
            .then(result => {

                // Log Results
                console.log('Activation Result:');
                console.log(result);
                console.log('Redirect URL: ', result.RedirectRecord);
                console.log('Redirect Object: ', result.RedirectObject);

                const redirectURL = result.RedirectRecord;

                console.log('Result Message:');
                console.log(redirectURL);

                const parentEvent = new CustomEvent("activationResult", {
                    detail: {redirectURL}
                });

                console.log('ParentEvent: ', parentEvent);

                this.dispatchEvent(parentEvent);

                console.log('Dispatched Event - ParentEvent');

                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'One Moment Please',
                        message: 'Redirecting to Record',
                        variant: 'info',
                        mode: 'dismissible'
                    })
                );

                // Record Redirect
                console.log('Redirecting User After Activation...');
                this.recordRedirect(result.RedirectRecord, result.RedirectObject);

            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error Activating record',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
                console.error('There was an Activating the record Error :( ...');
                this.error = error;
                console.error(error);
            })
        }
        
        // If Object Contact:
        else if(object == 'Contact'){

            console.log('Object Type == Contact');

            // Call Apex
            contactActivation({cmId: campaignMemberId, contactId : recId, userId: this.userId})
            .then(result => {

                // Log Results
                console.log('Activation Result:');
                console.log(result);
                console.log('Redirect URL: ', result.RedirectRecord);
                console.log('Redirect Object: ', result.RedirectObject);

                const redirectURL = result.RedirectRecord;

                console.log('Result Message:');
                console.log(redirectURL);

                const parentEvent = new CustomEvent("activationResult", {
                    detail: {redirectURL}
                });

                console.log('ParentEvent: ', parentEvent);

                this.dispatchEvent(parentEvent);

                console.log('Dispatched Event - ParentEvent');

                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'One Moment Please',
                        message: 'Redirecting to Record',
                        variant: 'info',
                        mode: 'dismissible'
                    })
                );

                // Record Redirect
                console.log('Redirecting User After Activation...');
                this.recordRedirect(result.RedirectRecord, result.RedirectObject);

            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error Activating record',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
                console.error('There was an Activating the record Error :( ...');
                this.error = error;
                console.error(error);
            })
        }else{
            console.warn('Object Type == Unknown');
        }

        // If Object Account:
        // Call Apex
                
        // Call Lead Activate Apex
        // activationFlow({userId : this.userId, recordId : recId, campaignMemberId : campaignMemberId})
        // .then(result => {
        
        //     // Log Results
        //     console.log('Activation Result:');
        //     console.log(result);
        //     console.log('Activation Date: ', result.ActivationDate);
        //     console.log('Redirect URL: ', result.RedirectRecord);
        //     console.log('Redirect Object: ', result.RedirectObject);



        //     const redirectURL = result.RedirectRecord;

        //     console.log('Result Message:');
        //     console.log(redirectURL);

        //     const parentEvent = new CustomEvent("activationResult", {
        //         detail: {redirectURL}
        //     });

        //     console.log('ParentEvent: ', parentEvent);

        //     this.dispatchEvent(parentEvent);

        //     console.log('Dispatched Event - ParentEvent');

        //     this.dispatchEvent(
        //         new ShowToastEvent({
        //             title: 'One Moment Please',
        //             message: 'Redirecting to Record',
        //             variant: 'info',
        //             mode: 'dismissible'
        //         })
        //     );

        //     // Record Redirect
        //     console.log('Redirecting User After Activation...');
        //     this.recordRedirect(result.RedirectRecord, result.RedirectObject);
        
        // })
        // .catch(error => {
        //     this.dispatchEvent(
        //         new ShowToastEvent({
        //             title: 'Error Activating record',
        //             message: error.body.message,
        //             variant: 'error'
        //         })
        //     );
        //     console.error('There was an Activating the record Error :( ...');
        //     this.error = error;
        //     console.error(error);
        // });

        // Record Redirect Original Location
        // Moved to only have the user be redirected after the flow is complete

        // Clear Search Values
        this.clearSearchValues();

        // Close Console Tab
        this.closeTab();

    }

    // Button Handler
    callRowAction(event) { 
        
        // Event Logging
        console.groupCollapsed('Action');
            console.log('***************');
            console.log('Card Search Button Clicked!');
            console.log('Log Event: ', event);
            console.log('event.detail.row.Id: ', event.detail.row.Id);
            console.log('CampaignId: ', event.detail.row.CampaignMemberId);
            console.log('event.detail.action.name: ', event.detail.action.name);
            console.log('event.detail.row: ', event.detail.row);
            console.log('User Id: ', this.userId);
        console.groupEnd('Action');

        // Define Variables
        const recId =  event.detail.row.Id;  
        const actionName = event.detail.action.name;
        const campaignMemberId = event.detail.row.CampaignMemberId;
        const activationDate = event.detail.row.ActivationDate;

        if ( actionName === 'ActivateAccount' ) {
            
            // Additional Logging
            console.groupCollapsed('ActivateAccount');
                console.log('***************');
                console.log('Attempting to Activate Account...');
                console.log('Record Id: ', recId);
                console.log('User Id: ', this.userId);
            console.groupEnd('ActivateAccount');

            // Activate Record
            this.activateRecord(recId, 'Account', campaignMemberId, activationDate);
  
        } 
        else if (actionName === 'ActivateLead') {

            // Additional Logging
            console.groupCollapsed('ActivateLead');
                console.log('***************');
                console.log('Attempting to Activate Lead...');
                console.log('Record Id: ', recId);
                console.log('User Id: ', this.userId);
            console.groupEnd('ActivateLead');

            // Activate Record
            this.activateRecord(recId, 'Lead', campaignMemberId, activationDate);
        
        } 
        else if (actionName === 'ActivateContact') {

            // Additional Logging
            console.groupCollapsed('ActivateContact');
                console.log('***************');
                console.log('Attempting to Activate Contact...');
                console.log('Record Id: ', recId);
                console.log('User Id: ', this.userId);
            console.groupEnd('ActivateContact');

            // Activate Record
            this.activateRecord(recId, 'Contact', campaignMemberId, activationDate);

        }
        else {

            console.log('***************');
            console.log('UNKNOWN button was Clicked!');
            
        }     
  
    }  
    
    // Search Term Handler
    handleSearchTerm(event) {
        event.preventDefault();
        console.log('Handling Search Term Update...');
        this.strSearchTerm = event.detail.value;
        console.log('Search Term: ', event.detail.value);
        console.log('Char Length: ', this.strSearchTerm.length);
    }

    formatSearchTerm(event){

        event.preventDefault();
        console.log('Formatting Input');

        this.cardSearchTerm = event.target.value;
        console.log('Search Term: ', this.cardSearchTerm);

        // Goal to reformat card search func to look like CC format xxxx-xxxx-xxxx-xxxx
        let value = event.target.value;
        let oldLength = value.length;
        value = value.replace(/\D/g, "");
        let selectionStart = event.target.selectionStart;
    
        var v = value.replace(/\s+/g, '').replace(/[^0-9]/gi, '');
        var matches = v.match(/\d{4,16}/g);
        var match = matches && matches[0] || '';
        var parts = [];
        var i;
        for (i=0; i<match.length; i+=4) {
            parts.push(match.substring(i, i+4))
        }
        
        if(parts.length) {
            value = parts.join('-');
        } else {
            value = value;
        }

        this.cardNumberFormating = value;

        if (oldLength == selectionStart) {
          selectionStart = value.length;
        }
        event.target.value = value;
        event.target.selectionStart = selectionStart;
        event.target.selectionEnd = selectionStart;
    }   

    updateLoadingIcon(){
        
        console.log('Checking Status of Data');
        console.log('Search 1 Complete: ', this.loadingSearchOne);
        console.log('Search 2 Complete: ', this.loadingSearchTwo);

        if(this.loadingSearchOne == true && this.loadingSearchTwo == true){
            this.isLoading = false;
            this.loadingSearchOne = false;
            this.loadingSearchTwo = false;

            console.log('Clear Loading Icon and Associated Variables');
        }
    }

    // Wild Card Search
    handleSearch() {

        console.log('Refreshing Data...');
        this.refresh();
        
        console.log('Attempting to complete a Wild Card Search...');

        if(this.strSearchTerm.length < 5){
            this.errorMsg = 'Your entry is too short'
            return;
        }

        if(!this.strSearchTerm) {

            this.errorMsg = 'Please enter a value in the search.';
            this.accountData = undefined;
            this.leadData = undefined;
            return;

        }

        console.log('Activating Spinner for User');
        this.isLoading = true;
        this.loadingSearchOne = false;
        this.loadingSearchTwo = false;

        this.errorMsg = undefined;

        console.log('Current Users Id:');
        console.log(this.userId);

        // Populate Create Lead Section in Result
        this.searchRan = true;

        // Account Search by Wild Card
        // accountSearch({srchTerm : this.strSearchTerm})
        // .then(result => 
        //     {

        //     console.log('*******************');
        //     console.log('Account Search Result:');
        //     console.log(result);

        //     var i;
        //     var iteration;
        //     var tempArray = [];
        //     var count = 0;

        //     console.log('Looping Accounts...');

        //     for (i = 0; i < result.length; i++) {

        //         // Log Results
        //         console.log('Iteration Number: ', i);
        //         console.log(result[i]);

        //         // Reconstruct
        //         iteration = {
        //             Id: result[i].Id, 
        //             Name: result[i].Name, 
        //             Phone: result[i].Phone, 
        //             Owner: result[i].Owner.Name,
        //             OwnerId: result[i].OwnerId,
        //             ActivationDate: result[i].Activation_Date__c
        //         }
                
        //         // Log Result
        //         console.log('Restructured Object:');
        //         console.log(iteration);

        //         // Push into Array
        //         console.log('Pushing into array...');
        //         tempArray.push(iteration);

        //         // Add one to count
        //         count ++;
        //         console.log('Record Count: ', count);
        //     }

        //     console.log('End - Log Temp Array:');
        //     console.table(tempArray);

        //     // Assign Values
        //     this.accountData = tempArray;
        //     this.accountCount = count;

        //     console.log('Search 1 Complete');
        //     this.loadingSearchOne = true;
        //     this.updateLoadingIcon();

        // })
        // .catch(error => {
        //     this.searchData = undefined;
        //     window.console.log('error =====> '+JSON.stringify(error));
        //     if(error) {
        //         this.errorMsg = error;
        //     }

        //     console.log('Search 1 Complete');
        //     this.loadingSearchOne = false;
        //     this.updateLoadingIcon();
        // })

        // Contact Search by Wild Card
        contactSearch({srchTerm : this.strSearchTerm})
        .then(result => 
            {

            console.log('*******************');
            console.log('Contact Search Result:');
            console.log(result);
    
            var i;
            var iteration;
            var tempArray = [];
            var count = 0;

            console.log('Looping Contacts...');
    
            for (i = 0; i < result.length; i++) {
    
                // Log Results
                console.log('Iteration Number: ',i);
                console.log(result[i]);

                // Reconstruct
                iteration = {
                    Id: result[i].Id,
                    AccountId: result[i].AccountId, 
                    Name: result[i].Name, 
                    Phone: result[i].Phone,
                    Company: result[i].Company, 
                    Owner: result[i].Account.Owner.Name,
                    OwnerId: result[i].Account.OwnerId,
                    ActivationDate: result[i].Account.Activation_Date__c
                }
                    
                // Log Result
                console.log('Restructured Object:');
                console.log(iteration);
    
                // Push into Array
                console.log('Pushing into array...');
                tempArray.push(iteration);
    
                // Add one to count
                count ++;
                console.log('Record Count: ', count);
            }
    
            console.log('End - Log Temp Array:');
            console.table(tempArray);

            // Assign Values
            this.contactData = tempArray;
            this.contactCount = count;
            
            // this.leadData = result;

            console.log('Search 2 Complete');
            this.loadingSearchOne = true;
            this.updateLoadingIcon();
            
        })
        .catch(error => {
            this.contactData = undefined;
            window.console.log('error =====> '+JSON.stringify(error));
            if(error) {
                this.errorMsg = error;
            }

            console.log('Search 2 Complete');
            this.loadingSearchOne = true;
            this.updateLoadingIcon();
        })
    

        // Lead Search by Wild Card
        leadSearch({srchTerm : this.strSearchTerm})
        .then(result => 
            {

            console.log('*******************');
            console.log('Lead Search Result:');
            console.log(result);
    
            var i;
            var iteration;
            var tempArray = [];
            var count = 0;

            console.log('Looping Leads...');
    
            for (i = 0; i < result.length; i++) {
    
                // Log Results
                console.log('Iteration Number: ',i);
                console.log(result[i]);

                // Reconstruct
                iteration = {
                    Id: result[i].Id, 
                    Name: result[i].Name, 
                    Phone: result[i].Phone,
                    Company: result[i].Company, 
                    Owner: result[i].Owner.Name,
                    OwnerId: result[i].OwnerId,
                    ActivationDate: result[i].Activation_Date__c
                }
                    
                // Log Result
                console.log('Restructured Object:');
                console.log(iteration);
    
                // Push into Array
                console.log('Pushing into array...');
                tempArray.push(iteration);
    
                // Add one to count
                count ++;
                console.log('Record Count: ', count);
            }
    
            console.log('End - Log Temp Array:');
            console.table(tempArray);

            // Assign Values
            this.leadData = tempArray;
            this.leadCount = count;
            
            // this.leadData = result;

            console.log('Search 2 Complete');
            this.loadingSearchTwo = true;
            this.updateLoadingIcon();
            
        })
        .catch(error => {
            this.leadData = undefined;
            window.console.log('error =====> '+JSON.stringify(error));
            if(error) {
                this.errorMsg = error;
            }

            console.log('Search 2 Complete');
            this.loadingSearchTwo = true;
            this.updateLoadingIcon();
        })
    }

    // Account Number Search
    handleCMSearch() {

        console.log('Refreshing Data...');
        this.refresh();

        console.log('Attempting to complete an Account Number Search...');
        console.log('Search Term: ', this.cardSearchTerm);

        // Remove Characters from Search Term
        var eventVal = this.cardSearchTerm;
        var tempValue = eventVal.replace(/\s+/g, '').replace(/[^0-9]/gi, '');
        var term = tempValue;
        var termLength = term.length;
        console.log('Unformatted Search Term: ', term, ' w/ Length ', termLength);

        if(!this.cardSearchTerm) {

            this.errorMsg = 'Please enter a value in the search.';
            this.leadData = undefined;
            this.contactData = undefined;
            return;

        } else if (termLength != 9 && termLength != 16){
            
            this.errorMsg = 'Please enter a Card Number with 9 or 16 Characters.';
            this.leadData = undefined;
            this.contactData = undefined;
            return;

        } else if(termLength>16) {

            this.errorMsg = 'Card Number cannot be greater than 16 Characters';
            this.leadData = undefined;
            this.contactData = undefined;
            return;
            
        }

        console.log('Activating Spinner for User');
        this.isLoading = true;
        this.loadingSearchOne = false;
        this.loadingSearchTwo = false;

        console.log('Current Users Id:');
        console.log(this.userId);

        // Populate Create Lead Section in Result
        this.searchRan = true;

        // Lead Search by Account Number
        leadCMSearch2({srchTerm : term})
        .then(result => 
            {

            console.log('*******************');
            console.log('Lead Search Result:');
            console.log(result);
    
            var i;
            var iteration;
            var tempArray = [];
            var count = 0;

            console.log('Looping Leads...');
    
            for (i = 0; i < result.length; i++) {
    
                // Log Results
                console.log('Iteration Number: ', i);
                console.log(result[i]);

                // Reconstruct
                iteration = {
                    Id: result[i].LeadId, 
                    Name: result[i].Lead.Name, 
                    Phone: result[i].Lead.Phone,
                    Company: result[i].Lead.Company, 
                    Owner: result[i].Lead.Owner.Name,
                    OwnerId: result[i].Lead.OwnerId,
                    CampaignMemberId: result[i].Id,
                    CampaignStatus: result[i].Status,
                    AccountNumber: result[i].Account_Number__c,
                    ActivationDate: result[i].Lead.Activation_Date__c
                }
                    
                // Log Result
                console.log('Restructured Object:');
                console.log(iteration);
    
                // Push into Array
                console.log('Pushing into array...');
                tempArray.push(iteration);
    
                // Add one to count
                count ++;
                console.log('Record Count: ', count);
            }
    
            console.log('End - Log Temp Array:');
            console.table(tempArray);

            // Assign Values
            this.leadData = tempArray;
            this.leadCount = count;

            // this.leadData = result;

            console.log('Search 1 Complete');
            this.loadingSearchOne = true;
            this.updateLoadingIcon();
            
        })
        .catch(error => {
            this.leadData = undefined;
            window.console.log('error =====> '+JSON.stringify(error));
            if(error) {
                this.errorMsg = error;
            }

            console.log('Search 1 Complete');
            this.loadingSearchOne = true;
            this.updateLoadingIcon();
        })

        // Contact Search by Account Number
        contactCMSearch2({srchTerm : term})
        .then(result => 
            {

            console.log('*******************');
            console.log('Contact Search Result:');
            console.log(result)

            var i;
            var iteration;
            var tempArray = [];
            var count = 0;

            console.log('Looping Contacts...');

            for (i = 0; i < result.length; i++) {

                // Log Results
                console.log('Iteration Number: ', i);
                console.log(result[i]);

                // Reconstruct
                iteration = {
                    Id: result[i].ContactId, 
                    Name: result[i].Contact.Name,
                    Account: result[i].Contact.Account.Name, 
                    Phone: result[i].Contact.Phone, 
                    Owner: result[i].Contact.Owner.Name,
                    OwnerId: result[i].Contact.OwnerId,
                    CampaignMemberId: result[i].Id,
                    CampaignStatus: result[i].Status,
                    AccountNumber: result[i].Account_Number__c,
                    ActivationDate: result[i].Contact.Account.Activation_Date__c
                }
                
                // Log Result
                console.log('Restructured Object:');
                console.log(iteration);

                // Push into Array
                console.log('Pushing into array...');
                tempArray.push(iteration);

                // Add one to count
                count ++;
                console.log('Record Count: ', count);
            }

            console.log('End - Log Temp Array:');
            console.table(tempArray);

            // Assign Values
            this.contactData = tempArray;
            this.contactCount = count;

            // this.contactData = result;

            console.log('Search 2 Complete');
            this.loadingSearchTwo = true;
            this.updateLoadingIcon();
            
        })
        .catch(error => {
            this.contactData = undefined;
            window.console.log('error =====> '+JSON.stringify(error));
            if(error) {
                this.errorMsg = error;
            }

            console.log('Search 2 Complete');
            this.loadingSearchTwo = true;
            this.updateLoadingIcon();
        })
    }

    // Refresh Functionality
    refresh(){

        this.accountData = undefined;
        this.leadData = undefined;
        this.contactData = undefined;
        this.errorMsg = undefined;

        console.log('Data Refreshed!');
        console.groupCollapsed('Refresh');
            console.log('accountData: ', this.accountData);
            console.log('leadData: ', this.leadData);
            console.log('contactData: ', this.contactData);
        console.groupEnd('Refresh');

    }
    
    // Create new Lead
    createNewLead(){
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Lead',
                actionName: 'new'                
            }
        });
    }

    // Record Redirect
    recordRedirect(recId, obj){

        // Navigate to Record
        this[NavigationMixin.Navigate]({  
            type: 'standard__recordPage',  
            attributes: {  
                recordId: recId,  
                objectApiName: obj,  
                actionName: 'view'  
            }  
        })
    }

    // Wild Card Search KeyUp
    wcsKeyUp(evt){
        const isEnterKey = evt.keyCode === 13;
        if (isEnterKey) {
            console.log('Enter Key Pressed');
            this.handleSearch();
        }
    }

    // Account Number Search KeyUp
    anKeyUp(evt){
        const isEnterKey = evt.keyCode === 13;
        if (isEnterKey) {
            console.log('Enter Key Pressed');
            this.handleCMSearch();
        }
    }

    // Close Tab (Call Aura Component)
    closeTab(){
        // Notes on communicating between LWC to Aura: 
        // https://developer.salesforce.com/docs/component-library/documentation/en/lwc/lwc.events_create_dispatch
        // https://developer.salesforce.com/docs/component-library/documentation/en/lwc/lwc.events_sending_to_aura_components
        // https://developer.salesforce.com/docs/atlas.en-us.lightning.meta/lightning/events_component_handling_intro.htm
        this.dispatchEvent(new CustomEvent('closetab'));
    }

    // Open Tab
    openTab(){
        console.log('Opening Utility Tab')
    }

}