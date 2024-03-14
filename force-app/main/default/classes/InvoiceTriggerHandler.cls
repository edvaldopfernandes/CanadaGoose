public class InvoiceTriggerHandler {
    /*
    * Function: OnBeforeInsert
    * --------------------
    * Trigger handler for the Before Insert event
    *
    *  lstNewInvoices: List of the new Invoice records being inserted
    *  mapNewInvoices: Map of the new Invoice records being inserted
    *
    *  returns: N/A
	*/
    public static void OnBeforeInsert(List<Invoice__c> lstNewInvoices, Map<Id, Invoice__c> mapNewInvoices) {
        Map<Id, Invoice__c> mapCaseIdToInvoice = new Map<Id, Invoice__c>();

        for (Invoice__c inv : lstNewInvoices) {
            // Invoice is created in Draft and payment method is a Wire-Transfer
            // or Invoice is created for an Adymen payment
            if ((inv.Status__c == 'Draft' && inv.Payment_Method__c == 'wire-transfer')
                || (inv.Status__c == 'Paid' && inv.Payment_Method__c != 'wire-transfer')) {
                mapCaseIdToInvoice.put(inv.Case__c, inv);
            }
            else if ((inv.Status__c == 'Draft' && inv.Payment_Method__c == 'Adyen')
                || (inv.Status__c == 'Paid' && inv.Payment_Method__c != 'Adyen')) {
                mapCaseIdToInvoice.put(inv.Case__c, inv);
            }
        }

        // Get all pending inspection results belonging to the parent cases
        if (!mapCaseIdToInvoice.isEmpty()) {
            List<Inspection_Result__c> lstInspectionResult = InspectionResultsUtility.getInspectionResults(mapCaseIdToInvoice.keySet(), true);

            if (lstInspectionResult != null && !lstInspectionResult.isEmpty()) {
                Map<Id, List<Inspection_Result__c>> mapCaseIdToInspections = new Map<Id, List<Inspection_Result__c>>();

                for (Inspection_Result__c inspection : lstInspectionResult) {
                    if (mapCaseIdToInspections.containsKey(inspection.Case__c))
                        mapCaseIdToInspections.get(inspection.Case__c).add(inspection);
                    else
                        mapCaseIdToInspections.put(inspection.Case__c, new List<Inspection_Result__c> {inspection});
                }

                if (!mapCaseIdToInspections.isEmpty()) {
                    for (Id caseId : mapCaseIdToInspections.keySet()) {
                        if (mapCaseIdToInvoice.containsKey(caseId)) {
                            ConvertInspectionsToHtml(mapCaseIdToInvoice.get(caseId), mapCaseIdToInspections.get(caseId));
                        }
                    }
                }
            }
        }
    }
    
    /*
    * Function: OnAfterInsert 
    * --------------------
    * Trigger handler for the After Update event
    *
    *  lstNewInvoices: List of the new Invoice records being inserted
    *  mapNewInvoices: Map of the new Invoice records being inserted
    *
    *  returns: N/A
	*/
    public static void OnAfterInsert(List<Invoice__c> lstNewInvoices, Map<Id, Invoice__c> mapNewInvoices) {
        Map<Id, Id> mapCaseToInvoiceId = new Map<Id, Id>();
        
        // Get the parent cases
        for (Invoice__c inv : lstNewInvoices) {
            // Invoice is created in Draft and payment method is a Wire-Transfer
            if (inv.Status__c == 'Draft' && inv.Payment_Method__c == 'wire-transfer') {
                mapCaseToInvoiceId.put(inv.Case__c, inv.Id);

                CalculateTaxForWireTransferInvoice(inv.Id, inv.Case__c);
            }
            else if (inv.Status__c == 'Draft' && inv.Payment_Method__c == 'Adyen') {
                mapCaseToInvoiceId.put(inv.Case__c, inv.Id);
				list<Invoice__c> listOfInvoices = new list<Invoice__c>();
      			listOfInvoices = checkInvoices(inv.Case__c, inv.Id);
                if(listOfInvoices != Null && listOfInvoices.size() >0){
                    update listOfInvoices;
                }
                CalculateTaxForWireTransferInvoice(inv.Id, inv.Case__c);
                generatePayLink(inv.Case__c);
            }
        }

        // Get all pending inspection results belonging to the parent cases
        if (!mapCaseToInvoiceId.isEmpty()) {
            List<Inspection_Result__c> lstInspectionResult =
                [SELECT Id, Case__c
                 FROM Inspection_Result__c
                 WHERE Case__c IN :mapCaseToInvoiceId.keySet()
                     AND Status__c = 'New' 
                     AND Case__r.Payment_pending__c > 0
                     AND Case__r.Status NOT IN ('New_Validate', 
                                                'Waiting On Product',
                                                'Cleaning',
                                                'Inspecting',
                                                'Pending Customer Feedback')];

            if (!lstInspectionResult.isEmpty()) {
                // Assign all pending inspection results to the new created invoices
                for (Inspection_Result__c ir : lstInspectionResult) {
                    ir.Invoice__c = mapCaseToInvoiceId.get(ir.Case__c);
                }
                
                update lstInspectionResult;
            }
        }
    }

    /*
    * Function: CalculateTaxForWireTransferInvoice 
    * --------------------
    * Calculate the required taxes for the wire transfer invoices
    *
    *  InvoiceId: related invoice record id
    *  CaseId: related case record id
    *
    *  returns: N/A
    */
    @future (callout=true)
    private static void CalculateTaxForWireTransferInvoice(Id InvoiceId, Id CaseId) {
        InspectionResultsUtility.TaxedInspectionResultStruct TaxedInspections;
		
        try{
            TaxedInspections = InspectionResultsUtility.getTaxedInspectionResults(CaseId);
        }
        catch(Exception e) {
            system.debug('InvoiceTriggerHandler Error Message: ' + e.getMessage());
            system.debug('InvoiceTriggerHandler Error Line No: ' + e.getLineNumber());
            system.debug(Label.Warranty_Adyen_Message_TaxCalculationFailed);
        }

        if (TaxedInspections == null) {
            system.debug(System.Label.Warranty_Adyen_Message_TaxCalculationFailed);
            return;
        }

        if (TaxedInspections.Total == null) {
            system.debug(System.Label.Warranty_Adyen_Message_TaxCalculationFailed);
            return;
        }

        Invoice__c Invoice = new Invoice__c (
            Id = InvoiceId
            , Status__c = 'Ready'
            , Subtotal__c = TaxedInspections.Subtotal
            , Tax__c = TaxedInspections.Tax
            , Total__c = TaxedInspections.Total
        );
        system.debug('TaxedInspections: ' + TaxedInspections);
        system.debug('TaxedInspections.InspectionResults: ' + TaxedInspections.InspectionResults);
        
        if (!(TaxedInspections.InspectionResults == null)) { //changed by adnan ashfaq (removed .isEmpty())
            Invoice.External_Company_ID__c = Utilities.GetCountrySetting(TaxedInspections.InspectionResults[0].Case__r.Account.ShippingCountryCode).ExternalCompanyId;
        }

        update Invoice;
    }

    /*
    * Function: ConvertInspectionsToHtml 
    * --------------------
    * Convert inspection results record into an HTML Table format to be used in an email template
    *
    *  Invoice: related invoice record
    *  InspectionResults: inspection results to be converted into HTML
    *
    *  returns: N/A
    */
    private static void ConvertInspectionsToHtml(Invoice__c Invoice, List<Inspection_Result__c> InspectionResults) {
        if (Invoice != null && !InspectionResults.isEmpty()) {
            String sLanguage = InspectionResults[0].Case__r.Account.Language__c;
            
            String sHTMLOutput = '';
            
            for (Inspection_Result__c ir : InspectionResults) {
                sHTMLOutput += '<tr><td>';
                
                if (sLanguage == 'fr')
                    sHTMLOutput += ir.Repair__r.Name_FR__c;
                else if (sLanguage == 'de')
                    sHTMLOutput += ir.Repair__r.Name_DE__c;
                else if (sLanguage == 'zh_CN')
                    sHTMLOutput += ir.Repair__r.Name_ZH__c;
                else if (sLanguage == 'it')
                    sHTMLOutput += ir.Repair__r.Repair_Name_IT__c;
                else
                    sHTMLOutput += ir.Repair__r.Name;
                
                sHTMLOutput += '</td><td>' + ir.Currency__c + ' ' + ir.Display_Price__c + '</td></tr>';
            }
            
            Invoice.Inspection_Result_HTML__c = sHTMLOutput;
        }
    }
    
     @future(callout=true)
    public static void generatePayLink(Id CaseId) {
		String UserName = UserInfo.getUserName();
        String varShopperLocale = '';
		String varCountryCode = '';
		String varCurrencyCode = '';
		String varMerchantAccount = '';
		String varShopperReference = '';
		String varValue = '';
		String varReference = '';
		String temp = '';
		String varAPIKey = '';
		PayLinkResponseParser payLinkData ;
        Case CustomerCase = new Case();
		
		CustomerCase = [SELECT Id, Status, Account.ShippingAddress, Account.ShippingCountryCode, 
                        Account.Currency__c, Payment_Pending__c, PayLinkId__c, PayByLinkURL__c,
                        PayByLinkStatus__c, PayByLinkExpireAt__c
                    FROM Case
                    WHERE Id=:CaseId];
        
        varAPIKey = Utilities.GetCountrySetting(CustomerCase.Account.ShippingCountryCode).apiKey;
        
        varShopperLocale = Utilities.GetCountrySetting(CustomerCase.Account.ShippingCountryCode).LocaleEnglish;
		
			//set country code
            temp = CustomerCase.Account.ShippingCountryCode;
            validateParam(temp,'Country code is not set');            
            varCountryCode = temp;
            
            //set currency code
            temp = CustomerCase.Account.Currency__c;
            validateParam(temp,'Currencycode is not set');
            varCurrencyCode = temp;
            
            //setting country based merchant account
            temp = Utilities.GetCountrySetting(CustomerCase.Account.ShippingCountryCode).AdyenMerchantAccount;
            validateParam(temp,'merchant Account is not found');
            varMerchantAccount = temp;
            
            //set merchant reference used in the response
            temp = CaseId + '-'+datetime.now().formatGMT('yyyyMMddHHmmss');
            validateParam(temp,'merchantReference is not set');
            varReference = temp;
            
           //set payment amount
            InspectionResultsUtility.TaxedInspectionResultStruct  taxedPayment = new  InspectionResultsUtility.TaxedInspectionResultStruct();
            //run code if not in test mode
            if (!Test.isRunningTest()){
                try{
                    taxedPayment = InspectionResultsUtility.getTaxedInspectionResults(CaseId);   
                }
                catch(Exception e){
                    system.debug(System.Label.Warranty_Adyen_Message_TaxCalculationFailed);
                }
            }
            else{
                taxedPayment = new InspectionResultsUtility.TaxedInspectionResultStruct();
            }
            validateParam(taxedPayment.Total,'One Source tax was not calculated');
            //Assumption: minor currency units have been assumed to be 2 decimal points
            //future integration of https://docs.adyen.com/developers/currency-codes
            Temp=String.valueOf(Integer.valueOf(taxedPayment.Total*100));
            validateParam(Temp,'One Source total was not calculated');
            varValue = Temp;
           
            //set shopperReference
            Temp = CaseId;
            validateParam(Temp, 'shopperReference is not set');
            varShopperReference = Temp;
            
          	String response = AdyenConnector.createPaymentLink(varAPIKey, varReference, 
																varShopperReference, varValue,
																varCurrencyCode, '', 
                                          						varCountryCode, varMerchantAccount,
                                          						varShopperLocale);  
		 	if(response != null){
				payLinkData = PayLinkResponseParser.parse(response);
		  	}
			System.debug('>>>PaylinkData'+ payLinkData);
           
        	if(payLinkData != null){
                CustomerCase.PayLinkId__c = payLinkData.id;
                CustomerCase.PayByLinkURL__c = payLinkData.url;
                CustomerCase.PayByLinkStatus__c = payLinkData.status;
                CustomerCase.PayByLinkExpireAt__c = payLinkData.expiresAt;
                Update CustomerCase;
           }
	}
     @TestVisible
    private static void validateParam (object Parameter, String Message){
        if (Parameter == null){
            system.debug(Message);
            CalloutException e = new CalloutException();
            e.setMessage(Message);
            throw e;
        }
        system.debug('Not happened'+Message);
    } 
    public static list<Invoice__c> checkInvoices(Id caseId,  id invoiceId){
        list<Invoice__c> listOfInvoices = new list<Invoice__c>();
        if(caseId != Null && invoiceId != NULL ){
            for(Invoice__c inv :[SELECT Id, isLatest__c FROM Invoice__c WHERE case__c =: caseId And Id !=:invoiceId 
                                 AND isLatest__c = true AND Payment_Method__c = 'Adyen']){
                inv.Total__c = 0;
                inv.Subtotal__c = 0;
                inv.Tax__c = 0;                     
                inv.isLatest__c = false;
                listOfInvoices.add(inv);
            }
        }
       return listOfInvoices;
    }   
}