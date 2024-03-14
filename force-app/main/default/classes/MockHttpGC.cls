global class MockHttpGC implements HTTPCalloutMock {
    
    global Map<string,HttpCalloutMock> mapOfrequests;
    
    global MockHttpGC(Map<string,HttpCalloutMock> requests){
        this.mapOfrequests = requests;
    }
    
    global HTTPResponse respond(HTTPRequest req) {
        string url = req.getEndpoint();
        system.debug('req.getEndpoint() - '+req.getEndpoint());
        
        HttpCalloutMock mock ;
        
        for(String k : mapOfrequests.keySet()) {
            system.debug(k);
            if(url == k) {
                mock = mapOfrequests.get(url);
            }
            
        }
        
        //system.debug('mock.respond(req) - '+mock.respond(req));
        if (mock != null) {
            system.debug('mock.respond(req) - '+mock.respond(req));
            return mock.respond(req);
        }
        return mock.respond(req);
    }
}