import { LightningElement, api, track, wire } from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import {getRecord, getFieldValue} from 'lightning/uiRecordApi';
import updateAccountData from '@salesforce/apex/subscribeMeController.updateAccountData';
import getCountryData from '@salesforce/apex/subscribeMeController.getMetaData';
import { FlowNavigationFinishEvent } from 'lightning/flowSupport';
export default class Subscribechildcomponent extends LightningElement {
    @api accountRecord;
     @api recordId;
    _recordId;
    @track selectedLang;
    @track countryCode;
    @track isSubscribe;
    @track mobile = '0000000000';
    @track countries = [];
    @track languages = [];
    countryMap = [];

    async connectedCallback(){        
        console.log('this.recordId>>>'+ this.recordId, '>>>>>',JSON.stringify(this.accountRecord));
        this._recordId = this.accountRecord.Id;
        //this._recordId = this.recordId
        this.selectedLang = this.accountRecord.Preferred_Lang__pc;
        this.isSubscribe = this.accountRecord.B2C_Add_To_Email_List__pc;
        this.countryCode = this.accountRecord.Marketing_Country_Code__pc;
        if(this.accountRecord.PersonMobilePhone != null || this.accountRecord.PersonMobilePhone != undefined){
            this.mobile = this.accountRecord.PersonMobilePhone;
        }

        console.log('mobile?????',this.mobile);
        await this.getMetadata();
        await this.getRecord();
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

    async getRecord(){                
        if(this.countryCode != undefined || this.countryCode != null || this.countryCode != '' ){
            let result = this.countryMap.filter((country) => country.label === this.countryCode );
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

    getShowToastEvent(title, message, variant){
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant
            })
        );
    }
    closeHandler(event){        
        this.dispatchEvent(new FlowNavigationFinishEvent());         
    }

    handleCountryChange(event){
        console.log('handleCountryChange ',event.target.value);
        this.countryCode = event.target.value;
        this.languages = [];
        this.selectedLang = '';
        if(this.countryCode != undefined || this.countryCode != null || this.countryCode != '' ){
            let result = this.countryMap.filter((country) => country.label === this.countryCode );
            console.log('<<<<result>>>>>',result[0].value);
            let langArr = result[0].value.split(',');
            if(langArr.length > 0){
                for(let elem of langArr){
                    this.languages.push({label:elem, value:elem});
                }
            }
            console.log('this.selectedLang>>>',this.selectedLang);
            console.log('<<<<this.languages on load>>>>>',JSON.stringify(this.languages));
        }
    }

    onSubscribeChange(event){
        this.isSubscribe = event.target.checked;
        console.log('>>>>onSubscribeChange>>>',this.isSubscribe);
    }

    handleLanguageChange(event){
        this.selectedLang = event.target.value;
        console.log('>>>>language>>>',this.selectedLang);
    }
    handleMobile(event){
        this.mobile = event.target.value;
        console.log('>>>>Mobile Number>>>',this.mobile);
    }

    async handleUpdate(){
        console.log('>>>code>>',this.countryCode,
                    '>>>>lang>>>',this.selectedLang,
                    '>>> this.isSubscribe >>',this.isSubscribe,
                    '>>>type of ',typeof this.isSubscribe,
                    '>>>mobile>>>', this.mobile);
        if((this.countryCode == undefined || this.countryCode == null || this.countryCode == '') 
        || (this.selectedLang == undefined || this.selectedLang == null || this.selectedLang == '')
        || (this.mobile == null || this.mobile == undefined  || this.mobile == '')){
            this.getShowToastEvent('Error','Please fill up the all the mandatory fields','error');  
            return;
        }
        else{
            updateAccountData({ recordId: this._recordId, 
                                isSubscribed : this.isSubscribe, 
                                countryCode : this.countryCode, 
                                language : this.selectedLang,
                                mobile : this.mobile}).then(response=>{
                if(response){
                    console.log('response >>>'+ JSON.stringify(response));                    
                    this.getShowToastEvent('Success','We are good to go ahead','success');                  
                    return;
                }
            })             
        }
        this.dispatchEvent(new FlowNavigationFinishEvent());         
    }

}