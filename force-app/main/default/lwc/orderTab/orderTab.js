import {LightningElement, track,wire} from 'lwc';
import getDeserialize from '@salesforce/apex/getOrdersByEmail.getDeserialize';
import getDeserializebyOrderNumber from '@salesforce/apex/getOrdersByOrderNumber.getDeserialize';
export default class OrderTab extends LightningElement {

    // Order number or email enabling
    @track emailToSearch = '';
    @track orderNumberToSearch = '';
    @track searchByEmail = false;

    // Order Details visibility 
    @track detailsVisible = false;
    @track showOrderTable = false;
    @track showError = false;


    handleEmailSearch(event) {
        this.emailToSearch = event.target.value;
        console.log('inputValue', this.emailToSearch);

        if (this.emailToSearch.length == 0) {
            this.template.querySelector('[data-id="input01"]').disabled = false;
            this.template.querySelector('[data-id="input02"]').required = false;
        } else {
            this.template.querySelector('[data-id="input01"]').disabled = true;
            this.template.querySelector('[data-id="input02"]').required = true;
        }
        this.searchByEmail = true;
    }

    handleOrderNumberSearch(event) {
        this.orderNumberToSearch = event.target.value;
        console.log('inputValue', this.orderNumberToSearch);

        if (this.orderNumberToSearch.length == 0) {
            this.template.querySelector('[data-id="input02"]').disabled = false;
            this.template.querySelector('[data-id="input01"]').required = false;
        } else {
            this.template.querySelector('[data-id="input02"]').disabled = true;
            this.template.querySelector('[data-id="input01"]').required = true;
        }
        this.searchByEmail = false;
    }

    //calling gerOrderbyOrderNumber
    @track customerResult = [];
    @track orderResult = [];
    @track addressByOrder = [];
    @track showNoOrderError = false;

    @wire(getDeserializebyOrderNumber, {orderNum: '$orderNumberToSearch'})
    deWiredOrder({error,data}) 
	{
        if (data) {
            console.log('has Order Data', data);
            if(data.statusCode != 404){
                if(data.status != 404 ){
            this.customerResult= data.customer_master;
            for (let i = 0; i < 1; i++) {
                    this.orderResult = data.customer_orders[i];
                    this.addressByOrder = data.customer_orders[i].address;
            }
            if (this.orderResult.order_id == 0 && this.orderResult.payment_status == 0 ){
                this.showNoOrderError = true;
                this.detailsVisible = false;
            } else {
                //setTimeout(() => this.detailsVisible = true, 800);
                this.detailsVisible = true
                this.showNoOrderError = false;
            }}
            else{
                this.showNoOrderError = true;
                this.detailsVisible = false;
            }
            }
            else{
                this.detailsVisible = false;
            }
        } else if (error) {
            console.log('has Order Error');
            this.error = error;
            console.log(error);
            this.orderResult = [];
            this.showNoOrderError = true;
            this.detailsVisible = false;
        }
    }

    //calling gerOrderEmail
    @track result = [];
    @track showNoOrderForEmailError = false;
    @track errorToShow = '';
    @wire(getDeserialize, {email: '$emailToSearch'})
    deWiredEmail({error,data}) {
        if (data) {
            this.showNoOrderForEmailError = false;
            console.log('has Email Data', data);
            this.result = data;
            this.emailNotExist=false;
        } else if (error) {
            this.error = error;
            console.log(error);
            this.result = [];
            if(error.body.exceptionType == 'System.JSONException'){
                this.errorToShow=' * No orders found for this email.';
            }
            else if (error.body.exceptionType == 'System.CalloutException')
            {
                this.errorToShow='*Order Search has timed out.';
            }
            this.showOrderTable = false;
            this.showNoOrderForEmailError = true;
        }
    }

    handleClick() {
        this.showNoOrderForEmailError = false;
        if (this.orderNumberToSearch.length == 0 && this.emailToSearch.length == 0) {
            this.showError = true;
            this.showOrderTable = false;
            this.detailsVisible = false;
            this.showNoOrderError = false;
        } else {
            this.showError = false;
            this.showNoOrderError = false;
            if (this.searchByEmail) {
                    this.showOrderTable = true;
                    this.detailsVisible = false;
            } else {
                this.showOrderTable = false;
            }
        }
    }


    @track columns = [{
            label: 'View',
            type: 'button-icon',
            initialWidth: 75,
            typeAttributes: {
                iconName: 'action:preview',
                title: 'Preview',
                variant: 'border-filled',
                alternativeText: 'View'
            }
        },
        {
            label: 'Order Number',
            fieldName: 'order_no',
            type: 'text',
            sortable: true
        },
        {
            label: 'Order Total',
            fieldName: 'order_total',
            type: 'text',
            sortable: true

        },
        {
            label: 'Payment Status',
            fieldName: 'payment_status',
            type: 'text',
            sortable: true
        }

    ];

    @track record = {};
    @track rowOffset = 0;
    @track bShowModal = false;
    @track orderToShow = [];

    // Row Action event to show the details of the record
    handleRowAction(event) {
        const row = event.detail.row;
        this.record = row.order_no;
        for (let i = 0; i < this.result.customer_orders.length; i++) {
            if (this.result.customer_orders[i].order_no == this.record) {
                this.orderToShow = this.result.customer_orders[i];
                this.addressO = this.result.customer_orders[i].address;
            }
        }
        this.bShowModal = true; // display modal window
    }

    // to close modal window set 'bShowModal' tarck value as false
    closeModal() {
        this.bShowModal = false;
    }
}