import { LightningElement, track, wire, api } from 'lwc';
import individualBankTabSummaryTab from '@salesforce/apex/CreditReviewScreen_LWC.individualBankTabSummaryTab';

export default class CreditReviewScreen_LWC extends LightningElement {
    @api recordId;
    @track colDATA;
    @track error;
    @track ready;

    @wire(individualBankTabSummaryTab, {recordId: '$recordId'})
    wireGetRecords(summaryRecords){
        this.ready = false;
        if(summaryRecords){
            console.log('data::: stringified::: ' + JSON.stringify(summaryRecords));
            this.colDATA = summaryRecords.data;
            if(this.colDATA){
                this.ready = true;
            }
            this.error = undefined;
        } else if (result.error) {
            this.error = error;
            this.colDATA = undefined;
        }
    }

    
    /*** data structure 
   {
    "data": {
    "BMA": {
      "Column1": "111.00",
      "Column2": 222,
      "Column3": "333.00",
      "Column4": "444.00",
      "Column5": "555.00",
      "Column6": "666.00",
      "Column7": 0,
      "Column8": 0,
      "Column9": "999.50"
    },
    "SummaryMonths": [
      {
        "Column1": 111,
        "Column2": 0,
        "Column3": 0,
        "Column4": 0,
        "Column5": 0,
        "Column6": 0,
        "Column7": 0,
        "Column8": 0,
        "Column9": 777,
        "Month": "7",
        "MonthName": "Jul",
        "Year": "2022"
      },
      {
        "Column1": 0,
        "Column2": 222,
        "Column3": 0,
        "Column4": 0,
        "Column5": 0,
        "Column6": 0,
        "Column7": 0,
        "Column8": 0,
        "Column9": 888,
        "Month": "6",
        "MonthName": "Jun",
        "Year": "2022"
      },
      {
        "Column1": 0,
        "Column2": 0,
        "Column3": 333,
        "Column4": 0,
        "Column5": 0,
        "Column6": 0,
        "Column7": 0,
        "Column8": 0,
        "Column9": 999,
        "Month": "5",
        "MonthName": "May",
        "Year": "2022"
      },
      {
        "Column1": 0,
        "Column2": 0,
        "Column3": 0,
        "Column4": 444,
        "Column5": 0,
        "Column6": 0,
        "Column7": 0,
        "Column8": 0,
        "Column9": 1010,
        "Month": "4",
        "MonthName": "Apr",
        "Year": "2022"
      },
      {
        "Column1": 0,
        "Column2": 0,
        "Column3": 0,
        "Column4": 0,
        "Column5": 555,
        "Column6": 0,
        "Column7": 0,
        "Column8": 0,
        "Column9": 1111,
        "Month": "3",
        "MonthName": "Mar",
        "Year": "2022"
      },
      {
        "Column1": 0,
        "Column2": 0,
        "Column3": 0,
        "Column4": 0,
        "Column5": 0,
        "Column6": 666,
        "Column7": 0,
        "Column8": 0,
        "Column9": 1212,
        "Month": "2",
        "MonthName": "Feb",
        "Year": "2022"
      }
    ]
   }
}*/
}