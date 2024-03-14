import { LightningElement, api } from 'lwc';
import getPicklistValues from '@salesforce/apex/CaseCreationController.getPicklistValues';
import LABELS from './customLabels.js';

export default class CaseCreationProdIssue extends LightningElement {

    @api editing;
    @api case;
    labels = LABELS;
    issueValues;

    get issues() {
        return (this.case.customerIssue || []).join(', ');
    }

    get description() {
        return this.case.description;
    }

    get disableContinue() {
        return (!this.issues);
    }

    edit() {
        this.sendEditEvent(false, false, true, false);
    }

    connectedCallback() {
        getPicklistValues({
            'fieldName' : 'Customer_Issue__c'
        })
        .then((result) => {
            this.issueValues = result;
        })
        .catch((error) => {
            console.log(error);
        });
    }

    renderedCallback() {
        this.selectIssueContainer(this.case.customerIssue);
    }

    setField(event) {
        let value = event.target.value;
        let field = event.target.name;
        this.case = {
            ...this.case,
            [field] : value
        };
    }

    selectIssue(event) {
        let value = event.target.dataset.item;
        let array = (this.case.customerIssue ? [...this.case.customerIssue] : []);

        if(array.find((issue) => issue === value)) {
            array = array.filter((issue) => issue !== value);
        } else {
            array.push(value);
        }

        this.case = {
            ...this.case,
            'customerIssue' : array
        };

        this.selectIssueContainer(this.case.customerIssue);
    }

    selectIssueContainer(value) {
        if(!value) {
            return;
        }

        for(let item of this.template.querySelectorAll('div.issue-field')) {
            if(!value.find((issue) => issue == item.dataset.item)) {
                item.classList.remove('issue-active');
            } else {
                item.classList.add('issue-active');
            }
        }
    }

    saveProdIssue() {
        const inputElements = this.template.querySelectorAll('lightning-input');
        let valid = true;

        inputElements.forEach((element) => {
            valid = (element.reportValidity() && valid);
        });

        if(!valid) {
            return;
        }

        const saveProdIssueEvent = new CustomEvent('saveprodissue', { 
            detail: {
                'case' : this.case, 
                'editing' : 'editImgUpload'
            }
        });
        this.dispatchEvent(saveProdIssueEvent);
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