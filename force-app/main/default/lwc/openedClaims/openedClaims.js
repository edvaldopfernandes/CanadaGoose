import { LightningElement, wire, track, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getLastCase from '@salesforce/apex/CaseController.getLastCase';
import getImageData from '@salesforce/apex/CaseController.getImageData';
import getInspectionResults from '@salesforce/apex/CaseController.getInspectionResults';
import IMAGES from "@salesforce/resourceUrl/ResourcesComponents";
import labels from './customLabels.js';

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

export default class OpenedClaims extends NavigationMixin(LightningElement) {

    labels = labels;
    
    // Variables for the images
    imageClaims = IMAGES + '/openedClaims/ImageClaims.png';
    @track imageData;
    @track imageId;

    // Variables for the wire services
    lastCase;
    @api caseId;
    inspectionResults;

    // Variables for control the visibility of the page
    noClaim;
    claimExist;
    claimPendingPayment;
    payNowbutton;

    /**
    * Returns the date the case was created in a formatted string
    */
    get caseCreatedDate() {
        let createdDate = new Date(this.lastCase[0].CreatedDate);
        return `${MONTHS[createdDate.getMonth()]} ${createdDate.getDate()}, ${createdDate.getFullYear()}`;
    }

    /**
    * Retrieves the last case from the server
    */
	@wire(getLastCase)
    wiredLastCase({ error, data }) {
        if (data) {
            this.noClaim = data.length === 0;
            if (data.length > 0) {
                this.claimExist = true;
                this.claimPendingPayment = false;
                this.lastCase = data.map(caseItem => ({
                    ...caseItem,
                    statusDescription: this.getStatusDescription(caseItem.Status)
                }));
                this.imageId = this.lastCase[0].Style__r.Id;
                this.caseId = this.lastCase[0].Id;
            }
        } else if (error) {
            console.error('Error:', error);
            this.noClaim = true;
            this.claimExist = false;
            this.claimPendingPayment = false; // Garante que é resetado em caso de erro
        }
    }

    /**
    * Retrieves the image data from the server
    */
    @wire(getImageData, { recordId: '$imageId' })
    wiredImageData({ error, data }) {
        if (data) {
            this.imageData = 'data:image/png;base64,' + data;
        } else if (error) {
            console.error('Error retrieving image data:', error);
        }
    }

    /**
    * Wire adapter for getting the inspection results
    */
    @wire(getInspectionResults, { caseId: '$caseId' })
    wiredInspectionResults({ error, data }) {
        if (data) {
            this.inspectionResults = data;
            if (data.length > 0) {
                this.claimPendingPayment = true;
                this.claimExist = false;
            } 
        } else if (error) {
            console.error(error);
        }
    }

    /**
    * Calculates the total payment from the inspection results
    */
    get calculateTotalPayment() {
        if (this.inspectionResults) {
            let total = 0;
            this.inspectionResults.forEach(result => {
                total += result.Display_Price__c;
            });
            if (total === 0) {
                this.payNowbutton = false;
            } else {
                this.payNowbutton = true;
            }
            return total;
        }
        return 0;
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

    /**
    * Navigates to the Case History page
    */
    navigateToCaseHistory() {
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Case',
                actionName: 'list'
            }
        });
    }
}