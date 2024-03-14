import { LightningElement, api } from 'lwc';

export default class WarrantyCheckbox extends LightningElement {

    @api label;
    @api required = false;
    @api checked = false;
    @api iconWidth;
    @api iconHeight;

    get isRequired() {
        return !!this.required;
    }

    setChecked() {
        this.checked = !this.checked;
        this.dispatchEvent(new CustomEvent('checkchange', { detail: this.checked }));
    }

}