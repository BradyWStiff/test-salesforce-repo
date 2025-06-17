import { LightningElement, api, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getRelatedOpportunities from '@salesforce/apex/OpportunityController.getRelatedOpportunities';
import insertOpportunities from '@salesforce/apex/OpportunityController.insertOpportunities';

export default class RelatedOpportunities extends LightningElement {
    @api recordId; // Record ID of the current Account
    opportunities; // This is a test
    wiredOpportunitiesResult;
    testVariable;

    columns = [
        { label: 'Opportunity Name', fieldName: 'Name', type: 'text' },
        { label: 'Close Date', fieldName: 'CloseDate', type: 'date' },
        { label: 'Stage', fieldName: 'StageName', type: 'text' },
        { label: 'Amount', fieldName: 'Amount', type: 'currency' }
    ];

    @wire(getRelatedOpportunities, { accountId: '$recordId' })
    wiredOpportunities(result) {
        this.wiredOpportunitiesResult = result; // Store the wire service result
        if (result.data) {
            this.opportunities = result.data;
        } else if (result.error) {
            console.error('Error fetching related opportunities:', result.error);
        }
    }

    handleFileChange(event) {
        const file = event.target.files[0];
        if (file) {
            let reader = new FileReader();
            reader.onload = () => {
                let text = reader.result;
                let csvOpportunities = this.csvToArray(text);
                this.insertOpportunities(csvOpportunities);
            };
            reader.readAsText(file);
        }
    }

    csvToArray(str, delimiter = ",") {
        // Split the string into rows
        const rows = str.slice(str.indexOf("\n") + 1).split("\n");
        // Map rows to Opportunity objects
        const opportunities = rows.map(row => {
            const values = row.split(delimiter);
            return {
                Name: values[0],
                CloseDate: values[1],
                StageName: values[2],
                Amount: values[3],
                AccountId: this.recordId // Assuming AccountId is the last column
            };
        });
        return opportunities;
    }

    insertOpportunities(opportunities) {
        insertOpportunities({ opportunitiesData: opportunities, AccountId: this.recordId})
            .then(result => {
                // Optionally, perform further validation here if necessary
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Opportunities inserted successfully!',
                        variant: 'success'
                    })
                );
                refreshApex(this.wiredOpportunitiesResult);
                //this.refreshDataTable();
                
            })
            .catch(error => {
                // Assuming the error body has a message field in the response
                let message = 'Error inserting opportunities';
                if (error.body && error.body.message) {
                    message = error.body.message;
                }
                console.log('Error:', error);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: message,
                        variant: 'error',
                        mode: 'sticky' // Makes the toast message remain on the screen until the user dismisses it
                    })
                );
            });
    }    

    // refreshDataTable() {
    //     return refreshApex(this.wiredOpportunitiesResult);
    // }
}