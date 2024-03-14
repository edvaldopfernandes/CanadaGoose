import { LightningElement, track } from 'lwc';

export default class CustomLoginForm extends LightningElement {
    @track username = '';
    @track password = '';

    handleUsernameChange(event) {
        this.username = event.target.value;
    }

    handlePasswordChange(event) {
        this.password = event.target.value;
    }

    handleLogin() {
        // Add your login logic here
        // You can use this.username and this.password to access the entered values
    }
}