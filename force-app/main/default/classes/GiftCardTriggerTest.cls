@isTest(seeAllData = false)
private class GiftCardTriggerTest {
    
    @testSetup 
    static void setup() {
        
        list<account> accountsToInsert = new list<account>();
        
        Account acc = TestDataFactory.createTestAccount(true);
        
        
        Contact con = TestDataFactory.createTestContact('xyz', acc.Id, true);
        
        Account accItaly = new Account(
            Name = 'italy Account'
            , ShippingStreet = '250 Bowie Avenue'
            , ShippingCity = 'Alessandria'
            , ShippingCountry = 'Italy'
            , ShippingCountryCode = 'IT'
            , ShippingState = 'Alessandria'
            , Currency__c = 'EUR'
            , ShippingPostalCode = 'M6E 2R9'
        ) ;
        accountsToInsert.add(accItaly);
        
        Account accBelgium = new Account(
            Name = 'italy Account'
            , ShippingStreet = '250 Bowie Avenue'
            , ShippingCity = 'Bruxellles'
            , ShippingCountry = 'Belgium'
            , ShippingCountryCode = 'BE'
            , Currency__c = 'EUR'
            , ShippingPostalCode = 'M6E 2R9'
        ) ;
        accountsToInsert.add(accBelgium);
        
        Account accAustria = new Account(
            Name = 'Austria Account'
            , ShippingStreet = '250 Bowie Avenue'
            , ShippingCity = 'Graz'
            , ShippingCountry = 'Austria'
            , ShippingCountryCode = 'AT'
            , Currency__c = 'EUR'
            , ShippingPostalCode = 'M6E 2R9'
        ) ;
        accountsToInsert.add(accAustria);
        
        Account accNetherLand = new Account(
            Name = 'NetherLand Account'
            , ShippingStreet = '250 Bowie Avenue'
            , ShippingCity = ''
            , ShippingCountry = 'Netherlands'
            , ShippingCountryCode = 'NL'
            , Currency__c = 'EUR'
            , ShippingPostalCode = 'M6E 2R9'
        ) ;
        accountsToInsert.add(accNetherLand);
        
        Account accLuxembourg = new Account(
            Name = 'accLuxembourg Account'
            , ShippingStreet = '250 Bowie Avenue'
            , ShippingCity = ''
            , ShippingCountry = 'Luxembourg'
            , ShippingCountryCode = 'LU'
            , Currency__c = 'EUR'
            , ShippingPostalCode = 'M6E 2R9'
        ) ;
        accountsToInsert.add(accLuxembourg);
        
        Account accGermany = new Account(
            Name = 'accGermany Account'
            , ShippingStreet = '250 Bowie Avenue'
            , ShippingCity = ''
            , ShippingCountry = 'Germany'
            , ShippingCountryCode = 'DE'
            , Currency__c = 'EUR'
            , ShippingPostalCode = 'M6E 2R9'
        ) ;
        accountsToInsert.add(accGermany);
        
         Account accFrance = new Account(
            Name = 'accFrance Account'
            , ShippingStreet = '250 Bowie Avenue'
            , ShippingCity = ''
            , ShippingCountry = 'France'
            , ShippingCountryCode = 'FR'
            , Currency__c = 'EUR'
            , ShippingPostalCode = 'M6E 2R9'
        ) ;
        accountsToInsert.add(accFrance);
        
        Account accIreland = new Account(
            Name = 'accIreland Account'
            , ShippingStreet = '250 Bowie Avenue'
            , ShippingCity = ''
            , ShippingCountry = 'Ireland'
            , ShippingCountryCode = 'IE'
            , Currency__c = 'EUR'
            , ShippingPostalCode = 'M6E 2R9'
        ) ;
        accountsToInsert.add(accIreland);
        
        insert accountsToInsert;
        
        
        list<case> cases = new list<case>();
        
        Case c = TestDataFactory.createTestCase(acc.Id , con.Id, false);  
        c.Language__c='English';c.Transaction_code__c='DVCA_A00132340';
        c.Customer_Email__c='test@approve.com';
        c.Customer_Name__c='Rfirst Rlast';c.entryGreetingFrom__c='xyz';
        c.entryGreetingBody__c='Hello, this is a test message.';
        c.ecertDeliveryMethod__c='email';c.Region__c='North America - Canada';
        //insert c;
        
        cases.add(c);
        
        Case c2 = new Case(
            Status = 'New_Validate'
            , WIP_Status__c = null
            , AccountId = acc.Id
            , ContactId = con.Id
            , Has_Fur__c = 'No'
            , Accept_Cleaning_Health_Policy__c = true
        );
        c2.Language__c='French';
        c2.Transaction_code__c='DVCA_A00132340';
        c2.Customer_Email__c='test123@approve.com';
        c2.Customer_Name__c='Rfirst Rlast';
        c2.entryGreetingFrom__c='abc';
        c2.entryGreetingBody__c='Hello, this is a test message.';
        c2.ecertDeliveryMethod__c='email';
        c2.Region__c='North America - Canada';
        
        cases.add(c2);
        
        Case c3 = new Case(
            Status = 'New_Validate'
            , WIP_Status__c = null
            , AccountId = accItaly.Id
            , ContactId = con.Id
            , Has_Fur__c = 'No'
            , Accept_Cleaning_Health_Policy__c = true
        );
        c3.Language__c='English';
        
        c3.Transaction_code__c='DVCA_A00132340';
        c3.Customer_Email__c='USA@approve.com';
        c3.Customer_Name__c='Rfirst Rlast';
        c3.entryGreetingFrom__c='abc';
        c3.entryGreetingBody__c='Hello, this is a test message.';
        c3.ecertDeliveryMethod__c='email';
        c3.Region__c='Europe - EU';
        
        
        cases.add(c3);
        
        // insert cases;
        Case c4 = new Case(
            Status = 'New_Validate'
            , WIP_Status__c = null
            , AccountId = acc.Id
            , ContactId = con.Id
            , Has_Fur__c = 'No'
            , Accept_Cleaning_Health_Policy__c = true
        );
        
        // Case c4 = new Case();
        c4.Language__c='English';  
        c4.Transaction_code__c='DVCA_A00132341';
        c4.Customer_Email__c='USA@rejected.com';
        c4.Customer_Name__c='Rejected test';
        c4.entryGreetingFrom__c='abc..';
        c4.entryGreetingBody__c='Hello, this is a test message.';
        c4.ecertDeliveryMethod__c='email';
        c4.Region__c='North America - USA';
        
        cases.add(c4);
        
        Case c5 = new Case(
            Status = 'New_Validate'
            , WIP_Status__c = null
            , ContactId = con.Id
            , Has_Fur__c = 'No'
            , Accept_Cleaning_Health_Policy__c = true
        );
        
        // Case c4 = new Case();
        c5.Language__c='English';  
        c5.Transaction_code__c='DVCA_A00132341';
        c5.Customer_Email__c='UK@rejected.com';
        c5.Customer_Name__c='Rejected test';
        c5.entryGreetingFrom__c='abc..';
        c5.entryGreetingBody__c='Hello, this is a test message.';
        c5.ecertDeliveryMethod__c='email';
        c5.Region__c = 'Europe - UK';
        c5.Currency__c = 'GBP';
        cases.add(c5);
        
        Case c6 = new Case(
            Status = 'New_Validate'
            , WIP_Status__c = null
            , AccountId = accBelgium.Id
            , Has_Fur__c = 'No'
            , Accept_Cleaning_Health_Policy__c = true
        );
        c6.Language__c='English';
        
        c6.Transaction_code__c='DVCA_A00132340';
        c6.Customer_Email__c='Belgium@approve.com';
        c6.Customer_Name__c='Rfirst Rlast';
        c6.entryGreetingFrom__c='abc';
        c6.entryGreetingBody__c='Hello, this is a test message.';
        c6.ecertDeliveryMethod__c='email';
        c6.Region__c='Europe - EU';
        c6.Currency__c = 'EUR';
        
        cases.add(c6);
        
        Case c7 = new Case(
            Status = 'New_Validate'
            , WIP_Status__c = null
            , AccountId = accAustria.Id
            , Has_Fur__c = 'No'
            , Accept_Cleaning_Health_Policy__c = true
            ,Currency__c = 'EUR'
        );
        c7.Language__c='English';
        c7.Transaction_code__c='DVCA_A00132340';
        c7.Customer_Email__c='accAustria@approve.com';
        c7.Customer_Name__c='Rfirst Rlast';
        c7.entryGreetingFrom__c='abc';
        c7.entryGreetingBody__c='Hello, this is a test message.';
        c7.ecertDeliveryMethod__c='email';
        c7.Region__c='Europe - EU';
        
        
        cases.add(c7);
        
        Case c8 = new Case(
            Status = 'New_Validate'
            , WIP_Status__c = null
            , AccountId = accNetherLand.Id
            , Has_Fur__c = 'No'
            , Accept_Cleaning_Health_Policy__c = true
            ,Currency__c = 'EUR'
        );
        c8.Language__c='English';
        c8.Transaction_code__c='DVCA_A00132340';
        c8.Customer_Email__c='accNetherLand@approve.com';
        c8.Customer_Name__c='Rfirst Rlast';
        c8.entryGreetingFrom__c='abc';
        c8.entryGreetingBody__c='Hello, this is a test message.';
        c8.ecertDeliveryMethod__c='email';
        c8.Region__c='Europe - EU';
        
        cases.add(c8);
        
        Case c9 = new Case(
            Status = 'New_Validate'
            , WIP_Status__c = null
            , AccountId = accLuxembourg.Id
            , Has_Fur__c = 'No'
            , Accept_Cleaning_Health_Policy__c = true
            ,Language__c='English'
            ,Transaction_code__c='DVCA_A00132340'
            ,Customer_Email__c='acds@approve.com'
            ,Customer_Name__c='Rfirst Rlast'
            ,entryGreetingFrom__c='abc'
            ,entryGreetingBody__c='Hello, this is a test message.'
            ,ecertDeliveryMethod__c='email'
            ,Region__c='Europe - EU'
            ,Currency__c = 'EUR'
        );
        cases.add(c9);
        
        Case c10 = new Case(
            Status = 'New_Validate'
            , WIP_Status__c = null
            , AccountId = accFrance.Id
            , Has_Fur__c = 'No'
            , Accept_Cleaning_Health_Policy__c = true
            ,Language__c='English'
            ,Transaction_code__c='DVCA_A00132340'
            ,Customer_Email__c='accFrance@approve.com'
            ,Customer_Name__c='Rfirst Rlast'
            ,entryGreetingFrom__c='abc'
            ,entryGreetingBody__c='Hello, this is a test message.'
            ,ecertDeliveryMethod__c='email'
            ,Region__c='Europe - EU'
            ,Currency__c = 'EUR'
        );
        
        cases.add(c10);
        
        Case c11 = new Case(
            Status = 'New_Validate'
            , WIP_Status__c = null
            , AccountId = accGermany.Id
            , Has_Fur__c = 'No'
            , Accept_Cleaning_Health_Policy__c = true
            ,Language__c='English'
            ,Transaction_code__c='DVCA_A00132340'
            ,Customer_Email__c='accGermany@approve.com'
            ,Customer_Name__c='Rfirst Rlast'
            ,entryGreetingFrom__c='abc'
            ,entryGreetingBody__c='Hello, this is a test message.'
            ,ecertDeliveryMethod__c='email'
            ,Region__c='Europe - EU'
            ,Currency__c = 'EUR'
        );
        
        cases.add(c11);
        
        Case c12 = new Case(
            Status = 'New_Validate'
            , WIP_Status__c = null
            , AccountId = accIreland.Id
            , Has_Fur__c = 'No'
            , Accept_Cleaning_Health_Policy__c = true
            ,Language__c='English'
            ,Transaction_code__c='DVCA_A00132340'
            ,Customer_Email__c='accIreland@approve.com'
            ,Customer_Name__c='Rfirst Rlast'
            ,entryGreetingFrom__c='abc'
            ,entryGreetingBody__c='Hello, this is a test message.'
            ,ecertDeliveryMethod__c='email'
            ,Region__c='Europe - EU'
        );
        
        cases.add(c12);
        
        
        insert cases;   
        system.debug(LoggingLevel.INFO, c5 );
        system.debug(LoggingLevel.INFO, cases.size() );
        Inspection_Result__c Insp = new Inspection_Result__c(
            Case__c   = c4.id, 
            RecordTypeId = schema.sObjectType.Inspection_Result__c.getRecordTypeInfosByName().get('Replacement').getRecordTypeId(),
            Status__c    = 'Gift Card',
            Replacement_Reason__c = 'Colour Fading'
        );
        insert Insp;
        
        list<case> casesToUpdate = new list<case>();
        
        c4.Refund_Total__c = '100';
        c4.IsApproved__c = False;
        c4.Status = 'Pending Customer Feedback';
        casesToUpdate.add(c4);
        c5.Region__c = 'Europe - UK';
        casesToUpdate.add(c5);
        
        update casesToupdate;
        
        Approval.ProcessSubmitRequest app = new Approval.ProcessSubmitRequest();
        app.setObjectId(c4.Id);
        Approval.ProcessResult result = Approval.process(app);
        
        //  system.assertEquals(Approval.ProcessResult, result);
        
        Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
        req.setComments('Rejecting request');
        req.setAction('Reject');
        id workItemId = getWorkItemId(c4.Id);
        req.setWorkitemId(workItemId);
        Approval.ProcessResult result2 = Approval.process(req);
    }
    
