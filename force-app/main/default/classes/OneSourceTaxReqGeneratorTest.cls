@isTest
private class OneSourceTaxReqGeneratorTest {

	@testSetup
    static void Init() {
    	TestDataFactory.createTestTROneSourceOrgDefault(true);
    }

	//Test callouts and
	@isTest static void TestCalloutMethod() {

		String fakeresponse = '<ROOT><TAX><IS_SUCCESS>true</IS_SUCCESS><EXTERNAL_COMPANY_ID>555</EXTERNAL_COMPANY_ID><TOTAL_TAX_AMOUNT>85.00</TOTAL_TAX_AMOUNT></TAX></ROOT>';
		Test.setMock(httpCalloutMock.class, new OneSourceTaxReqGeneratorMockCallout(fakeresponse));

		Test.startTest();
		
		System.assertEquals(85.00,OneSourceTaxReqGenerator.GetGeneratedTax('TestReqBody'),'XML Parser not grabbing correct value');

		Test.stopTest();
	}

	@isTest static void TestDMLMethods() {

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

        Account ac2 = TestDataFactory.createTestAccount(false);
		ac2.ShippingCity = 'Toronto';
		ac2.ShippingPostalCode = 'M4Y';
		ac2.ShippingState = 'Ontario';
		ac2.ShippingStateCode = 'ON';
		ac2.ShippingCountry = 'Canada';
		ac2.ShippingCountryCode = 'CA';
		ac2.Currency__c = 'CAD';
		insert ac2;

		Repair_Facility__c rf1 = TestDataFactory.createTestRepairFacility('77057','Elk Grove Village','IL','US',true);

		Case cs1 = TestDataFactory.createTestCase(ac1.Id, ct1.Id, false);
		cs1.Repair_Facility__c=rf1.Id;
		insert cs1;

		Repair__c r1 = TestDataFactory.createTestRepair(true);

		Inspection_Result__c ir0 = TestDataFactory.createTestInspectionResult(cs1.Id, r1.Id, true);

		Inspection_Result__c ir1 = [SELECT Display_Price__c, Repair__r.Product_Code__c, Repair__c, Case__c FROM Inspection_Result__c WHERE Id=:ir0.Id];
		List<Inspection_Result__c> irs = new List<Inspection_Result__c>{ir1};

		test.startTest();

		OneSourceTaxReqGenerator.GetGeneratedTaxFromInspectionResults(irs);
		OneSourceTaxReqGenerator.PostGeneratedTaxFromInspectionResults(irs);


		OneSourceTaxReqGenerator.GetRequestFromParams(cs1, ac1, rf1, irs, false, false); //TEST US (STATE)

		OneSourceTaxReqGenerator.GetRequestFromParams(cs1, ac2, rf1, irs, false, false); //TEST CA (PROVINCE)

		System.assertEquals(10,OneSourceTaxReqGenerator.GetSubtotalFromInspectionResults(irs),'Inspection result must have Display_Price__c of $10');

		test.stopTest();
	}	
}