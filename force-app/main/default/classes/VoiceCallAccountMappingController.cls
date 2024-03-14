public class VoiceCallAccountMappingController {
    
    
    @AuraEnabled(cacheable=true)
    
    public static InitWrapper findPersonAccRecord(string voiceCallId){
        
        InitWrapper oInitWrapper = new InitWrapper();
        
        VoiceCall oVoiceCall = [Select Id,FromPhoneNumber,ToPhoneNumber,Related_Person_Account__c From VoiceCall WHERE ID  =: voiceCallId LIMIT 1];
        if(oVoiceCall.Related_Person_Account__c != null){
            oInitWrapper.bHasPersonAccountAlreadyInVC = true;
            return oInitWrapper;
        }else{
            oInitWrapper.bHasPersonAccountAlreadyInVC = false;
        }
        oInitWrapper.oVcRecord = oVoiceCall;
        
        if(oVoiceCall.FromPhoneNumber != null){
            oInitWrapper.bHasCallerNumber = true;
            
            string sCallNumber = oVoiceCall.FromPhoneNumber;
            string sCallNumberWithoutplus = oVoiceCall.FromPhoneNumber.replace('+', ''); 
            list<string> lstCallNumberAllFormate = new list<string>{sCallNumber,sCallNumberWithoutplus};
                list<Account> lstMatchedPersonAccount = new list<Account>();
            
            for(Account pa : [Select Id,FirstName,LastName,PersonHomePhone,PersonMobilePhone,Phone,PersonAssistantPhone,PersonEmail
                              From Account 
                              WHERE RecordType.Name = 'Customer' AND 
                              (PersonHomePhone IN : lstCallNumberAllFormate OR  
                               PersonMobilePhone IN : lstCallNumberAllFormate OR 
                               Phone IN : lstCallNumberAllFormate OR 
                               PersonAssistantPhone IN : lstCallNumberAllFormate OR 
                               Mobile__c IN : lstCallNumberAllFormate) 
                             ]){
                                 
                                 lstMatchedPersonAccount.add(pa);
                                 
                                 
                             }
            
            oInitWrapper.matchPersonAccount = lstMatchedPersonAccount;
            oInitWrapper.bHasMatchPersonAccount = lstMatchedPersonAccount.size() > 0 ? true : false;
            
            
        }
        
        return oInitWrapper;
        
    }
    
    
    @AuraEnabled
    
    public static void createNewPersonAccountandLink(Account newPersonAcc, string vcId){
        
        newPersonAcc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Insert newPersonAcc;
        
        VoiceCall oVoiceCall = [Select Id,FromPhoneNumber,Related_Person_Account__c From VoiceCall WHERE ID  =: vcId LIMIT 1];
        oVoiceCall.Related_Person_Account__c = newPersonAcc.Id;
        Update oVoiceCall;
        
        
        
    }
    
    
    @AuraEnabled 
    public static list<Account> searchByPersonEmail(string sPersonEmailInput){
        
        list<Account> lstPersonAccount = new list<Account>();
        for(Account pa : [Select Id,FirstName,LastName,PersonHomePhone,PersonMobilePhone,Phone,PersonAssistantPhone,PersonEmail
                          From Account 
                          WHERE RecordType.Name = 'Customer' AND 
                          PersonEmail = : sPersonEmailInput 
                         ]){
                             
                             lstPersonAccount.add(pa);
                             
                             
                         }
        return lstPersonAccount; 
    }
    
    
    public class InitWrapper{
        @AuraEnabled public VoiceCall oVcRecord {get;set;}
        @AuraEnabled public boolean bHasCallerNumber {get;set;}
        @AuraEnabled public boolean bHasPersonAccountAlreadyInVC {get;set;}
        @AuraEnabled public list<account> matchPersonAccount {get;set;}
        @AuraEnabled public boolean bHasMatchPersonAccount {get;set;}
    }
    
    
    
}