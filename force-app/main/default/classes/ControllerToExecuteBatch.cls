/**
* ============================================
* Name: ControllerToExecuteBatch
* Description: Batch to pull the ControllerToExecuteBatch
 
* Author :- Venkat Kalyan
* Date   :- 26-02-2023
* Test Class :- ControllerToExecuteBatchTest 
* =======================================================
* */
public class ControllerToExecuteBatch{
   
    @AuraEnabled
    public static string executeBatch(id recordId) {
        try { System.debug('>>>> Record Id >>>'+recordId);
             BatchToInsertOrderAPI batch = new BatchToInsertOrderAPI(recordId);
             Database.executeBatch(batch);
            return 'Batch Executed Successfully'; } catch (Exception e) {  throw new AuraHandledException(e.getMessage()); }
    }
}