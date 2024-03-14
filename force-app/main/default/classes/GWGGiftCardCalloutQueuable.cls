/**
* Name : GWGGiftCardCalloutQueuable
* Description :- Queuable class to make callout for GWG Gift card
 
* Author :- Venkata Kalyan
* Date   :- 22-07-2023
* Story/Task :- 
* Test Class :- GWGGiftCardCalloutQueuableTest - To be Created
* */
public class GWGGiftCardCalloutQueuable  implements Queueable,Database.AllowsCallouts {
    
    // class variables
    public string reqBody, resbody,status, errormsg1, errormsg2; public boolean UnableTocall1 = false, UnableTocall2 = false;
    public Case_Gift_Card__mdt metadata =  new Case_Gift_Card__mdt();
    public GWG_Gift_Card__c card = new GWG_Gift_Card__c();
    
  	public GWGGiftCardCalloutQueuable (String reqBody, GWG_Gift_Card__c card){
        this.reqBody = reqBody;
        this.metadata = GWGGiftCardTriggerHandler.getMetadata(card);
        this.card = card; 
    }
    public void execute(QueueableContext qc){      
        try{
            HTTPResponse response ;
            try {
                 response = GetHttpRes(metadata.Endpoint__c);
            }catch(Exception ex) { errormsg1 = ex.getMessage(); UnableTocall1 = true; }            
                if (response.getStatusCode() == 200) {
                    Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                    List<Object> r = (List<Object>) results.get('result'); System.debug('>>>>>result>>>'+r);System.debug('>>>>>(String)r[1] == 0>>>'+(String)r[1] == '0');
                  	if((String)r[1] == '0') { System.debug('>>>>>result>>>'+r); UpdateGWGGiftCardOnSuccess(r); }
                    else { system.debug(LoggingLevel.Info,'gcf:: ' + r[2]);  errormsg1 = (String)r[2]; }
                }
                else{  errormsg1 ='Status Code: ' + response.getStatusCode() + ', Status message:' + response.getStatus();
                    Endpoint2Callout();   system.debug(LoggingLevel.Info,'gcf:: ' + response.getStatusCode());
                }
            }
        	catch(exception e) {  system.debug(e.getLineNumber() + e.getMessage());  Endpoint2Callout();  }
            finally{  Integration_Log__c log = ExceptionLog();  insert log;
                    if(UnableTocall1 && UnableTocall2){   System.debug('In finally Unable to call'); card.IsApproved__c = false; card.Approval_Status__c ='Not Issued'; update card;}
            }
    }
    
    public HTTPResponse GetHttpRes(String endpoint) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('POST');   System.debug(LoggingLevel.Info,'Request Body>>'+ reqBody);
        req.setbody(reqbody);
        Http http = new Http();
        HTTPResponse response = http.send(req);
        resbody = response.getBody();  System.debug(LoggingLevel.Info,'Response JSON>>'+response.getBody());
        return response;
    }
    
     public Integration_Log__c ExceptionLog() { 
        Integration_Log__c log = new Integration_Log__c();
        Map<String, Object> tt;  
        log.Request__c = reqbody;
        try{    tt=   (Map<String, Object>)JSON.deserializeUntyped(resbody);  }catch(Exception ex){  resbody =(String)resbody;  }
        if(status == 'Success'){//For Getting GCgivex number
            list<object> s = (list<object>) tt.get('result');
            list<object> s1 =(list<object>)s[2];
            list<object> s2 =(list<object>)s1[0];
            string cardNumber =  (string)s2[1];
            string cardNumberTrim = cardNumber.right(4);   system.debug(cardNumberTrim); //replacing complete GCGX number with 4 digits
            resbody = resbody.replace(cardNumber, cardNumberTrim);
        }
        log.Response__c = resbody;
        log.Status__c = status;
        log.Error_Message__c = errormsg1 ; 
        if(errormsg2 != ''){  log.Error_Message__c = log.Error_Message__c +'>> 2nd Endpoint error >>'+errormsg2;  }
        log.Record_Id__c = card.Name;
        return log;
    }
    //Called when 1st API callout is a failure
    public void Endpoint2Callout() {
       HTTPResponse response ;
        try {   try{  response = GetHttpRes(metadata.Endpoint2__c); }
            catch(Exception ex){  errorMsg2 = ex.getMessage();  UnableTocall2 = true;  }
            if (response.getStatusCode() == 200) {
                Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                List<Object> r = (List<Object>) results.get('result');  //on successful giftcard
                if((String)r[1] == '0') {  UpdateGWGGiftCardOnSuccess(r);  }
                else {
                    card.IsApproved__c = false;
               		card.Error_Message__c = (String)r[2];
                    card.Approval_Status__c ='Not Issued';
                    update card;
                    status = 'Callout Failure';
                    errormsg2 = (String)r[2];   system.debug(LoggingLevel.Info,'gcf2:: ' + r[2]);
                    ExceptionLog(); //Exception Log 2
                }
            } else{ //on API failure
                card.IsApproved__c = false;
                card.Error_Message__c ='Status Code: ' + response.getStatusCode() + ', Status message:' + response.getStatus(); 
                card.Approval_Status__c ='Not Issued';
                update card;
                status = 'API Failure';
                errormsg2 = 'Status Code: ' + response.getStatusCode() + ', Status message:' + response.getStatus(); system.debug(LoggingLevel.Info,'gcf2:: ' + response.getStatusCode());
                ExceptionLog(); // Exception Log 3
            }
        }
        catch(exception e) {  /*on callout exceptions*/   system.debug(e.getLineNumber() + e.getMessage());
            card.IsApproved__c = false;
            card.Error_Message__c =e.getMessage(); 
            card.Approval_Status__c ='Not Issued';
            update card;
            status = 'API Failure';
            errormsg2 = e.getMessage();
            ExceptionLog(); 
        }       
    }
    
      //update case fields on successful callout
    public void UpdateGWGGiftCardOnSuccess(List<Object> r) {  //System.assertEquals('0',(String)r[1]);
        String givexNumber = r[2].toString();
        List<String> gn = givexNumber.split(',');
        String shippingCode = gn[0].remove('((');
        card.Tracking_Number__c = 'Givex Tracking Id -'+ shippingCode;  System.debug('Shipping code =>>'+gn[0]);
        card.Shipping_Courier__c = 'Gift Card';
        card.Gift_Card_Issue_Date__c = date.parse(system.today().format()); 
        card.Gift_Card_Digits__c = gn[1].right(4);
        card.GWG_GivexNumber__c = gn[1];
        card.Error_Message__c = '';
        card.IsApproved__c = true;
        card.Approval_Status__c ='Issued';
        update card;
        status = 'Success';
        errormsg1 = ''; 
        errormsg2 = '';  system.debug(LoggingLevel.Info,'gcs:: success' + gn[1]);
    }
}