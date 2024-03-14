@isTest
private class AdyenPaymentControllerTest {
    private static final String CONTACT_LAST_NAME1 = '3ff3cd4c7199a983bd';
    private static final String CONTACT_LAST_NAME2 = '793d10bdfc2a96bcff';
    
    @testSetup
    static void Init() {
        TestDataFactory.createTestAdyenHPPWarrantyOrgDefault(true);
        TestDataFactory.createTestRepairFacility('66057','Elk Grove Village','IL','US',true);
    }

    @isTest
    static void getJsonResponseTest(){
        AdyenPayByLinkEndpoint__c paylink = new AdyenPayByLinkEndpoint__c();
        paylink.Name='PayByLink';
        paylink.URL__c = 'https://google.com';
        insert paylink;
         Test.setMock(HttpCalloutMock.class, new AdyenConnector_MockService());
        
        Map<String,String> params = new Map<String,String>();
        
        params.put('A','a');
        params.put('B',null);
        params.put('C','c');
        
        List<String> listparams = new List<String>(params.keySet());
        
        String jsonres = AdyenPaymentController.getJsonResponse(listparams, params);
        System.assertEquals(jsonres,'{"A":"a","B":"","C":"c"}');
    }
    
    @isTest
    static void getHppformTest(){
        AdyenPayByLinkEndpoint__c paylink = new AdyenPayByLinkEndpoint__c();
        paylink.Name='PayByLink';
        paylink.URL__c = 'https://google.com';
        insert paylink;
         Test.setMock(HttpCalloutMock.class, new AdyenConnector_MockService());
        
        Account ac1 = TestDataFactory.createTestAccount(false);
        ac1.ShippingCity = 'Houston';
        ac1.ShippingPostalCode = '77057';
        ac1.ShippingState = 'Texas';
        ac1.ShippingStateCode = 'TX';
        ac1.ShippingCountryCode = 'US';
        ac1.ShippingCountry = 'United States';
        ac1.Currency__c = 'USD';
        insert ac1;
        
        Contact ct1 = TestDataFactory.createTestContact('OneSourceTest', ac1.Id, true);
        
        Repair_Facility__c rf1 = TestDataFactory.createTestRepairFacility('77057','Elk Grove Village','IL','US',true);
        
        Case cs1 = TestDataFactory.createTestCase(ac1.Id, ct1.Id, false);
        cs1.Repair_Facility__c=rf1.Id;
        insert cs1;
        
        Repair__c r1 = TestDataFactory.createTestRepair(true);
        
        Inspection_Result__c ir1 = TestDataFactory.createTestInspectionResult(cs1.Id, r1.Id, true);
        
        cs1.Status = 'Pending Payment';
        update cs1;
        
        test.startTest();
        
        System.assertNotEquals(AdyenPaymentController.getHppform(cs1.Id,'1'),'','getHppform should return a String value');
        
        test.stopTest();
    }

    
    @isTest
    static void getHppReceivedPaymentVerificationTest1(){
        AdyenPayByLinkEndpoint__c paylink = new AdyenPayByLinkEndpoint__c();
        paylink.Name='PayByLink';
        paylink.URL__c = 'https://google.com';
        insert paylink;
        
         Test.setMock(HttpCalloutMock.class, new AdyenConnector_MockService());
        
        Account ac = TestDataFactory.createTestAccount(true);
        Contact ct = TestDataFactory.createTestContact('VerificationTest1Contact',ac.Id,true);
        Case cs = TestDataFactory.createTestCase(ac.Id , ct.Id, true);
        cs.Status = 'Pending Payment';
        cs.Customer_Status__c = 'Payment Required';
        //cs.Id = '500m0000007ZeQPAA0';
        cs.Payment_Salesforce_Reference__c = cs.Id+'-20180426153706';
        cs.Payment_Adyen_Reference__c = null;
        update cs;
        
        Repair__c rep = TestDataFactory.createTestRepair(true);
        
        TestDataFactory.createTestInspectionResult(cs.Id , rep.Id, true);
        TestDataFactory.createTestInspectionResult(cs.Id , rep.Id, true);
        TestDataFactory.createTestInspectionResult(cs.Id , rep.Id, false);
        
        //Case VF Page
        ApexPages.StandardController sc = new ApexPages.StandardController(cs);
        PageReference pageRef = Page.AdyenPaymentReceived;
        Test.setCurrentPage(pageRef);
        
        AdyenPaymentController apc = new AdyenPaymentController();
        
        Set<String> SetParams = new Set<String>{'skinCode','authResult','paymentMethod','merchantSig','shopperLocale','merchantReference','pspReference'};
        setParams.remove('merchantSig');
        List<String> ListParams=new List<String>(setParams);
        ListParams.sort();
        Map<String,String> MapParams = new Map<String,String>();
        mapParams.put('skinCode','knNPycs1');
        mapParams.put('authResult','AUTHORISED');
        mapParams.put('paymentMethod','visa');
        mapParams.put('shopperLocale','en_CA');
        mapParams.put('merchantReference',cs.Payment_Salesforce_Reference__c);
        mapParams.put('pspReference','8835247570530891');
        
        String MerchantSig = AdyenPaymentController.getMerchantSig(ListParams,mapParams,false);
        String Referer = 'https://dev-canadagoose.cs20.force.com/warranty/s/payment-received?merchantSig='+
            MerchantSig+
            '&skinCode=knNPycs1&authResult=AUTHORISED&paymentMethod=visa&shopperLocale=en_CA&merchantReference='+
            cs.Payment_Salesforce_Reference__c+
            '&pspReference=8835247570530891';
            
        System.currentPageReference().getHeaders().put('Referer', Referer);
        //Url testurl = new URL('https://dev-canadagoose.cs20.force.com/warranty/s/payment-received?merchantSig=kNnB6kByYsreu8i3qXo%2BHEbR414cuVUn3s8YcQeMtgY%3D&skinCode=knNPycs1&authResult=AUTHORISED&paymentMethod=visa&shopperLocale=en_CA&merchantReference=500m0000007ZeQPAA0-20180426153706&pspReference=8835247570530891');
                
        Test.startTest();
        
        //merchantsig!=null
        apc.getHPPReceivedPaymentVerification();
        
        Test.stopTest();
    }

