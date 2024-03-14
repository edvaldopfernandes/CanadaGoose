import { LightningElement,track,api } from 'lwc';
import {getRecord, getFieldValue} from 'lightning/uiRecordApi';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import getGiftCards from '@salesforce/apex/GWGGiftCardController.getGiftCards'; 
//import getAccRecord from '@salesforce/apex/GWGGiftCardController.getAccountRecord'; 
import checkPermission from '@salesforce/apex/GWGGiftCardController.checkPermission'; 
import {NavigationMixin} from 'lightning/navigation';

export default class ParentGiftCardComponent extends NavigationMixin(LightningElement) {
    @track showChild;
    @api recordId;
    @track gcRecords = [];
    @track columns = [];
    //accRecord;
    @track isPermitted = false;
    defaultSortDirection = 'asc';
    sortDirection = 'asc';
    sortedBy;

    columns =[
        {label: 'Name', fieldName: 'cardLink', type: 'url', sortable: true, typeAttributes: { label: { fieldName: 'Name' }, target: '_blank' }},
        { label: 'Gift Card Value', fieldName: 'Gift_Card_Value__c', type: 'Decimal', hideDefaultActions: true },
        { label: 'Approval Status', fieldName: 'Approval_Status__c', type: 'text', hideDefaultActions: true },
        { label: 'Tracking Number', fieldName: 'Tracking_Number__c', type: 'text', hideDefaultActions: true },
        { label: 'Approval Comment', fieldName: 'Approval_Comment__c', type: 'text', hideDefaultActions: true },
    ];

   
    fetchRecords(){
        getGiftCards({accId : this.recordId})
        .then(data=>{
            data = JSON.parse(JSON.stringify(data));

            data.forEach(res => {
                res.cardLink = '/' + res.Id;
            });

            this.error = undefined;
            this.gcRecords = data;
        }).catch(error=>{
            console.error('>>>>>>>>> error in fetching data', error);
        });
    }
    checkPermissions(){
        checkPermission().then(result=>{
            console.debug('>>>>> permssions',result);
            this.isPermitted = result;
        }).catch(error=>{
            console.error('>>>>> error in checking permission ', error);
        });
    }
    connectedCallback(){
        console.log('>>>>>>recordId>>>>',this.recordId);
        this.fetchRecords();
       // this.fetchAccRecord();
        this.checkPermissions();
       
        
    }
    
    clickHandler(){
        this.showChild = !this.showChild;
        console.log('in Handler > '+this.showChild);
    }
    handleClose(){
        this.showChild = false;
        //this.msg = event.detail;
    }
    handleCancel(){
        this.showChild = false;
        //this.msg = event.detail;
    }
   /* fetchAccRecord(){
        getAccRecord({accId : this.recordId})
        .then(data=>{
            this.accRecord = data;
        }).catch(error=>{
            console.error('error while fetching the account record', error);
        })
    }*/
   
    getShowToastEvent(title, message, variant){
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant
            })
        );
    }


    // Used to sort the 'Age' column
    sortBy(field, reverse, primer) {
        const key = primer
            ? function (x) {
                  return primer(x[field]);
              }
            : function (x) {
                  return x[field];
              };

        return function (a, b) {
            a = key(a);
            b = key(b);
            return reverse * ((a > b) - (b > a));
        };
    }

    onHandleSort(event) {
        const { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = [...this.gcRecords];

        cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
        this.gcRecords = cloneData;
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;
    }
}