import { LightningElement, api } from 'lwc';
import infoImages from '@salesforce/resourceUrl/CaseCreationInfoImages';

export default class CaseCreationModal extends LightningElement {

    @api title;
    @api content;
    @api image;
    render = false;

    get imageSrc() {
        return infoImages + '/infoImages/' + this.image;
    }

    renderComponent() {
        this.render = true;
    }

    handleClose() {
        this.render = false;
        this.dispatchEvent(new CustomEvent('closecasemodal'));
    }
}