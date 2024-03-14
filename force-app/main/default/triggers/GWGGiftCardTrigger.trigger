trigger GWGGiftCardTrigger on GWG_Gift_Card__c (before insert, after insert, before update, after update) {
    Trigger_Switch__c  triggerSwitch = new Trigger_Switch__c(); 
    triggerSwitch = Trigger_Switch__c.getInstance('GWGGiftCardTrigger');
     
    if((test.isRunningTest()) || (triggerSwitch.Switch__c == true)){
      	if(trigger.isInsert && trigger.IsBefore){
            GWGGiftCardTriggerHandler.beforeInsert(Trigger.new);
        }
       if(trigger.isUpdate && trigger.IsBefore){
            GWGGiftCardTriggerHandler.beforeUpdate(Trigger.new, Trigger.oldMap);
        }
        if(trigger.isInsert && trigger.IsAfter){
            GWGGiftCardTriggerHandler.afterInsert(Trigger.new);
        }
        if(trigger.isUpdate && trigger.IsAfter){
            GWGGiftCardTriggerHandler.afterUpdate(Trigger.new, Trigger.oldMap);
        }
     
    }  
}