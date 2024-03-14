/**
 *
 * =Update===================
 * @description This trigger is used to create Platform Events that trigger an
 * update of the Contact with a details of a mapped B2C Commerce Customer Profile.
 */

trigger ContactTrigger on Contact (before update, after update) {
	Trigger_Switch__c  triggerSwitch = new Trigger_Switch__c(); 
	triggerSwitch = Trigger_Switch__c.getInstance('ContactTrigger');
	if((test.isRunningTest()) || (triggerSwitch.Switch__c == true)){
		if(Trigger.isBefore) {
			if(Trigger.isUpdate) {
                	ContactTriggerHandler.OnBeforeUpdate(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
                	if(B2CConfigurationManager.isB2CProcessContactTriggerEnabled() == true &&
                    B2CConfigurationManager.getDefaultAccountContactModel() == B2CConstant.ACCOUNTCONTACTMODEL_STANDARD) {
                    	// Invoke the trigger handler and process the contactUpdates
                    	B2CProcessContactHelper.processTrigger(Trigger.new, Trigger.old);
                	}
            }
        }
        else if (Trigger.isAfter) {
            if (Trigger.isUpdate) {
                ContactTriggerHandler.OnAfterUpdate(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
            }
    	}
	}
}