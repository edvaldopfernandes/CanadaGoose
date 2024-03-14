/**
* 	@description Created as a part of the Zendesk Migration to Salesforce project.
*	trac_EmailToCaseLoopPrevent
*	@description Prevent Email To Case Loop
*	@author Kofi Johnson, Traction on Demand
*/
public class trac_EmailToCaseLoopPrevent {
	private final static Integer HOURS_IN_DAY = 24;
	private final static Integer MINUTES_IN_HOUR = 60;
	private final static Integer DEFAULT_TIME_INTERVAL = HOURS_IN_DAY * MINUTES_IN_HOUR;
	
	public static void checkEmailToCaseLoop(List<Case> newCases) {
 
		Integer interval = DEFAULT_TIME_INTERVAL; 

		Email_To_Case_Loop_Prevent__c loopPreventCustomSetting = Email_To_Case_Loop_Prevent__c.getOrgDefaults();
		if(loopPreventCustomSetting != null && loopPreventCustomSetting.Interval__c != null) {
		   interval = Integer.valueOf(loopPreventCustomSetting.Interval__c);
		}

		Map<String, Case> emailToCases = new Map<String, Case>();

		for(Case aCase :newCases) {
		    if (String.isNotBlank(aCase.SuppliedEmail)
				&& aCase.Origin != null && !aCase.Origin.containsIgnoreCase('Web')
				&& aCase.RecordTypeId == CaseConstants.RECORD_TYPE.EMAIL_SUPPORT) {
		    	emailToCases.put(aCase.SuppliedEmail, aCase);
		    }
		}
		
		if(!emailToCases.isEmpty()){
			preventLoopCases(emailToCases, interval);
		}
    }

    private static void preventLoopCases(Map<String,Case> emailToCases, Integer interval) {
		List<Case> originalCases = [SELECT SuppliedEmail FROM Case WHERE CreatedDate <= :Datetime.now() AND CreatedDate >= :Datetime.now().addMinutes(-interval) AND SuppliedEmail IN :emailToCases.keySet() AND Don_t_Send_Auto_Response__c != true];
		for(Case aCase :originalCases) {
		    Case aNewCase = emailToCases.get(aCase.SuppliedEmail);
		    if(aNewCase != null) {
                aNewCase.Don_t_Send_Auto_Response__c = true;
		    }
		}
    }
}