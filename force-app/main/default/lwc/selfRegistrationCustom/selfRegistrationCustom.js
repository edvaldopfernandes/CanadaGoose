import { LightningElement, wire } from 'lwc';
import LABELS from './customLabels.js';
import { getPicklistValues } from "lightning/uiObjectInfoApi";

export default class SelfRegistrationCustom extends LightningElement {

    labels = LABELS;
    countries;
    states;
    countryByNumberMap = {};
    numberByStatesMap = {};
    selectedCountry;
    selectedState;

    @wire(getPicklistValues, { recordTypeId: "012000000000000AAA", fieldApiName: 'Account.BillingCountryCode' })
    picklistCountryResults({data, error}){
        if(data){

            // get countries list to display in picklist
            let countries = [];
            data.values.forEach(element => {
                countries.push(element);
            });
            this.countries = countries;

        }
        else{
            console.log(error);
        }
    }

    @wire(getPicklistValues, { recordTypeId: "012000000000000AAA", fieldApiName: 'Account.BillingStateCode' })
    picklistStateResults({data, error}){
        if(data){

            // build map to get country number by country name
            this.countryByNumberMap = data.controllerValues;

            let states  = []
            let numberByStatesMap = new Map();

            // get all states and build a map of states by country number
            data.values.forEach(element => {
                if(numberByStatesMap.has(element.validFor[0])){
                    numberByStatesMap.get(element.validFor[0]).push({label: element.label, value: element.value});
                }
                else{
                    states = [];
                    states.push({label: element.label, value: element.value});
                    numberByStatesMap.set(element.validFor[0], states);
                }
            });

            this.numberByStatesMap = numberByStatesMap;

        }
        else{
            console.log(error);
        }
    }

    handleState(event){
        this.selectedState = event.detail.value;
    } 
    
    handleCountry(event){
        console.log(event)
        this.selectedCountry = event.detail.value;
        let number = this.countryByNumberMap[this.selectedCountry];
        this.states = this.numberByStatesMap.get(number);
    }
    
}