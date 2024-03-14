@isTest
public class getOrdersByOrderNumberTest {
    
        static testMethod void Callout() {
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new orderDetailsMockHttpResponse()); 
        Map<String,Object> data = getOrdersByOrderNumber.getDeserialize('1234');
        
        System.assertEquals(String.valueof(data.get('example')), 'Test');
        Test.stopTest();
    }

}