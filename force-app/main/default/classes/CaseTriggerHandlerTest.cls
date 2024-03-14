@isTest
private class CaseTriggerHandlerTest {
    private static final String CONTACT_LAST_NAME = 'uUQ42StQPFfjhVvra4';

    @TestSetup
    static void createTestData(){
        //Initialize
        Account account = TestDataFactory.createTestAccount(false);
        account.Region__c = 'North America - USA';
        account.ShippingCountryCode = 'US';
        account.ShippingState = 'New York';
        account.ShippingStateCode = 'NY';
        account.ShippingCity = 'New York';
        account.ShippingPostalCode = '77057';
        account.ShippingCountry = 'United States';
        account.Currency__c = 'USD';
        insert account;

        List<Contact> contacts = new List<Contact>();
        for(Integer i=0; i<5; i++){
            Contact contact = TestDataFactory.createTestContact('TestContact', account.Id, false);
            contacts.add(contact);
        }
        insert contacts;
    }

    @isTest static void testWireTransferInvoice(){
        //Initialize
        Account acc = TestDataFactory.createTestAccount(false);
        acc.ShippingStreet = '123 Test';
        acc.ShippingCity = 'Brasil';
        acc.ShippingState = 'Amazonas';
        acc.ShippingStateCode = 'AM';
        acc.ShippingCountry = 'Brazil';
        acc.ShippingCountryCode = 'BR';
        acc.ShippingPostalCode = '12345';
        insert acc;
        
        Contact con = TestDataFactory.createTestContact(CONTACT_LAST_NAME, acc.Id, true);
        Case cas = TestDataFactory.createTestCase(acc.Id , con.Id, false);
        Repair__c rep = TestDataFactory.createTestRepair(true);
        Repair_Facility__c repFac = TestDataFactory.createTestRepairFacility('M1M1M1', 'Toronto', 'ON', 'CA', true);
        cas.Repair_Facility__c = repFac.Id;
        insert cas;
        
        Inspection_Result__c inspectionResult = TestDataFactory.createTestInspectionResult(cas.Id , rep.Id, true);

        Test.startTest();
        // Move the status to check with customer to trigger the pending payment status
        cas.Status = 'Pending Payment';
        update cas;
        
        List<Invoice__c> lstInvoices = [SELECT Status__c, Payment_Method__c FROM Invoice__c WHERE Case__c = :cas.Id];
        //System.assertEquals(1, lstInvoices.size(), 'One wire-transfer invoice must be created');
        //System.assertEquals('Draft', lstInvoices[0].Status__c, 'Invoice must be created in Draft state');
        //System.assertEquals('wire-transfer', lstInvoices[0].Payment_Method__c, 'Invoice must be created with payment method of wire-transfer');

        List<Inspection_Result__c> lstInspectionResult = [SELECT Id FROM Inspection_Result__c WHERE Invoice__c = :lstInvoices[0].Id];
        //System.assertEquals(1, lstInspectionResult.size(), 'Inspection result must be assigned to the new draft invoice.');
        Test.stopTest();
        
        // Mark case as paid
        cas.Payment_Made__c = true;
        update cas;

        lstInvoices = [SELECT Status__c FROM Invoice__c WHERE Case__c = :cas.Id];
       //System.assertEquals('Paid', lstInvoices[0].Status__c, 'Invoice must be updated to Paid state');
    }

    @isTest static void should_AssociateContact_whenMultipleContactExist() {
        List<Contact> contacts = [SELECT Email FROM Contact];
        Case contactCase = new Case(
            Subject = 'Case 1.2',
            SuppliedEmail =  contacts[0].Email,
            SuppliedName = 'Suppier Name 1',
            Origin = 'Email - Ask Us',
            RecordTypeId = CaseConstants.RECORD_TYPE.EMAIL_SUPPORT,
            Client_Attention_Required__c = true
        );
        Test.startTest();
        insert new List<Case>{contactCase};
        Test.stopTest();

        Map<Id,Case> allCases = new Map<Id,Case>([SELECT Id, ContactId FROM Case]);
        //System.assertEquals(contacts[0].Id, allCases.get(contactCase.Id).ContactId, 'Contact did not update.');
    }

    @isTest static void should_AssociatePersonAccount_whenNoContactExist() {
        Case personCase = new Case(
            Subject = 'Case 1.3',
            SuppliedEmail = 'case3@email.com',
            SuppliedName = 'Suppier Name 1',
            Origin = 'Email - Ask Us',
            RecordTypeId = CaseConstants.RECORD_TYPE.EMAIL_SUPPORT,
            Client_Attention_Required__c = true
        );
        Test.startTest();
        insert new List<Case>{personCase};
        Test.stopTest();

        Map<Id,Case> allCases = new Map<Id,Case>([SELECT Id, ContactId FROM Case]);
        List<Account> personAccounts = [SELECT PersonContactId FROM Account WHERE PersonEmail =: personCase.SuppliedEmail];
        //System.assertEquals(personAccounts[0].PersonContactId, allCases.get(personCase.Id).ContactId, 'Contact did not update.');
	}
}