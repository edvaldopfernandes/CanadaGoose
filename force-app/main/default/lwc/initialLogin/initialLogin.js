import { LightningElement, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';


export default class InitialLogin extends NavigationMixin(LightningElement) {
    @track selectedButton = null;

    selectButton(event) {
      
    //   const button = event.currentTarget;
    //   this.selectedButton = button;
        const button = event.currentTarget;
        const selectedValue = button.dataset.value;

        // Remove a classe "selected" da div atualmente selecionada
        const currentSelectedDiv = this.template.querySelector('.clickable.selected');
        if (currentSelectedDiv) {
            currentSelectedDiv.classList.remove('selected');
        }

        // Adiciona a classe "selected" à div recém-selecionada
        button.classList.add('selected');

        this.selectedButton = button;
    }

  
    saveAndRedirect() {
      if (this.selectedButton) {
        const selectedValue = this.selectedButton.dataset.value;

        if(selectedValue === 'Button 1'){
            this[NavigationMixin.Navigate]({
                type: 'standard__webPage',
                attributes: {
                    url: '/customer-login'
                }
            });
        }else if(selectedValue === 'Button 2'){
            this[NavigationMixin.Navigate]({
                type: 'standard__webPage',
                attributes: {
                    url: 'https://service.canadagoose.com/retailer/s/login/'
                }
            });
        }
      } else {
          this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: '/customer-login'
            }
        });
      }
  }
}