import { LightningElement,api } from 'lwc';
export default class CgModalWindow extends LightningElement {
     @api title;
    cancel() {
        this.dispatchEvent(new CustomEvent("cancelevent"));
    }
    save() {
        this.dispatchEvent(new CustomEvent("saveevent"));
    }
}