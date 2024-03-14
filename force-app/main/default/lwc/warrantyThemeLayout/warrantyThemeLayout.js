import { LightningElement } from 'lwc';
import isGuestUser from '@salesforce/user/isGuest';
import formFactor from "@salesforce/client/formFactor";

/**
 * @slot header This is the header slot
 * @slot navMenu This is the Navigation Menu slot
 * @slot logo This is the Logo slot
 * @slot languageSelector This is the Language Selector slot
 * @slot footer This is the footer slot
 * @slot default This is the default slot
 */
export default class WarrantyThemeLayout extends LightningElement {

    get isDesktop() {
        return (formFactor === "Large");
    }

    get logoClass() {
        return `logo ${this.isDesktop ? 'desktop-logo' : 'mobile-logo'}`;
    }

    get isGuest() {
        return isGuestUser;
    }

}