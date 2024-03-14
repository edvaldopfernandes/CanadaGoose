/**
 * Test Class Name : GCJSON.apxc
 * Created By : Adnan, 21 April 2021
 * Last Modified By : Venkata Kalyan, July 14 2021
 * Description      : This class is written to 
 * 						1. get Inspection Result's related case id to display related case on Inspection Result Object
 * 						2. get case refund, curruncy, language and tax fields to display on GC component
 * 						3. set case currency field on the basis of region and language field on the basis of account's language
 * 						4. coversion from any object to string
 * 						5. get Triggered case 
 * 						6. get canada based user, password, itemref and endpoints
 * 						7. get serialized JSON request body
 ***/
public class GCJSON {
    //get Inspection Result's related case id to display related case on Inspection Result Object
    @AuraEnabled
    public static String GetCaseofIR(Id IRid) {
        Inspection_Result__c caseid = [Select Case__c from Inspection_Result__c where id = :IRid];
        return caseid.Case__c;
    }
    
    //get case refund, curruncy, language and tax fields to display on GC component
    @AuraEnabled 
    public static String[] GetRefund(Id cid) {
        String[] arr = new List<String>();
        Case c= getCase(cid);
        
        if(!String.isBlank(c.Refund_Total_Before_Taxes__c)) {
            arr.add(c.Refund_Total_Before_Taxes__c);
        }
        else {
            arr.add('0');
        }
        
        arr.add(c.Currency__c);
        arr.add(c.Language__c);
        
        if(!String.isBlank(c.State_Tax_Rate__c)) {
            arr.add(c.State_Tax_Rate__c);
        }
        else {
            arr.add('0');
        }
        
        if(!String.isBlank(c.Refund_Total__c)) {
            arr.add(c.Refund_Total__c);
        }
        else {
            arr.add('0');
        }
        
        return arr;
    }
    
    //set case currency field on the basis of region and language field on the basis of account's language
    @AuraEnabled
    public static Integer SetFields(Id cid) {
        Case caseid = getCase(cid);
        integer f = 0;
        
        if(caseid.Region__c == 'North America - Canada' && caseid.Currency__c != 'CAD') 
        {caseid.Currency__c = 'CAD'; f=1;}
        else if(caseid.Region__c == 'North America - USA' && caseid.Currency__c != 'USD') 
        {caseid.Currency__c = 'USD'; f=1;}
        else if(caseid.Region__c == 'Europe - EU' && caseid.Currency__c != 'EUR') 
        {caseid.Currency__c = 'EUR'; f=1;}
        else if(caseid.Region__c == 'Europe - UK' && caseid.Currency__c != 'GBP') 
        {caseid.Currency__c = 'GBP'; f=1;}
        else 
        {System.debug(LoggingLevel.Info,'already corresponding currency');}
        
        if(caseid.Account.Language__c == 'en_US' && caseid.Language__c != 'English') 
        {caseid.Language__c = 'English'; f=1;}
        if(caseid.Account.Language__c == 'en_UK' && caseid.Language__c != 'English') 
        {caseid.Language__c = 'English'; f=1;}
        else if(caseid.Account.Language__c == 'fr' && caseid.Language__c != 'French') 
        {caseid.Language__c = 'French'; f=1;}
        //update Eu
        else if(caseid.Account.Language__c == 'de' && caseid.Language__c != 'German') 
        {caseid.Language__c = 'German'; f=1;}
        else if(caseid.Account.Language__c == 'it' && caseid.Language__c != 'Italian') 
        {caseid.Language__c = 'Italian'; f=1;}
        
        else 
        {System.debug(LoggingLevel.Info,'already corresponding language');}
        
        if(f==1) {
            update caseid;
        }
        return f;
    }
    
    //coversion from any object to string
    public static String getString (Object casefield) {
        String str = String.valueOf( casefield );
        if ( casefield instanceof Decimal ) str = ((Decimal)casefield).toPlainString(); // Prevent scientific notation
        return str;
    }
    
    //get Triggered case 
    public static Case getCase(String caseId){
        Case c;
        try{
            // Added Account_Country__c in SOql
            c = [Select id,CaseNumber,Language__c,orderSender__c,Refund_Total__c,receivingName__c,CustomerEmail__c,CustomerName__c,expiryDate__c,
                 entryGreetingFrom__c,entryGreetingBody__c,ecertDeliveryDate__c,ecertDeliveryMethod__c,Region__c,Currency__c,Account.Language__c, Account_Country__c,
                 Refund_Total_Before_Taxes__c,State_Tax_Rate__c, Receipt_Provided__c from Case where id = :caseId];
        }
        catch(Exception e){
            System.debug('****Exception' + e.getMessage());
        }
        return c;
    }
    
