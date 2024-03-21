import { LightningElement, api, track, wire } from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import createAccount from '@salesforce/apex/ContactSearchController.createAccount';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import {getRecord, getFieldValue} from 'lightning/uiRecordApi';
import getCountryData from '@salesforce/apex/subscribeMeController.getMetaData';
import SHIPSTATE from "@salesforce/schema/Account.shippingState";
import COMPANY_LOGO from '@salesforce/resourceUrl/companyName';

export default class CgModalAccount extends LightningElement {

    @track mobile;
    @track firstName;
    @track lastName;
    @track language;
    @track email;
    @track consent;
    @track street;
    @track city;
    @track state;
    @track country;
    @track postalcode;
    @track shippingAdd = false;
    @track accountRecord;
    @track error;
    @track isLoading = false;
    @track countries = [];
    @track languages = [];
    shippingStates = [];
    headerImageUrl = COMPANY_LOGO;

    get myheader(){
        return 'background-image: url(${this.headerImageUrl});';
    }
    
    countryMap = []
     @wire(getPicklistValues, { recordTypeId: "012000000000000AAA", fieldApiName: SHIPSTATE })
        picklistResults({ error, data }) {
            if (data) {
                this.shippingStates = data.values;
                this.error = undefined;
            } else if (error) {
                this.error = error;
                this.shippingStates = undefined;
            }
        }
        
    async connectedCallback(){
        await this.getMetadata();
        console.log('this.country>>>',this.countries);
         console.log('this.countryMap>>>',this.countryMap);
           console.log('this.languages>>>',this.languages);
    }
    handleSave(event){
        this.isLoading = true;
        this.mobile = parseFloat(this.refs.mobileRef.value);
        this.firstName = this.refs.firstNameRef.value;
        this.lastName = this.refs.lastNameRef.value;
        this.email= this.refs.emailRef.value; 
        this.language= this.refs.languageRef.value;
        this.consent= this.refs.consentRef.value;
        this.street= this.refs.streetRef.value;
        this.city= this.refs.cityRef.value;
        this.state= this.refs.stateRef.value;
        this.country= this.refs.countryRef.value;
        this.postalcode= this.refs.shippostalcodeRef.value;
        this.shippingAdd= this.refs.shippingAddRef.value;
        this.shipstreet= this.refs.shipstreetRef.value;
        this.shipcity= this.refs.shipcityRef.value;
        this.shipstate= this.refs.shipstateRef.value;
        this.shipcountry= this.refs.shipcountryRef.value;
        this.shippostalcode= this.refs.shippostalcodeRef.value;

        if((isNaN(this.mobile) || this.mobile === 0  || this.mobile === null) ||
           (this.firstName === '' ||  this.firstName === undefined) ||
           ( this.lastName === '' || this.lastName === undefined ) || 
           ( this.email === '' || this.email === undefined))
           {
            this.isLoading = false;
            this.getShowToastEvent('Error','Please fill up the all the mandatory fields','error');  
            return;
        }
        else{
            createAccount({email : this.email, firstName : this.firstName, 
                           lastName : this.lastName, mobile : this.mobile, language : this.language,
                           consent : this.consent, street : this.street, city : this.city, state : this.state,
                           country : this.country, postalcode : this.postalcode, shippingAdd : this.shippingAdd,
                           shipstreet : this.shipstreet, shipcity : this.shipcity, shipstate : this.shipstate, shipcountry : this.shipcountry, 
                           shippostalcode : this.shippostalcode })
            .then(result=>{
                this.accountRecord = result;
                 
            }).catch(error=>{
                console.error('>>>>>><<<< error',error);
                this.error = error;
            })
             this.isLoading = false;
             this.getShowToastEvent('Success',`Account created successfully`,'success');
             this.dispatchEvent(new CustomEvent("saveaccount"));
            return;
        }
    }
    async getMetadata(){
        const data = await getCountryData();
        if (data) {
            this.countries = data.map(item => ({
                label: item.Country__c,
                value: item.Country_Code__c
            }));

            this.countryMap = data.map(item => ({
                label: item.Country_Code__c,
                value: item.Languages__c
            }));
        } else if (error) {
            console.error('Error fetching custom metadata records:', error);
        }
    }
    getShowToastEvent(title, message, variant){
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant
            })
        );
    }
    setNullValue(event){
        this.error = null;
    }
    closeModal(){
        this.dispatchEvent(new CustomEvent("closemodal"));
    }
    handleFirstName(event) {
        console.log('Change is done :'+ event.detail.value);
        this.firstName=event.detail.value;
    }
    handleLastName(event) {
        console.log('Change is done :'+ event.detail.value);
        this.lastName=event.detail.value;
    }
    handleMobile(event) {
        console.log('Change is done :'+ event.detail.value);
        this.mobile=event.detail.value;
    }
    handleLanguage(event) {
        console.log('Change is done :'+ event.detail.value);
        this.language=event.detail.value;
    }
    handleEmail(event) {
        console.log('Change is done :'+ event.detail.value);
        this.email=event.detail.value;
    }
    handleConsent(event) {
        console.log('Change is done :'+ event.detail.checked);
        this.consent=event.detail.checked;
    }
    handleStreet(event){
        console.log('Change is done :'+ event.detail.value);
        this.street=event.detail.value;
    }
    handleCity(event){
        console.log('Change is done :'+ event.detail.value);
        this.city=event.detail.value;
    }
    handleState(event){
        console.log('Change is done :'+ event.detail.value);
        this.state=event.detail.value;
    }
    handleCountry(event){
        console.log('Change is done :'+ event.detail.value);
        this.country=event.detail.value;
         if(this.country != undefined || this.country != null || this.country != '' ){
            let result = this.countryMap.filter((country) => country.label === this.country );
            if(result.length > 0 ){
                let langStr = result[0].value;
                let langArr = [];
                if(langStr.includes(',')){
                    langArr = langStr.split(',');
                }else{
                    langArr.push(langStr);
                }
                let languages= [];
                if(langArr.length > 0){
                    for(let elem of langArr){
                        languages.push({label:elem.trim(), value:elem.trim()});
                    }
                }
                this.languages = languages;
            }
        }
        
    }
    handlePostalCode(event){
        console.log('Change is done :'+ event.detail.value);
        this.postalcode=event.detail.value;
    }
    handleshippingAdd(event){
        console.log('handleshippingAdd>>'+ event.detail.checked);
        this.shippingAdd=event.detail.checked;
        /*if (shippingAdd.value == true){
            this.ShippAddRequired = true;
            console.log('Change is done :'+ event.detail.value);
        }
        else {
            this.ShippAddRequired = false;
        }*/
    }
    handleshipStreet(event){
        console.log('Change is done :'+ event.detail.value);
        this.shipstreet=event.detail.value;
    }
    handleshipCity(event){
        console.log('Change is done :'+ event.detail.value);
        this.shipcity=event.detail.value;
    }
    handleshipState(event){
        console.log('Change is done :'+ event.detail.value);
        this.shipstate=event.detail.value;
    }
    handleshipCountry(event){
        console.log('Change is done :'+ event.detail.value);
        this.shipcountry=event.detail.value;
    }
    handleshipPostalCode(event){
        console.log('Change is done :'+ event.detail.value);
        this.shippostalcode=event.detail.value;
    }
}