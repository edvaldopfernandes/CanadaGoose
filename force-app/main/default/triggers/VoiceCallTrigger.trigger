trigger VoiceCallTrigger on VoiceCall (before insert, after insert, After Update) {
    Trigger_Switch__c  triggerSwitch = new Trigger_Switch__c(); 
    triggerSwitch = Trigger_Switch__c.getInstance('VoiceCallTrigger');
    	if((test.isRunningTest()) || (triggerSwitch.Switch__c == true && triggerSwitch.AvoidTriggerOnBatchRun__c == false)){       
    		if(trigger.isBefore && trigger.isInsert){
        		VoiceCallTriggerHandler.voiceCallBeforeInsert(trigger.new);
    		}            
    	if(trigger.isAfter && trigger.isupdate){         
        		VoiceCallTriggerHandler.voiceCallAfterUpdate(trigger.new, trigger.oldMap); 
            	system.debug('VoiceCallTriggerHandler.voiceCallAfterUpdate');
    	}
    }
}