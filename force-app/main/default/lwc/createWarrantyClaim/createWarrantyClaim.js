import { LightningElement } from 'lwc';
import IMAGES from "@salesforce/resourceUrl/ResourcesComponents";
import { NavigationMixin } from 'lightning/navigation';
import createClaim from '@salesforce/label/c.CGWCreateWarrantyClaim';
import createClaimText from '@salesforce/label/c.GCWWarrantyClaimText';
import creatClaimButton from '@salesforce/label/c.GCWWarrantyClaimButton';

export default class CreateWarrantyClaim extends NavigationMixin(LightningElement) {
    imageWarranty = IMAGES + '/createWarrantyClaim/CreateWarrantyImage.png';


    labels = {
        'createClaim' : createClaim,
        'createClaimText' : createClaimText,
        'creatClaimButton' : creatClaimButton
    };

    navigateToCaseCreation() {
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'warrantypolicy__c'
            }
        });
    }
}