@isTest
public class getOrdersByEmailTest {
    static testMethod void Callout() {
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new orderDetailsMockHttpResponse()); 
        Map<String,Object> data = getOrdersByEmail.getDeserialize('TestAccount123@test.com');
        
        System.assertEquals(String.valueof(data.get('example')), 'Test');
        Test.stopTest();
    }

}