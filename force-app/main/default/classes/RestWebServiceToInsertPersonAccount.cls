/*******************************************************************************************************************************
 * @Name         RestWebServiceToInsertPersonAccount
 * @Author       Venkata Kalyan
 * @Date         26/06/2023
 * @Description  Rest Web Service To Insert Person Account
 *******************************************************************************************************************************
 * Version      Developer                Date          Description
 *-------------------------------------------------------------------------------------------------------------------------------
 *  1.0       Venkata Kalyan        26/06/2023   Initial Creation
 ********************************************************************************************************************************/
@RestResource(urlMapping='/restWebServiceToInsertPersonAccount/')
global without sharing class RestWebServiceToInsertPersonAccount {

    @HttpPost
    global static void doPost() {
        String message = '';
        String response ='';
        String jsonString = '';
        list<Account> listOfAccounts = new list<account>();
        try {
                RestRequest req = RestContext.request;
                Blob body = req.requestBody;
                jsonString = body.toString();
                response = processJSON(jsonString);
            	
        }catch (Exception ex) {
            	System.debug(message +'>>>Catch Exception' +ex);
            	IntegrationLogUtility.error = ex.getMessage();
            if(jsonString != null){
            	IntegrationLogUtility.status = 'Request captured With Error';
            }else {
                IntegrationLogUtility.status = 'Empty Request';
            }
            	IntegrationLogUtility.exp = ex;
        }
        finally{
             string resCode = '';
           		RestResponse res = RestContext.response;
                if(response != '' && response != NULL){
                    res.responseBody = Blob.ValueOf(response);
                    res.statusCode = 200;
                    resCode = response;
                    if(String.valueOf(response) == '[]'){
                        resCode = 'Insertion failed due to internal error';
                        IntegrationLogUtility.status = 'Request captured With Error';
					}
                }
            	else{ res.statusCode = 400;  resCode = 'failure';}
            	IntegrationLogUtility.createOutBoundLog(jsonString, resCode , 'Generations'+DateTime.now(), 'Inbound', 'Generations', null);
         }
    }
        /* Method to search the existing account using personEmail  */
    public static map<String, account> searchAccounts(set<String> setOfEmails){
        map<String, account> mapOfAccounts = new map<string, account>();
        for(account acc : [SELECT Id, PersonEmail,Marketing_Consent_Status__pc FROM Account WHERE personemail IN :setOfEmails]){
            if(!mapOfAccounts.containsKey(acc.PersonEmail)){
                mapOfAccounts.put(acc.PersonEmail, acc);
            }
        }
        return mapOfAccounts;
    }
    
	public static string processJSON(String jsonString){
        
    	list<Account> listOfAccounts = new list<account>();
        set<id> accountIds = new set<Id>();
        String response ='';
        String errorDetail = '';
        set<string> setOfEmails = new set<String>();
        for(PersonAccountJSONParser parsedData : PersonAccountJSONParser.parse(jsonString)){
             Account acc = new Account();
             acc.FirstName = parsedData.FirstName;
             acc.LastName = parsedData.LastName;
             acc.recordtypeId = parsedData.recordtypeId;
             acc.PersonEmail = parsedData.PersonEmail;
             acc.Preferred_Lang__pc = String.valueOf(parsedData.Language); 
             acc.PersonMobilePhone = String.valueOf(parsedData.PersonMobilePhone);
             acc.PersonMailingStreet = parsedData.ShippingStreet;
             acc.PersonMailingCity = parsedData.ShippingCity;
             acc.PersonMailingState = parsedData.ShippingState;
             acc.PersonMailingPostalCode = parsedData.ShippingPostalCode;
             acc.PersonMailingCountryCode = parsedData.ShippingCountryCode;
             acc.Marketing_Country_Code__pc = parsedData.ShippingCountryCode; 
             acc.B2C_Gender_ID__pc = parsedData.B2C_GenderID;
           	 Datetime dt = (DateTime)JSON.deserialize('"' + parsedData.CreatedDate + '"', DateTime.class);
             acc.Marketing_Consent_Date__pc = dt;//added this field to get consent date
           	 acc.Origin__c = parsedData.Origin;
             acc.Origin__pc = parsedData.Origin;
             acc.Marketing_Subscription_Source__pc = parsedData.Marketing_Subscription_Source;
             acc.Marketing_Source_Location__pc = parsedData.Marketing_Source_Location;
             acc.Marketing_Consent_Status__pc =parsedData.Marketing_Consent_Status;   
             acc.B2C_Add_To_Email_List__pc = true;
             acc.Is_Generations_User__c = true;
             listOfAccounts.add(acc);
             setOfEmails.add(parsedData.PersonEmail);
		}
        map<String, account> mapOfAccounts = new map<string, account>();
        mapOfAccounts = searchAccounts(setOfEmails);
        list<account> updateAccList = new list<account>();
        list<account> InsertAccList = new list<account>();
        for(account acc : listOfAccounts){
            String accEmail = acc.PersonEmail;
            Account upAcc = new Account();
            if(mapOfAccounts.containsKey(accEmail.toLowerCase()) && mapOfAccounts.get(accEmail.toLowerCase()) != null){
                upAcc.id = mapOfAccounts.get(accEmail.toLowerCase()).id;
                if(mapOfAccounts.get(accEmail.toLowerCase()).Marketing_Consent_Status__pc == 'express'){
                  upAcc.Is_Generations_User__c = true;
                  updateAccList.add(upAcc);
                }
                else{
                    acc.id = mapOfAccounts.get(accEmail.toLowerCase()).id;
                    updateAccList.add(acc);
                }
                
            }
            else{ insertAccList.add(acc); }
          }
       	if(insertAccList != null && insertAccList.size() > 0){
          Database.SaveResult[] srList = Database.Insert(insertAccList, false);
		  for(Database.SaveResult sr : srList) {
    		if (sr.isSuccess()) { accountIds.add(sr.getId()); }
    		else {	for(Database.Error err : sr.getErrors()) {
              			System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        errorDetail = errorDetail +'>>'+  err.getMessage();
        			}
    		}
		  }
        }
          if(updateAccList != null && updateAccList.size() > 0){
          	list<Database.SaveResult> urList = Database.update(updateAccList, false);
		  	for(Database.SaveResult sr : urList) {
    			if (sr.isSuccess()) {	accountIds.add(sr.getId()); }
    			else {
           				for(Database.Error err : sr.getErrors()) {
              				System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        	errorDetail = errorDetail +'>>'+  err.getMessage();
        				}
    			}
		  	}
        }
        
       list<Account> accList = [SELECT Id, PersonContactId, personemail, Name FROM Account WHERE Id IN :accountIds];
       response ='[';
       integer i = 0;
       for(account acc : accList){
           Map<String, String> objDetails = new Map<String, String>();
           objDetails.put('Id', String.ValueOf(acc.id));
           objDetails.put('PersonContactId', String.ValueOf(acc.PersonContactId));
           objDetails.put('Email', String.ValueOf(acc.personemail));
           objDetails.put('Name', String.ValueOf(acc.Name));
           objDetails.put('Success', 'true');
		   response = response + JSON.serialize(objDetails);
           if(i!= accList.size() - 1) {
           	response = response + ',';
           }
			 i++;
       }
       response =  response + ']';
        if(response == null){
        	response = errorDetail;
        }
       return response;
    }
}