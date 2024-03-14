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
    labels = labels;

    /**
    * Wire adapter getOpenCases to get the list of open cases
    */
    @wire(getOpenCases)
    wiredCases({ error, data }) {
        if (data && data.length > 0) {
            this.casesExist = true;
            // if one of the cases has the Style__r field empty, it will throw an error
            // filtering out the cases that don't have the Style__r field
            data = data.filter(caseItem => {
                return caseItem.Style__r;
            });
            this.cases = this.formatCases(data);
            this.originalCases = this.cases;
        } else if (data && data.length === 0) {
            this.casesExist = false;
        } else if (error) {
            console.error(error);
        }
    }

    /**
    * Formats the case data to include the formatted date
    */
    formatCases(data) {
        return data.map(caseItem => {
            let createdDate = new Date(caseItem.CreatedDate);
            let formattedDate = `${MONTHS[createdDate.getMonth()]} ${createdDate.getDate()}, ${createdDate.getFullYear()}`;
            return { ...caseItem, CreatedDate: formattedDate };
        });
    }

    /**
    * Handles the search event and filters the cases list
    */
    handleSearch(event) {
        console.log(event);
        const searchKey = event.target.value.toLowerCase();
        if (searchKey) {
            const filteredCases = this.cases.filter(caseItem => {
                return caseItem.CaseNumber.toLowerCase().includes(searchKey) ||
                       caseItem.Style__r.Name.toLowerCase().includes(searchKey) ||
                       caseItem.Status.toLowerCase().includes(searchKey);
            });
            this.cases = filteredCases;
        } else {
            // Reset the list to show all cases
            this.cases = this.originalCases;
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