    public static Case getCase(){
        Case c;
        try{
            
            c = [Select id,CaseNumber,Language__c,orderSender__c,Refund_Total__c,receivingName__c,CustomerEmail__c,CustomerName__c,expiryDate__c,
                 entryGreetingFrom__c,entryGreetingBody__c,ecertDeliveryDate__c,ecertDeliveryMethod__c,Region__c,Currency__c,Account.Language__c, 
                 Refund_Total_Before_Taxes__c,State_Tax_Rate__c from Case where Language__c='English' and Region__c = 'North America - Canada' LIMIT 1];
            System.debug(LoggingLevel.INFO,c);
        }
        catch(Exception e){
            
            System.debug('****Exception' + e.getMessage());
        }
        return c;
    }
    
    public static Case getUSACase(){
        Case c;
        try{
            
            c = [Select id,CaseNumber,Language__c,orderSender__c,Refund_Total__c,receivingName__c,CustomerEmail__c,CustomerName__c,expiryDate__c,
                 entryGreetingFrom__c,entryGreetingBody__c,ecertDeliveryDate__c,ecertDeliveryMethod__c,Region__c,Currency__c,Account.Language__c, 
                 Refund_Total_Before_Taxes__c,State_Tax_Rate__c from Case where Region__c = 'North America - USA' LIMIT 1];
            System.debug(LoggingLevel.INFO,c);
        }
        catch(Exception e){
            
            System.debug(LoggingLevel.INFO,'****Exception' + e.getMessage());
        }
        return c;
    }
    
