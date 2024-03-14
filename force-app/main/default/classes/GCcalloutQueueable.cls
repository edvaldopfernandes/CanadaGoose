public class GCcalloutQueueable implements Queueable,Database.AllowsCallouts{
    Case c;
    //Integration_Log__c log = new Integration_Log__c();
    public String reqbody,resbody,status,errormsg1, errormsg2; //-kalyan
    public boolean UnableTocall1 = false; //-kalyan
    public boolean UnableTocall2 = false; //-kalyan
    // List<object> res = new list<object>();
    
    //set triggered case and request body
    public GCcalloutQueueable(Case icase){
        c = icase ;  
        reqbody = GCJSON.getSerializedBody(c.id);
    }
    
    public string getLanguage (Case c){
        string countryLanguage = '';
        if(c.Region__c == 'North America - Canada'){
            
            countryLanguage= 'Canada_'+c.Language__c;
        }
        else if(c.Region__c == 'North America - USA'){
            countryLanguage= 'USA_'+c.Language__c;
        }
        else if(c.Region__c == 'Europe - UK'){
            countryLanguage = 'UK_'+c.Language__c;
        }
        else if(c.Region__c == 'Europe - EU'){
            
            if(c.Account_Country__c == 'IT'){
                countryLanguage = 'Italy_'+c.Language__c;
            }
            else if(c.Account_Country__c == 'AT'){
                
                countryLanguage = 'Austria_'+c.Language__c;
            }
            else if(c.Account_Country__c == 'NL'){
                countryLanguage = 'Netherlands_'+c.Language__c;
                
            }
            else if(c.Account_Country__c == 'LU'){
                countryLanguage = 'Luxembourg_'+c.Language__c;
            }
            else if(c.Account_Country__c == 'BE'){
                countryLanguage = 'Belgium_'+c.Language__c;
            }
            else if(c.Account_Country__c == 'DE'){
                countryLanguage = 'Germany_'+c.Language__c;   
            }
            else if(c.Account_Country__c == 'FR'){
                
                countryLanguage= 'France_'+c.Language__c; 
            }
            else if(c.Account_Country__c == 'IE'){
                //Ireland
                countryLanguage= 'Ireland_'+c.Language__c; 
            }
        }
        return countryLanguage;
    }
    
    //insert exception log to keeep track of errors and messages
    public Integration_Log__c ExceptionLog() { //-kalyan
        Integration_Log__c log = new Integration_Log__c();  //-kalyan
        Map<String, Object> tt;  
        log.Request__c = reqbody;
        
        
        try{
       	tt=   (Map<String, Object>)JSON.deserializeUntyped(resbody);
        }catch(Exception ex){
            resbody =(String)resbody;
        }
        if(status == 'Success'){
            
            //For Getting GCgivex number
            list<object> s = (list<object>) tt.get('result');
            list<object> s1 =(list<object>)s[2];
            list<object> s2 =(list<object>)s1[0];
            
            string cardNumber =  (string)s2[1];
            string cardNumberTrim = cardNumber.right(4);
            
            //system.debug(cardNumberTrim); 
            
            //replacing complete GCGX number with 4 digits
            resbody = resbody.replace(cardNumber, cardNumberTrim);
        }
        
        log.Response__c = resbody;
        log.Status__c = status;
        log.Error_Message__c = errormsg1 ; //-kalyan
        if(errormsg2 != ''){ //-kalyan
            log.Error_Message__c = log.Error_Message__c +'>> 2nd Endpoint error >>'+errormsg2;//-kalyan
        }
        log.Record_Id__c = c.CaseNumber;
        
        return log;
    }
    
    //get http response from given endpoint
    public HTTPResponse GetHttpRes(String endpoint) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('POST');
        System.debug(LoggingLevel.Info,'Request Body>>'+ reqbody);
        req.setbody(reqbody);
        Http http = new Http();
        HTTPResponse response = http.send(req);
        resbody = response.getBody();
        System.debug(LoggingLevel.Info,'Response JSON>>'+response.getBody());
        c.Gift_Card_Status__c = response.getBody();
        return response;
    }
    
    //update case fields on successful callout
    public void OnSuccessSetFields(List<Object> r) {
        //System.assertEquals('0',(String)r[1]);
        String givexNumber = r[2].toString();
        List<String> gn = givexNumber.split(',');
        c.Gift_Card__c = true;
        String shippingCode = gn[0].remove('((');
        c.Tracking_Number__c = 'Givex Tracking Id -'+ shippingCode;
        System.debug('Shipping code =>>'+gn[0]);
        c.Shipping_Courier__c = 'Gift Card';
        c.Status = 'Closed - Resolved';
        c.Gift_Card_Issue_Date__c = date.parse(system.today().format()); 
        c.Gift_Card_Digits__c = gn[1].right(4);
        c.GC_GivexNumber__c = gn[1];
        c.Error_Message__c = '';
        update c;
        status = 'Success';
        errormsg1 = ''; //-kalyan
        errormsg2 = '';//-kalyan
        system.debug(LoggingLevel.Info,'gcs:: success' + gn[1]);
        //ExceptionLog(reqbody,resbody,status,errormsg); // Exception log
    }
    
    //Called when 1st API callout is a failure
    public void Endpoint2Callout() {
        string countryLanguage = '';
        HTTPResponse response ;
        try {
           	countryLanguage = getLanguage(c);
            try{
            	response = GetHttpRes(GCJSON.getData(countryLanguage).Endpoint2__c);
            }
            catch(Exception ex){//-kalyan
                errorMsg2 = ex.getMessage();//-kalyan
                UnableTocall2 = true;//-kalyan
            }
            if (response.getStatusCode() == 200) {
                Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                List<Object> r = (List<Object>) results.get('result');
                
                //on successful giftcard
                if((String)r[1] == '0') {
                    //res = r;
                    OnSuccessSetFields(r);
                }
                else {
                    //on getting error message
                    c.IsApproved__c = false;
                    c.Error_Message__c = (String)r[2];
                    update c;
                    status = 'Callout Failure';
                    errormsg2 = (String)r[2];//-kalyan
                    system.debug(LoggingLevel.Info,'gcf2:: ' + r[2]);//-kalyan
                    //ExceptionLog(reqbody,resbody,status,errormsg); //Exception Log 2
                }
            }
            else{
                //on API failure
                c.IsApproved__c = false;
                c.Error_Message__c ='Status Code: ' + response.getStatusCode() + ', Status message:' + response.getStatus(); 
                update c;
                status = 'API Failure';
                errormsg2 = 'Status Code: ' + response.getStatusCode() + ', Status message:' + response.getStatus();//-kalyan
                system.debug(LoggingLevel.Info,'gcf2:: ' + response.getStatusCode());//-kalyan
                //ExceptionLog(reqbody,resbody,status,errormsg); // Exception Log 3
            }
        }
        catch(exception e) {//-kalyan
            //on callout exceptions
            system.debug(e.getLineNumber() + e.getMessage());//-kalyan
            c.IsApproved__c = false;//-kalyan
            c.Error_Message__c =e.getMessage(); //-kalyan
            update c;//-kalyan
            status = 'API Failure';//-kalyan
            errormsg2 = e.getMessage();//-kalyan
            //ExceptionLog(reqbody,resbody,status,errormsg); // Exception Log 4
        }       
    }
    
    public void execute(QueueableContext qc){      
        try{
            string countryLanguage = '';
            HTTPResponse response ;
            try {
                 countryLanguage = getLanguage(c);
                
                 response = GetHttpRes(GCJSON.getData(countryLanguage).Endpoint__c);
                
            }catch(Exception ex)//-kalyan
                {//-kalyan
                    errormsg1 = ex.getMessage();//-kalyan
                    UnableTocall1 = true;//-kalyan
                }            
                if (response.getStatusCode() == 200) {
                    Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                    List<Object> r = (List<Object>) results.get('result');
                    
                    //on successful giftcard
                    if((String)r[1] == '0') {
                        OnSuccessSetFields(r);
                    }
                    else {
                        //on getting error message
                        Endpoint2Callout();
                        system.debug(LoggingLevel.Info,'gcf:: ' + r[2]);//-kalyan
                        errormsg1 = (String)r[2];//-kalyan
                    }
                }
                else{//-kalyan
                    errormsg1 ='Status Code: ' + response.getStatusCode() + ', Status message:' + response.getStatus();//-kalyan
                    //on API failure
                    Endpoint2Callout();//-kalyan
                    system.debug(LoggingLevel.Info,'gcf:: ' + response.getStatusCode());//-kalyan
                }
            }
        	catch(exception e) {//-kalyan
                //on callout exceptions
                system.debug(e.getLineNumber() + e.getMessage());//-kalyan
                Endpoint2Callout();//-kalyan
        	}
            finally{//-kalyan
                Integration_Log__c log =ExceptionLog();//-kalyan
                insert log;//-kalyan
                if(UnableTocall1 && UnableTocall2){//-kalyan
                  	  c.IsApproved__c = false;//-kalyan
                      update c;//-kalyan
                }
                
            }
    }
    
}