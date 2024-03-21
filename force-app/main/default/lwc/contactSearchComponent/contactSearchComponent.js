import { LightningElement,track, wire, api } from 'lwc';
import searchByEmail from '@salesforce/apex/ContactSearchController.searchByEmail';
import COMPANY_LOGO from '@salesforce/resourceUrl/companyName';

const columns = [
        { label: 'FirstName', fieldName: 'FirstName', type: 'text' },
        { label: 'LastName', fieldName: 'LastName', type: 'text' },
        { label: 'Email', fieldName: 'Email', type: 'email' },
    ];
export default class ContactSearchComponent extends LightningElement {
    @track searchEmail = '';
    @track contacts =[];
    @track data = [];
    @track error;
    @track isData = false;
    @track showModal = false;
    @track searchPerformed = false;
    @track noContactsFound = false;
    columns = columns;
    headerImageUrl = COMPANY_LOGO;

    get myheader(){
        return 'background-image: url(${this.headerImageUrl});';
    }
    handleEmailChange(event) {
        this.searchEmail = event.target.value;
        this.searchPerformed = false;
        this.noContactsFound = false;
        this.handleSearch();        
    }
    @wire(searchByEmail,{email:'$searchEmail'}) 
        wiredContacts(result){
            this.data = result;
            if(result.data){
                this.contacts = result.data
            }
            else if(result.error){
                console.log('Error in searching the data', error)
           }
           this.searchPerformed = true;
        }
    handleSearch() {
        searchByEmail({ email: this.searchEmail })
            .then(result => {

                console.log('>>>>>result',result);
                this.isData = result != null ? true:false;
                this.contacts = result;
                this.error = undefined;
                this.searchPerformed = true;
                this.isData = Array.isArray(result) && result.length > 0;
                this.noContactsFound = !this.isData;
            })
            .catch(error => {
                this.error = error;
                this.contacts = undefined;
                this.isData = false;
                this.noContactsFound = false; // to ensure it is reset in case of an error
                this.searchPerformed = true;
            });
    }

    handleClick() {
        // Custom event to trigger account creation
        console.log('In handleClick>>>');
        this.showModal = true;
    }

    handleCreateAccount(){
        console.log('In handleCreateAccount>>>');
        this.showModal = true;
    }
    saveAccount(){
        this.showModal = false;
    }

    closeModal(){
        this.showModal = false;
    }
    get disableCreatAccountButton(){
        return !(this.noContactsFound && this.searchPerformed);
    }
}