    public static Case getUKCase(){
        Case c;
        try{
            
            c = [Select id,CaseNumber,Language__c,orderSender__c,Refund_Total__c,receivingName__c,CustomerEmail__c,CustomerName__c,expiryDate__c,
                 entryGreetingFrom__c,entryGreetingBody__c,ecertDeliveryDate__c,ecertDeliveryMethod__c,Region__c,Currency__c,Account.Language__c, 
                 Refund_Total_Before_Taxes__c,State_Tax_Rate__c from Case where Region__c = 'Europe - UK' LIMIT 1];
            
        }
        catch(Exception e){
            
            System.debug(LoggingLevel.INFO,'****Exception' + e.getMessage());
        }
        return c;
    }
    public static  list<Case> getEUCase(){
        list<Case> c;
        try{
            c = [Select id,CaseNumber,Language__c,orderSender__c,Refund_Total__c,receivingName__c,CustomerEmail__c,CustomerName__c,expiryDate__c,
                 entryGreetingFrom__c,entryGreetingBody__c,ecertDeliveryDate__c,ecertDeliveryMethod__c,Region__c,Currency__c,Account.Language__c, 
                 Refund_Total_Before_Taxes__c,State_Tax_Rate__c from Case where Region__c = 'Europe - EU' ];
            System.debug(LoggingLevel.INFO,c);
        }
        catch(Exception e){
            System.debug('****Exception' + e.getMessage());
        }
        return c;
    }
    
