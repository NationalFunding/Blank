import { LightningElement, track, wire, api } from 'lwc';
import individualBankTabSummaryTab from '@salesforce/apex/CreditReviewScreen_LWC.individualBankTabSummaryTab';

const columns = [
  { label: 'Daily Balance($)', fieldName: 'name' }];

export default class CreditReviewScreen_LWC extends LightningElement {
    @api recordId;
    @track colDATA;
    @track error;
    @track ready;
    @track colOneReady;
    columns = columns;

    @wire(individualBankTabSummaryTab, {recordId: '$recordId'})
    wireGetRecords(summaryRecords){
        this.ready = false;
        if(summaryRecords){
          let finalObject = {};

            if(summaryRecords.data && summaryRecords.data.BMA && summaryRecords.data.MonthlyLedgerParentsList && summaryRecords.data.SummaryMonths){
              let restructuredBMA = summaryRecords.data.BMA; //object
              let restructuredMonthlyLedgerParentsList = Object.assign([], summaryRecords.data.MonthlyLedgerParentsList); //array
              let restructuredSummaryMonths = summaryRecords.data.SummaryMonths; //array
              let newRestructuredMonthlyLedgerParentsList = [];

              for(let i = 0; i <= restructuredMonthlyLedgerParentsList.length; i++){ //looping through array of banks
                  let newChildsArray = []; //one child array per MonthlyLedgerParentsList 

                  if(restructuredMonthlyLedgerParentsList[i] != undefined && restructuredMonthlyLedgerParentsList[i] != null && restructuredMonthlyLedgerParentsList[i].Childs != null && restructuredMonthlyLedgerParentsList[i].Childs != undefined){ //i really shouldn't need this...if it's empty it wont loop through it
                      let childArray = Object.assign([], restructuredMonthlyLedgerParentsList[i].Childs);

                      for(let j = 0; j < childArray.length; j++) {
                        //todo:: try and get these nested loops out of each other
                        if(childArray[j] != null && childArray[j].Mr != null && childArray[j].Mr != undefined){
                          let mrObject = Object.assign({}, childArray[j].Mr);

                          if(!Object.hasOwn(mrObject, 'Beginning_Balance__c')){
                            Object.assign(mrObject, {Beginning_Balance__c : 0});
                          }
                          if(!Object.hasOwn(mrObject, 'Deposits_Number__c')){
                            Object.assign(mrObject, {Deposits_Number__c : 0});
                          }
                          if(!Object.hasOwn(mrObject, 'Counter_Deposits__c')){
                            Object.assign(mrObject, {Counter_Deposits__c : 0})
                          }
                          if(!Object.hasOwn(mrObject, 'Other_Deposits__c')){
                            Object.assign(mrObject, {Other_Deposits__c : 0});
                          }
                          if(!Object.hasOwn(mrObject, 'Withdrawls__c')){
                            Object.assign(mrObject, {Withdrawls__c : 0});
                          }
                          if(!Object.hasOwn(mrObject, 'Ending_Balance__c')){
                            Object.assign(mrObject, {Ending_Balance__c : 0})
                          }
                          if(!Object.hasOwn(mrObject, 'Negative_Days__c')){
                            Object.assign(mrObject, {Negative_Days__c : 0});
                          }
                          if(!Object.hasOwn(mrObject, 'NSF__c')){
                            Object.assign(mrObject, {NSF__c : 0});
                          }
                          if(!Object.hasOwn(mrObject, 'Avg_Daily_Balance__c')){
                            Object.assign(mrObject, {Avg_Daily_Balance__c : 0});
                          }

                          /*************/
                          //todo:: maybe seperate this out into it's own function?
                          //todo:: try and get these nested loops out of each other
                          let daysInMonthList = [];
                          for(let m = 0; m < childArray[j].FieldNames.length; m++){
                            let fieldDay = String(childArray[j].FieldNames[m]);
                            if( Object.hasOwn(childArray[j].Mr, fieldDay) ){
                              daysInMonthList.push( { name: childArray[j].Mr[fieldDay], dayNumber : m + 1 } );
                            } else{
                              daysInMonthList.push( { name: 0, dayNumber : m + 1 } );
                            }
                          }

                          //one mr object per one child
                          let newChildObject = {
                            DaysInMonth : childArray[j].DaysInMonth , 
                            FieldNames : childArray[j].FieldNames, 
                            Mr : mrObject,
                            DaysInMonthList : daysInMonthList
                          };

                          newChildsArray.push(newChildObject);
                        }
                      }

                      let arrayOfCalendarDays= [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31];
                      //removing the loop to avoid nesting loops
                      // for(let l = 1; l <= 31; l++){
                      //   arrayOfCalendarDays.push(l);
                      // }

                      let singularMonthlyLedgerParent = {
                        Account_Number : restructuredMonthlyLedgerParentsList[i].Account_Number,
                        Avg : restructuredMonthlyLedgerParentsList[i].Avg,
                        BankId : restructuredMonthlyLedgerParentsList[i].BankId,
                        BankSummaryId : restructuredMonthlyLedgerParentsList[i].BankSummaryId,
                        Childs : newChildsArray,
                        TabName : restructuredMonthlyLedgerParentsList[i].TabName + ' #' + (restructuredMonthlyLedgerParentsList[i].Account_Number).slice(-4), 
                        DaysInMonth : arrayOfCalendarDays
                      };
    
                      newRestructuredMonthlyLedgerParentsList.push(singularMonthlyLedgerParent);
                  }
              }
              if(restructuredBMA.Column1 != null && restructuredBMA.Column1 != undefined){
                this.colOneReady = true;
              }

              finalObject = {BMA: restructuredBMA, MonthlyLedgerParentsList: newRestructuredMonthlyLedgerParentsList, SummaryMonths: restructuredSummaryMonths};

            }

            console.log('finalObject::: ' + JSON.stringify(finalObject));
            this.colDATA = finalObject;

            if(this.colDATA){
                this.ready = true;
            }
            this.error = undefined;
        } else if (result.error) {
            this.error = error;
            this.colDATA = undefined;
        }
    }

}