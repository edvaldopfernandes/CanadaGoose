import { LightningElement, api } from 'lwc';
import getUserInfos from '@salesforce/apex/CaseCreationController.getUserInfo';
import LABELS from './customLabels.js';

export default class CaseCreationAddress extends LightningElement {

    @api case;
    @api editing;
    labels = LABELS;
    confirming = false;
    

    get showTitle() {
        return (this.editing || this.confirming);
    }

    get editingClass() {
        return `card${this.editing ? ' opened' : ''}`;
    }

    get address() {
        return this.case.address;
    }

    get complement() {
        return this.case.complement;
    }

    get zipCode() {
        return this.case.zipCode;
    }

    get city() {
        return this.case.city;
    }

    get province() {
        return this.case.province;
    }

    get country() {
        return this.case.country;
    }

    get phone() {
        return this.case.phone;
    }

    connectedCallback() {
        getUserInfos()
        .then((result) => {
            console.log('result -', result);
            if(result.success) {
                this.case = result.values;
            }
        });
    }

    setField(event) {
        let value = event.target.value;
        let field = event.target.name;
        this.case = {
            ...this.case,
            [field] : value
        };
    }

    edit() {
        this.sendEditEvent(true, false, false, false);
        this.confirming = false;
    }

    confirmAddress() {
        const inputElements = this.template.querySelectorAll('lightning-input');
        let valid = true;

        inputElements.forEach((element) => {
            valid = (element.reportValidity() && valid);
        });

        if(!valid) {
            return;
        }

        this.sendEditEvent(false, false, false, false);
        this.confirming = true;
    }

    saveAddress(event) {
        const saveAddressEvent = new CustomEvent('saveaddress', { 
            detail: {
                'case' : this.case, 
                'editing' : 'editProdIdent'
            }
        });
        this.dispatchEvent(saveAddressEvent);
        this.confirming = false;
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

}