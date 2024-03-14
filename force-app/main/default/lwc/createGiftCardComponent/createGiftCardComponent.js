import { LightningElement, api, track, wire } from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import CHANNEL_FIELD from '@salesforce/schema/GWG_Gift_Card__c.Channel__c';
import BUSINESS_UNIT_FIELD from '@salesforce/schema/GWG_Gift_Card__c.Business_Unit__c';
import REASON_FIELD from '@salesforce/schema/GWG_Gift_Card__c.Reason__c';
import GWG_Country_Field from '@salesforce/schema/GWG_Gift_Card__c.GWG_Country__c';
import {getObjectInfo} from 'lightning/uiObjectInfoApi';
import GIFT_CARD_OBJECT from '@salesforce/schema/GWG_Gift_Card__c';
import createGiftCard from '@salesforce/apex/GWGGiftCardController.createGiftCard';
/*import getAccRecord from '@salesforce/apex/GWGGiftCardController.getAccountLanguage';*/

export default class CreateGiftCardComponent extends LightningElement {
    @api recordId;
    @track channel;
    @track channelOptions = [];
    @track businessunit;
    @track buOptions = [];
    @track cardValue = 0;
    @track reason;
    @track reasonOptions = [];
    @track language;
    @track langOptions = [];
    @track accCountry;
    @track GWGCountry;
    @track GWGCountryOptions = [];
    @track reasonDesc;
    isLoaded = false;
    giftcardId;
   

