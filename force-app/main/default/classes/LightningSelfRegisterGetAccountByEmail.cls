public without sharing class LightningSelfRegisterGetAccountByEmail {
    public static String getAccountIDByEmail(String email){
        String accountId;
        List<Account> acclist = [SELECT Id FROM Account where RecordType.Name = 'Customer' and PersonEmail =:email limit 1];
            if(acclist.size() > 0){
                accountId = acclist[0].Id;
            }
			system.debug('accountId**********'+accountId); 
        return accountId;            
    }

}