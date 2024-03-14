@isTest
private class MilestoneUtilsTest {
    private static final String CONTACT_LAST_NAME = 'uUQ42StQPFfjhVvra4';
    static testMethod void TestCompleteMilestoneCase(){
        
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
        Entitlement entl = new Entitlement(Name='First Response', AccountId=acc.Id, StartDate=Date.valueof(System.now().addDays(-2)), EndDate=Date.valueof(System.now().addYears(2)) );
        insert entl;
        
        List<SlaProcess> lstEntitlementProcess = [SELECT Id, Name FROM SlaProcess WHERE Name='Standard Case'  LIMIT 1];
        System.debug('lstEntitlementProcess= '+lstEntitlementProcess);
        entl.SlaProcessId = lstEntitlementProcess[0].id;
        update entl;
                                
        List<Case> cases = new List<Case>{};            
        Case c = TestDataFactory.createTestCase(acc.Id , con.Id, false);
        c.EntitlementId = entl.Id;        
        cases.add(c);        
        insert cases;                                        
        
        List<Id> caseIds = new List<Id>();
        for (Case cL : cases){
            caseIds.add(cL.Id);
        }
        
        test.startTest();
        	milestoneUtils.completeMilestone(caseIds, System.now());
        test.stopTest();        
    }    
}