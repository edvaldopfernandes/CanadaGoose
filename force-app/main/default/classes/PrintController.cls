public with sharing class PrintController {
    /*
     * This function gets paid inspection results and sends it to the front end controller to be displayed on Inspection results label
     * input: case ID
     * output: List of inspection results
     */
    @AuraEnabled
    public static List<Inspection_result__c> getPaidInspectionResults (Id caseId)
    {
        return InspectionResultsUtility.getInspectionResults(caseId, false);
    }
    
    /*
     * This class is used to return both country setting and case information for the logistics label creation
     */
    public class CaseCountrySetting
    {
        @AuraEnabled
        public Utilities.CountrySetting CounSet {get;set;}
        @AuraEnabled
        public Case cse {get;set;}
    }
    
    /*
     * This function gets information needed for logistics label
     * input: case ID
     * output: case information and country setting
     */    
    @AuraEnabled
    public static CaseCountrySetting getLogisticsPrint (Id caseId)
    {
        CaseCountrySetting caseCountSet = new CaseCountrySetting();
        caseCountSet.cse = [SELECT Id, CaseNumber, Account.ShippingCountryCode,Colour_Name__c,MID_code__c,
                            Cut_Number__c,Manufacture_Year__c,Generation_Re_commerce__c, Style__r.Name,
                            StyleNumber__c, Size__c, Items_Missing_On_Arrival__c, Colour_Name__r.Name, MID_code__r.Name
                            FROM Case
                            WHERE Id = :caseId LIMIT 1];
        caseCountSet.CounSet = Utilities.GetCountrySetting(caseCountSet.cse.Account.ShippingCountryCode);
        System.debug('>>>>casecountSet'+caseCountSet.cse);
        return caseCountSet;
    }
}