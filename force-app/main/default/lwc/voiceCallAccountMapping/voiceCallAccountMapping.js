import { LightningElement, wire,api} from 'lwc';
import findPersonAccRecord from'@salesforce/apex/VoiceCallAccountMappingController.findPersonAccRecord';
import createNewPersonAccountandLink from'@salesforce/apex/VoiceCallAccountMappingController.createNewPersonAccountandLink';
import searchByPersonEmail from'@salesforce/apex/VoiceCallAccountMappingController.searchByPersonEmail';



import { updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


import {notifyRecordUpdateAvailable } from 'lightning/uiRecordApi';




import ID_FIELD from '@salesforce/schema/VoiceCall.Id';
import RELATED_PA from '@salesforce/schema/VoiceCall.Related_Person_Account__c';

const COLS = [
    {
        label: 'First Name',
        fieldName: 'FirstName',
        editable: false
    },
    {
        label: 'Last Name',
        fieldName: 'LastName',
        editable: false
    },    
    {
        label: 'Phone',
        fieldName: 'PersonMobilePhone',
        type: 'phone',
        editable: false
    },
    {
        label: 'Email',
        fieldName: 'PersonEmail',
        type: 'email',
        editable: false
    }
];

export default class VoiceCallAccountMapping extends LightningElement {
 @api recordId; 
  columns = COLS;
 error = '';
 wrapper;
 searchedEmail = '';
 bShowSpinner = false;

 bShowNewPersonAccountCreation = false;
 bShowSearchByEmail = false;

 bShowExistingListOfPersonAccountTable = false;
 bHideMainCmp = false;
 selectedExistingPersonAcc = '';
 emailSearchUiMsg = '';
 msgWhenNoRecordsFoundByPhone = '';


 get isLinkingRecSelected() {
        return this.selectedExistingPersonAcc == '' ? true : false;
    }


 get hasDataInEmailInputField(){
         return this.searchedEmail ==  '' ? true:false
     }

  newPersonRec = { 'sobjectType' : 'Account', 
                    'FirstName' : '', 
                    'LastName' : '',
                    'PersonEmail' : '',
                    'PersonMobilePhone' : ''
                    }; 

 @wire(findPersonAccRecord,{voiceCallId: '$recordId'}) 
 initWrapperData({data, error}){
		if(data) {
            console.log('data===> ' + JSON.stringify(data));
			this.wrapper =  JSON.parse(JSON.stringify(data)) ;
 			this.error = undefined;
             
            if(this.wrapper.bHasPersonAccountAlreadyInVC){
               this.bHideMainCmp = true;               
            }else{
              this.newPersonRec.PersonMobilePhone = this.wrapper.oVcRecord.FromPhoneNumber;
 
            // if no person contact found  
            if(this.wrapper.bHasMatchPersonAccount == false){
               
               this.bShowNewPersonAccountCreation = false;
               this.bShowSearchByEmail = true;
               this.msgWhenNoRecordsFoundByPhone = 'No record found based on incoming phone number. please search by email.';
               this.bShowExistingListOfPersonAccountTable = false;
            } 
            else{ // if we found 1 or more person account for this caller number 
               this.bShowNewPersonAccountCreation = false; // TBD
               this.bShowExistingListOfPersonAccountTable = true;
               this.bShowSearchByEmail = false; // hide search by email option 
               this.msgWhenNoRecordsFoundByPhone = '';
            }
            }

            
            
		}else {
			this.wrapper =undefined;
			this.error = error;
		}
	}
  
   
    onEmailSearchValueChange(event){
       var inputField = event.target.value; 
       this.searchedEmail = inputField;
  
    }

    searchByEmail(event){
        this.emailSearchUiMsg  = '';
       this.bShowSpinner = true;
       // call apex method to search records by email ID     
      searchByPersonEmail({ sPersonEmailInput: this.searchedEmail})
            .then(result => {    
                console.log('result---> ' + JSON.stringify(result));
                console.log('result.length----> ' + result.length);
                if(result.length > 0){
                    console.log('JSON.stringiy ---> this.wrapper ' + JSON.stringify(this.wrapper));
                    this.wrapper.matchPersonAccount = result;
                    this.bShowExistingListOfPersonAccountTable = true; // if data came based on searched email ID show datatable under this
                    this.bShowNewPersonAccountCreation = false; // hide new creation form
                    this.emailSearchUiMsg  = '';
                }else{
                    // no person account found based on given email ID, now show create new form and hide everthing                     
                    this.bShowNewPersonAccountCreation = true;
                    //show display msg if no record found
                    this.bShowExistingListOfPersonAccountTable = false;
                    this.emailSearchUiMsg  = 'No records found with this email Id. You can create a new person account and link.';


                }
                this.bShowSpinner = false;
             })
            .catch(error => {         
                   console.log('error while fetching Person account based on the Email Id');
            });



    }
    
    onNewInputChange(event){
        var inputField = event.target; 
        console.log('inputField name --> ' + inputField.name);
        console.log('inputField value--> ' + inputField.value);

        switch (inputField.name) {
        case 'sFName':
            this.newPersonRec.FirstName = inputField.value;
            break;
        case 'sLName':
            this.newPersonRec.LastName = inputField.value;
            break;
        case 'sPhone':
            this.newPersonRec.Mobile__c = inputField.value;
            break;
        case 'sEmail':
            this.newPersonRec.PersonEmail = inputField.value;
            break;
        }                
    }


    createNewAccAndLink(){
        this.bShowSpinner = true;
       console.log('newPersonRec--> ' + JSON.stringify(this.newPersonRec));
        if(this.newPersonRec.FirstName != '' && this.newPersonRec.LastName != '' && this.newPersonRec.Phone != '' && this.newPersonRec.PersonEmail != '' ){
          console.log('newPersonRec--> ' + JSON.stringify(this.newPersonRec));
          

          createNewPersonAccountandLink({ newPersonAcc: this.newPersonRec, vcId: this.recordId })
            .then(result => {    
                   this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success', 
                            message: 'Record has been linked Successfully.',
                            variant: 'success'
                        })
                    );                    
                    notifyRecordUpdateAvailable([{recordId: this.recordId}]);
                     this.bHideMainCmp = true;    
                     this.bShowSpinner = false;

             })
            .catch(error => {         
                   this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error On Record Creation',
                            message: error.body.message,
                            variant: 'error'
                        })
                    );
                    this.bShowSpinner = false;
            });

   


        }else{
            this.bShowSpinner = false;
              this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Required Field Missing',
                            message: 'Please Enter all required fields.',
                            variant: 'error'
                        })
                    );
        }


    }

    linkExistingAccountRecord(){
       if(this.selectedExistingPersonAcc != ''){
          this.bShowSpinner = true;
         const fields = {};
            fields[ID_FIELD.fieldApiName] = this.recordId;
            fields[RELATED_PA.fieldApiName] = this.selectedExistingPersonAcc;            

            const recordInput = { fields };

            updateRecord(recordInput)
                .then(() => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success', 
                            message: 'Record has been linked Successfully.',
                            variant: 'success'
                        })
                    );                    
                    notifyRecordUpdateAvailable([{recordId: this.recordId}]);
                     this.bHideMainCmp = true;
                     this.bShowSpinner = false;
                })
                .catch(error => {
                    this.bShowSpinner = false;
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error updating record',
                            message: error.body.message,
                            variant: 'error'
                        })
                    );
                });


           


       }
    }

    createNewAccountScreen(){
        this.bShowNewPersonAccountCreation = true;
    }


    getSelectedName(event) {
        const selectedRows = event.detail.selectedRows;      
        for (let i = 0; i < selectedRows.length; i++) {
            this.selectedExistingPersonAcc = selectedRows[i].Id;
        }
    }


}