import { LightningElement, api, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import getNavigationMenuItems from '@salesforce/apex/WarrantyNavigationMenuController.getNavigationMenuItems';
import basePath from '@salesforce/community/basePath';
import isGuestUser from '@salesforce/user/isGuest';
import formFactor from "@salesforce/client/formFactor";
import lang from '@salesforce/i18n/lang';

export default class WarrantyNavMenu extends LightningElement {

    @api menuName = 'Warranty Navigation';
    @api contentId;

    error;
    href = basePath;
    isLoaded;
    isShowing = false;
    publishedState;

    menuItems = [];
    home = {
        target: '',
        id: 0,
        label: 'Home',
        defaultListViewId: '',
        type: 'InternalLink',
        accessRestriction: 'LoginRequired'
    };
    language = {
        target: '/languages',
        id: this.menuItems.length - 1,
        label: `Languages | ${(lang.split('-')[0]).toUpperCase()}`,
        defaultListViewId: '',
        type: 'InternalLink',
        accessRestriction: 'LoginRequired'
    };
    logout = {
        target: '',
        id: this.menuItems.length,
        label: 'Logout',
        defaultListViewId: '',
        type: 'Logout',
        accessRestriction: 'LoginRequired'
    };

    get isGuest() {
        return isGuestUser;
    }

    get isDesktop() {
        return (formFactor === "Large");
    }

    get logoutLink() {
        const sitePrefix = basePath.replace(/\/s$/i, ""); // site prefix is the site base path without the trailing "/s"
        return sitePrefix + "/secur/logout.jsp";
    };

    @wire(getNavigationMenuItems, {
        menuName: '$menuName',
        publishedState: '$publishedState'
    })
    wiredMenuItems({ error, data }) {
        if (data && !this.isLoaded) {
            data.map((item, index) => {
                this.menuItems.push({
                    target: item.Target,
                    id: index,
                    label: item.Label,
                    defaultListViewId: item.DefaultListViewId,
                    type: item.Type,
                    accessRestriction: item.AccessRestriction,
                    isExternal: (item.Type == 'ExternalLink')
                });
            });
            this.error = undefined;
            this.isLoaded = true;
        } else if (error) {
            this.error = error;
            this.isLoaded = true;
            console.log(`Navigation menu error: ${JSON.stringify(this.error)}`);
        }
    }

    @wire(CurrentPageReference)
    setCurrentPageReference(currentPageReference) {
        const app =
            currentPageReference &&
            currentPageReference.state &&
            currentPageReference.state.app;
        if (app === 'commeditor') {
            this.publishedState = 'Draft';
        } else {
            this.publishedState = 'Live';
        }
    }

    changeDisplay(event) {
        this.isShowing = !this.isShowing;
    }

    closeMenuOnClickOutside(event) {
        let menu = document.querySelector('.hamburger-menu');

        document.addEventListener('click', function (event) {

            let targetElement = event.target;  // clicked element

            if (!menu.contains(targetElement)) {
                this.isShowing = false;
            }

        });
        
    }
    
}