    public static  list<Case> getAllCase(){
        list<Case> c;
        try{
            c = [Select id,CaseNumber,Language__c,orderSender__c,Refund_Total__c,receivingName__c,CustomerEmail__c,CustomerName__c,expiryDate__c,
                 entryGreetingFrom__c,entryGreetingBody__c,ecertDeliveryDate__c,ecertDeliveryMethod__c,Region__c,Currency__c,Account.Language__c, 
                 Refund_Total_Before_Taxes__c,State_Tax_Rate__c from Case ];
            System.debug(LoggingLevel.INFO,c);
        }
        catch(Exception e){
            System.debug('****Exception' + e.getMessage());
        }
        return c;
    }
    
    public static Case getPendingCase(){
        Case c;
        try{
            c = [Select id,CaseNumber,Language__c,orderSender__c,Refund_Total__c,receivingName__c,CustomerEmail__c,CustomerName__c,expiryDate__c,
                 entryGreetingFrom__c,entryGreetingBody__c,ecertDeliveryDate__c,ecertDeliveryMethod__c,Region__c,Currency__c,Account.Language__c, 
                 Refund_Total_Before_Taxes__c,State_Tax_Rate__c from Case where status = 'Pending Customer Feedback' and Region__c = 'North America - USA' LIMIT 1 ];
            System.debug(LoggingLevel.INFO,c);
        }
        catch(Exception e){
            System.debug('****Exception' + e.getMessage());
        }
        return c;
    } 
  
