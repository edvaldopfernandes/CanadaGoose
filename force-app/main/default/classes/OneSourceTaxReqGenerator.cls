global with sharing class OneSourceTaxReqGenerator {

    //Custom labels hold authentication details
    static private final String USER_NAME = TROneSource__c.getOrgDefaults().Username__c;
    static private final String PASSWORD = TROneSource__c.getOrgDefaults().Password__c;
    static private final String HOST_SYSTEM = TROneSource__c.getOrgDefaults().Host_System__c;
    static private final String API_ENDPOINT = TROneSource__c.getOrgDefaults().API_Endpoint__c;

    //Class used to hold details for Invoice piece of request
    private class Invoice{
        public String CALCULATION_DIRECTION;
        public String COMPANY_ROLE;
        public String CURRENCY_CODE;
        public String INVOICE_DATE;
        public String INVOICE_NUMBER;
        public String IS_AUDITED;
        public String TRANSACTION_TYPE;
        public String IS_CREDIT;
        public String ORIGINAL_INVOICE_NUMBER;
        public String ORIGINAL_INVOICE_DATE;
        public String EXTERNAL_COMPANY_ID;

        public Invoice(){
            this.CALCULATION_DIRECTION='';
            this.COMPANY_ROLE = '';
            this.CURRENCY_CODE = '';
            this.INVOICE_DATE = '';
            this.INVOICE_NUMBER = '';
            this.IS_AUDITED = '';
            this.TRANSACTION_TYPE = '';
            this.IS_CREDIT = '';
            this.ORIGINAL_INVOICE_NUMBER = '';
            this.ORIGINAL_INVOICE_DATE = '';
            this.EXTERNAL_COMPANY_ID = '';
        }
    }

    //Class used to hold details for each line item of request
    private class LineItem{
        private String LINE_NUMBER;
        private Shipping SHIP_TO;
        private Shipping SHIP_FROM;
        private String COMMODITY_CODE;
        private String PRODUCT_CODE;
        private String GROSS_AMOUNT;

        //Constructor creates two new Shipping objects for SHIP_TO, SHIP_FROM
        public lineItem(){
            this.LINE_NUMBER = '';
            this.SHIP_TO = new Shipping();
            this.SHIP_FROM = new Shipping();
            this.COMMODITY_CODE = '';
            this.PRODUCT_CODE = '';
            this.GROSS_AMOUNT = '';
        }
    }

    //Class used to hold details SHIP_TO,SHIP_FROM of each line item
    private class Shipping{
        private String COUNTRY;
        private String PROVINCE;
        private String STATE;
        private String CITY;
        private String POSTCODE;
        private String GEOCODE;

        public Shipping(){}
        /*
        * Constructor: Shipping 
        * --------------------
        * Trigger handler for the Before Update event
        *
        * postcode: Postal Code
        * city: City Name
        * state: State Code (if US, set state field, else (eg. CA) set province field)
        * country: Country Code
        *
        *  returns: Shipping object
        */
        public Shipping(String postcode, String city, String state, String country){
            this.CITY = city;
            //Code Addition for tax fix--- Start// 
            //this.POSTCODE = postcode;
            this.COUNTRY = country;
            //this.GEOCODE = '';
            
            if(postcode.contains('-'))
            {
                system.debug('- present'+' String :' +postcode);  
                
                this.POSTCODE = postcode.substringBefore('-').replaceAll( '\\s+', '');
                this.GEOCODE = postcode.substringAfter('-').replaceAll( '\\s+', '');
                
                system.debug('postcode : '+this.POSTCODE +'::: gencode : '+this.GEOCODE); 
            }
            else
            {
                system.debug('String :' +postcode);
                
                this.POSTCODE = postcode;
                this.GEOCODE = '';
                
                system.debug('- not present'); 
            }
            //Code Addition for tax fix--- End// 
            
            if (country == 'US'){
                this.STATE = (String.isBlank(state) ? '' : state);
                this.PROVINCE = '';
            }else{
                this.STATE = '';
                this.PROVINCE = (String.isBlank(state) ? '' : state);
            }
        }
    }


    public class GeneralException extends Exception{}

    /*
    * Function: getHeader
    * --------------------
    * Returns header for request to be generated
    * 
    *  inv: Invoice object, which holds the EXTERNAL_COMPANY_ID
    *
    *  returns: header string
    */
    static private String getHeader(Invoice inv){
        string header = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns="http://www.sabrix.com/services/taxcalculationservice/2011-09-01">'+
                        +'<soapenv:Header>'
                        +'<wsse:Security soapenv:mustUnderstand="1" xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd" xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd">'
                        +'<wsse:UsernameToken wsu:Id="UsernameToken-1">'
                        +'<wsse:Username>' + USER_NAME + '</wsse:Username>'
                        +'<wsse:Password Type="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText">' + PASSWORD + '</wsse:Password>'
                        +'</wsse:UsernameToken>'
                        +'</wsse:Security>'
                        +'</soapenv:Header>'
                        +'<soapenv:Body>'
                        +'<ns:taxCalculationRequest>'
                        +'<ns:INDATA version="G">'
                        +'<ns:EXTERNAL_COMPANY_ID>'+inv.EXTERNAL_COMPANY_ID+'</ns:EXTERNAL_COMPANY_ID>'
                        +'<HOST_SYSTEM>'+HOST_SYSTEM+'</HOST_SYSTEM>';
        
        return header;
    }

    /*
    * Function: getFooter
    * --------------------
    * Returns footer for request to be generated
    * 
    *  returns: footer string
    */
    static private String getFooter(){
        return '</ns:INDATA>'
                +'</ns:taxCalculationRequest>'
                +'</soapenv:Body>'
                +'</soapenv:Envelope>';
    }

    /*
    * Function: ComposeInvoiceBodyXML
    * --------------------
    * Builds the invoice body to be used in the request
    * 
    *  inv: Invoice object
    *  lineItems: list of line items for the request
    *
    *  returns: body string
    */
    private static String ComposeInvoiceBodyXML(Invoice inv, List<LineItem> lineItems){
        String invoiceHeader = '<ns:INVOICE>'
               +'<ns:CALCULATION_DIRECTION>'+inv.CALCULATION_DIRECTION+'</ns:CALCULATION_DIRECTION>'
               +'<ns:COMPANY_ROLE>'+inv.COMPANY_ROLE+'</ns:COMPANY_ROLE>'
               +'<ns:CURRENCY_CODE>'+inv.CURRENCY_CODE+'</ns:CURRENCY_CODE>'
               +'<ns:INVOICE_DATE>'+inv.INVOICE_DATE+'</ns:INVOICE_DATE>'
               +'<ns:INVOICE_NUMBER>'+inv.INVOICE_NUMBER+'</ns:INVOICE_NUMBER>'
               +'<ns:IS_AUDITED>'+inv.IS_AUDITED+'</ns:IS_AUDITED>'
               +'<ns:TRANSACTION_TYPE>'+inv.TRANSACTION_TYPE+'</ns:TRANSACTION_TYPE>'
               +'<ns:IS_CREDIT>'+inv.IS_CREDIT+'</ns:IS_CREDIT>'
               +'<ns:ORIGINAL_INVOICE_NUMBER>'+inv.ORIGINAL_INVOICE_NUMBER+'</ns:ORIGINAL_INVOICE_NUMBER>'
               +'<ns:ORIGINAL_INVOICE_DATE>'+inv.ORIGINAL_INVOICE_DATE+'</ns:ORIGINAL_INVOICE_DATE>';

        String lineItemBodies = '';
        for(LineItem l: lineItems){
            String b = '<ns:LINE ID="'+l.LINE_NUMBER+'">'
            +'<ns:LINE_NUMBER>'+l.LINE_NUMBER+'</ns:LINE_NUMBER>'
                +'<ns:SHIP_FROM>'
                    +'<ns:COUNTRY>'+l.SHIP_FROM.COUNTRY+'</ns:COUNTRY>'
                    +'<ns:PROVINCE>'+l.SHIP_FROM.PROVINCE+'</ns:PROVINCE>'
                    +'<ns:STATE>'+l.SHIP_FROM.STATE+'</ns:STATE>'
                    +'<ns:CITY>'+l.SHIP_FROM.CITY+'</ns:CITY>'
                    +'<ns:POSTCODE>'+l.SHIP_FROM.POSTCODE+'</ns:POSTCODE>'
                    +'<ns:GEOCODE>'+l.SHIP_FROM.GEOCODE+'</ns:GEOCODE>'
                +'</ns:SHIP_FROM>'
                +'<ns:SHIP_TO>'
                    +'<ns:COUNTRY>'+l.SHIP_TO.COUNTRY+'</ns:COUNTRY>'
                    +'<ns:PROVINCE>'+l.SHIP_TO.PROVINCE+'</ns:PROVINCE>'
                    +'<ns:STATE>'+l.SHIP_TO.STATE+'</ns:STATE>'
                    +'<ns:CITY>'+l.SHIP_TO.CITY+'</ns:CITY>'
                    +'<ns:POSTCODE>'+l.SHIP_TO.POSTCODE+'</ns:POSTCODE>'
                    +'<ns:GEOCODE>'+l.SHIP_TO.GEOCODE+'</ns:GEOCODE>'
                +'</ns:SHIP_TO>'
                +'<ns:COMMODITY_CODE>'+l.COMMODITY_CODE+'</ns:COMMODITY_CODE>'
                +'<ns:PRODUCT_CODE>'+l.PRODUCT_CODE+'</ns:PRODUCT_CODE>'
                +'<ns:GROSS_AMOUNT>'+l.GROSS_AMOUNT+'</ns:GROSS_AMOUNT>'
                +'</ns:LINE>';
            lineItemBodies += b;
        }
        String invoiceFooter = '</ns:INVOICE>';
        return invoiceHeader + lineItemBodies + invoiceFooter;
    }

    /*
    * Function: GenerateXMLBody
    * --------------------
    * Returns the full request body
    * 
    * inv: Invoice object
    * lineItems: list of line items for the request
    *
    * returns: XML request string
    */
    public static String GenerateXMLBody(Invoice inv, List<LineItem> lineItems){
        String body = ComposeInvoiceBodyXML(inv,lineItems);
        return getHeader(inv) + body + getFooter();
    }

    /*
    * Function: PostGeneratedXML
    * --------------------
    * Posts the request to TR OneSource API, and returns the response
    * 
    *  reqbody: XML request string
    *
    *  returns: XML response string
    */
    public static String PostGeneratedXML(String reqbody){

        if (reqbody == null) return null;

        string endpoint = API_ENDPOINT;
        string method = 'POST';
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod(method);
        req.setTimeout(50000);
        req.setBody(reqbody);

        req.setHeader('Content-Type','text/xml');
        req.SetHeader('SOAPACTION','');

        http h = new Http();
        HttpResponse res = null;
        try{
            res = h.send(req);
        }catch(System.CalloutException e){
            return null;
        }
        return res.getBody();
    }

    /*
    * Function: SearchXMLNodeFirst
    * --------------------
    * Recursively searches the given DOM.XMLNode for a tag and returns the value
    * 
    *  nd: DOM.XMLNode to be searched
    *  name: Name of the tag to be searched
    *
    *  returns: DOM.XMLNode node that has the correct name
    */
    public static DOM.XMLNode SearchXMLNodeFirst(DOM.XMLNode nd, String name){
        if (nd != null && nd.getNodeType() == DOM.XMLNodeType.ELEMENT) { //check that node is not null, and is a XML Element Node
            if (nd.getName() == name){
                return nd; //Return the node if the name matches
            }else{
                for(DOM.XMLNode child : nd.getChildren()){
                    DOM.XMLNode nd2 = SearchXMLNodeFirst(child,name); //recursively search the node's children

                    if (nd2 != null) return nd2; //if a non null node is found in a child, return the new node
                }
            }
        }
        return null; //return null if none found
    }

    /*
    * Function: GetGeneratedTax
    * --------------------
    * Posts the request to TR OneSource API, and returns the tax value in the response if successful
    * 
    *  reqbody: XML request string
    *
    *  returns: Decimal that holds generated tax 
    */
    public static Decimal GetGeneratedTax(String reqbody){
        String resbody = OneSourceTaxReqGenerator.PostGeneratedXML(reqbody); //Post request and receive response

        if (resbody==null) return null;

        //create a new DOM.Document from the response, and search for TOTAL_TAX_AMOUNT
        DOM.Document doc = new DOM.Document();

        doc.load(resbody);

        DOM.XMLNode nd = doc.getRootElement();

        DOM.XMLNode nd_tx = SearchXMLNodeFirst(nd,'TOTAL_TAX_AMOUNT');
        DOM.XMLNode nd_success = SearchXMLNodeFirst(nd,'IS_SUCCESS');

        Decimal tx = null;

        try{
            //System.debug(nd.getName());
            //System.debug(nd.getText());
            
            if (nd_success.getText().toUpperCase()=='TRUE')
                tx = Decimal.valueOf(nd_tx.getText()); //get Decimal value from XML Node
        }catch(System.NullPointerException e){
            //System.debug('No node found or no value read');
        }

        System.debug(reqbody);
        System.debug(resbody);
        return tx;
    }

    /*
    * Function: ShippingFromAccount
    * --------------------
    * Given an account, create a Shipping object out of its details
    * 
    *  ac: Account
    *
    *  returns: Shipping
    */
    public static Shipping ShippingFromAccount(Account ac){
        return new Shipping(ac.ShippingPostalCode, ac.ShippingCity, ac.ShippingStateCode, ac.ShippingCountryCode);
    }
    
    /*
    * Function: ShippingFromRepairFacility
    * --------------------
    * Given a Repair Facility, create a Shipping object out of its details
    * 
    *  rf: Repair Facility
    *
    *  returns: Shipping
    */
    public static Shipping ShippingFromRepairFacility(Repair_Facility__c rf){
        return new Shipping(rf.Postal_Code__c, rf.City_Name__c, rf.State_Code__c,rf.Country_Code__c);
    }
    //create Invoice used to generate request body
    private static Invoice GetInvoiceFromCase(Case cs, Account ac, Repair_Facility__c rf, Boolean audited, Boolean credited){
        DateTime dtInvoice = System.Datetime.now();
        Invoice inv = new Invoice();
        
        inv.CALCULATION_DIRECTION = 'F';
        inv.COMPANY_ROLE = 'S';
        inv.CURRENCY_CODE = ac.Currency__c;
        inv.INVOICE_DATE = String.valueOf(dtInvoice);
        inv.INVOICE_NUMBER = String.valueOf(cs.CaseNumber) + dtInvoice.format('_yyyyMMdd_HHmmss');
        inv.IS_AUDITED=String.valueOf(audited);
        inv.TRANSACTION_TYPE = 'GS';
        inv.IS_CREDIT = String.valueOf(credited);
        inv.ORIGINAL_INVOICE_DATE = inv.INVOICE_DATE;
        inv.ORIGINAL_INVOICE_NUMBER = inv.INVOICE_NUMBER;
        //find SHIP_TO EXTERNAL_COMPANY_ID
        Utilities.CountrySetting countrysetting = Utilities.GetCountrySetting(ac.ShippingCountryCode);
        inv.EXTERNAL_COMPANY_ID = countrysetting.ExternalCompanyId;

        return inv;
    }
    
    /*
    * Function: GetLineItemFromInspectionResult
    * --------------------
    * Given parameters, create line item to be used in request
    * 
    *  i: integer for line number
    *  cs: Case used
    *  ac: Account used for shipping details,
    *  rf: Repair Facility used
    *  ir: Inspection Result for creating each line item
    *
    *  returns: LineItem
    */
    private static LineItem GetLineItemFromInspectionResult(Integer i, Case cs, Account ac, Repair_Facility__c rf, Inspection_Result__c ir){
        LineItem item = new LineItem();
        //Repair__c repair = [SELECT CAD__c, EUR__c, GBP__c, SEK__c, USD__c, Repair_Type__c FROM Repair__c WHERE Id=:ir.Repair__c];
        item.LINE_NUMBER=String.valueOf(i);
        item.SHIP_TO = ShippingFromAccount(ac);
        item.SHIP_FROM = ShippingFromRepairFacility(rf);
        item.COMMODITY_CODE = ''; //TODO
        item.PRODUCT_CODE=ir.Repair__r.Product_Code__c;
        item.GROSS_AMOUNT=String.valueOf(ir.Display_Price__c);
        return item;
    }

    /*
    * Function: GetRequestFromParams
    * --------------------
    * Given parameters, generate XML body 
    * 
    *  cs: Case used
    *  ac: Account used for shipping details
    *  rf: Repair Facility used,
    *  insResults: Inspection Results for creating each line item, 
    *  audited: determines if submission to TR OneSource is audited (recorded)
    *  credited: determines if submission to TR OneSource is credited
    *
    *  returns: XML Request string
    */
    public static String GetRequestFromParams(Case cs, Account ac, Repair_Facility__c rf, List<Inspection_Result__c> insResults, 
                                                Boolean audited, Boolean credited){
        if (insResults.size()==0) return 'ERROR';

        Invoice inv = new Invoice();
        List<LineItem> lineItems = new List<LineItem>();

        try{
            inv = GetInvoiceFromCase(cs, ac, rf, audited, credited); //create Invoice

            Integer i = 1;
            for(Inspection_Result__c ins : insResults){ //Create list of line items from the queried Inspection Results
                lineItems.add(GetLineItemFromInspectionResult(i++, cs, ac, rf, ins)); 
            }
            
        }catch(System.SObjectException e){
            //Exception where sObject does not have correct fields
        } 

        String reqbody = OneSourceTaxReqGenerator.GenerateXMLBody(inv,lineItems);

        return reqbody;
    }

    /*
    * Function: GetGeneratedTaxFromInspectionResults
    * --------------------
    * Given list of inspection results, generate the tax
    * 
    *  insResults: Inspection Results for creating each line item, 
    *   audited: determines if submission to TR OneSource is audited (recorded)
    *   credited: determines if submission to TR OneSource is credited
    *
    *  returns: Decimal for tax
    */
    @AuraEnabled
    public static Decimal GetGeneratedTaxFromInspectionResults(List<Inspection_Result__c> insResults, Boolean audited, Boolean credited){
        
        Case cs;
        Account ac;
        Repair_Facility__c rf;
        Decimal tx = null;

        if (insResults.size() == 0) return 0.00;
        
        try{
            cs = [SELECT CreatedDate, CaseNumber, AccountId, Payment_Pending__c, Repair_Facility__c FROM Case WHERE Id = :insResults[0].Case__c];
        }catch(System.QueryException e){throw new GeneralException('Query Error on Case');}

        try{
            ac = [SELECT ShippingCity, ShippingStateCode, ShippingPostalCode, ShippingCountryCode, Currency__c FROM Account WHERE Id = :cs.AccountId];
        }catch(System.QueryException e){throw new GeneralException('Query Error on Account');}

        try{
            rf = [SELECT City_Name__c, State_Code__c, Postal_Code__c, Country_Code__c FROM Repair_Facility__c WHERE Id = :cs.Repair_Facility__c];
        }catch(System.QueryException e){throw new GeneralException('Query Error on Repair Facility');}

        try{    
            String request = GetRequestFromParams(cs, ac, rf, insResults, audited, credited);
                
            if (!Test.isRunningTest()) tx = GetGeneratedTax(request);
            //System.debug(tx);

        }catch(System.NullPointerException e){}

        if (Test.isRunningTest()) return 0.00;
        
        return tx;
    }

    /*
    * Function: GetGeneratedTaxFromInspectionResults
    * --------------------
    * Given list of inspection results, generate the tax without saving to system
    * 
    *  insResults: Inspection Results for creating each line item
    *
    *  returns: Decimal for tax
    */
    @AuraEnabled
    public static Decimal GetGeneratedTaxFromInspectionResults(List<Inspection_Result__c> insResults){
        return GetGeneratedTaxFromInspectionResults(insResults, FALSE, FALSE);
    }

    @AuraEnabled
    public static Decimal PostGeneratedTaxFromInspectionResults(List<Inspection_Result__c> insResults){
        return GetGeneratedTaxFromInspectionResults(insResults, TRUE, FALSE);
    }

    /*
    * Function: GetSubtotalFromInspectionResults
    * --------------------
    * Given list of inspection results, sum for the total price
    * 
    *  insResults: Inspection Results for creating each line item
    *
    *  returns: Decimal for subtotal
    */
    @AuraEnabled
    public static Decimal GetSubtotalFromInspectionResults(List<Inspection_Result__c> insResults){
        Decimal sbt = 0.00;
        for (Inspection_Result__c ir : insResults){
            sbt += ir.Display_Price__c;
        }
        return sbt;
    }
}