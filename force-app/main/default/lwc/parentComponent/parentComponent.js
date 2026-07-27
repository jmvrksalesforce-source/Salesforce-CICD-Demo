import { LightningElement, track } from 'lwc';

export default class ParentComponent extends LightningElement {
    @track childMessage;

    // parentComponent.js
    handleClick1(event) {
        console.log('handleClick1');
        console.log(JSON.stringify(event.detail));
        this.childMessage = event.detail.data;
    }
}