    @isTest
    static void getHppReceivedPaymentVerificationTest2(){
        AdyenPayByLinkEndpoint__c paylink = new AdyenPayByLinkEndpoint__c();
        paylink.Name='PayByLink';
        paylink.URL__c = 'https://google.com';
        insert paylink;
        
         Test.setMock(HttpCalloutMock.class, new AdyenConnector_MockService());
        
        Account ac = TestDataFactory.createTestAccount(true);
        Contact ct = TestDataFactory.createTestContact('TestContactHppForm',ac.Id,true);
        Case cs = TestDataFactory.createTestCase(ac.Id, ct.Id, true);
        cs.Payment_Salesforce_Reference__c = cs.Id + '-20180426153706';
        cs.Payment_Adyen_Reference__c = '8835247570530891';
        update cs;
        
        //Case VF Page
        ApexPages.StandardController sc = new ApexPages.StandardController(cs);
        PageReference pageRef = Page.AdyenPaymentReceived;
        Test.setCurrentPage(pageRef);
        
        Test.setCurrentPageReference(new PageReference('Page.AdyenPaymentReceived')); 
        System.currentPageReference().getParameters().put('merchantSig', 'kNnB6kByYsreu8i3qXo%2BHEbR414cuVUn3s8YcQeMtgY%3D');
        System.currentPageReference().getParameters().put('skinCode', 'knNPycs1');
        System.currentPageReference().getParameters().put('authResult', 'NOTAUTHORISED');
        System.currentPageReference().getParameters().put('paymentMethod', 'visa');
        System.currentPageReference().getParameters().put('shopperLocale', 'en_CA');
        System.currentPageReference().getParameters().put('merchantReference', cs.Payment_Salesforce_Reference__c);
        System.currentPageReference().getParameters().put('pspReference', '8835247570530891');
        
        //Url testurl = new URL('https://dev-canadagoose.cs20.force.com/warranty/s/payment-received?merchantSig=kNnB6kByYsreu8i3qXo%2BHEbR414cuVUn3s8YcQeMtgY%3D&skinCode=knNPycs1&authResult=AUTHORISED&paymentMethod=visa&shopperLocale=en_CA&merchantReference=500m0000007ZeQPAA0-20180426153706&pspReference=8835247570530891');
        
        AdyenPaymentController apc = new AdyenPaymentController();
        
        Test.startTest();
        
        //merchantsig!=null
        apc.getHPPReceivedPaymentVerification();
        
        Test.stopTest();
    }

