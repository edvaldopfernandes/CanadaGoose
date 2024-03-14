@isTest
public class ServiceNowAPITest {
    // Helper method
    static String createTestRecord() {
        // Create test record
        User UserTest = new User(
            username = 'ovais.ali123@systemsltd.com',
            Alias =  'hamh',
            ProfileId = '00e1N000001tnTs', 
            Email = 'ovais.ali@systemsltd.com',
            EmailEncodingKey = 'ISO-8859-1',
            LastName = 'test',
            LanguageLocaleKey = 'pt_BR',
            LocaleSidKey = 'pt_BR',
            TimeZoneSidKey = 'America/Sao_Paulo');
        insert UserTest;
        return UserTest.username;
    }      
    @isTest static void testGetUserByUsername() {
        String username = createTestRecord();
        // Set up a test request
        RestRequest request = new RestRequest();
        request.requestUri =
            'https://canadagoose--cgdev.cs14.my.salesforce.com/services/apexrest/UserRecords/'
            + username;
        request.httpMethod = 'GET';
        RestContext.request = request;
        // Call the method to test
        User thisuser= ServiceNowAPI.getUserByUsername();
        // Verify results
        System.assert(thisuser != null);
    }
}