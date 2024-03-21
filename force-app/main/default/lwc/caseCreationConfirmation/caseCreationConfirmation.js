import { LightningElement, wire } from 'lwc';
import { CurrentPageReference, NavigationMixin} from 'lightning/navigation';
import caseConfirmed from '@salesforce/label/c.CGWCaseConfirmation';
import caseConfirmed2 from '@salesforce/label/c.CGWCaseConfirmation2';
import returnHomeLabel from '@salesforce/label/c.CGWCaseHistoryButton';

export default class CaseCreationConfirmation extends NavigationMixin(LightningElement) {

    @wire(CurrentPageReference) pageRef;

    paragraph1Message = caseConfirmed;
    paragraph2Message = caseConfirmed2;
    returnHomeLabel = returnHomeLabel;

    // Retorna o caseNumber do estado da navegação ou uma string padrão caso não esteja definido
    get caseNumber() {
        return this.pageRef && this.pageRef.state.caseNumber ? this.pageRef.state.caseNumber : 'não fornecido';
    }

    returnHome(){
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage', 
            attributes: {
                name: 'Home'
            }
        });
    }
}