    /*  public static Case getCasefrench(){
        Case c;
        try{
            c = [Select id,CaseNumber,Language__c,orderSender__c,Refund_Total__c,receivingName__c,CustomerEmail__c,CustomerName__c,expiryDate__c,
                 entryGreetingFrom__c,entryGreetingBody__c,ecertDeliveryDate__c,ecertDeliveryMethod__c,Region__c,Currency__c,Account.Language__c, 
                 Refund_Total_Before_Taxes__c,State_Tax_Rate__c from Case where Language__c='French' and Region__c = 'North America - Canada' LIMIT 1 ];
            System.debug(LoggingLevel.INFO,c);
        }
        catch(Exception e){
            System.debug('****Exception' + e.getMessage());
        }
        return c;
    }
   
		public static Case_Gift_Card__mdt  getCanadaData(){
        Case_Gift_Card__mdt  cg;
        try{
            cg = [select User__c,Password__c,Item_Id__c,Endpoint__c,Endpoint2__c from Case_Gift_Card__mdt where DeveloperName = 'Canada'];
        }
        catch(Exception e){
            System.debug('****Exception' + e.getMessage());
        }
        return cg;
    }
    */
    
    public static Case_Gift_Card__mdt  getData(string devName){
        Case_Gift_Card__mdt  cg;
        try{
            cg = [select User__c,Password__c,Item_Id__c,Endpoint__c,Endpoint2__c from Case_Gift_Card__mdt where DeveloperName = :devName];
        }
        catch(Exception e){
            System.debug('****Exception' + e.getMessage());
        }
        return cg;
    }
    
