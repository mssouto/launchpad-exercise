import { LightningElement,api, track } from 'lwc';
import fetchData from '@salesforce/apex/ObjectTableWithActionsHelper.fetchData';
import followRecord from '@salesforce/apex/ObjectTableWithActionsHelper.followRecord';
import unfollowRecord from '@salesforce/apex/ObjectTableWithActionsHelper.unfollowRecord';

const actions = [
    { label: 'Follow', name: 'follow' },
    { label: 'Unfollow', name: 'unfollow' },
];

export default class ObjectTableWithActions extends LightningElement {
    @track data = [];
    @track columnsInfo = [];

    @api columns;
    @api objectName;
    @api selectFields;
    @api whereCondition;

    async connectedCallback() {
        this.data = await fetchData({   objectName: this.objectName,
                                        selectFields: this.selectFields,
                                        whereCondition: this.whereCondition
                                    });
        if (this.objectName == 'Case') {
            this.data.forEach(item => {
                let priority = item.Priority + "";
                switch (priority) {
                    case "High":
                        item.format =  'slds-icon-standard-quip';
                        break;
                    case "Medium":
                        item.format = 'slds-icon-standard-case';
                        break;
                    default:
                        item.format = 'slds-icon-standard-approval';

                }
            });
        }
        this.columnsInfo = [
            ...this.columnsInfo, 
            ...JSON.parse(this.columns), 
            ... [{
                    type: 'action',
                    typeAttributes: { rowActions: actions },
                }]];
        this.columnsInfo.forEach(item => {
            item.cellAttributes = {
                class: {
                    fieldName: `format`
                }
            };
        });
                
        
    }

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        switch (actionName) {
            case 'follow':
                followRecord({recordId : event.detail.row.Id});
                break;
            case 'unfollow':
                unfollowRecord({recordId : event.detail.row.Id});
                break;
            default:
        }
    }

}
