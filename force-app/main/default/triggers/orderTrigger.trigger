/**
* ============================================
* Name: orderTrigger
* Description:  trigger for the Order
 
* Author :- Venkat Kalyan
* Date   :- 26-02-2023
* Test Class :- 
* =======================================================
* */
trigger orderTrigger on Order(After Insert, After Update) {
	if (Trigger.isAfter && Trigger.isUpdate) { OrderTriggerHandler.OnAfterUpdate(Trigger.new, Trigger.oldMap); }
    if (Trigger.isAfter && Trigger.isInsert) { OrderTriggerHandler.OnAfterInsert(Trigger.new); }
}