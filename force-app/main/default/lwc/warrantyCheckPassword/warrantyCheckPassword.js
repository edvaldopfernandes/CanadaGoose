import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import title from '@salesforce/label/c.CGWCPTitle';
import content from '@salesforce/label/c.CGWCPContent';
import button from '@salesforce/label/c.CGWCPButton';

export default class WarrantyCheckPassword extends NavigationMixin(LightningElement) {

    labels = {
        'title' : title,
        'content' : content,
        'button' : button
    };

    handleResendCode() {
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'Forgot_Password'
            }
        });
    }
}