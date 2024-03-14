import { LightningElement,track, wire } from 'lwc';
import searchByEmail from '@salesforce/apex/ContactSearchController.searchByEmail';

const columns = [
        { label: 'Id', fieldName: 'Id', type: 'text' },
        { label: 'Name', fieldName: 'Name', type: 'text' },
        { label: 'email', fieldName: 'email', type: 'text' },
    ];
export default class ContactSearchComponent extends LightningElement {
    @track searchEmail = '';
    @track contacts =[];
    @track data = [];
    @track error;
    @track isData = false;
    @track showModal = false;
    columns = columns;
    

    handleEmailChange(event) {
        this.searchEmail = event.target.value;
        this.handleSearch();
    }
    @wire(searchByEmail,{email:'$searchEmail'}) wiredContacts(result){
        this.data = result;
        if(result.data){
            this.contacts = result.data
        }
        else if(result.error){
            console.log('Error in searching the data', error)
        }
    }
    handleSearch() {
        searchByEmail({ email: this.searchEmail })
            .then(result => {

                console.log('>>>>>result',result);
                this.isData = result != null ? true:false;
                this.contacts = result;
                this.error = undefined;
            })
            .catch(error => {
                this.error = error;
                this.contacts = undefined;
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
}