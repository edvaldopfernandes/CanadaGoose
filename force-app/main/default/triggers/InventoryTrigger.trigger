trigger InventoryTrigger on Inventory__c (before insert, before update) {
    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            InventoryTriggerHandler.OnBeforeInsert(Trigger.new, Trigger.newMap);
        }
        else if (Trigger.isUpdate) {
            InventoryTriggerHandler.OnBeforeUpdate(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
        }
    }
}