    @wire(getObjectInfo, {objectApiName: GIFT_CARD_OBJECT})
    giftObjectInfo;
    @wire( getPicklistValues, { recordTypeId: '$giftObjectInfo.data.defaultRecordTypeId', fieldApiName: CHANNEL_FIELD} )
    wiredData( { error, data } ) {
        if (data) { console.log('>>>> data.values>>>',data.values);
            this.channelOptions = data.values.map( objPL => {
                return { label: `${objPL.label}`,  value: `${objPL.value}`};
            });
           }
    }
    @wire( getPicklistValues, { recordTypeId: '$giftObjectInfo.data.defaultRecordTypeId', fieldApiName: BUSINESS_UNIT_FIELD} )
    buData( { error, data } ) {
        if (data) { console.log('>>>> bu data.values>>>',data.values);
            this.buDataInfo = data;
            this.buOptions = data.values.map( objPL => {
                return { label: `${objPL.label}`,  value: `${objPL.value}`};
            });
           }
    }
    @wire( getPicklistValues, { recordTypeId: '$giftObjectInfo.data.defaultRecordTypeId', fieldApiName: GWG_Country_Field} )
    GWGCountryData( { error, data } ) {
        if (data) { console.log('>>>> GWGCountryData data.values>>>',data.values);
            this.GWGCountryOptions = data.values.map( objPL => {
                return { label: `${objPL.label}`,  value: `${objPL.value}`};
            });
           }
    }
    @wire( getPicklistValues, { recordTypeId: '$giftObjectInfo.data.defaultRecordTypeId', fieldApiName: REASON_FIELD} )
    reasonData( { error, data } ) {
        if (data) { console.log('>>>> reason data.values>>>',data.values);
            this.reasonDataInfo = data;
            this.reasonOptions = data.values.map( objPL => {
                return { label: `${objPL.label}`,  value: `${objPL.value}`};
            });
           }
    }
    handleBuChange(event){
        console.log('>>>this.buDataInfo>>',JSON.stringify(this.reasonDataInfo));
        let key = this.reasonDataInfo.controllerValues[event.target.value];
        console.log('>>>key>>',key);
        this.reasonOptions = this.reasonDataInfo.values.filter(opt => opt.validFor.includes(key));
    }
    connectedCallback(){
        console.log('this.recordId>>>'+ this.recordId);
        /*this.fetchAccRecord();
        console.log('this.language >>>>',this.language);
        console.log('this.accCountry >>>>',this.accCountry);*/
      
    }
    changeHandler(event){
        let countryVal = event.target.value;
        console.log('country selected in handler', countryVal);
        if(countryVal &&  countryVal != 'undefined'){
            this.langOptions =[];
            if(countryVal ==='Canada' || countryVal ==='France' || countryVal ==='Belgium' || countryVal ==='Luxembourg'){
                this.langOptions.push({label: 'en_US',  value: 'en_US'});
                this.langOptions.push({label: 'fr',  value: 'fr'});
            }
            else if(countryVal ==='United States' || countryVal ==='United Kingdom' || countryVal ==='Ireland' || countryVal ==='Netherlands' ){
                this.langOptions.push({label: 'en_US',  value: 'en_US'});
            }
            else if(countryVal ==='Austria' || countryVal ==='Germany'){
                this.langOptions.push({label: 'en_US',  value: 'en_US'});
                this.langOptions.push({label: 'de',  value: 'de'});
            }
            else if(countryVal ==='Italy'){
                this.langOptions.push({label: 'en_US',  value: 'en_US'});
                this.langOptions.push({label: 'it',  value: 'it'});
            }
        }
        
    }
    handleInsert(event){
        this.cardValue = parseFloat(this.refs.valueref.value);
        this.channel = this.refs.channelref.value;
        this.businessunit = this.refs.buref.value;
        this.reason= this.refs.reasonref.value;
        this.GWG_Country = this.refs.GWGCountref.value;
        let desc =this.refs.reasonDesc.value;
        desc = desc.trim();
        this.reasonDesc = desc;
        console.log('country selected', this.GWGCountry);
        this.language = this.refs.langref.value;
        if((isNaN(this.cardValue) || this.cardValue === 0  || this.cardValue === null) ||
           (this.channel === '' ||  this.channel === undefined) ||
           ( this.businessunit === '' || this.businessunit === undefined ) || 
           ( this.reason === '' || this.reason === undefined) ||
           (this.language === '' || this.language == undefined)||
           (this.GWG_Country === '' || this.GWG_Country == undefined) ||
           (this.reasonDesc === '' || this.reasonDesc == undefined))
           {
            this.getShowToastEvent('Error','Please fill up the all the mandatory fields','error');  
            return;
        }
        else if(this.cardValue >3000){
            this.getShowToastEvent('Error','Gift Card Value Can not exceed 3000','error');  
            return;
        }
        else if(this.cardValue <50){
            this.getShowToastEvent('Error','Gift Card Value Can not be below 50','error');  
            return;
        }
        else{
            createGiftCard({recordId : this.recordId, channel : this.channel, 
                            businessUnit : this.businessunit, reason : this.reason, total : this.cardValue,
                             lang : this.language, GWGCountryValue: this.GWG_Country,
                             reasonDesc : this.reasonDesc})
            .then(result=>{
                this.giftcardId = result
            }).catch(error=>{
                console.error('>>>>>><<<< error',error);
            })
             this.getShowToastEvent('Success',`Gift Card record created successfully`,'success');
             this.cancelHandler();  
            return;
        }
    }

    /*fetchAccRecord(){
        getAccRecord({accId : this.recordId}).then(data =>{
            console.log('data>>>>>',data.ShippingCountry);
            this.language = data.Language__c;
            this.accCountry = data.ShippingCountry;
        }).catch(error =>{
            console.error('???????? error',error);
        });
    } */
    getShowToastEvent(title, message, variant){
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant
            })
        );
    }
    closeHandler(){
        const myEvent =new CustomEvent('close',{detail:`Gift Card Created Successfully, Please find the ${this.giftcardId} to see the detail record`});
        this.dispatchEvent(myEvent);
    }

    cancelHandler(){
        const cancelEvent = new CustomEvent('cancel',{detail:'Cancelled Successfully'});
        this.dispatchEvent(cancelEvent);
    }
}