public class GWGGiftCardController {
    
    @auraEnabled()
    public static string createGiftCard(String recordId, String channel, String businessUnit, String reason,
                                         String total, String lang, String GWGCountryValue, String reasonDesc){
        String cardId = '';
        try{
            GWG_Gift_Card__c giftCard = new GWG_Gift_Card__c (customer__c = recordId, 
                                                              channel__c = channel,
                                                              business_Unit__c = businessUnit,
                                                              reason__c = reason,
                                                              GWG_Country__c = GWGCountryValue,
                                                              Gift_Card_Value__c = Decimal.valueOf(total),
                                                              GC_Language__c = lang,
                                                              Reason_Description__c = reasonDesc);
            insert giftCard;
            if(giftCard != null && giftCard.id != null){
                cardId = String.valueOf(giftCard.id);
                initiateCallout(cardId);
            }
            return cardId;
        }catch(DmlException e) {throw new AuraHandledException(e.getMessage());}
        finally{    
          return cardId;
        }
    }
	
    @auraEnabled(cacheable =true)
    public static list<GWG_Gift_Card__c> getGiftCards(String accId){
    	return [SELECT Id, Name, Gift_Card_Value__c, Approval_Status__c, Tracking_Number__c, Approval_Comment__c, IsApproved__c FROM GWG_Gift_Card__c WHERE customer__c =:accId];
    }
    public static void initiateCallout(Id cardId){
        if(cardId != null){ GWGGiftCardTriggerHandler.triggerUnapprovedGWGCard(cardId); }
    }
    
    @auraEnabled(cacheable =true)
    public static account getAccountLanguage(String accId){
       Account accRecord = new  Account();
       for( Account acc : [SELECT Id, Language__c, ShippingCountry FROM Account WHERE id =:accId LIMIT 1]){
            accRecord = acc;
       }
        return accRecord;
    }

	 @auraEnabled(cacheable =true)
    public static boolean checkPermission(){
       boolean isPermitted = false;
       for( user currentUser : [SELECT Id, profile.Name FROM User WHERE id =: UserInfo.getUserId() LIMIT 1]){
           GWG_Submit_Permission__c permissions = GWG_Submit_Permission__c.getValues(currentUser.profile.Name);
           if(permissions != null && permissions.IsPermitted__c == true){ isPermitted = true; }
       }
       return isPermitted;
    }
    
    
}