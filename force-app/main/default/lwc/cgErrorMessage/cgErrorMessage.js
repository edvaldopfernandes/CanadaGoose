import { LightningElement, api } from 'lwc';
export default class CgErrorMessage extends LightningElement {
    @api error;

    close() {
        this.error = null;
        let setErrorNullDetails = {error : null};
        const setErrorNullEvent = new CustomEvent('seterrornull', {

            detail: setErrorNullDetails
        });
        this.dispatchEvent(setErrorNullEvent);
    }
}