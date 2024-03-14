import { LightningElement } from 'lwc';
import labels from './customLabels.js';
import getUserInfo from '@salesforce/apex/UserProfileController.getUserInfo';
import updateUserInfo from '@salesforce/apex/UserProfileController.updateUserInfo';

export default class UserProfile extends LightningElement {

    labels = labels;
    userInfo;
    userInfoEdited = {};
    editing = false;
    editType = '';
    loading = false;

    get disableContinue() {
        console.log(this.userInfoEdited);
        return (this.editName && (!this.userInfoEdited.firstName || !this.userInfoEdited.lastName)) ||
            (this.editEmail && !this.userInfoEdited.email) ||
            (this.editPhone && !this.userInfoEdited.phone) ||
            (this.editAddress && (!this.userInfoEdited.street || !this.userInfoEdited.complement || !this.userInfoEdited.zipCode || !this.userInfoEdited.city || !this.userInfoEdited.state || !this.userInfoEdited.country));
    }

    get editName() {
        return (this.editing && this.editType == 'name');
    }

    get editEmail() {
        return (this.editing && this.editType == 'email');
    }

    get editPhone() {
        return (this.editing && this.editType == 'phone');
    }

    get editAddress() {
        return (this.editing && this.editType == 'address');
    }

    get name() {
        return `${this.userInfo?.firstName} ${this.userInfo?.lastName}`;
    }

    get email() {
        return this.userInfo?.email;
    }

    get phone() {
        return this.userInfo?.phone;
    }

    get address() {
        return this.userInfo?.street;
    }

    get complement() {
        return this.userInfo?.complement;
    }

    get zipCode() {
        return this.userInfo?.zipCode;
    }

    get city() {
        return this.userInfo?.city;
    }

    get province() {
        return this.userInfo?.state;
    }

    get country() {
        return this.userInfo?.country;
    }

    get addressFormatted() {
        return `${this.complement}, ${this.address}, ${this.zipCode}\n${this.city}, ${this.province}, ${this.country}`;
    }

    connectedCallback() {
        this.loading = true;

        getUserInfo()
        .then((result) => {
            console.log('start -', result);
            if(result.success) {
                this.userInfo = result.values;
            }
        })
        .finally(()=> {
            this.loading = false;
        });
    }

    handleEditInfo(event) {
        this.editType = event.detail;
        this.userInfoEdited = this.userInfo;
        this.editing = true;
    }

    handleClose() {
        this.editType = '';
        this.editing = false;
        this.userInfoEdited = {};
    }

    setField(event) {
        let value = event.target.value;
        let field = event.target.name;
        this.userInfoEdited = {
            ...this.userInfoEdited,
            [field] : value
        };
    }

    updateUserInfo(event) {
        this.loading = true;
        let newUser = {
            ...this.userInfoEdited
        };

        updateUserInfo({
            'cntWpr' : newUser
        })
        .then((result) => {
            console.log('result -', result);
            if(result.success) {
                this.userInfo = newUser;
                this.handleClose();
            }
        })
        .finally(()=> {
            this.loading = false;
        });
    }
}