import { LightningElement, api } from 'lwc';

export default class CaseList extends LightningElement {
    @api caseItem;

    connectedCallback() {
        console.log('case item: ', JSON.stringify(this.caseItem));
    }
}