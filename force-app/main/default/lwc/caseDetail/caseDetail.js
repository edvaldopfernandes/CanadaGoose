import { LightningElement, api } from 'lwc';
import doInit from '@salesforce/apex/CaseDetailController.doInit';
import labels from './customLabels.js';
import basePath from '@salesforce/community/basePath';

const MONTHS = {
    0 : 'January',
    1 : 'February',
    2 : 'March',
    3 : 'April',
    4 : 'May',
    5 : 'June',
    6 : 'July',
    7 : 'August',
    8 : 'September',
    9 : 'October',
    10 : 'November',
    11 : 'December'
};

export default class CaseDetail extends LightningElement {

    @api recordId;
    case;
    image;
    labels = labels;

    get render() {
        return !!(this.case);
    }

    get caseNumber() {
        return this.case.CaseNumber;
    }

    get caseDescription() {
        return this.case.Description;
    }

    get caseCreatedDate() {
        let createdDate = new Date(this.case.CreatedDate);
        return `${MONTHS[createdDate.getMonth()]} ${createdDate.getDate()}, ${createdDate.getFullYear()}`;
    }

    get caseStyle() {
        return (this.case.Style__r ? this.case.Style__r.Name : '');
    }

    get caseStatus() {
        return this.case.Status;
    }

    get imageUrl() {
        return (this.image ? `${basePath}/sfc/servlet.shepherd/version/download/${this.image[0].Id}` : '');
    }

    get isWaitingPayment() {
        return (this.case.Status === 'Pending Payment');
    }

    connectedCallback() {
        doInit({
            'recordId' : this.recordId
        })
        .then((result) => {
            if(result.success) {
                console.log(result.values.case);
                this.case = result.values.case;
                console.log(this.case);
                this.image = result.values.images;
            } else {
                console.log('ERROR -', result.message);
            }
        }).catch(e => {
            console.log('ERROR -', JSON.stringify(e));
        });
    }

    get statusDescription() {
        if (this.case && this.case.Status) {
            return this.getStatusDescription(this.case.Status);
        }
        return '';
    }
    
    get caseStatusTranslated() {
        return this.case ? this.case.statusTranslated : '';
    }

    getStatusDescription(status) {
        console.log('Status:', status);
        switch (status) {
            case 'New_Validate':
                return this.labels.caseUnderReviewDesc;
            case 'Waiting On Product':
                return this.labels.caseShipProductDesc;
            case 'Received':
                return this.labels.casePackageReceivedDesc;
            case 'Cleaning':
                return this.labels.caseItemCleaningDesc;
            case 'Inspecting':
                return this.labels.caseInspectionDesc;
            case 'Pending Payment':
                return this.labels.casePaymentReqDesc;
            case 'Work In Progress':
                return this.labels.caseInRepairDesc;
            case 'Ready for Shipping':
                return this.labels.caseReadyToShipDesc;
            case 'Gift Card Confirmed':
                return this.labels.caseClosedGiftCardDesc;
            case 'Closed - Denied':
                return this.labels.caseClosedRTCDesc;
            default:
                return '';
        }
    }
}