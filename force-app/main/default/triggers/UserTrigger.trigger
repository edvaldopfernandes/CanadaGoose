trigger UserTrigger on User (before insert, before update, after insert, after update) {
    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            UserTriggerHandler.OnBeforeInsert(Trigger.new, Trigger.newMap);
        }
        else if (Trigger.isUpdate) {
            UserTriggerHandler.OnBeforeUpdate(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
        }
    }
    else if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            UserTriggerHandler.OnAfterInsert(Trigger.new, Trigger.newMap);
        }
        else if (Trigger.isUpdate) {
            UserTriggerHandler.OnAfterUpdate(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
        }
    }
}