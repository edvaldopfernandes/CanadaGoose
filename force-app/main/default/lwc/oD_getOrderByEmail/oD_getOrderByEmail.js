import {LightningElement, track, api} from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import getDeserialize from '@salesforce/apex/getOrdersByEmail.getDeserialize';
import executeBatch from '@salesforce/apex/ControllerToExecuteBatch.executeBatch';
import { CurrentPageReference } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class oD_getOrderByEmail extends LightningElement {
    @api open;
    @api recordId;
    
    // get sectionClass() {
    //     return this.open ? 'slds-section slds-is-open' : 'slds-section';
    // }

    // handleClick() {
    //     this.open = !this.open;
    // }
    
    
    async connectedCallback() {  
        try{
           // if (typeof this.open === 'undefined') this.open = true;
            //let rec = await getDeserialize({accountId: this.recordId});
            console.log('record>>>',this.recordId);
            //let obj = JSON.parse(await ControllerToExecuteBatch({recordId : this.recordId}));
            //if (recordId) {
            //    this.executeBatchApex(recordId);
            //}
        }  catch(error){
           console.log("Error",error);
        }   
      
    }
    handleGetOrders(){
        try {
                console.log('this.recordId >>',this.recordId);
                if (this.recordId) {
                   let msg = executeBatch({recordId : this.recordId});
                   console.log('msg>>>',msg);
                   
                    this.dispatchEvent(
                        new ShowToastEvent({
                            message : 'Request Submitted Successfully',
                            variant : 'success'
                        })
                    );
                } else{
                    this.dispatchEvent(
                        new ShowToastEvent({
                            message : 'Record Id does not exist',
                            variant : 'error'
                        })
                    );
                }
            }  catch(error){
                console.log("Error",error);
            }   
    }
     

}