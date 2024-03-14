//Created for API Call for Retrieving user from Salesforce
//Done For Service Now implementation. 
@RestResource(urlMapping='/UserRecords/*')
global with sharing class ServiceNowAPI {
    @HttpGet
     global static user getUserByUsername() {
        RestRequest request = RestContext.request;
        // grab the caseId from the end of the URL
        String Username = request.requestURI.substring(
          request.requestURI.lastIndexOf('/')+1);
         system.debug('Username'+Username);
        User result =  [SELECT username,id
                        FROM user
                        WHERE username = :Username];
        return result;
    }
}