import { LightningElement, api } from 'lwc';
import getPicklistValues from '@salesforce/apex/CaseCreationController.getPicklistValues';
import LABELS from './customLabels.js';

export default class CaseCreationProdIdentification extends LightningElement {

    @api editing;
    @api case;
    labels = LABELS;
    sizeValues;

    get styleNumber() {
        return this.case.styleNumber;
    }

    get colour() {
        return this.case.colour;
    }

    get size() {
        return this.case.size;
    }

    get disableContinue() {
        return (!this.styleNumber || !this.colour || !this.size);
    }

    connectedCallback() {
        getPicklistValues({
            'fieldName' : 'Size__c'
        })
        .then((result) => {
            this.sizeValues = result;
        })
        .catch((error) => {
            console.log(error);
        });
    }

    renderedCallback() {
        this.selectSizeContainer(this.case.size);
    }

    edit() {
        this.sendEditEvent(false, true, false, false);
    }

    setField(event) {
        let value = event.target.value;
        let field = event.target.name;
        this.case = {
            ...this.case,
            [field] : value
        };
    }

    selectSize(event) {
        let value = event.target.dataset.item;

        this.case = {
            ...this.case,
            'size' : value
        };

        this.selectSizeContainer(value);
    }

    selectSizeContainer(value) {
        for(let item of this.template.querySelectorAll('div.size-field')) {
            if(item.dataset.item != value) {
                item.classList.remove('size-active');
            } else {
                item.classList.add('size-active');
            }
        }
    }

    saveProdIdent() {
        const inputElements = this.template.querySelectorAll('lightning-input');
        let valid = true;

        inputElements.forEach((element) => {
            valid = (element.reportValidity() && valid);
        });

        if(!valid) {
            return;
        }

        const saveProdIdentEvent = new CustomEvent('saveprodident', { 
            detail: {
                'case' : this.case, 
                'editing' : 'editProdIssue'
            }
        });
        this.dispatchEvent(saveProdIdentEvent);
    }

    sendEditEvent(address, prodIdent, prodIssue, imgUpload) {
        const editEvent = new CustomEvent('editinfo', { 
            detail: {
                'addressEditing' : address, 
                'prodIdentEditing' : prodIdent, 
                'prodIssueEditing' : prodIssue, 
                'imgUploadEditing' : imgUpload
            }
        });
        this.dispatchEvent(editEvent);
    }

    dispatchModal() {
        const modalEvent = new CustomEvent('dispatchmodal', { 
            detail: {
                'modalTitle' : this.labels.prodIdentPictureTitle,
                'modalContent' : this.labels.prodIdentPictureText,
                'modalImage' : 'StyleNumber.png'
            }
        });
        this.dispatchEvent(modalEvent);
    }
}