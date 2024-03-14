import { LightningElement, track } from 'lwc';
import saveAgreement from '@salesforce/apex/WarrantyPolicyController.saveAgreement';
import { NavigationMixin } from 'lightning/navigation';

const STEPS = [
    {step: 1, current: true, class:'breadcrumb-circle breadcrumb-active'},
    {step: 2, current: false, class:'breadcrumb-circle'},
    {step: 3, current: false, class:'breadcrumb-circle'}
];

export default class WarrantyPolicy extends NavigationMixin(LightningElement) {

    loading = false;
    currentStep = 1;
    @track steps = STEPS;

    get isOne() {
        return this.currentStep === 1;
    }

    get isTwo() {
        return this.currentStep === 2;
    }

    get isThree() {
        return this.currentStep === 3;
    }

    connectedCallback() {
        this.configBreadcrumbs();
    }

    proceed() {
        this.currentStep++;
        this.configBreadcrumbs();
    }

    saveInfo(event) {
        this.loading = true;

        saveAgreement({'agreement': event.detail})
        .then(result => {
            if(result.success) {
                this[NavigationMixin.Navigate]({
                    type: 'comm__namedPage',
                    attributes: {
                        name: 'caseCreation__c'
                    }
                });
            } else {
                console.log(result.message);
            }
        })
        .finally(() => {
            this.loading = false;
        });
    }

    configBreadcrumbs() {
        this.steps.map((item) => {
            item.current = (item.step === this.currentStep);
            item.class = ((item.step === this.currentStep) ? 'breadcrumb-circle breadcrumb-active' : 'breadcrumb-circle');
        });
    }
}