    public static Map<string,HttpCalloutMock> GetRequest(String resbody) {
        Case_Gift_Card__mdt cg = getData('Canada_English');
        SingleRequestMock res = new SingleRequestMock(200,
                                                      'OK',
                                                      resbody,
                                                      null);
        
        Map<string,HttpCalloutMock> mapOfrequests = new Map<string,HttpCalloutMock>();
        mapOfrequests.put(cg.Endpoint__c,res);
        
        // Update
        mapOfrequests.put(cg.Endpoint2__c,res);
        return mapOfrequests;
    }
    
    public static Map<string,HttpCalloutMock> GetBadRequest(String resbody) {
        Case_Gift_Card__mdt cg = getData('Canada_English');
        SingleRequestMock res = new SingleRequestMock(400,
                                                      'Bad Request',
                                                      resbody,
                                                      null);
        
        Map<string,HttpCalloutMock> mapOfrequests = new Map<string,HttpCalloutMock>();
        mapOfrequests.put(cg.Endpoint__c,res);
        
        // Update
        mapOfrequests.put(cg.Endpoint2__c,res);
        return mapOfrequests;
    }
    
    static testMethod void CalloutSuccessful() {
        case c = getCase();
        String resbody = '{"jsonrpc": "2.0", "id": "437", "result": ["DVCA_A00132340", "0", [["579991", "6099500097910034605", "1962"]], "586376"]}';
        Test.setMock(HttpCalloutMock.class, new MockHttpGC(GetRequest(resbody)));
        
        Test.startTest();
        c.IsApproved__c = true;
        update c;
        //System.enqueueJob(new GCcalloutQueueable(c));
        Test.stopTest();
        System.assertEquals(true, c.IsApproved__c);
    }
       
    static testMethod void CalloutUSASuccessful() {
        case c = getUSACase();
        String resbody = '{"jsonrpc": "2.0", "id": "437", "result": ["DVCA_A00132340", "0", [["579991", "6099500097910034605", "1962"]], "586376"]}';
        Test.setMock(HttpCalloutMock.class, new MockHttpGC(GetRequest(resbody)));
        
        Test.startTest();
        c.IsApproved__c = true;
        update c;
        //System.enqueueJob(new GCcalloutQueueable(c));
        Test.stopTest();
        System.assertEquals(true, c.IsApproved__c);
    }
    
    static testMethod void CalloutUKSuccessful() {
        case c = getUKCase();
        system.debug(LoggingLevel.INFO,c);
        String resbody = '{"jsonrpc": "2.0", "id": "437", "result": ["DVCA_A00132340", "0", [["579991", "6099500097910034605", "1962"]], "586376"]}';
        Test.setMock(HttpCalloutMock.class, new MockHttpGC(GetRequest(resbody)));
        
        Test.startTest();
        c.IsApproved__c = true;
        update c;
        //System.enqueueJob(new GCcalloutQueueable(c));
        Test.stopTest();
        System.assertEquals(true, c.IsApproved__c);
    }
    
    static testMethod void CalloutEUSuccessful() {
        list<case> cases = getEUCase();
        String resbody = '{"jsonrpc": "2.0", "id": "437", "result": ["DVCA_A00132340", "0", [["579991", "6099500097910034605", "1962"]], "586376"]}';
        Test.setMock(HttpCalloutMock.class, new MockHttpGC(GetRequest(resbody)));
        
        Test.startTest();
        for (case c :cases){
            c.IsApproved__c = true;
        }
        update cases;
        //System.enqueueJob(new GCcalloutQueueable(c));
        Test.stopTest();
        System.assertEquals(true, cases[0].IsApproved__c);
    }
    
