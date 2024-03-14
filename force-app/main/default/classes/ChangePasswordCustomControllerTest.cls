@isTest
public class ChangePasswordCustomControllerTest {
    private static final String CONTACT_LAST_NAME1 = '877d5675cf2223043f';
    private static final String CONTACT_LAST_NAME2 = '39493011050a147c45';

    @isTest
    static public void testChangePasswordWrong()
    {
        //create user 
        //Initialize
        Account acc = TestDataFactory.createTestAccount(true);
        Contact con = TestDataFactory.createTestContact(CONTACT_LAST_NAME1,acc.Id,true);
        User usr = TestDataFactory.createTestWarrantyCommunityUser(acc, con, false);
        
        usr.LanguageLocaleKey = 'en_US';
        insert usr;	
        System.setPassword(usr.Id, 'CritiqEc1!');
        User currentUser;
        
        System.runAs(usr)
        {      
            Test.startTest();
            currentUser = ChangePasswordCustomController.getUser();
            ChangePasswordCustomController.changePassword('CritiqEc1!', 'CritiqEc1!', 'CritiqEc1!');
            Test.stopTest();
        }
        
        system.assertEquals(currentUser.Id, usr.Id);
    }

    @isTest
    static public void testChangePasswordRight()
    {
        //create user 
        //Initialize
        Account acc = TestDataFactory.createTestAccount(true);
        Contact con = TestDataFactory.createTestContact(CONTACT_LAST_NAME2,acc.Id,true);
        User usr = TestDataFactory.createTestWarrantyCommunityUser(acc, con, false);
        
        usr.LanguageLocaleKey = 'en_US';
        insert usr;	
        System.setPassword(usr.Id, 'CritiqEc1!');
        User currentUser;
        
        System.runAs(usr)
        {      
            Test.startTest();
            currentUser = ChangePasswordCustomController.getUser();
            ChangePasswordCustomController.changePassword('CritiqEc2!','CritiqEc2!','CritiqEc1!');
            Test.stopTest();
        }
        system.assertEquals(currentUser.Id, usr.Id);
    }
}