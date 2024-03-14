trigger InvoiceTrigger on Invoice__c (before insert, after insert) {
    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            InvoiceTriggerHandler.OnBeforeInsert(Trigger.new, Trigger.newMap);
        }
    }
    else if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            InvoiceTriggerHandler.OnAfterInsert(Trigger.new, Trigger.newMap);
        }
    }
}