    @isTest
    static void getHppReceivedPaymentVerificationTest3(){     
        AdyenPayByLinkEndpoint__c paylink = new AdyenPayByLinkEndpoint__c();
        paylink.Name='PayByLink';
        paylink.URL__c = 'https://google.com';
        insert paylink;
           
        Test.setMock(HttpCalloutMock.class, new AdyenConnector_MockService());
        
        Account ac = TestDataFactory.createTestAccount(true);
        Contact ct = TestDataFactory.createTestContact('TestContactHppForm',ac.Id,true);
        Case cs = TestDataFactory.createTestCase(ac.Id, ct.Id, true);
        cs.Payment_Salesforce_Reference__c = cs.Id + '-20180426153706';
        cs.Payment_Adyen_Reference__c = '8835247570530891';
        update cs;
        
        //Case VF Page
        ApexPages.StandardController sc = new ApexPages.StandardController(cs);
        PageReference pageRef = Page.AdyenPaymentReceived;
        Test.setCurrentPage(pageRef);
        
        //Test.setCurrentPageReference(new PageReference('Page.AdyenPaymentReceived')); 
        
        //Url testurl = new URL('https://dev-canadagoose.cs20.force.com/warranty/s/payment-received?merchantSig=kNnB6kByYsreu8i3qXo%2BHEbR414cuVUn3s8YcQeMtgY%3D&skinCode=knNPycs1&authResult=AUTHORISED&paymentMethod=visa&shopperLocale=en_CA&merchantReference=500m0000007ZeQPAA0-20180426153706&pspReference=8835247570530891');
        
        AdyenPaymentController apc = new AdyenPaymentController();
        
        Test.startTest();
        
        //merchantsig!=null
        apc.getHPPReceivedPaymentVerification();
        
        Test.stopTest();
    }
    
    @isTest
    static void getHppReceivedPaymentVerificationTest4(){
        AdyenPayByLinkEndpoint__c paylink = new AdyenPayByLinkEndpoint__c();
        paylink.Name='PayByLink';
        paylink.URL__c = 'https://google.com';
        insert paylink;
        
        Test.setMock(HttpCalloutMock.class, new AdyenConnector_MockService());
        
        Account ac = TestDataFactory.createTestAccount(true);
        Contact ct = TestDataFactory.createTestContact('TestContactHppForm',ac.Id,true);
        Case cs = TestDataFactory.createTestCase(ac.Id, ct.Id, true);
        cs.Payment_Salesforce_Reference__c = cs.Id + '-20180426153706';
        cs.Payment_Adyen_Reference__c = '8835247570530891';
        update cs;

        //Case VF Page
        ApexPages.StandardController sc = new ApexPages.StandardController(cs);
        PageReference pageRef = Page.AdyenPaymentReceived;
        Test.setCurrentPage(pageRef);
        
        Test.setCurrentPageReference(new PageReference('Page.AdyenPaymentReceived')); 
        //System.currentPageReference().getParameters().put('merchantReference', String.valueOf(cs.Id)+'-20180426153706');

        Set<String> SetParams = new Set<String>{'skinCode','authResult','paymentMethod','merchantSig','shopperLocale','merchantReference','pspReference'};
        setParams.remove('merchantSig');
        List<String> ListParams=new List<String>(setParams);
        ListParams.sort();
        Map<String,String> MapParams = new Map<String,String>();
        mapParams.put('skinCode','knNPycs1');
        mapParams.put('authResult','AUTHORISED');
        mapParams.put('paymentMethod','visa');
        mapParams.put('shopperLocale','en_CA');
        mapParams.put('merchantReference',cs.Payment_Salesforce_Reference__c);
        mapParams.put('pspReference','8835247570530891');

        String MerchantSig = AdyenPaymentController.getMerchantSig(ListParams,mapParams,false);
        String Referer = 'https://dev-canadagoose.cs20.force.com/warranty/s/payment-received?merchantSig='+
            MerchantSig+
            '&skinCode=knNPycs1&authResult=AUTHORISED&paymentMethod=visa&shopperLocale=en_CA&merchantReference='+
            cs.Payment_Salesforce_Reference__c+
            '&pspReference=8835247570530891';

        System.currentPageReference().getParameters().put('skinCode','knNPycs1');
        System.currentPageReference().getParameters().put('authResult','AUTHORISED');
        System.currentPageReference().getParameters().put('paymentMethod','visa');
        System.currentPageReference().getParameters().put('shopperLocale','en_CA');
        System.currentPageReference().getParameters().put('merchantReference',cs.Payment_Salesforce_Reference__c);
        System.currentPageReference().getParameters().put('pspReference','8835247570530891');
        System.currentPageReference().getParameters().put('merchantSig',MerchantSig);
            
        System.currentPageReference().getHeaders().put('Referer', Referer);
        //Url testurl = new URL('https://dev-canadagoose.cs20.force.com/warranty/s/payment-received?merchantSig=kNnB6kByYsreu8i3qXo%2BHEbR414cuVUn3s8YcQeMtgY%3D&skinCode=knNPycs1&authResult=AUTHORISED&paymentMethod=visa&shopperLocale=en_CA&merchantReference=500m0000007ZeQPAA0-20180426153706&pspReference=8835247570530891');
        
        AdyenPaymentController apc = new AdyenPaymentController();

        Test.startTest();
        
        //merchantsig!=null
        apc.getHPPReceivedPaymentVerification();
        
        Test.stopTest();
    }

