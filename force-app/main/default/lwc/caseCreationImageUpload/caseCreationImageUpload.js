import { LightningElement, api, track } from 'lwc';
import getImageOpts from '@salesforce/apex/CaseCreationController.getImageUploadValues';
import LABELS from './customLabels.js';

export default class CaseCreationImageUpload extends LightningElement {

    @api editing;
    @api case;
    @track imageOpts = [];
    labels = LABELS;
    lastSelectedImage;

    get disableEdit() {
        return !(this.imageOpts.find((item) => !!(item.image?.filename)));
    }

    get disableContinue() {
        return (this.imageOpts.filter((item) => (item.required && !item.image?.filename)).length > 0);
    }

    connectedCallback() {
        getImageOpts()
        .then((result) => {
            if(result.success) {
                this.imageOpts = result.values;
                this.imageOpts.map((item) => {
                    item.hasHelp = (item.helpInfos.length > 0);
                    return item;
                });
                if(this.case?.images) {
                    this.case.images.map((item) => {
                        let imgOpt = this.imageOpts.find((opt) => opt.developerName == item.developerName);
                        if(imgOpt) {
                            imgOpt.image = item.image;
                        }
                    });
                }
            }
        });
    }

    edit() {
        this.sendEditEvent(false, false, false, true);
    }

    openFileSearch(event) {
        this.lastSelectedImage = event.target.dataset.item;
        this.template.querySelector(`.${this.lastSelectedImage}`).click();
    }

    handleFileUpload(event) {
        const file = event.target.files[0];
        
        if(!file) {
            return;
        }

        const reader = new FileReader();
        
        reader.onload = () => {
            let imgOpt = this.imageOpts.find((item) => item.developerName == this.lastSelectedImage);
            let fileType = file.name.split('.')[1];
            
            if(!imgOpt.fileType.split(',').includes(fileType)) {
                this.dispatchEvent(new CustomEvent('toast', {
                    detail : {
                        'title' : 'Error',
                        'message' : 'This type of file is not accepted for this image',
                        'type' : 'error'
                    }
                }));
                return;
            }
            
            const base64 = reader.result.split(",")[1];
            let obj = { filename: `${this.lastSelectedImage}.${fileType}`, base64: base64 };
            
            imgOpt.image = obj;
        };
        reader.readAsDataURL(file);
    }

    removeImage(event) {
        event.preventDefault();
        let opt = event.target.dataset.item;
        delete this.imageOpts.find((item) => item.developerName == opt).image;
        this.template.querySelector(`.${opt}`).value = null;
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

    openInfo(event) {
        let imageOpt = this.imageOpts.find(item => item.developerName == event.target.dataset.item);
        let modalTitle, modalContent;

        switch (imageOpt.developerName) {
            case 'Canada_Goose_Logo':
                modalTitle = this.labels.imgTitleArcticDisco; 
                modalContent = this.labels.imgSubtitleArcticDisco;
                break;
            case 'Label_Booklet':
                modalTitle = this.labels.imgTitleProductInfoLabel;
                modalContent = this.labels.imgSubtitleProductInfoLabel;
                break;
            case 'Label_Inside_of_Jacket':
                modalTitle = this.labels.imgTitleCenterBackLabel;
                modalContent = this.labels.imgSubtitleCenterBackLabel;
                break;
            case 'Defect_or_Damage':
                modalTitle = this.labels.imgTitleProductConcern; 
                modalContent = this.labels.imgSubtitleProductConcern;
                break;
            default:
                modalTitle = '';
                modalContent = '';
        }

        this.dispatchModal({
            'modalTitle': modalTitle,
            'modalContent': modalContent,
            'modalImage': imageOpt.helpInfos[0].ImageName__c
        });
    }

    dispatchModal(detail) {
        const modalEvent = new CustomEvent('dispatchmodal', { 
            detail: detail
        });
        this.dispatchEvent(modalEvent);
    }

    save() {
        const saveAllEvent = new CustomEvent('saveall', { 
            detail: {
                'images' : this.imageOpts
            }
        });
        this.dispatchEvent(saveAllEvent);
    }
}