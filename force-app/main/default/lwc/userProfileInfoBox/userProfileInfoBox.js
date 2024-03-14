import { LightningElement, api } from 'lwc';

export default class UserProfileInfoBox extends LightningElement {
    @api label;
    @api value;
    @api type;

    edit() {
        this.dispatchEvent(new CustomEvent('editinfo', {
            detail: this.type
        }));
    }
}