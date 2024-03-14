import { LightningElement, track } from 'lwc';
import activeLanguages from '@salesforce/site/activeLanguages';
import lang from '@salesforce/i18n/lang';
import { NavigationMixin } from 'lightning/navigation';
import basePath from '@salesforce/community/basePath';
import title from '@salesforce/label/c.CGWALTitle';
import updateBtn from '@salesforce/label/c.CGWALUpdateButton';

export default class WarrantyAvailableLanguages extends NavigationMixin(LightningElement) {

    @track activeLanguages = [];
    isLoading = false;
    labels = {
      'title': title,
      'updateBtn' : updateBtn
    };

    connectedCallback() {
        this.activeLanguages = activeLanguages.map((item) => {
            return {
                ...item,
                active: (lang === item.code)
            }
        });
    }

    handleSelect(event) {
        let code = event.target.dataset.code;
        this.activeLanguages = this.activeLanguages.map((item) => {
            return {
                ...item,
                active: (code == item.code)
            }
        });
    }

    savePreference() {
        this.isLoading = true;
        
        const selectedLanguageCode = this.activeLanguages.filter(item => item.active === true)[0].code;
        // locale is in base path and needs to be replaced with new locale
        const newBasePath = this.updateLocaleInBasePath(basePath, lang, selectedLanguageCode);
    
        const currentUrl = window.location.pathname;

        if(currentUrl) {
          window.location.href = window.location.origin + newBasePath;
        } else {
          console.warn("Lightning Locker must be disabled for this language picker component to redirect");
        }
      }
    
      updateLocaleInBasePath(path, oldLocale, newLocale) {
        if (path.endsWith("/" + oldLocale)) {
          // replace with new locale
          return path.replace(new RegExp("/" + oldLocale + "$"), "/" + newLocale);
        } else {
          return path + "/" + newLocale;
        }
      }
}