public with sharing class WarrantyPolicyController extends LightningController {
    
    @AuraEnabled
    public static Response saveAgreement(Boolean agreement) {
        try {
            User user = [SELECT Id, ContactId FROM User WHERE Id =:UserInfo.getUserId() LIMIT 1];
            Contact userCnt = [SELECT Id, AccountId FROM Contact WHERE Id =:user.ContactId LIMIT 1];

            Account acc = new Account();
            acc.Id = userCnt.AccountId;
            acc.CleaningAgreement__c = agreement;
            update acc;

            return new Response(true, 'success');
        } catch (Exception e) {
            return new Response(false, e.getMessage());
        }
    }
}