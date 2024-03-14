/**
* 	@description Created as a part of the Zendesk Migration to Salesforce project.
*/
@isTest
private class trac_EmailToCaseLoopPreventTest {
    @testSetup
    static void setupTestData() { 
        //Initialize
        Account account = TestDataFactory.createTestAccount(false);
        account.Name = 'Canada Goose - Test';
        account.Region__c = 'North America - USA';
        account.ShippingCountryCode = 'US';
        account.ShippingState = 'New York';
        account.ShippingStateCode = 'NY';
        account.ShippingCity = 'New York';
        account.ShippingPostalCode = '77057';
        account.ShippingCountry = 'United States';
        account.Currency__c = 'USD';
        insert account;
        Contact contact = TestDataFactory.createTestContact('AdamTestUser', account.Id, true);
        Queue_IDs__c queueIds = TestDataFactory.createTestQueueIDOrgDefault(true);
    }

    private static Contact getContact(){
        return [SELECT Id FROM Contact LIMIT 1];
    }
    
    @isTest static void testInvalidOriginCaseLoop() {
        Contact contact = getContact();

        Test.startTest();
        Case aCase1 = new Case(Subject = 'Case 1.2', SuppliedEmail = 'case1@email.com', Origin = 'Web', 
        Accept_Cleaning_Health_Policy__c = true, ContactId = contact.Id);
        insert aCase1;

        Case aCase2 = new Case(Subject = 'Case 1.3', SuppliedEmail = 'case1@email.com', Origin = 'Web', 
        Accept_Cleaning_Health_Policy__c = true, ContactId = contact.Id);
        insert aCase2;
        Test.stopTest();

        Map<Id,Case> allCases = new Map<Id,Case>([SELECT Id, CreatedDate, Don_t_Send_Auto_Response__c FROM Case]);
        System.assertEquals(false, allCases.get(aCase1.Id).Don_t_Send_Auto_Response__c);
        System.assertEquals(false, allCases.get(aCase2.Id).Don_t_Send_Auto_Response__c);
    }

    @isTest static void testInvalidEmailCaseLoop() {
        Contact contact = getContact();

        Test.startTest();
        Case aCase1 = new Case(Subject = 'Case 1.2', SuppliedEmail = 'case2@email.com', Origin = 'Email', 
            RecordTypeId = CaseConstants.RECORD_TYPE.EMAIL_SUPPORT, ContactId = contact.Id);
        insert aCase1;

        Case aCase2 = new Case(Subject = 'Case 1.3', SuppliedEmail = 'case3@email.com', Origin = 'Email', 
            RecordTypeId = CaseConstants.RECORD_TYPE.EMAIL_SUPPORT, ContactId = contact.Id);
        insert aCase2;
        Test.stopTest();

        Map<Id,Case> allCases = new Map<Id,Case>([SELECT Id, CreatedDate, Don_t_Send_Auto_Response__c FROM Case]);
        System.assertEquals(false, allCases.get(aCase1.Id).Don_t_Send_Auto_Response__c);
        System.assertEquals(false, allCases.get(aCase2.Id).Don_t_Send_Auto_Response__c);
	}

    @isTest static void testValidCaseLoop() {
        Contact contact = getContact();

        Test.startTest();
        Case aCase1 = new Case(Subject = 'Case 1.2', SuppliedEmail = 'case1@email.com', Origin = 'Email', 
            RecordTypeId = CaseConstants.RECORD_TYPE.EMAIL_SUPPORT, ContactId = contact.Id);
        insert aCase1;

        Case aCase2 = new Case(Subject = 'Case 1.3', SuppliedEmail = 'case1@email.com', Origin = 'Email', 
            RecordTypeId = CaseConstants.RECORD_TYPE.EMAIL_SUPPORT, ContactId = contact.Id);
        insert aCase2;
        Test.stopTest();

        Map<Id,Case> allCases = new Map<Id,Case>([SELECT Id, CreatedDate, Don_t_Send_Auto_Response__c FROM Case]);
        System.assertEquals(false, allCases.get(aCase1.Id).Don_t_Send_Auto_Response__c);
        System.assertEquals(true, allCases.get(aCase2.Id).Don_t_Send_Auto_Response__c);
	}

    @isTest static void testValidCustomSetting() {
        Contact contact = getContact();

        Email_To_Case_Loop_Prevent__c loopPreventCustomSetting = new Email_To_Case_Loop_Prevent__c();
        loopPreventCustomSetting.Interval__c = 60;
        insert loopPreventCustomSetting;

        Test.startTest();
        Case aCase1 = new Case(Subject = 'Case 1.2', SuppliedEmail = 'case1@email.com', Origin = 'Email', 
            RecordTypeId = CaseConstants.RECORD_TYPE.EMAIL_SUPPORT, ContactId = contact.Id);
        insert aCase1;

        Case aCase2 = new Case(Subject = 'Case 1.3', SuppliedEmail = 'case1@email.com', Origin = 'Email', 
            RecordTypeId = CaseConstants.RECORD_TYPE.EMAIL_SUPPORT, ContactId = contact.Id);
        insert aCase2;
        Test.stopTest();

        Map<Id,Case> allCases = new Map<Id,Case>([SELECT Id, CreatedDate, Don_t_Send_Auto_Response__c FROM Case]);
        System.assertEquals(false, allCases.get(aCase1.Id).Don_t_Send_Auto_Response__c);
        System.assertEquals(true, allCases.get(aCase2.Id).Don_t_Send_Auto_Response__c);
    }

    @isTest static void testNegativeCustomSetting() {
        Contact contact = getContact();
        
        Email_To_Case_Loop_Prevent__c loopPreventCustomSetting = new Email_To_Case_Loop_Prevent__c();
        loopPreventCustomSetting.Interval__c = -1;
        insert loopPreventCustomSetting;

        Test.startTest();
        Case aCase1 = new Case(Subject = 'Case 1.2', SuppliedEmail = 'case1@email.com', Origin = 'Email', 
            RecordTypeId = CaseConstants.RECORD_TYPE.EMAIL_SUPPORT, ContactId = contact.Id);
        insert aCase1;

        Case aCase2 = new Case(Subject = 'Case 1.3', SuppliedEmail = 'case1@email.com', Origin = 'Email', 
            RecordTypeId = CaseConstants.RECORD_TYPE.EMAIL_SUPPORT, ContactId = contact.Id);
        insert aCase2;
        Test.stopTest();

        Map<Id,Case> allCases = new Map<Id,Case>([SELECT Id, CreatedDate, Don_t_Send_Auto_Response__c FROM Case]);
        System.assertEquals(false, allCases.get(aCase1.Id).Don_t_Send_Auto_Response__c);
        System.assertEquals(false, allCases.get(aCase2.Id).Don_t_Send_Auto_Response__c);
    }
}