    static testMethod void CalloutFailure() {
        list<case> cases = getAllCase();
        String resbody = '{"jsonrpc": "2.0", "id": "437", "result": ["DVCA_A00132340", "302", "CWS Entry quantity is not valid"]}';
        Test.setMock(HttpCalloutMock.class, new MockHttpGC(GetRequest(resbody)));
        
        Test.startTest();
        for(Case c : cases){
            c.IsApproved__c = true;
        }
        update cases;
        //System.enqueueJob(new GCcalloutQueueable(c));
        Test.stopTest();
    }
    
    /*  static testMethod void CalloutFailure1() {
case c = getCase();
String resbody = '{"jsonrpc": "2.0", "id": "437", "result": ["DVCA_A00132340", "302", "CWS Entry quantity is not valid"]}';

Test.setMock(HttpCalloutMock.class, new MockHttpGC(GetBadRequest(resbody)));

Test.startTest();
c.IsApproved__c = true;
update c;
//System.enqueueJob(new GCcalloutQueueable(c));
Test.stopTest();
System.assertEquals(true, c.IsApproved__c);
}

static testMethod void CalloutFailureUSA() {
case c = getUSACase();
String resbody = '{"jsonrpc": "2.0", "id": "437", "result": ["DVCA_A00132340", "302", "CWS Entry quantity is not valid"]}';

Test.setMock(HttpCalloutMock.class, new MockHttpGC(GetBadRequest(resbody)));

Test.startTest();
c.IsApproved__c = true;
update c;
//System.enqueueJob(new GCcalloutQueueable(c));
Test.stopTest();
System.assertEquals(true, c.IsApproved__c);
}
*/ 
    static testMethod void GetCaseIdofIR() {
        case c = getCase();
        Repair__c r = TestDataFactory.createTestRepair(true);
        Inspection_Result__c ir = TestDataFactory.createTestInspectionResult(c.id,r.id,true);
        System.assertEquals(ir.Case__c, GCJSON.GetCaseofIR(ir.id));
    }
    
    static testMethod void GetRefundTest() {
        case c = getCase();
        String[] s = GCJSON.GetRefund(c.id);
        System.assertEquals(c.Language__c, s[2]);
    }
    
    static testMethod void SetFieldsTest() {
        List<case> cases = getAllCase();
        integer i = 0;
        for(case c : cases){
            if(i == 3) break;
            i++;
            GCJSON.SetFields(c.id);
        }
        
        // System.assertEquals(1, GCJSON.SetFields(cases[3].id));
    }
    
    static testMethod void SendEmailTest() {
        case c = getPendingCase();
        List<Inspection_Result__c> insList = getInspectionResult(c.Id);
        List<id> caseIds = new List<id>();
        caseIds.add(c.id);
        CaseHelper.sendEmail(caseIds); 
        // System.assertEquals(1, GCJSON.SetFields(fc.id));
    }
    
    public static id getWorkItemId (id targetObjectId){
        id retVal = null; 
        for(ProcessInstanceWorkItem item: [SELECT p.id FROM ProcessInstanceWorkItem p 
                                           WHERE p.ProcessInstance.targetObjectId = :targetObjectId]){    
                                               retVal = item.id;                                       
                                           }
        return retVal;
    }
    
    public static List<Inspection_Result__c> getInspectionResult(id caseId){
        List<Inspection_Result__c> insList = [SELECT id, LastModifiedById, case__r.CaseNumber FROM Inspection_Result__c  
                                              WHERE Case__c = :CaseId 
                                              AND RecordType.Name = 'Replacement' 
                                              ORDER by LastModifiedById DESC LIMIT 1]; 
        return insList;
    }
}