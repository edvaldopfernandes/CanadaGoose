import { LightningElement, api, wire } from 'lwc';
import getOrderRecord from '@salesforce/apex/getOrderData.getOrderDetails';

export default class OrderDetailsViewPage extends LightningElement {
    @wire(getOrderRecord) wiredOrders;
    @api objectApiName;
    @api recordId;

    @wire (getOrderRecord) wiredOrders({data,error}){
        if (data) {
        console.log(data); 
        } else if (error) {
        console.log(error);
        }
   }
    
}