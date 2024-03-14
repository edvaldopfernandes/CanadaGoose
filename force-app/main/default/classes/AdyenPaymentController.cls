global with sharing class AdyenPaymentController {
    public String PaymentConfirmationStatus {get; set;}
    public String PageURL {get; set;}
    public String caseNumber {get; set;}
    public String HPP_ENDPOINT {
        get {
                        Id caseid = apexpages.currentpage().getparameters().get('id');	
            Case CustomerCase = [SELECT Id, PayByLinkURL__c FROM Case WHERE Id=:CaseId];	
            if(CustomerCase.PayByLinkURL__c == null){	
                return null;	
            }	
            return CustomerCase.PayByLinkURL__c; //Adyen_HPP_Warranty__c.getOrgDefaults().HPP_Endpoint__c; 
        }
    }
    
	public class VerificationResponse
    {
        public String PaymentConfirmationStatus;
        public String caseNumber;
    }
    	
        
    
    @AuraEnabled
    public static String getHPPReceivedPaymentVerification(String URL){
        //Get Params
        system.debug('In Server');
        system.debug('URL:'+ URL);
        Map<String,String> MapParams= new Map<String,String>();
        Set<String> setParams= new Set<String>();
        MapParams = (Map<String, String>) JSON.deserialize(URL,Map<String,String>.class);
        
        system.debug('MapParams');
        system.debug(MapParams);
        setParams=MapParams.keySet();
        
        VerificationResponse VR = new VerificationResponse();
        
        ////////////////////////////////////////////////////////
        system.debug('MapParams');
        system.debug(MapParams);
        //extract caseId from the query params
        String CaseId = MapParams.get('merchantReference').split('-')[0];
        VR.caseNumber = CaseId;
        system.debug('authResult');
        system.debug(MapParams.get('authResult'));
        
        //only proceed if the status of the payment is Authorised
        if (MapParams.get('authResult') != 'AUTHORISED') {
            VR.PaymentConfirmationStatus=System.Label.Warranty_Adyen_Message_UnSuccessful;
            system.debug(System.Label.Warranty_Adyen_Message_UnSuccessful);
            return JSON.serialize(VR);
        }
        
        
        
        //store paymentMerchantSig
        String PaymentMerchantSig =  MapParams.get('merchantSig');
       
        //remove merchantSig from Set of Params
        
        setParams.remove('merchantSig');
        
        //get a list of params and sort it
        List<String> listParams = new List<String>(setParams);
        listParams.sort();
        
        //calculate merchantSig 
        String MerchantSig = getMerchantSig(listParams,MapParams,true);

        //make sure Payment merchantSig is equal to Calculated merchantSig
        if (MerchantSig != PaymentMerchantSig) {
            VR.PaymentConfirmationStatus = System.Label.Warranty_Adyen_Message_Tamperred;
            system.debug(System.Label.Warranty_Adyen_Message_Tamperred);
            return JSON.serialize(VR);
        }
      
        Case PaidCase = [SELECT Id, Account.ShippingCountryCode, Payment_Salesforce_Reference__c,Payment_Adyen_Reference__c FROM Case WHERE Id = :CaseId];
        
        //check validity and duplication on the claim
        if ((PaidCase.Payment_Salesforce_Reference__c == MapParams.get('merchantReference')) && (PaidCase.Payment_Adyen_Reference__c != MapParams.get('pspReference'))){
            PaidCase.Payment_Adyen_Reference__c = MapParams.get('pspReference');
        } else {  VR.PaymentConfirmationStatus = System.Label.Warranty_Adyen_Message_Duplicate;
            return JSON.serialize(VR); 
        }
        
        InspectionResultsUtility.TaxedInspectionResultStruct TaxedResults = new InspectionResultsUtility.TaxedInspectionResultStruct();
        //mark tax as paid
        try{	TaxedResults = InspectionResultsUtility.PostTaxedInspectionResults(CaseId);
        }
        catch(Exception e)
        { 	return JSON.serialize(VR);
        }

        if (TaxedResults==null)
        {	VR.PaymentConfirmationStatus = System.Label.Warranty_Adyen_Message_TaxCalculationFailed; return JSON.serialize(VR);
        }
        if (TaxedResults.Total == null)
        {	VR.PaymentConfirmationStatus = System.Label.Warranty_Adyen_Message_TaxCalculationFailed; return JSON.serialize(VR);
        }
        //create an invoice
        List<Invoice__c> relatedInvoice = new List<Invoice__c>();
        for(Invoice__c inv : [Select Name,id,Payment_Method__c,Status__c,Case__c,Subtotal__c,Tax__c,Total__c,
                                  PSP_Reference__c,Adyen_Auth_code__c,Settlement_Date__c,External_Company_ID__c 
                                  from Invoice__c where Case__c= :CaseId limit 1]){
                                      
                                      //  Subtotal, Tax, Total, 
                                      inv.Status__c = 'Paid'; inv.Subtotal__c = TaxedResults.Subtotal; inv.Tax__c = TaxedResults.Tax; inv.Total__c = TaxedResults.Total;
                                      //  PSPreference field, SF Auth code,
                                      inv.PSP_Reference__c 	= MapParams.get('pspReference'); inv.Payment_Method__c 	= MapParams.get('paymentMethod'); inv.Adyen_Auth_code__c 	= PaymentMerchantSig;
                                      inv.Settlement_Date__c 	= System.Datetime.now();
                                      //    Country OR External CompanY ID (Field from OneSource),GRAND TOTAL FOR Amount Settled for date range
                                      inv.External_Company_ID__c = Utilities.GetCountrySetting(PaidCase.Account.ShippingCountryCode).ExternalCompanyId;
                                      
                                      //update relatedInvoice;
                                      relatedInvoice.add(inv);
                                      
                                  }
        if(relatedInvoice.size()>0)
        {
            update relatedInvoice;
            //assign the invoice to Inspection results
            for(Inspection_Result__c Insp : TaxedResults.InspectionResults)
            {	Insp.Invoice__c = relatedInvoice[0].Id;
            }
            update TaxedResults.InspectionResults;
        }
        else
        {
            Invoice__c Invoice = new Invoice__c ( Case__c = CaseId , Subtotal__c = TaxedResults.Subtotal  , Tax__c = TaxedResults.Tax , Total__c = TaxedResults.Total
                , PSP_Reference__c 	= MapParams.get('pspReference') , Payment_Method__c = MapParams.get('paymentMethod') , Adyen_Auth_code__c 	= PaymentMerchantSig
                , Settlement_Date__c 	= System.Datetime.now() , External_Company_ID__c = Utilities.GetCountrySetting(PaidCase.Account.ShippingCountryCode).ExternalCompanyId);
            insert Invoice;
            //assign the invoice to Inspection results
            for(Inspection_Result__c Insp : TaxedResults.InspectionResults)
            {
                Insp.Invoice__c = invoice.Id;
            }
            update TaxedResults.InspectionResults;
        }     
        

        
        
        //mark the case as paid
        PaidCase.Payment_Made__c = true;
        update PaidCase;
        
        //display the payment page
        VR.PaymentConfirmationStatus = System.Label.Warranty_Adyen_Message_Successful +  ': ' + MapParams.get('pspReference');
        //https://uat-canadagoose.cs9.force.com/warranty/s/case/
        
        return JSON.serialize(VR);
        ////////////////////////////////////////////////////////
        
    }
    
 	/**
	* Validates response sent from Adyen
	*@return a response indicating whether the payment weas successful
	*/
    public PageReference getHPPReceivedPaymentVerification() {
        //Get Params
        Map<String,String> MapParams= new Map<String,String>();
        Set<String> setParams= new Set<String>();

        //error when neither referred nor the merchant sig is set
        system.debug('apexpages.currentPage().getParameters().get(inpval)');
        system.debug(apexpages.currentPage().getParameters().get('inpval'));
        system.debug('ApexPages.currentPage()');
        system.debug(ApexPages.currentPage());
        system.debug('pageParams');
        system.debug(ApexPages.currentPage().getParameters());
        system.debug('header');
        system.debug(ApexPages.currentPage().getHeaders());
        system.debug('ApexPages.currentPage().getHeaders().get(Referer)');
        system.debug(ApexPages.currentPage().getHeaders().get('Referer'));
        system.debug('ApexPages.currentPage().getHeaders().get(Host)');
        system.debug(ApexPages.currentPage().getHeaders().get('Host'));
        system.debug('ApexPages.currentPage().getParameters().get(merchantSig)');
        system.debug(ApexPages.currentPage().getParameters().get('merchantSig'));
        system.debug('ApexPages.currentPage().getParameters().get(referralUrl)');
        system.debug(ApexPages.currentPage().getParameters().get('referralUrl'));
        
        if (ApexPages.currentPage().getParameters().get('merchantSig') == null && ApexPages.currentPage().getHeaders().get('Referer')==null)
        {
            PaymentConfirmationStatus=System.Label.Warranty_Adyen_Message_UnSuccessful;
            system.debug(System.Label.Warranty_Adyen_Message_UnSuccessful);
            return null;
        }

        //if it is in communities
        if (ApexPages.currentPage().getParameters().get('merchantSig') == null)
        {
            
            String Referrer = ApexPages.currentPage().getHeaders().get('Referer');
            system.debug(Referrer);
            URL Url = new URL(referrer);
    		String Query = Url.getQuery();
    		String[] Pairs = Query.split('&');
            for (String Pair : Pairs) {
                if (pair!=null)
                {
                    
                    List<String> PairSplit = Pair.split('=');
                    String FirstParam=pairSplit[0];
                    String SecondParam=pairSplit[1];
                    String Decoded = EncodingUtil.urlDecode(PairSplit[1],'UTF-8');
                    
                    MapParams.put(PairSplit[0], EncodingUtil.urlDecode(PairSplit[1],'UTF-8'));
                }
            }
        }
        else {
            MapParams = ApexPages.currentPage().getParameters();            
        }
        system.debug('MapParams');
        system.debug(MapParams);
        //extract caseId from the query params
        String CaseId = MapParams.get('merchantReference').split('-')[0];
        caseNumber = CaseId;
        
        
        //only proceed if the status of the payment is Authorised
        if (MapParams.get('authResult') != 'AUTHORISED') {
            PaymentConfirmationStatus=System.Label.Warranty_Adyen_Message_UnSuccessful;
            system.debug(System.Label.Warranty_Adyen_Message_UnSuccessful);
            return null;
        }
        
        setParams=MapParams.keySet();
        
        //store paymentMerchantSig
        String PaymentMerchantSig =  MapParams.get('merchantSig');
       
        //remove merchantSig from Set of Params
        setParams.remove('merchantSig');
        
        //get a list of params and sort it
        List<String> listParams=new List<String>(setParams);
        listParams.sort();
        
        //calculate merchantSig 
        String MerchantSig = getMerchantSig(listParams,MapParams,true);

        //make sure Payment merchantSig is equal to Calculated merchantSig
        if (MerchantSig != PaymentMerchantSig) {
            PaymentConfirmationStatus = System.Label.Warranty_Adyen_Message_Tamperred;
            system.debug(System.Label.Warranty_Adyen_Message_Tamperred);
            return null;
        }
        
        Case PaidCase = [SELECT Id, Account.ShippingCountryCode, Payment_Salesforce_Reference__c,Payment_Adyen_Reference__c FROM Case WHERE Id = :CaseId];
        
        //check validity and duplication on the claim
        if ((PaidCase.Payment_Salesforce_Reference__c == MapParams.get('merchantReference')) && (PaidCase.Payment_Adyen_Reference__c != MapParams.get('pspReference'))){
            PaidCase.Payment_Adyen_Reference__c = MapParams.get('pspReference');
        } else {
            PaymentConfirmationStatus = System.Label.Warranty_Adyen_Message_Duplicate;
            system.debug(System.Label.Warranty_Adyen_Message_Duplicate);
            return null; 
        }
        
        InspectionResultsUtility.TaxedInspectionResultStruct TaxedResults = new InspectionResultsUtility.TaxedInspectionResultStruct();
        //mark tax as paid
        try{
            TaxedResults = InspectionResultsUtility.PostTaxedInspectionResults(CaseId);
        }
        catch(Exception e)
        {
            system.debug(Label.Warranty_Adyen_Message_TaxCalculationFailed);
            return null;
        }

        if (TaxedResults==null)
        {
            PaymentConfirmationStatus = System.Label.Warranty_Adyen_Message_TaxCalculationFailed;
            system.debug(System.Label.Warranty_Adyen_Message_TaxCalculationFailed);
            return null;
        }
        if (TaxedResults.Total == null)
        {
            PaymentConfirmationStatus = System.Label.Warranty_Adyen_Message_TaxCalculationFailed;
            system.debug(System.Label.Warranty_Adyen_Message_TaxCalculationFailed);
            return null;
        }
        //create an invoice
        Invoice__c Invoice = new Invoice__c (
            //Case Number or ID, Invoice Number, Settlement Date, payment method i.e Visa
            Case__c = CaseId
            //  Subtotal, Tax, Total, 
            , Subtotal__c = TaxedResults.Subtotal
            , Tax__c = TaxedResults.Tax
            , Total__c = TaxedResults.Total
            //  PSPreference field, SF Auth code,
            , PSP_Reference__c 	= MapParams.get('pspReference')
            , Payment_Method__c 	= MapParams.get('paymentMethod')
            , Adyen_Auth_code__c 	= PaymentMerchantSig
            , Settlement_Date__c 	= System.Datetime.now()
            //    Country OR External CompanY ID (Field from OneSource),GRAND TOTAL FOR Amount Settled for date range
            , External_Company_ID__c = Utilities.GetCountrySetting(PaidCase.Account.ShippingCountryCode).ExternalCompanyId
        );
        insert Invoice;

        //assign the invoice to Inspection results
        for(Inspection_Result__c Insp : TaxedResults.InspectionResults)
        {
            Insp.Invoice__c = invoice.Id;
        }
        update TaxedResults.InspectionResults;
        
        //mark the case as paid
        PaidCase.Payment_Made__c = true;
        update PaidCase;
        
        //display the payment page
        PaymentConfirmationStatus = System.Label.Warranty_Adyen_Message_Successful +  ': ' + MapParams.get('pspReference');
        //https://uat-canadagoose.cs9.force.com/warranty/s/case/
        
        return null;
    }

    /**
	* Creates an Adyen form to be posted to the HPP
	*https://docs.adyen.com/developers/features/hosted-payment-pages/payment-request
	*@return a json response to be inputted into the valid post form
	*/
    @RemoteAction
    global static String getHppform(Id CaseId, String OrderNumber) 
    {
        
        system.debug('Getting HPP form');
        //Documantation: https://docs.adyen.com/developers/features/hosted-payment-pages/hmac-signature-calculation
        String UserName = UserInfo.getUserName();
        String Locale = UserInfo.getLocale();
        //meta data is not supported at this moment
        //String allowedMethods,blockedMethods,brandCode,countryCode,currencyCode,issuerId,merchantAccount,merchantReference,merchantReturnData,merchantSig,offset,orderData,paymentAmount,resURL,sessionValidity,shipBeforeDate,shopperEmail,shopperLocale,shopperReference,shopperStatement,skinCode,resURL;
        
        //Note some variables have been removed from the request for compatibility purposes: 'allowedMethods','blockedMethods','issuerId','offset','resURL'
        Set<String> setParams = new Set<String> {
            'brandCode', 'countryCode', 'currencyCode', 'merchantAccount', 'merchantReference', 'merchantReturnData', 'merchantSig'
            , 'orderData', 'paymentAmount', 'sessionValidity', 'shipBeforeDate', 'shopperEmail', 'shopperLocale', 'shopperReference'
            , 'shopperStatement' , 'skinCode', 'resURL'
        };

        setParams.remove('merchantSig');
        List<String> listParams = new List<String>(setParams);
        listParams.sort();
        Map<String,String> mapParams = new Map<String,String>();
        //////////set hpp params///////////////
        Case CustomerCase = [SELECT Id, Status, Account.ShippingAddress, Account.ShippingCountryCode, Account.Currency__c, Payment_Pending__c
                    FROM Case
                    WHERE Id=:CaseId];

        //set payment method
        String PaymentMethod = Utilities.GetCountrySetting(CustomerCase.Account.ShippingCountryCode).PaymentMethod;
        
        //only load the page if payment is pending
        if((CustomerCase.Payment_Pending__c == 0
            || CustomerCase.Status == 'New_Validate'
            || CustomerCase.Status == 'Waiting On Product'
            || CustomerCase.Status == 'Cleaning'
            || CustomerCase.Status == 'Inspecting'
            || CustomerCase.Status == 'Pending Customer Feedback'
            || CustomerCase.Status == 'Check In With Customer'))
        {
            return null;
        }
        else if (PaymentMethod == 'Adyen') {
            String Temp;
            //set country code
            Temp = CustomerCase.Account.ShippingCountryCode;
            validateParam(Temp,'Country code is not set');            
            mapParams.put('countryCode',Temp);
            
            //set currency code
            Temp = CustomerCase.Account.Currency__c;
            validateParam(Temp,'Currencycode is not set');
            mapParams.put('currencyCode',Temp);
            
            //setting country based merchant account
            Temp = Utilities.GetCountrySetting(CustomerCase.Account.ShippingCountryCode).AdyenMerchantAccount;
            validateParam(Temp,'merchant Account is not found');
            mapParams.put('merchantAccount',Temp);
            
            //set merchant reference used in the response
            Temp = CaseId + '-'+datetime.now().formatGMT('yyyyMMddHHmmss');
            validateParam(Temp,'merchantReference is not set');
            mapParams.put('merchantReference',Temp);
            
            //set session validity for payment
            Temp = datetime.now().formatGMT('yyyy-MM-dd')+'T'+datetime.now().addMinutes(Integer.valueOf(Adyen_HPP_Warranty__c.getOrgDefaults().Session_Validity_Minutes__c)).formatGMT('HH:mm:ss')+'Z';
            validateParam(Temp,'sessionValidity is not set');
            mapParams.put('sessionValidity',Temp);
            
            //set ship before date using SLA agreement
            Temp = datetime.now().addDays(Integer.valueOf(Adyen_HPP_Warranty__c.getOrgDefaults().Service_Level_Agreement__c)).formatGMT('yyyy-MM-dd');
            validateParam(Temp,'shipBeforeDate is not set');
            mapParams.put('shipBeforeDate',Temp);
            
            //set payment amount
            InspectionResultsUtility.TaxedInspectionResultStruct  taxedPayment = new  InspectionResultsUtility.TaxedInspectionResultStruct();
            //run code if not in test mode
            if (!Test.isRunningTest()){
                try{
                    taxedPayment = InspectionResultsUtility.getTaxedInspectionResults(CaseId);   
                }
                catch(Exception e)
                {
                    system.debug(System.Label.Warranty_Adyen_Message_TaxCalculationFailed);
                    return null;
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
            mapParams.put('paymentAmount',Temp);
            
            // set shopperEmail
            Temp= UserInfo.getUserEmail();
            validateParam(Temp, 'Shopper Email does not exist');
            mapParams.put('shopperEmail',Temp);
            
            // set shopperLocale to set the language
            Temp = UserInfo.getLocale();
            validateParam(Temp, 'Shopper Locale does not exist');
            mapParams.put('shopperLocale',Temp);
            
            //set shopperReference
            Temp = CaseId;
            validateParam(Temp, 'shopperReference is not set');
            mapParams.put('shopperReference',Temp);
            
            //set skin Code
            Temp = String.valueOf(Adyen_HPP_Warranty__c.getOrgDefaults().Skin_Code__c);
            validateParam(Temp, 'Skin code of HPP is not set');
            mapParams.put('skinCode',Temp);
            
            //set results URL
            Temp = String.valueOf(Adyen_HPP_Warranty__c.getOrgDefaults().Results_Callback_URL__c);
            validateParam(Temp, 'Results URL of HPP is not set');
            mapParams.put('resURL', Temp);
            
            String MerchantSig = getMerchantSig(listParams, mapParams, false);
            
            listParams.add('merchantSig');
            listParams.sort();
            mapParams.put('merchantSig', MerchantSig);
        
            //set salesforce payment reference
            CustomerCase.Payment_Salesforce_Reference__c = mapParams.get('merchantReference');
            update CustomerCase;
        }
        String HPPform = getJsonResponse(listParams, mapParams);

        return HPPform;
    }
    
    /**
	* Creates an Adyen based string for merchant signature
	*https://docs.adyen.com/developers/features/hosted-payment-pages/hmac-signature-calculation
	*@return valid string to be concatenated to generate a 
	*/
    public static String getValidAdyenString(String beforeValidation)
    {
        return beforeValidation.replace('\\', '\\\\').replace(':', '\\:');
    }
    
    /**
	* creates a merchant signature using a set of params for both validation and payment request
	*@return a merchant signature
	*/
    public static String getMerchantSig(List<String> SortedParams, Map<String,String> Params, boolean UrlEncoded)
    {
        // concatenated and delimited key-value pairs
        String ParamKey, ParamValue, ParamValueUrlDecoded, ParamValueAdyenValid;
        String Concat_1 = '';
        String Concat_2 = '';

        //create a string to be hashed via hmac key               
		for (Integer i = 0; i < SortedParams.size(); i++) {
            ParamKey = SortedParams[i];
            ParamValue = Params.get(ParamKey);
            if (ParamValue == null)
            {
                ParamValue='';
            }
             
            if (i != 0)
            {
                Concat_1 += ':';
                Concat_2 += ':'; 
            }
            
            ParamValueUrlDecoded = (UrlEncoded?EncodingUtil.urlDecode(ParamValue, 'UTF-8'):ParamValue);
            ParamValueAdyenValid = getValidAdyenString(ParamValueUrlDecoded);
            Concat_1 += ParamKey;
            Concat_2 += ParamValueAdyenValid;
        }
        
        String Concatenated = Concat_1 + ':' + Concat_2;
        
        Blob privateKeyBlob = EncodingUtil.convertFromHex(Adyen_HPP_Warranty__c.getOrgDefaults().HMAC_Key__c);
        //calculate the hmac generated hash of string
        String MerchantSig = EncodingUtil.base64Encode(crypto.generateMac('HmacSHA256', Blob.valueOf(Concatenated), privateKeyBlob));
        
		return merchantSig;        
    }
    
    /**
	* Create an Adyen based Json response 
	*/
    public static String getJsonResponse ( List<String> listParams, Map<String,String> MapParams )
    {      
        String ParamKey,ParamValue,ParamValueUrlEncoded;
        String Json = '{';
        //initialize the first parameter               
		for (Integer i=0;i<listParams.size();i++)
        {
            ParamKey=listParams[i];
            ParamValue=MapParams.get(ParamKey);
            if (ParamValue == null)
            {
               ParamValue ='';               
            }
            if (i!=0)
            {
                Json += ','; 
            }
            ParamValueUrlEncoded=EncodingUtil.urlEncode(ParamValue, 'UTF-8');
            Json+='"'+ParamKey+'":"'+ParamValueUrlEncoded+'"';
        }
        Json += '}';   
		return Json;        
    }
	
    /**
	* Throw an exception if the parameter is null
	*/
    @TestVisible
    private static void validateParam (object Parameter, String Message)
    {
        if (Parameter == null)
        {
            system.debug(Message);
            CalloutException e = new CalloutException();
            e.setMessage(Message);
            throw e;
        }
        system.debug('Not happened'+Message);
    } 
}