public class InventoryTriggerHandler {
    /*
    * Function: OnBeforeInsert 
    * --------------------
    * Trigger handler for the Before Insert event
    *
    *  lstNewInventories: List of the new Inventory records being updated
    *  mapNewInventories: Map of the new Inventory records being updated
    *
    *  returns: N/A
	*/
    public static void OnBeforeInsert(List<Inventory__c> lstNewInventories, Map<Id, Inventory__c> mapNewInventories) {
        for (Inventory__c invt : lstNewInventories) {
            invt.Name = invt.Smart_SKU__c;
            invt.Upload_Operation__c = null;
        }
    }
    
    /*
    * Function: OnBeforeUpdate 
    * --------------------
    * Trigger handler for the Before Update event
    *
    *  lstNewInventories: List of the new Inventory records being updated
    *  mapNewInventories: Map of the new Inventory records being updated
    *  lstOldInventories: List of the old Inventory records being updated
    *  mapOldInventories: Map of the old Inventory records being updated
    *
    *  returns: N/A
	*/
    public static void OnBeforeUpdate(List<Inventory__c> lstNewInventories, Map<Id, Inventory__c> mapNewInventories, List<Inventory__c> lstOldInventories, Map<Id, Inventory__c> mapOldInventories) {
        for (Inventory__c invt : lstNewInventories) {
            invt.Name = invt.Smart_SKU__c;
            
            if (invt.Upload_Operation__c == 'Add') {
                invt.Available_Quantity__c += mapOldInventories.get(invt.Id).Available_Quantity__c;
            }
            
            invt.Upload_Operation__c = null;
        }
    }
}