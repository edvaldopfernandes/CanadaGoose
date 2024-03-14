import { LightningElement } from 'lwc';
import LABELS from './customLabels.js';

export default class WarrantyPolicyStepTwo extends LightningElement {

    labels = LABELS;

    proceedStep() {
        this.dispatchEvent(new CustomEvent('proceedstep'));
    }
}