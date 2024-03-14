@isTest
public class RestWebServiceToInsertAccMock implements HttpCalloutMock {
	private string requestMsg;
    private string responseType;
    public RestWebServiceToInsertAccMock(string req, string resType){
		this.requestMsg = req;
        this.responseType = resType;
    }
    public HttpResponse respond(HttpRequest req) {
      	HttpResponse res = new HttpResponse();
        switch on this.responseType {
            when 'Success' {
                 	res.setHeader('Content-Type', 'application/json');
                    res.setBody(this.requestMsg);
                    res.setStatus('Success');
                    res.setStatusCode(200);
                    return res;
            }
            when 'Failure' {
                 	res.setHeader('Content-Type', 'application/json');
                    res.setBody(this.requestMsg);
                    res.setStatus('Error');
                    res.setStatusCode(400);
                    return res;
            }
       }
        return res;
	}
}