    @isTest
    static void getHppReceivedPaymentVerificationTest5(){
    AdyenPayByLinkEndpoint__c paylink = new AdyenPayByLinkEndpoint__c();
    paylink.Name='PayByLink';
    paylink.URL__c = 'https://google.com';
    insert paylink;
         Test.setMock(HttpCalloutMock.class, new AdyenConnector_MockService());
        
        Style__c style = new Style__c();
        style.name ='57576M';
        insert style;
        
        Account ac = TestDataFactory.createTestAccount(true);
        Contact ct = TestDataFactory.createTestContact('TestContactHppForm',ac.Id,true);
        Case cs = TestDataFactory.createTestCase(ac.Id, ct.Id, true);
        cs.Payment_Salesforce_Reference__c = cs.Id + '-20180426153706';
        cs.Payment_Adyen_Reference__c = '8835247570530891';
        update cs;

        Repair__c rep = TestDataFactory.createTestRepair(true);
        
        TestDataFactory.createTestInspectionResult(cs.Id , rep.Id, true);
        
        // Move the status to check with customer to trigger the pending payment status
        cs.Status = 'Check In With Customer';
        cs.Repair_Facility__c = [SELECT Id FROM Repair_Facility__c WHERE Postal_Code__c = '66057' LIMIT 1].Id;
        cs.Tag_Removed__c = true;
        cs.Style__c =style.id;
        update cs;
        
        //Case VF Page
        ApexPages.StandardController sc = new ApexPages.StandardController(cs);
        PageReference pageRef = Page.AdyenPaymentReceived;
        Test.setCurrentPage(pageRef);
        
        Test.setCurrentPageReference(new PageReference('Page.AdyenPaymentReceived')); 
        //System.currentPageReference().getParameters().put('merchantReference', String.valueOf(cs.Id)+'-20180426153706');

        Set<String> SetParams = new Set<String>{'skinCode','authResult','paymentMethod','merchantSig','shopperLocale','merchantReference','pspReference'};
        setParams.remove('merchantSig');
        List<String> ListParams=new List<String>(setParams);
        ListParams.sort();
        Map<String,String> MapParams = new Map<String,String>();
        mapParams.put('skinCode','knNPycs1');
        mapParams.put('authResult','AUTHORISED');
        mapParams.put('paymentMethod','visa');
        mapParams.put('shopperLocale','en_CA');
        mapParams.put('merchantReference',cs.Payment_Salesforce_Reference__c);
        mapParams.put('pspReference','');

        String MerchantSig = AdyenPaymentController.getMerchantSig(ListParams,mapParams,false);
        String Referer = 'https://dev-canadagoose.cs20.force.com/warranty/s/payment-received?merchantSig='+
            MerchantSig+
            '&skinCode=knNPycs1&authResult=AUTHORISED&paymentMethod=visa&shopperLocale=en_CA&merchantReference='+
            cs.Payment_Salesforce_Reference__c+
            '&pspReference=8835247570530891';

        System.currentPageReference().getParameters().put('skinCode','knNPycs1');
        System.currentPageReference().getParameters().put('authResult','AUTHORISED');
        System.currentPageReference().getParameters().put('paymentMethod','visa');
        System.currentPageReference().getParameters().put('shopperLocale','en_CA');
        System.currentPageReference().getParameters().put('merchantReference',cs.Payment_Salesforce_Reference__c);
        System.currentPageReference().getParameters().put('pspReference','');
        System.currentPageReference().getParameters().put('merchantSig',MerchantSig);
            
        System.currentPageReference().getHeaders().put('Referer', Referer);
        //Url testurl = new URL('https://dev-canadagoose.cs20.force.com/warranty/s/payment-received?merchantSig=kNnB6kByYsreu8i3qXo%2BHEbR414cuVUn3s8YcQeMtgY%3D&skinCode=knNPycs1&authResult=AUTHORISED&paymentMethod=visa&shopperLocale=en_CA&merchantReference=500m0000007ZeQPAA0-20180426153706&pspReference=8835247570530891');
        
        AdyenPaymentController apc = new AdyenPaymentController();

        Test.startTest();
        //merchantsig!=null
        apc.getHPPReceivedPaymentVerification();
        Test.stopTest();
        
        List<Invoice__c> Invoices = new List<Invoice__c>([select Id from Invoice__c where case__c = : cs.Id]);
        //assert an invoice has been created
        system.assertEquals(Invoices.size(), 2);
    }
    
    
    @isTest
    static void getHppReceivedPaymentVerificationTestURL(){
        AdyenPayByLinkEndpoint__c paylink = new AdyenPayByLinkEndpoint__c();
        paylink.Name='PayByLink';
        paylink.URL__c = 'https://google.com';
        insert paylink;
        
         Test.setMock(HttpCalloutMock.class, new AdyenConnector_MockService());
        
        Style__c style = new Style__c();
        style.name ='57576M';
        insert style;
        
        Account ac = TestDataFactory.createTestAccount(true);
        Contact ct = TestDataFactory.createTestContact('TestContactHppForm',ac.Id,true);
        Case cs = TestDataFactory.createTestCase(ac.Id, ct.Id, true);
        cs.Payment_Salesforce_Reference__c = cs.Id + '-20180426153706';
        cs.Payment_Adyen_Reference__c = '8835247570530891';
        cs.PayByLinkURL__c ='https://google.com';
        cs.Tag_Removed__c = true;
        cs.style__c =style.id;
       
        update cs;

        Repair__c rep = TestDataFactory.createTestRepair(true);
        
        TestDataFactory.createTestInspectionResult(cs.Id , rep.Id, true);
        
        // Move the status to check with customer to trigger the pending payment status
        cs.Status = 'Check In With Customer';
        cs.Repair_Facility__c  = [SELECT Id FROM Repair_Facility__c WHERE Postal_Code__c = '66057' LIMIT 1].Id;
        update cs;
        
        //Case VF Page
        ApexPages.StandardController sc = new ApexPages.StandardController(cs);
        PageReference pageRef = Page.AdyenPaymentReceived;
        Test.setCurrentPage(pageRef);
        
        Test.setCurrentPageReference(new PageReference('Page.AdyenPaymentReceived')); 
        //System.currentPageReference().getParameters().put('merchantReference', String.valueOf(cs.Id)+'-20180426153706');

        Set<String> SetParams = new Set<String>{'skinCode','authResult','paymentMethod','merchantSig','shopperLocale','merchantReference','pspReference'};
        setParams.remove('merchantSig');
        List<String> ListParams=new List<String>(setParams);
        ListParams.sort();
        Map<String,String> MapParams = new Map<String,String>();
        mapParams.put('skinCode','knNPycs1');
        mapParams.put('authResult','AUTHORISED');
        mapParams.put('paymentMethod','visa');
        mapParams.put('shopperLocale','en_CA');
        mapParams.put('merchantReference',cs.Payment_Salesforce_Reference__c);
        mapParams.put('pspReference','');

        String MerchantSig = AdyenPaymentController.getMerchantSig(ListParams,mapParams,false);
        String Referer = 'https://dev-canadagoose.cs20.force.com/warranty/s/payment-received?merchantSig='+
            MerchantSig+
            '&skinCode=knNPycs1&authResult=AUTHORISED&paymentMethod=visa&shopperLocale=en_CA&merchantReference='+
            cs.Payment_Salesforce_Reference__c+
            '&pspReference=8835247570530891';

        System.currentPageReference().getParameters().put('skinCode','knNPycs1');
        System.currentPageReference().getParameters().put('authResult','AUTHORISED');
        System.currentPageReference().getParameters().put('paymentMethod','visa');
        System.currentPageReference().getParameters().put('shopperLocale','en_CA');
        System.currentPageReference().getParameters().put('merchantReference',cs.Payment_Salesforce_Reference__c);
        System.currentPageReference().getParameters().put('pspReference','');
        System.currentPageReference().getParameters().put('merchantSig',MerchantSig);
            
        System.currentPageReference().getHeaders().put('Referer', Referer);
        //Url testurl = new URL('https://dev-canadagoose.cs20.force.com/warranty/s/payment-received?merchantSig=kNnB6kByYsreu8i3qXo%2BHEbR414cuVUn3s8YcQeMtgY%3D&skinCode=knNPycs1&authResult=AUTHORISED&paymentMethod=visa&shopperLocale=en_CA&merchantReference=500m0000007ZeQPAA0-20180426153706&pspReference=8835247570530891');
        string URL = '{"merchantSig":"'+AdyenPaymentController.getMerchantSig(ListParams,mapParams,false)+'","skinCode":"8DSIt217","authResult":"AUTHORISED","paymentMethod":"visa","shopperLocale":"en_GB","merchantReference":"500c000000FgoL1AAJ-20190903155355","pspReference":"851567526053276J"}';
       

        Test.startTest();
        //merchantsig!=null
        AdyenPaymentController.getHPPReceivedPaymentVerification(URL);
        Test.stopTest();
        
        List<Invoice__c> Invoices = new List<Invoice__c>([select Id from Invoice__c where case__c = : cs.Id]);
        //assert an invoice has been created
        system.assertEquals(Invoices.size(), 1);//as payment is tampered no invoice is generated
    }
    
