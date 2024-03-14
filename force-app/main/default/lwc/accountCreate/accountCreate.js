import { LightningElement,track,wire,api } from 'lwc';
import insertAccountMethod from '@salesforce/apex/AccountCreate.insertAccountMethod';
import accFirstName from '@salesforce/schema/Account.FirstName';
import accLastName from '@salesforce/schema/Account.LastName';
import accPhone from '@salesforce/schema/Account.PersonMobilePhone';
import accEmail from '@salesforce/schema/Account.PersonEmail';
import accPersonMailingStreet from '@salesforce/schema/Account.PersonMailingStreet';
import accPersonMailingCity from '@salesforce/schema/Account.PersonMailingCity';
import accPersonMailingCountry from '@salesforce/schema/Account.PersonMailingCountry';
import accPersonMailingState from '@salesforce/schema/Account.PersonMailingState'; 
import accPersonMailingPostalCode from '@salesforce/schema/Account.PersonMailingPostalCode'; 
//import accLanguage from '@salesforce/schema/Account.Language__c';
//import conAddToEmailList from '@salesforce/schema/Contact.B2C_Add_To_Email_List__c';

import { CloseActionScreenEvent } from 'lightning/actions';

import {ShowToastEvent} from 'lightning/platformShowToastEvent';

export default class AccountCreate extends LightningElement {
@track accountid;
@api contactId;
@track error;
@track getAccountRecord={
FirstName:accFirstName,
LastName:accLastName,
PersonMobilePhone:accPhone,
PersonEmail:accEmail,
PersonMailingStreet:accPersonMailingStreet,
PersonMailingCity:accPersonMailingCity,
PersonMailingCountry:accPersonMailingCountry,
PersonMailingState:accPersonMailingState,
PersonMailingPostalCode:accPersonMailingPostalCode
//Language__c:accLanguage
//B2C_Add_To_Email_List__c:conAddToEmailList
};

firstNameInpChange(event){
this.getAccountRecord.FirstName = event.target.value;
//window.console.log(this.getAccountRecord.FirstName);
}
lastNameInpChange(event){
this.getAccountRecord.LastName = event.target.value;
//window.console.log(this.getAccountRecord.LastName);
}

phoneInpChange(event){
this.getAccountRecord.PersonMobilePhone = event.target.value;
//window.console.log(this.getAccountRecord.PersonMobilePhone);
}

emailInpChange(event){
this.getAccountRecord.PersonEmail = event.target.value;
//window.console.log(this.getAccountRecord.PersonEmail);
}

streetInpChange(event){
this.getAccountRecord.PersonMailingStreet = event.target.value;
//window.console.log(this.getAccountRecord.PersonMailingStreet);
}

cityInpChange(event){
this.getAccountRecord.PersonMailingCity = event.target.value;
//window.console.log(this.getAccountRecord.PersonMailingCity);
}

countryInpChange(event){
this.getAccountRecord.PersonMailingCountry = event.target.value;
//window.console.log(this.getAccountRecord.PersonMailingCountry);
}
postalCodeInpChange(event){
this.getAccountRecord.PersonMailingPostalCode = event.target.value;
//window.console.log(this.getAccountRecord.PersonMailingPostalCode);
}
stateInpChange(event){
this.getAccountRecord.PersonMailingState = event.target.value;
//window.console.log(this.getAccountRecord.PersonMailingState);
}
/*languageInpChange(event){
this.getAccountRecord.Language__c = event.target.value;
//window.console.log(this.getAccountRecord.Language__c); 
}*/
handleCheckboxChange(event){
    const fieldvalue = event.target.value;

}

 closeAction() {
        this.isModalOpen = false;
        this.dispatchEvent(new CloseActionScreenEvent({ bubbles: true, composed: true }));
    }
saveAccountAction(){
window.console.log('before save' + this.createAccount);
insertAccountMethod({accountObj:this.getAccountRecord})
.then(result=>{
window.console.log(this.createAccount);
this.getAccountRecord={};
this.accountid=result.Id;
window.console.log('after save' + this.accountid);

const toastEvent = new ShowToastEvent({
title:'Success!',
message:'Account created successfully',
variant:'success'
});
this.dispatchEvent(toastEvent);
})
.catch(error=>{
this.error=error.message;
window.console.log(this.error);
});
}
}