import { LightningElement, api } from 'lwc';
export default class CgPageSection extends LightningElement {
    @api title;
    @api activeSectionCss = 'slds-accordion__section slds-is-open';
      handleToggleSection(event){
         this.activeSectionCss = this.activeSectionCss.includes('slds-is-open')? 'slds-accordion__section':'slds-accordion__section slds-is-open';
    }
}