public with sharing class ChangePasswordCustomController {
    @AuraEnabled 
    public static user getUser(){
        User u = [select id,Name, Username from User where id =: userInfo.getUserId()];
        return u;
    }
    
    @AuraEnabled
    public Static String changePassword(String newPassword, String verifyNewPassword, String oldPassword) {
        try {
            Site.changePassword(newPassword, verifyNewPassword, oldPassword);
            //System.changeOwnPassword(oldPassword, newPassword);
            return null;
        } catch (Exception ex) {
            return (ex.getMessage());
        }
    }
    
}