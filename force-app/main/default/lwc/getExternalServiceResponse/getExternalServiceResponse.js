import { LightningElement, track } from 'lwc';
import getExternalServiceResponse from '@salesforce/apex/ExternalServiceController.getResponse';

export default class LwcComponent extends LightningElement {
    @track status = '';
    @track statusCode = '';
    @track errorMessage = '';

    handleGetResponse() {
        this.errorMessage = '';
        getExternalServiceResponse()
            .then(result => {
                this.status = result.status;
                this.statusCode = result.statusCode;
            })
            .catch(error => {
                this.errorMessage = 'Error: Unknown error';
            });
    }
}