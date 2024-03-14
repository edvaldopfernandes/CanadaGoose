@isTest
public class orderDetailsDataParserTest {
    
    static testMethod void Callout() {
        
        
        RecordType personAccountRecordType =  [Select Id from RecordType where (Name='Customer') and (SobjectType='Account')];
    Account newPersonAccount = new Account();

    // for person accounts we can not update the Name field instead we have to update the    
    // FirstName and LastName individually

     newPersonAccount.FirstName = 'Fred';
     newPersonAccount.LastName = 'Smith';
        newPersonAccount.PersonEmail='TestAccount123@test.com';
     newPersonAccount.RecordType  = personAccountRecordType;
     insert newPersonAccount;
        
        List<Account> accList = [SELECT ID FROM ACCOUNT WHERE LastName = 'Smith'];
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new orderDetailsMockHttpResponse()); 
        Map<String,Object> data = orderDetailsDataParser.getDeserialize(accList[0].ID);
        
        System.assertEquals(String.valueof(data.get('example')), 'Test');
        Test.stopTest();
    }
    
        
}