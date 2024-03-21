public class subscribeMeController {
    @AuraEnabled()
    public static account updateAccountData(string recordId, boolean isSubscribed, String countryCode, String language, string mobile){
        Account acc = new Account();
        profile currentProfile = new Profile();
        try{
            currentProfile = [SELECT Name FROM Profile WHERE id =:UserInfo.getProfileId() LIMIT 1]; 
            system.debug('recordId>>> '+recordId +' >>>isSubscribed>>>>> '+ isSubscribed +'  >>>countryCode>>>> '+countryCode +' language>>>> '+language +' mobile >>>'+mobile +'Profile >>>'+currentProfile.Name);
            acc = new Account(id = recordId);
            
            if(isSubscribed){
                acc.PersonHasOptedOutOfEmail = false;
                acc.B2C_Add_To_Email_List__pc = true;
                acc.Marketing_Country_Code__pc = countryCode;
                acc.Marketing_Consent_Date__pc = DateTime.now();
                acc.Marketing_Consent_Status__pc = 'express';
                acc.Origin__pc = 'Service Portal';
                acc.Marketing_Source_Location__pc = 'SFSC';
                acc.Marketing_Subscription_Source__pc = 'CSR';
                
                acc.Subscribed_By_CSR_Name__c = UserInfo.getName();
                acc.Preferred_Lang__pc = language;
                acc.PersonMobilePhone = mobile;
                if(currentProfile != null && currentProfile.Name != '' && (currentProfile.Name == 'System Administrator' || currentProfile.Name =='Warranty CSR-Tier2 User') ){
                    acc.Subscribed_By__c = 'Call Center';
                }
                else if(currentProfile != null && currentProfile.Name != '' && currentProfile.Name == 'Flagship Store'){
                    acc.Subscribed_By__c = 'Flagship Store';
                }
            }
            else{
             	acc.PersonHasOptedOutOfEmail = true;
                /*acc.B2C_Add_To_Email_List__pc = false;*/
            	acc.Marketing_Consent_Date__pc = DateTime.now();
            	acc.Marketing_Consent_Status__pc = 'Unsubscribed';
                acc.Marketing_Country_Code__pc = countryCode;
                acc.Origin__pc = 'Service Portal';
                acc.Marketing_Source_Location__pc = 'SFSC';
                acc.Marketing_Subscription_Source__pc = 'CSR';
                acc.PersonMobilePhone = mobile;
           
            } 
            if(acc != null){
                update acc;
                System.debug(acc);
          	}
          return acc;  
        }
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        finally{
            return acc;
        }
	}
     @AuraEnabled(cacheable = true)
    public static account getAccountData(string accountId){
        Account acc = new Account();
        try{
            if(accountId != null && accountId != ''){
                acc = [SELECT Id, PersonHasOptedOutOfEmail, Marketing_Country_Code__pc, Preferred_Lang__pc,PersonMobilePhone 
                                FROM Account WHERE id =:accountId LIMIT 1];
            }
            return acc;
        }
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        finally{
            return acc;
        }
    }
    
    
     @AuraEnabled(cacheable = true)
    public static list< Country_Code__mdt > getMetaData(){
        try{ return [SELECT Country__c , Country_Code__c, Languages__c, Frequently_Used__c  FROM Country_Code__mdt ORDER BY Frequently_Used__c DESC];}
        catch (Exception e) { throw new AuraHandledException(e.getMessage()); }
    }
}