    //get canada based user, password, itemref and endpoints
    public static Case_Gift_Card__mdt  getData(string devName){
        Case_Gift_Card__mdt  cg;
        try{
            // Update:: Fasih - add 'Canada_French_Item_Id__c' in Soql
             
            cg = [select User__c,Password__c,Item_Id__c,Endpoint__c,Endpoint2__c from Case_Gift_Card__mdt where DeveloperName = :devName];
        }
        catch(Exception e){
            System.debug('****Exception' + e.getMessage());
        }
        return cg;
    }
   
    
    //get serialized JSON request body
    public static String getSerializedBody(String caseId)
    {
        
        Case c = getCase(caseId);
        
        //Update :: Fasih - getMetadata according to Region
        Case_Gift_Card__mdt cg ;// getCanadaData();
        
        if(c.Region__c == 'North America - Canada'){
            
            cg = getData('Canada_'+c.Language__c);
        }
        else if(c.Region__c == 'North America - USA'){
            
            cg = getData('USA_'+c.Language__c);
        }
        else if(c.Region__c == 'Europe - EU'){
            
            if(c.Account_Country__c == 'IT'){
                 cg = getData('Italy_'+c.Language__c);
            }
            else if(c.Account_Country__c == 'AT'){
                 cg = getData('Austria_'+c.Language__c);             
            }
            else if(c.Account_Country__c == 'NL'){
                //Netherlands
                cg = getData('Netherlands_'+c.Language__c);
            }
            else if(c.Account_Country__c == 'LU'){
               //Luxembourg
               cg = getData('Luxembourg_'+c.Language__c);
            }
            else if(c.Account_Country__c == 'BE'){
                  cg = getData('Belgium_'+c.Language__c); 
            }
            else if(c.Account_Country__c == 'DE'){
                cg = getData('Germany_'+c.Language__c); 
            }
            else if(c.Account_Country__c == 'FR'){
               cg = getData('France_'+c.Language__c); 
            }
            else if(c.Account_Country__c == 'IE'){
                cg = getData('Ireland_'+c.Language__c);
                   
               //Ireland
            }
            //getEUData()
        }
        else if(c.Region__c == 'Europe - Non-EU'){
            // getNonEUData();
        }
         else if(c.Region__c == 'Europe - UK'){
             cg = getData('UK_'+c.Language__c);
        }
     
        JSONGenerator gen = JSON.createGenerator(true);
        String lang = getString(c.Language__c);
        String lcode;
        
        // Update:: Fasih - item ID set according to language
        String itemId = cg.Item_Id__c;
       
        if(lang == 'English') {lcode='en';  }
        else if(lang == 'Italian') {lcode='it';}
        else if(lang == 'French') {lcode='fr'; }
        else if(lang == 'German') {lcode='de';}
        else {lcode='';}
        
        List<String> egm = new List<String>();
        List<Object> entryGreetingMessage = new List<Object>();
        List<Object> odi = new List<Object>();
        List<Object> orderDetailInfo = new List<Object>();
        List<Object> eoi = new List<Object>();
        List<Object> ecertOrderInfo = new List<Object>();
        List<Object> gc = new List<Object>();
        
        if(!String.isBlank(c.CustomerName__c)) egm.add(c.CustomerName__c); else egm.add('');
        if(!String.isBlank(c.entryGreetingFrom__c)) egm.add(c.entryGreetingFrom__c); else egm.add('');
        //if(!String.isBlank(c.entryGreetingBody__c)) egm.add(c.entryGreetingBody__c); else egm.add('');
        
        entryGreetingMessage.add(egm);
        
        if(!String.isBlank(c.CaseNumber)) odi.add(c.CaseNumber); else odi.add('');
        //odi.add(cg.CanadaItemId__c);
        
        //Update :: Fasih
        odi.add(itemId);
        
        odi.add('1');
        if(!String.isBlank(getString(c.Refund_Total__c))) odi.add(c.Refund_Total__c); else odi.add(0);
        odi.add(entryGreetingMessage);
        
        orderDetailInfo.add(odi);
        
        if(!String.isBlank(c.CaseNumber)) eoi.add(c.CaseNumber); else eoi.add('');
        if(!String.isBlank(c.receivingName__c)) eoi.add(c.receivingName__c); else eoi.add('');
        if(!String.isBlank(c.CustomerEmail__c)) eoi.add(c.CustomerEmail__c); else eoi.add('');
        if(!String.isBlank(getString(c.expiryDate__c))) eoi.add(getString(c.expiryDate__c).split(' ',2)[0]); else eoi.add('');
        eoi.add(orderDetailInfo);
        if(!String.isBlank(getString(c.ecertDeliverydate__c))) eoi.add(getString(c.ecertDeliverydate__c).split(' ',2)[0]); else eoi.add('');
        if(!String.isBlank(getString(c.ecertDeliveryMethod__c))) eoi.add(getString(c.ecertDeliveryMethod__c)); else eoi.add('');
        
        ecertOrderInfo.add(eoi);
        
        gc.add(lcode);
        if(!String.isBlank(c.CaseNumber)) gc.add(c.CaseNumber); else gc.add('');
        gc.add(cg.User__c);
        gc.add(cg.Password__c);
        if(!String.isBlank(c.CaseNumber)) gc.add(c.CaseNumber); else gc.add('');
        if(!String.isBlank(c.orderSender__c)) gc.add(c.orderSender__c); else gc.add('');
        if(!String.isBlank(c.CustomerEmail__c)) gc.add(c.CustomerEmail__c); else gc.add('');
        if(!String.isBlank(getString(c.Refund_Total__c))) gc.add(getString(c.Refund_Total__c)); else gc.add('');
        gc.add(ecertOrderInfo);
        
        gen.writeStartObject();      
        gen.writeStringField('jsonrpc','2.0');
        gen.writeStringField('method','956');
        gen.writeStringField('id','437');
        gen.writeObjectField('params', gc);
        gen.writeEndObject();
        
        return gen.getAsString();
    }
}