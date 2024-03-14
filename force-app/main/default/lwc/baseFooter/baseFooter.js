import { LightningElement, track, api } from 'lwc';
import IMAGES from "@salesforce/resourceUrl/ResourcesComponents";

export default class BaseFooter extends LightningElement {
    @track didNotAgreeToSignUp = true;

    // Setting the icons
    facebookIcon = IMAGES + '/baseFooter/FacebookIcon.svg';
    twitterIcon = IMAGES + '/baseFooter/TwitterIcon.svg';
    instagramIcon = IMAGES + '/baseFooter/InstagramIcon.svg';
    youtubeIcon = IMAGES + '/baseFooter/YoutubeIcon.svg';
    companyIcon = IMAGES + '/baseFooter/CompanyIcon.svg';
    arrowStoreIcon = IMAGES + '/baseFooter/ArrowStoreIcon.svg';
    arrowEmailIcon = IMAGES + '/baseFooter/ArrowEmailIcon.svg';
    redirectIcon = IMAGES + '/baseFooter/RedirectIcon.svg';
    imageStore = IMAGES + '/baseFooter/ImageStore.png';

    // Setting the links
    @api linkFindStore = 'https://www.canadagoose.com/ca/en/find-a-retailer/find-a-retailer.html';
    @api linkContactUs = 'https://www.canadagoose.com/ca/en/customer-care/cs-landing.html';
    @api linkFAQs = 'https://www.canadagoose.com/ca/en/faq/faq.html';
    @api linkGetUsInbox = 'https://www.canadagoose.com/ca/en/email-signup#basecamp-signup-form';
    @api linkFacebook = 'https://www.facebook.com/canadagoose/';
    @api linkTwitter = 'https://twitter.com/canadagoose';
    @api linkInstagram = 'https://www.instagram.com/canadagoose/';
    @api linkYoutube = 'https://www.youtube.com/user/CanadaGooseInc';
    @api linkAccessibility = 'https://www.canadagoose.com/ca/en/accessibility/accessibility.html';
    @api linkPrivacyPolicy = 'https://www.canadagoose.com/ca/en/privacy-policy/privacy-policy.html';
    @api linkTermsConditions = 'https://www.canadagoose.com/ca/en/terms-and-conditions/legal.html';
}