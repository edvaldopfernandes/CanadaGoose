import { LightningElement, api } from 'lwc';

export default class CagButton extends LightningElement {

    @api label;
    @api disabled;
    @api variant;

    get dynamicClass() {
        return `slds-button ${this.variantClass}`;
    }
    
    get variantClass() {
        switch (this.variant) {
            case 'neutral':
                return 'slds-button_neutral';
            case 'outline-brand':
                return 'slds-button_outline-brand';
            case 'destructive':
                return 'slds-button_destructive';
            case 'text-destructive':
                return 'slds-button_text-destructive';
            case 'success':
                return 'slds-button_success';
            default:
                return 'slds-button_brand';
        }
    }

    get lineClass(){
        switch (this.variant) {
            case 'neutral':
                return 'line_neutral';
            default:
                return 'line_brand';
        }
    }

    click() {
        this.dispatchEvent(new CustomEvent('buttonclick'));
    }
}