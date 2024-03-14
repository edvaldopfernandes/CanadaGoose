import { LightningElement,track , api} from 'lwc';
import getDeserialize from '@salesforce/apex/orderDetailsDataParser.getDeserialize';
export default class DummyComp extends LightningElement {

    @track result=[]

    //Pagination Variables
    @track page = 1; 
    @track startingRecord = 1;
    @track endingRecord = 0; 
    @track pageSize = 20; 
    @track totalRecountCount = 0;
    @track totalPage = 1;
    @track toDisplay=[];

    //Columns for dataTable
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
            type:'text',
            sortable: true

        },
        {
            label: 'Payment Status',
            fieldName: 'payment_status',
            type: 'text',
            sortable: true
        },
        /*{
            label: 'Invoice Status',
            fieldName: 'invoice_status',
            type: 'text',
            sortable: true
        }*/

    ];

    @track varQ= [];
    @track addressO=[];
    @track detailsData=[];
    @api recordId;
    connectedCallback()
    { 
        getDeserialize({ rId : this.recordId }).then(response =>{
            //console.log(response);
            this.result = response;
            this.varQ = response.customer_orders;
            this.detailsData= this.formatData(response);
            this.totalRecountCount = response.customer_orders.length; 
            this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize); 
            this.result.customer_orders = this.result.customer_orders.slice(0,this.pageSize); 
            this.endingRecord = this.pageSize;
        }).catch(error =>{
            console.error(error);
        })
    }

    //format data to show details in modal
    formatData(res)
    {

    }

    @track record = {};
    @track rowOffset = 0;
    @track bShowModal = false;
    @track orderToShow=[];

    // Row Action event to show the details of the record
    handleRowAction(event) {
        const row = event.detail.row;
        this.record = row.order_no;
        for (let i=0; i<this.result.customer_orders.length; i++)
        {
            if (this.result.customer_orders[i].order_no == this.record)
            {
                this.orderToShow=this.result.customer_orders[i];
                this.addressO=this.result.customer_orders[i].address;
            }
        }
        this.bShowModal = true; // display modal window
    }

    // to close modal window set 'bShowModal' tarck value as false
    closeModal() {
        this.bShowModal = false;
    }

    // Pagination Handlers
    //clicking on previous button this method will be called
    previousHandler() {
        if (this.page > 1) {
            this.page = this.page - 1; //decrease page by 1
            this.displayRecordPerPage(this.page);
        }
    }

    //clicking on next button this method will be called
    nextHandler() {
        if((this.page<this.totalPage) && this.page !== this.totalPage){
            this.page = this.page + 1; //increase page by 1
            this.displayRecordPerPage(this.page);            
        }             
    }

    //this method displays records page by page
    displayRecordPerPage(page){

        this.startingRecord = ((page -1) * this.pageSize) ;
        this.endingRecord = (this.pageSize * page);

        this.endingRecord = (this.endingRecord > this.totalRecountCount) 
                            ? this.totalRecountCount : this.endingRecord; 

        this.result.customer_orders = this.varQ.slice(this.startingRecord, this.endingRecord);

        this.startingRecord = this.startingRecord + 1;
    } 

    //Search Handler
    handleSearch(event) {
        const inputValue = event.target.value;

        if (inputValue.length == 0) {
            this.result.customer_orders = this.varQ.slice(0, this.pageSize);;
        }
        else{
            const regex = new RegExp(`^${inputValue}`, 'i');     
            this.result.customer_orders = this.varQ.filter(row => regex.test(row.order_no));
        }
    }
}