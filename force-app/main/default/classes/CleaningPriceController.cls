public class CleaningPriceController {
    /*
    * Function: getContactCurrencyCode
    * --------------------
    * Lightning enabled function to support retrieving customer related information
    *
    *  returns: Currency Code for the logged in customer community user
	*/
    @AuraEnabled
    public static String getContactCurrencyCode() {
        User loggedUser = [SELECT AccountId FROM User WHERE Id = : UserInfo.getUserId()];
        Account loggedAccount = [SELECT Currency__C FROM Account WHERE Id = :loggedUser.AccountId];
        return loggedAccount.Currency__c;
    }
}