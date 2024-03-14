import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getCarouselImages from '@salesforce/apex/WarrantyNavigationMenuController.getCarouselImages';

export default class WarrantyNavMenuCarousel extends NavigationMixin(LightningElement) {
    currentIndex = 0;
    images;

    connectedCallback() {
        getCarouselImages()
        .then((result) => {
            if(result.success) {
                this.images = result.values.map((item) => {
                    return {
                        id: item.Id,
                        label: item.MasterLabel,
                        buttonLabel: item.ButtonLabel__c,
                        buttonUrl: item.ButtonUrl__c,
                        title: item.Title__c,
                        colour: item.Colour__c,
                        url: item.ImageUrl__c
                    };
                });
            } 
        });
    }

    handleRedirect(event) {
		this.dispatchEvent(new CustomEvent('navigation'));
      	let item = this.images.find((item) => item.id == event.target.dataset.id);
		this[NavigationMixin.Navigate]({
			type: 'standard__webPage',
			attributes: {
				url: item.buttonUrl
			}
		});
    }

    handleClick(event) {
		const arrow = event.target;
        console.log(event.target.classList);
		if (arrow.classList.contains('icon-left')) {
			this.currentIndex = (this.currentIndex - 1 + this.images.length) % this.images.length;
		} else {
			this.currentIndex = (this.currentIndex + 1) % this.images.length;
		}
		const carouselInner = this.template.querySelector('.carousel-inner');
		carouselInner.style.transform = `translateX(-${this.currentIndex * 100}%)`;
    }
}