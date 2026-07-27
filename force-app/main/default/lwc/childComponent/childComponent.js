// childComponent.js
import { LightningElement, api } from 'lwc';

export default class ChildComponent extends LightningElement {
    @api message; // Receives from parent
    
    sendToParent() {
        console.log('sendToParent');
        this.dispatchEvent(
            new CustomEvent('childclick1', {
                detail: { data: 'Hi from child' }
            })
        ); // Sends to parent
    }
}