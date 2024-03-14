import { LightningElement, track } from 'lwc';
import LABELS from './customLabels.js';

export default class WarrantyPolicyStepThree extends LightningElement {

    labels = LABELS;
    @track agreed = false;
    
    get disabledContinue() {
        return !this.agreed;
    }

    agree(event) {
        this.agreed = !!(event.target.checked);
    }

    saveInfo() {
        this.dispatchEvent(new CustomEvent('saveinfo', {
            detail: this.agreed
        }));
    }
}