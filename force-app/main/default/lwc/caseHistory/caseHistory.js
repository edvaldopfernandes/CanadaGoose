import { LightningElement, wire, track } from 'lwc';
import getOpenCases from '@salesforce/apex/CaseController.getOpenCases';
import IMAGES from "@salesforce/resourceUrl/ResourcesComponents";
import labels from './customLabels.js';
import { NavigationMixin } from 'lightning/navigation';

const MONTHS = {
    0 : 'January',
    1 : 'February',
    2 : 'March',
    3 : 'April',
    4 : 'May',
    5 : 'June',
    6 : 'July',
    7 : 'August',
    8 : 'September',
    9 : 'October',
    10 : 'November',
    11 : 'December'
};

export default class OpenCases extends NavigationMixin(LightningElement) {
    
    arrowHistory = IMAGES + '/caseHistory/ArrowHistory.svg';
    casesExist;
    cases;
    originalCases;
    groupedCases;
    labels = labels;

    connectedCallback() {
        getOpenCases()
        .then(caseMap => {

            if(caseMap && Object.keys(caseMap).length > 0) {
                this.casesExist = true;
                this.groupedCases = Object.keys(caseMap).map(key => ({
                    createdDate: this.formatDate(key),
                    cases: this.filterStyle(caseMap[key])
                }));
                this.originalCases = caseMap;

            } else if (error) {
                this.casesExist = false;
            }
   
        })
        .catch(error => {
            this.casesExist = false;
            console.log(error);
        });
    }

    // if one of the cases has the Style__r field empty, it will throw an error
    // filtering out the cases that don't have the Style__r field
    filterStyle(cases) {
        cases = cases.filter(caseItem => {
            return caseItem.Style__r;
        });
        return cases;
    }

    /**
    * Formats the date and converts it to the user's timezone
    * @param {String} dateString - date string to be formatted
    * @returns {String} formatted date
    */
    formatDate(dateString) {
        // Converting the date string to a Date object
        let date = new Date(dateString); //Added a time to convert to user's timezone

        // Using Intl.DateTimeFormat to format the date
        let options = { year: 'numeric', month: 'long', day: 'numeric', timeZone: 'UTC' };
        let formattedDate = new Intl.DateTimeFormat('en-US', options).format(date);

        return formattedDate;
    }

    /**
    * Handles the search event and filters the cases list
    */
    handleSearch(event) {
        const searchKey = event.detail.value.toLowerCase();
        if(searchKey) {

            let filteredDataMap = {};

            for (let key in this.originalCases) {
                if (this.originalCases.hasOwnProperty(key)) {
                    filteredDataMap[key] = this.originalCases[key].filter(item =>{
                        return item.CaseNumber.toLowerCase().includes(searchKey) || 
                        item.Status.toLowerCase().includes(searchKey) || 
                        item.Style__r.Name.toLowerCase().includes(searchKey);
                    });
                }
            }

            this.groupedCases = Object.keys(filteredDataMap)
            .filter(key => filteredDataMap[key].length > 0) // Filter out keys with empty arrays
            .map(key => ({
                createdDate: this.formatDate(key),
                cases: this.filterStyle(filteredDataMap[key])
            }));
            
        } else {
            // Reset the list to show all cases
            this.groupedCases = Object.keys(this.originalCases).map(key => ({
                createdDate: this.formatDate(key),
                cases: this.filterStyle(this.originalCases[key])
            }));
        }
    }

    /**
    * Navigates to the record page of the selected case
    */
    handleViewCase(event) {
        const currentId = event.currentTarget.dataset.value;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: currentId,
                objectApiName: 'Case',
                actionName: 'view'
            }
        });
    }
}