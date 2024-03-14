public with sharing class InspectionResultsController {
    /*
    * Function: getTaxedInspectionResults
    * --------------------
    * Lightning enabled function to support retrieving case related inspection results
    * 
    *  caseId: Id of the parent case
    *
    *  returns: A class TaxedInspectionResultsStruct, (object holding a list of Inspection_Result__c InspectionResults,
    *    Decimals Subtotal, Tax, and Total, String CurrencyCode)
    */
    @AuraEnabled
    public static InspectionResultsUtility.TaxedInspectionResultStruct getTaxedInspectionResults(Id caseId){
        return InspectionResultsUtility.getTaxedInspectionResults(caseId);
    }
}