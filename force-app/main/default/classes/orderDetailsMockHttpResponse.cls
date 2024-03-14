@isTest
global class orderDetailsMockHttpResponse implements HttpCalloutMock{

    global HTTPResponse respond(HTTPRequest req) {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"example":"Test"}');
        res.setStatusCode(200);
        return res;
    }
}