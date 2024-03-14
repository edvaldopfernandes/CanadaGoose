import { LightningElement, api, wire } from 'lwc';
import getContent from '@salesforce/apex/ManagedContentController.getContent';
import basePath from '@salesforce/community/basePath';

export default class WarrantyLogo extends LightningElement {

    @api logoCmsId;
    @api width;
    @api height;

    url;

    get basePath() {
        return basePath;
    }

    @wire(getContent, {
        contentId: '$logoCmsId',
        page: 0,
        pageSize: 1,
        language: 'en_US',
        filterby: ''
    })
    results({ data, error }) {
        if (data) {
            this.url = basePath + '/sfsites/c' + data.source.url;
            this.error = undefined;
        }
        if (error) {
            console.log('Error: ' + JSON.stringify(error));
        }
    }

}