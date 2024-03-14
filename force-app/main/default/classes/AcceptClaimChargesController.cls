public class AcceptClaimChargesController {
    /*
    * Function: acceptCharges
    * --------------------
    * Allows retailer to accept charges on behalf of a customer
    *
    *  caseId: Id of the case being accepted
    * 
    *  returns: empty string if successful, or error message if not successful
	*/
    @AuraEnabled
    public static String acceptCharges(Id caseId) {
        Case retailerCase = new Case (Id = caseId, Accept_Charges__c = true);
        
        try {
        	update retailerCase;
            return '';
        }
        catch (Exception e) {
            System.debug('AcceptClaimChargesController:acceptCharges: Error occured while trying to accept charges, error: ' + e.getMessage());
            return Label.Warranty_AcceptCharges_Message_ErrorDescription;
        }
    }
}