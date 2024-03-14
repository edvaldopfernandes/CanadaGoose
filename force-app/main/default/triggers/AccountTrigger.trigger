/**
 * Update ---
 *@description This trigger is used to create Platform Events that trigger an
 * update of the PersonAccount with a details of a mapped B2C Commerce Customer Profile.
 * 
 * */
trigger AccountTrigger on Account (before insert, before update, after update) {
    Trigger_Switch__c  triggerSwitch = new Trigger_Switch__c(); 
     triggerSwitch = Trigger_Switch__c.getInstance('AccountTrigger');
     if((test.isRunningTest()) || (triggerSwitch.Switch__c == true)){
    
        if (Trigger.isBefore) {
            if (Trigger.isInsert) {
                AccountTriggerHandler.OnBeforeInsert(Trigger.new, Trigger.newMap);
            }
            else if (Trigger.isUpdate){
                AccountTriggerHandler.OnBeforeUpdate(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
                 if (B2CConfigurationManager.isB2CProcessContactTriggerEnabled() == true &&
                		B2CConfigurationManager.getDefaultAccountContactModel() == B2CConstant.ACCOUNTCONTACTMODEL_PERSON) {
						// Process the trigger and handle the personAccount updates
            			B2CProcessPersonAccountHelper.processTrigger(Trigger.new, Trigger.old);
				 }
            }
        }
        else if (Trigger.isAfter) {
            if (Trigger.isUpdate) {
                AccountTriggerHandler.OnAfterUpdate(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
            }
        }
     }
}