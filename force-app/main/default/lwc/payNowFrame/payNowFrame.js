import { LightningElement, api } from 'lwc';

export default class PayNowFrame extends LightningElement {

    @api width = '100%';
    @api height = '100%';
    @api recordId;

    get frameUrl() {
        return '/cgwarrantyvforcesite/AdyenPayment?id=' + this.recordId;
    }

}