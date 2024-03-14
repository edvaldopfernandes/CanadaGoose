public with sharing class InspectionResultsUtility {

    public List<Inspection_Result__c> Inspections;
    
    /*
    * Class: TaxedInspectionResultStruct
    * --------------------
    * Class to define object to be passed to lightning controller
    * 
    *  InspectionResults: List of Inspection_Result__c
    *  Subtotal: sum of Inspection Results display prices
    *  Tax: Tax calculated from Subtotal
    *  Total: Subtotal + Tax
    *  CurrencyCode: Currency Code (defined by region eg. USD)
    */
    public class TaxedInspectionResultStruct{
        @AuraEnabled public List<Inspection_Result__c> InspectionResults;
        @AuraEnabled public List<Inspection_Result__c> PaidInspectionResults;
        @AuraEnabled public Decimal Subtotal;
        @AuraEnabled public Decimal Tax;
        @AuraEnabled public Decimal Total;
        @AuraEnabled public Decimal InvoicedSubtotal;
        @AuraEnabled public Decimal InvoicedTax;
        @AuraEnabled public Decimal InvoicedTotal;
        @AuraEnabled public String CurrencyCode;
        @AuraEnabled public String CountryCode;
        @AuraEnabled public String PaymentMethod;
        
        public TaxedInspectionResultStruct(){
            this.InspectionResults = new List<Inspection_Result__c>();
            this.Subtotal=0.00;
            this.Tax=0.00;
            this.Total=this.Subtotal+this.Tax;
            this.CurrencyCode='';
        }
    }
    /*
    * Function: getPendingPayment
    * --------------------
    * Lightning enabled function to support retrieving case related pending payment inspection results
    * 
    *  caseId: Id of the parent case
    *
    *  returns: list of inspection results
    */
    @AuraEnabled
    public static List<Inspection_Result__c> getPendingInspectionResults(Id CaseId){
        return getInspectionResults(CaseId, true);
    }
    
    /*
    * Function: getPendingPayment
    * --------------------
    * Lightning enabled function to support retrieving case related pending payment inspection results
    * 
    *  caseId: Id of the parent case
    *
    *  returns: list of inspection results
    */
    @AuraEnabled
    public static List<Inspection_Result__c> getPaidInspectionResults(Id CaseId){
        return getInspectionResults(CaseId, false);
    }
    
    /*
    * Function: InspectionResults
    * --------------------
    * Lightning enabled function to support retrieving case related inspection results
    * 
    *  caseId: Id of the parent case, Boolean PendingPayment
    *
    *  returns: list of inspection results
    */
    @AuraEnabled    
    public static List<Inspection_Result__c> getInspectionResults(Id CaseId, Boolean PendingPayment){
        return getInspectionResults(new Set<Id> {CaseId}, PendingPayment);
    }

    /*
    * Function: InspectionResults
    * --------------------
    * Lightning enabled function to support retrieving case related inspection results
    * 
    *  CaseIds: Id of the parent cases, Boolean PendingPayment
    *
    *  returns: list of inspection results
    */
    public static List<Inspection_Result__c> getInspectionResults(Set<Id> CaseIds, Boolean PendingPayment){
        if (PendingPayment) {
            List<Inspection_Result__c> PendingPaymentInspectionResults =  
                [SELECT Id, Status__c, Display_Price__c,Currency__c , Under_Warranty__c,
                    Repair_Type__c,Repair__r.Product_Code__c,Description__c,
                    Repair__r.Name, Repair__r.Name_FR__c, Repair__r.Name_DE__c, Repair__r.Name_ZH__c,Repair__r.Repair_Name_IT__c,
                    Case__c, Case__r.Status , Case__r.Payment_pending__c, Case__r.CaseNumber,
                    Case__r.Account.Language__c, Case__r.Account.ShippingCountryCode
                 FROM Inspection_Result__c
                 WHERE Case__c IN :CaseIds
                     AND Status__c = 'New' 
                     AND Case__r.Payment_pending__c > 0
                     AND Case__r.Status NOT IN ('New_Validate', 
                                                'Waiting On Product',
                                                'Cleaning',
                                                'Inspecting',
                                                'Pending Customer Feedback')];        
            
            return PendingPaymentInspectionResults.isEmpty() ? null : PendingPaymentInspectionResults;
        }
        else {
            return [SELECT Id, Status__c, Display_Price__c,Currency__c , Under_Warranty__c,
                        Repair_Type__c,Repair__r.Product_Code__c,Description__c,
                        Repair__r.Name, Repair__r.Name_FR__c, Repair__r.Name_DE__c, Repair__r.Name_ZH__c,Repair__r.Repair_Name_IT__c,
                        Case__c, Case__r.Status , Case__r.Payment_pending__c, Case__r.CaseNumber
                    FROM Inspection_Result__c
                    WHERE Case__c IN :CaseIds
                        AND Status__c NOT IN ('New', 'Rejected by client')];
        }
    }
    
    /*
    * Function: getTaxedInspectionResults
    * --------------------
    * Lightning enabled function to support retrieving case related pending payment and taxed inspection results
    * 
    *  caseId: Id of the parent case
    *
    *  returns: TaxedInspectionResultStruct
    */
    @AuraEnabled
    public static TaxedInspectionResultStruct getTaxedInspectionResults(Id caseId){
        system.debug('getTaxedInspectionResults::: ');
        TaxedInspectionResultStruct results = new TaxedInspectionResultStruct();
        results.InspectionResults = getPendingInspectionResults(caseId);
        results.PaidInspectionResults = getPaidInspectionResults(caseId);
        system.debug('results.InspectionResults::: ' + results.InspectionResults);
        system.debug('results.PaidInspectionResults::: ' + results.PaidInspectionResults);
                
        Case cse = [SELECT Id, Invoiced_Subtotal__c, Invoiced_Tax__c, Invoiced_Total__c, Account.ShippingCountryCode
                    FROM Case
                    WHERE Id = :caseId];

        system.debug('cse::: ' + cse);
        
        results.InvoicedSubtotal = cse.Invoiced_Subtotal__c;
        results.InvoicedTotal = cse.Invoiced_Total__c;
        results.InvoicedTax = cse.Invoiced_Tax__c;
        results.CountryCode = cse.Account.ShippingCountryCode;

        results.PaymentMethod = Utilities.GetCountrySetting(results.CountryCode).PaymentMethod;
        
        system.debug('results.PaymentMethod::: ' + results.PaymentMethod);
        system.debug('results.InspectionResults::: ' + results.InspectionResults);
        
        if (results.InspectionResults != null && results.PaymentMethod != 'None') 
        {
            results.Subtotal = OneSourceTaxReqGenerator.GetSubtotalFromInspectionResults(results.InspectionResults);
            system.debug('results.Subtotal::: ' + results.Subtotal);
            results.Tax = 0.00;
            results.Total = null; //set to null
            results.CurrencyCode = results.InspectionResults[0].Currency__c;

            if(!Test.isRunningTest()) results.Tax = OneSourceTaxReqGenerator.GetGeneratedTaxFromInspectionResults(results.InspectionResults);
            if (!Test.isRunningTest() && results.Tax == null) return results;
            results.Total = results.Subtotal + results.Tax;
        }
        //addition for retailer case accept charges== Start
        else if (results.PaidInspectionResults != null && results.PaymentMethod != 'None') 
        {
            if(cse.Invoiced_Subtotal__c == 0 &&  cse.Invoiced_Total__c == 0 && cse.Invoiced_Tax__c== 0){
                results.InvoicedSubtotal = OneSourceTaxReqGenerator.GetSubtotalFromInspectionResults(results.PaidInspectionResults);
                system.debug('results.Subtotal::: ' + results.InvoicedSubtotal);
                results.InvoicedTax = 0.00;
                results.InvoicedTotal = null; //set to null
                results.CurrencyCode = results.PaidInspectionResults[0].Currency__c;
                
                if(!Test.isRunningTest()) results.InvoicedTax = OneSourceTaxReqGenerator.GetGeneratedTaxFromInspectionResults(results.PaidInspectionResults);
                if (!Test.isRunningTest() && results.InvoicedTax == null) return results;
                results.InvoicedTotal = results.InvoicedSubtotal + results.InvoicedTax;
            }
        }
        //addition for retailer case== end
        return results;
    }

    /*
    * Function: PostTaxedInspectionResults
    * --------------------
    * Lightning enabled function to support posting case related pending payment to TR OneSource
    * 
    *  caseId: Id of the parent case
    *
    *  returns: TaxedInspectionResultStruct
    */
    @AuraEnabled
    public static TaxedInspectionResultStruct PostTaxedInspectionResults(Id caseId){
        TaxedInspectionResultStruct results = new TaxedInspectionResultStruct();
        results.InspectionResults = getPendingInspectionResults(caseId);
        if (results.InspectionResults == null) return null;
        results.Subtotal = OneSourceTaxReqGenerator.GetSubtotalFromInspectionResults(results.InspectionResults);
        results.Tax = 0.00;
        results.Total = null; //set to null
        results.CurrencyCode = results.InspectionResults[0].Currency__c;
        
        if(!Test.isRunningTest()) results.Tax = OneSourceTaxReqGenerator.PostGeneratedTaxFromInspectionResults(results.InspectionResults);
        if (!Test.isRunningTest() && results.Tax == null) return results;
        
        results.Total = results.Subtotal + results.Tax;
        
        return results;
    }
}