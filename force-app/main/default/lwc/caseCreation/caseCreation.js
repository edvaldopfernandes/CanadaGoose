import { LightningElement } from 'lwc';
import ToastContainer from 'lightning/toastContainer';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import saveCase from '@salesforce/apex/CaseCreationController.saveCase';
import { NavigationMixin } from 'lightning/navigation';

export default class CaseCreation extends NavigationMixin(LightningElement) {

    caseObj = {};
    loading = false;

    addressEditing = true;
    prodIdentEditing = false;
    prodIssueEditing = false;
    imgUploadEditing = false;

    showModal = false;
    modalTitle;
    modalContent;
    modalImage;

    connectedCallback() {
        const toastContainer = ToastContainer.instance();
        toastContainer.toastPosition = 'top-center';
    }

    edit(event) {
        for(let edits in event.detail) {
            this[edits] = event.detail[edits];
        }
    }

    editAddress() {
        this.addressEditing = true;
        this.prodIdentEditing = false;
        this.prodIssueEditing = false;
        this.imgUploadEditing = false;
    }

    editProdIdent() {
        this.addressEditing = false;
        this.prodIdentEditing = true;
        this.prodIssueEditing = false;
        this.imgUploadEditing = false;
    }

    editProdIssue() {
        this.addressEditing = false;
        this.prodIdentEditing = false;
        this.prodIssueEditing = true;
        this.imgUploadEditing = false;
    }

    editImgUpload() {
        this.addressEditing = false;
        this.prodIdentEditing = false;
        this.prodIssueEditing = false;
        this.imgUploadEditing = true;
    }

    save(event) {
        this.caseObj = event.detail.case;
        this[event.detail.editing]();
    }

    saveAll(event) {
        this.loading = true;
        let images = event.detail.images;
        this.caseObj.images = images.filter((item) => (!!item.image));
        saveCase({
            'caseObj' : this.caseObj
        })
        .then((result) => {
            if(result.success) {
                // Extrair caseNumber do mapa values
                const caseNumber = result.values.caseNumber;
                console.log ('Case Number: ' + caseNumber);
                this[NavigationMixin.Navigate]({
                    type: 'comm__namedPage',
                    attributes: {
                        name: 'caseConfirmation__c'
                    },
                    state: {
                        // Passando caseNumber como um parâmetro de estado para a página de confirmação
                        caseNumber: caseNumber
                    }
                });
            } else {
                console.log(result.message);
                this.sendToast('Error', result.message, 'error');
            }
        })
        .catch((error) => {
            this.sendToast('Error', error.body.message, 'error');
        })
        .finally(() => {
            this.loading = false;
        });
    }

    dispatch(event) {
        this.modalTitle = event.detail.modalTitle;
        this.modalContent = event.detail.modalContent;
        this.modalImage = event.detail.modalImage;
        this.showModal = true;
    }

    closeCaseModal() {
        this.modalTitle = '';
        this.modalContent = '';
        this.modalImage = '';
        this.showModal = false;
    }

    showToast(event) {
        this.sendToast(event.detail.title, event.detail.message, event.detail.type);
    }

    sendToast(title, message, type) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: type
        });
        this.dispatchEvent(evt);
    }
}