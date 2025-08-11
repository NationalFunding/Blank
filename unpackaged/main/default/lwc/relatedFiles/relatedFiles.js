import { LightningElement, wire, api, track } from 'lwc';
import filesQuery from '@salesforce/apex/RelatedContentDocumentLinkRecords.getfiles';
import { refreshApex } from '@salesforce/apex';
import { NavigationMixin } from 'lightning/navigation';

export default class RelatedFiles extends NavigationMixin(LightningElement){

    @api recordId; // Grab the Record Id
    @api objectApiName; // Grab the Objects API Name

    wireFilesResult;
    files;
    error;
    filesData;
    
    @wire(filesQuery, {recordId: '$recordId'})
    filesResult(result){
        console.log('Files Result:');
        this.wireFilesResult = result;
        
        if(result.data){
            console.log('Data');
            console.log(result.data);

            this.files = result.data;
            console.table(this.files);

            let i;
            let iteration;
            let tempArray = [];
    
            for ( i=0; i < result.data.length; i ++){

                iteration = {
                    Id: result.data[i].Id,
                    ContentDocumentId: result.data[i].ContentDocumentId,
                    Title: result.data[i].ContentDocument.Title,
                    DocLinkId: result.data[i].Id,
                    FileType: result.data[i].ContentDocument.FileType,
                    CreatedDate: new Date(result.data[i].ContentDocument.CreatedDate).toDateString(),
                }

                console.log(iteration);
                tempArray.push(iteration);

            }
            
            this.filesData = tempArray;
            console.log(this.filesData);

        } else if (result.error) {
            console.error(error);
        }

    }

    filePreview(event) {
        // Naviagation Service to the show preview
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'filePreview'
            },
            state : {
                // assigning ContentDocumentId to show the preview of file
                selectedRecordId:event.currentTarget.dataset.id
            }
          })
    }

    refresh(){
        console.log('Refreshing Files');
        return refreshApex(this.wireFilesResult);
    }

}