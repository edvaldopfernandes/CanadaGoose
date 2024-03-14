@isTest
global class AdyenConnector_MockService implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest request) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('[{"amount": {"currency": "CAD","value": 22 },"countryCode": "CA","description": "Test Payment",    "expiresAt": "2022-10-15T00:00:00Z","merchantAccount": "CanadaGooseCA","reference": "001929501",    "reusable": false,    "shopperLocale": "en-CA",    "shopperReference": "00192950111",    "id": "PLCF3CAEA8569D737D",    "status": "active",    "url": "https://test.adyen.link/PLCF3CAEA8569D737D"}');
        response.setStatusCode(201);
        return response; 
    }
}