    @isTest
    static void generalAdyenPaymentControllerTest(){
        AdyenPayByLinkEndpoint__c paylink = new AdyenPayByLinkEndpoint__c();
        paylink.Name='PayByLink';
        paylink.URL__c = 'https://google.com';
        insert paylink;
        
         Test.setMock(HttpCalloutMock.class, new AdyenConnector_MockService());
        
        Account ac = TestDataFactory.createTestAccount(true);
        Contact ct = TestDataFactory.createTestContact('TestContactHppForm',ac.Id,true);
        Case cs = TestDataFactory.createTestCase(ac.Id, ct.Id, true);
        cs.Payment_Salesforce_Reference__c = cs.Id + '-20180426153706';
        cs.Payment_Adyen_Reference__c = '8835247570530891';
        cs.PayByLinkURL__c ='https://google.com';
        update cs;

        //AdyenPaymentController apc = new AdyenPaymentController();
        
        //apc.PaymentConfirmationStatus = 'test';
        String temp = 'https:google.com';
    }
    
    @isTest
    static void getValidAdyenStringTest(){
        String s = '\\:';
        System.assertEquals(AdyenPaymentController.getValidAdyenString(s),'\\\\\\:','Should be \\\\\\:');
    }
    
    @isTest
    static void getMerchantSigTest(){
        AdyenPayByLinkEndpoint__c paylink = new AdyenPayByLinkEndpoint__c();
        paylink.Name='PayByLink';
        paylink.URL__c = 'https://google.com';
        insert paylink;
        
        Map<String,String> params = new Map<String,String>{
            'shopperLocale'=>'en_GB',
                'merchantReference'=>'paymentTest:143522\\64\\39255"',
                'merchantAccount'=>'TestMerchant',
                'sessionValidity'=>'2018-07-25T10:31:06Z',
                'shipBeforeDate'=>'2018-07-30',
                'paymentAmount'=>'1995',
                'currencyCode'=>'EUR',
                'skinCode'=>'X7hsNDWp',
                'EmptyKey'=>null
                };
                    
        List<String> sortedparams = new List<String>(params.keySet());
        sortedparams.sort();
        
        test.startTest();
        
        AdyenPaymentController.getMerchantSig(sortedparams, params, true);
        
        test.stopTest();
    }
    
    @isTest
    static void validateParamTest(){
        test.startTest();
        try {
            AdyenPaymentController.validateParam(null,'validate Param test message');
        }
        catch(CalloutException e){
            System.assertEquals(e.getMessage(),'validate Param test message','Message should be equivalent');
        }
        
        test.stopTest();
    }   
}