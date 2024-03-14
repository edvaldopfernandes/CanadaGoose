public class GWGGiftCardTriggerHandler {
    public static void beforeInsert(list<GWG_Gift_Card__c> listOfRecords){
        set<id> accountSet = new set<id>();
        Map<Id, account> mapOfAccounts = new Map<id, account>();
        for(GWG_Gift_Card__c card :listOfRecords){
             if(card.GWG_Country__c != null){ 
                     if(card.GWG_Country__c == 'Canada'){  card.Currency__c = 'CAD'; card.Region__c = 'North America - Canada'; }
                     else if(card.GWG_Country__c == 'United States'){  card.Currency__c = 'USD';  card.Region__c = 'North America - USA'; }
                     else if(card.GWG_Country__c == 'United Kingdom'){ card.Currency__c = 'GBP'; card.Region__c = 'Europe - UK'; } 
                     else if(card.GWG_Country__c == 'Austria' || card.GWG_Country__c == 'Germany'|| card.GWG_Country__c == 'France' || card.GWG_Country__c == 'Italy' ||
                             card.GWG_Country__c == 'Ireland' || card.GWG_Country__c == 'Netherlands' || card.GWG_Country__c == 'Belgium' || card.GWG_Country__c == 'Luxembourg'){
                         			card.Currency__c = 'EUR'; card.Region__c = 'Europe - EU';
                 	 } 
              }
             if(card.customer__c != null){ accountSet.add(card.customer__c); }
        }
        for(account acc : [SELECT id, Name, PersonEmail FROM Account WHERE Id IN:accountSet ]){
            if(!mapOfAccounts.containsKey(acc.id)){ mapOfAccounts.put(acc.id, acc); } 
        }
        for(GWG_Gift_Card__c card :listOfRecords){
             if(card.customer__c != null && mapOfAccounts.containsKey(card.customer__c)
                && mapOfAccounts.get(card.customer__c)!= null){
			  	 Account acc = mapOfAccounts.get(card.customer__c);              
                 card.Name__c  = acc.Name;
                 card.Email__c  = acc.PersonEmail;
                 card.Entry_Greeting_To__c =acc.Name;    
                 card.Receiving_Email__c  = acc.PersonEmail;
                 card.Receiving_Name__c = acc.Name;
                 card.Tax__c = 0;
                 card.Order_Sender__c = 'Canada Goose';
                 card.Order_Type__c = 'Goodwill Gesture Gift Card';
                 card.Line_Number__c = '1';
             }
        
        }
    }
	public static void afterInsert(list<GWG_Gift_Card__c> listOfRecords){
        set<id> setOfAccountIds = new set<id>();
        Map<Id, account> mapOfAccounts = new Map<id, account>();
        for(GWG_Gift_Card__c card : listOfRecords){
            if(card.customer__c != null){
                setOfAccountIds.add(card.customer__c);
            }
        }
        for(account acc : [SELECT id, Ecomm_Lost_Parcel__c, Warranty_Lost_Parcel__c, Last_GWGGC_Issued_Date__c, Returns_In_Last_Year__c  FROM Account WHERE Id IN:setOfAccountIds ]){
            if(!mapOfAccounts.containsKey(acc.id)){
                mapOfAccounts.put(acc.id, acc);
            } 
        }
        for(GWG_Gift_Card__c card : listOfRecords){
            Account acc = new Account();
            if(mapOfAccounts.containsKey(card.customer__c)){
                acc = mapOfAccounts.get(card.customer__c);
            }
            Decimal issuedTime = 0.00;
            Decimal currentTime = DateTime.now().getTime();
            Decimal diff = 0.00;
            if(acc.Last_GWGGC_Issued_Date__c != null){
                issuedTime  = acc.Last_GWGGC_Issued_Date__c.getTime();
                diff = issuedtime - currentTime;
            }
            if(acc != null && (card.Gift_Card_Value__c  > 300 || (card.Gift_Card_Value__c  <= 300 && 
                  (acc.Ecomm_Lost_Parcel__c == true || acc.Warranty_Lost_Parcel__c == true || acc.Returns_In_Last_Year__c == true || ((diff <= 31536000000.00) && ((diff > 0.00) || (acc.Last_GWGGC_Issued_Date__c != null))))))){
                 	submitForApproval(card);}
         }
    }
    public static void triggerUnapprovedGWGCard(Id cardId){
       list<GWG_Gift_Card__c> listOfRecords = [SELECT Id, Customer__r.Last_GWGGC_Issued_Date__c, Customer__c, Gift_Card_Value__c, Approval_Status__c,Approved_Date_Time__c,
                                               Approver__c,Business_Unit__c,Channel__c,Currency__c,E_cert_delivery_Method__c,Email__c,Entry_Greeting_From__c,
                                               Entry_Greeting_To__c,Error_Message__c,Gift_Card_Digits__c,Gift_Card_Issue_Date__c,Name,GWG_GivexNumber__c,
                                               GWG_Submitted_Date__c,IsApproved__c,Item_Quantity__c,Language__c,Name__c,Order_Sender__c, Reason__c,Receiving_Email__c,
                                               Receiving_Name__c,Region__c,Rejected_Date_Time__c,Shipping_Courier__c,Tracking_Number__c,Transaction_Code__c, 
                                               GWG_Country__c,GC_Language__c FROM GWG_Gift_Card__c WHERE id =:cardId];
       list<GWG_Gift_Card__c> listOfGWGRec = new list<GWG_Gift_Card__c>();
        list<String> listOfReqs = new list<string>();
        Map<id,Account> mapOfAccounts = new Map<id, Account>();
        set<id> setOfAccountIds = new set<Id>();//
        if(listOfRecords.size() > 0){
            for(GWG_Gift_Card__c card : listOfRecords){
                setOfAccountIds.add(card.Customer__c);
            }
           	for(account acc : [SELECT id,  Ecomm_Lost_Parcel__c, Warranty_Lost_Parcel__c, Returns_In_Last_Year__c,Last_GWGGC_Issued_Date__c, (SELECT Id FROM Cases WHERE Gift_Card_Confirmed__c = false )
                               FROM Account WHERE id IN: setOfAccountIds]){
               if(!mapOfAccounts.containsKey(acc.id)){
                   mapOfAccounts.put(acc.id, acc);
               }                      
            }
            decimal dt1 = DateTime.now().addDays(-365).getTime();
            for(GWG_Gift_Card__c card : listOfRecords){
                Decimal issuedTime = 0.00;
                Decimal currentTime = DateTime.now().getTime();
                Decimal diff = 0.00;
                if(card.Customer__r.Last_GWGGC_Issued_Date__c != null){
                    issuedTime  = card.Customer__r.Last_GWGGC_Issued_Date__c.getTime();
                    diff = issuedtime - currentTime;
                }
                if(mapOfAccounts.size() > 0 && mapOfAccounts.containsKey(card.customer__c) && mapOfAccounts.get(card.customer__c) != null){
                    Account acc = mapOfAccounts.get(card.customer__c);
                    if(acc.cases.size() >=0 && acc.Ecomm_Lost_Parcel__c== false && acc.Warranty_Lost_Parcel__c == false 
                       && acc.Returns_In_Last_Year__c ==false && card.Gift_Card_Value__c <= 300 && (diff > 31536000000.00 || (diff == 0.00 && acc.Last_GWGGC_Issued_Date__c == null))){
                       listOfGWGRec.add(card);    
                    }
                }
            }
       }
           if(listOfGWGRec.size()>0){
             listOfReqs = generateReqBody(listOfGWGRec);
             System.enqueueJob(new GWGGiftCardCalloutQueuable(listOfReqs[0], listOfGWGRec[0]));
           }
    }
    public static void beforeUpdate(list<GWG_Gift_Card__c> listOfRecords, Map<id, GWG_Gift_Card__c> mapOfOldRecords){
        list<GWG_Gift_Card__c> listOfGWGRec = new list<GWG_Gift_Card__c>();
        list<String> listOfReqs = new list<string>();
        set<id> setOfIds = new set<id>();
        Map<Id,ProcessInstanceStep> mapOfComments = new Map<Id,ProcessInstanceStep>();
        if(listOfRecords.size() > 0  && mapOfOldRecords.size() > 0 ){
            for(GWG_Gift_Card__c card : listOfRecords){
                GWG_Gift_Card__c oldCard = new GWG_Gift_Card__c();
                if(mapOfOldRecords.containsKey(card.id)){
                    oldCard = mapOfOldRecords.get(card.id);
                    
                    if(card.Approval_Status__c == 'Approved' && oldCard.Approval_Status__c != card.Approval_Status__c){ listOfGWGRec.add(card); setOfIds.add(card.id);}
                    
                    if(card.Approval_Status__c == 'Rejected' && oldCard.Approval_Status__c != card.Approval_Status__c){setOfIds.add(card.id); }                  
                }
             }
            if(setOfIds != null && setOfIds.size() >0){mapOfComments = processComments(setOfIds);     }
            if(mapOfComments != null && mapOfComments.size() >0 ){
                for(GWG_Gift_Card__c card : listOfRecords){
                    if(mapOfComments.containsKey(card.id) && mapOfComments.get(card.id) != null){
                    	card.Approval_Comment__c = mapOfComments.get(card.id).comments;
                        card.Approver__c = mapOfComments.get(card.id).Actor.Name;
                	}
                }
            }
            if(listOfGWGRec.size()>0){  listOfReqs = generateReqBody(listOfGWGRec); System.enqueueJob(new GWGGiftCardCalloutQueuable(listOfReqs[0], listOfGWGRec[0]));	}
        }
     }
    
    public static void afterUpdate(List <GWG_Gift_Card__c> listOfRecords, Map<Id, GWG_Gift_Card__c> mapOfOldRecords){
        set<Id> setOfIds = new set<Id>();
        if(listOfRecords.size() > 0  && mapOfOldRecords.size() > 0 ){
            for(GWG_Gift_Card__c card : listOfRecords){
                GWG_Gift_Card__c oldCard = new GWG_Gift_Card__c();
                if(mapOfOldRecords.containsKey(card.id)){
                    oldCard = mapOfOldRecords.get(card.id);
                    
                    if(card.Approval_Status__c == 'Issued' && oldCard.Approval_Status__c != card.Approval_Status__c){ setOfIds.add(card.customer__c);  }
                }
    		}
        }
        list<Account> listOfAccount = new list<Account>();
        for(Account acc : [SELECT id, Last_GWGGC_Issued_Date__c  FROM Account WHERE id IN: setOfIds]){
            acc.Last_GWGGC_Issued_Date__c = DateTime.now();
            listOfAccount.add(acc);
        }
        if(listOfAccount.size() >0){  Database.update(listOfAccount, false); }
    }
    
    public static Map<Id,ProcessInstanceStep> processComments(set<id> setOfIds){
        Map<Id,Id> GWGProcessMap = new Map<Id,Id>();
        Map<Id,ProcessInstanceStep> approvalCommentMap = new Map<Id,ProcessInstanceStep>(); 
        for(ProcessInstance pi: [SELECT Id, TargetObjectId FROM ProcessInstance WHERE TargetObjectId IN :setOfIds]){
        	GWGProcessMap.put (pi.Id, pi.TargetObjectId); 
        }
    	for(ProcessInstanceStep pis: [select Comments,ProcessInstanceId, OriginalActor.Name, actor.Name from ProcessInstanceStep where ProcessInstanceId in :GWGProcessMap.keyset()]){
            if(GWGProcessMap.containsKey(pis.ProcessInstanceId) && GWGProcessMap.get(pis.ProcessInstanceId) != null ){
            	approvalCommentMap.put (GWGProcessMap.get(pis.ProcessInstanceId), pis); 
            }
    	}
        return approvalCommentMap;
    }
    
    public static list<string> generateReqBody(list<GWG_Gift_Card__c> listOfGWGRec){
        list<string> jsonStringList = new list<string>();
        Case_Gift_Card__mdt cg = new Case_Gift_Card__mdt();
        for(GWG_Gift_Card__c card : listOfGWGRec){
            cg = getMetadata(card);
            String  req = '{ "jsonrpc": "2.0", "method": "956", "id": "437", "params": [';
            req = req + '"'+card.GC_Language__c +'",';
            req = req + '"'+card.Name +'",';
            req = req + '"'+cg.User__c +'",'; //username
            req = req + '"'+cg.Password__c +'",'; // password
            req = req + '"'+card.Name +'",'; 
            req = req + '"'+card.Approver__c +'",';
            req = req + '"'+card.Email__c  +'",'; //  Approver__c
            req = req + '"'+card.Gift_Card_Value__c +'",';
            req = req + '[["'+card.Name +'",';
            req = req + '"'+card.Name__c +'",';
            req = req + '"'+card.Email__c  +'",';
            req = req + '"",';
            req = req + '[[';
            req = req + '"'+card.Name +'",';
            req = req + '"'+cg.GWG_Item_Id__c +'",'; // GWGitem Id
            req = req + '"1",'; 
            req = req + '"'+card.Gift_Card_Value__c +'",';
            req = req + '[[';
            req = req + '"'+card.Name__c +'",';
            req = req + '"'+card.Entry_Greeting_From__c+'"';
            req = req + ']]]],';
            req = req + '"",';
			req = req + '"'+card.Email__c  +'"';
            req = req + ']]]}';
            
            jsonStringList.add(req);
            
        }
        return jsonStringList;
    }
    public static Case_Gift_Card__mdt  getData(string devName){
        Case_Gift_Card__mdt  cg = new Case_Gift_Card__mdt();
        try{ cg = [select User__c,Password__c,GWG_Item_Id__c,Endpoint__c,Endpoint2__c from Case_Gift_Card__mdt where DeveloperName = :devName]; }
        catch(Exception e){  System.debug('****Exception' + e.getMessage()); }
        return cg;
   }
   public static Case_Gift_Card__mdt getMetadata(GWG_Gift_Card__c card){
        Case_Gift_Card__mdt cg =  new Case_Gift_Card__mdt();
        String language = getLanguage(card);
        if(card.Region__c == 'North America - Canada'){  cg = getData('Canada_'+language); }
        else if(card.Region__c == 'North America - USA'){ cg = getData('USA_'+ language);  }
        else if(card.Region__c == 'Europe - EU'){
            if(card.GWG_Country__c == 'Italy'){ cg = getData('Italy_'+ language); }
            else if(card.GWG_Country__c == 'Austria'){ cg = getData('Austria_'+ language); }
            else if(card.GWG_Country__c == 'Netherlands'){ cg = getData('Netherlands_'+language); }
            else if(card.GWG_Country__c == 'Luxembourg'){ cg = getData('Luxembourg_'+ language);  }
            else if(card.GWG_Country__c == 'Belgium'){ cg = getData('Belgium_'+ language); }
            else if(card.GWG_Country__c == 'Germany'){ cg = getData('Germany_'+ language); }
            else if(card.GWG_Country__c == 'France'){ cg = getData('France_'+ language); }
            else if(card.GWG_Country__c == 'Ireland'){ cg = getData('Ireland_'+ language); }
        }
        else if(card.Region__c == 'Europe - UK'){ cg = getData('UK_'+ language); }
        return cg;
    }
    public static string getLanguage(GWG_Gift_Card__c card) {
        String language= '';
        if(card.GC_Language__c == 'en_US' || card.GC_Language__c == 'en_UK') { language = 'English'; }
        else if(card.GC_Language__c == 'fr'){ language = 'French'; }
		else if(card.GC_Language__c == 'de'){ language = 'German'; }
        else if(card.GC_Language__c == 'it'){ language = 'Italian'; }
      return language;
    }
   public static void submitForApproval(GWG_Gift_Card__c card){   //Method to send the record for approval
        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
        req.setComments('Submitting GWG Record '+card.id+ ' for Approval using Trigger');
        req.setObjectId(card.id);
        Approval.ProcessResult result = Approval.process(req);
   }
}