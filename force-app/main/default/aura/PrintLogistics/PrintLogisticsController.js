({
    // Load expenses from Salesforce
    doInit: function(component) {
        //if payment is pending request the inspection results
        //and if the status of case is past inspection
        var action = component.get("c.getLogisticsPrint");

        action.setParams({
            "caseId":component.get("v.caseId")
        }); 

        // Add callback behavior for when response is received      
        action.setCallback(this, function(response) {
            // Call back is Received 
            var state = response.getState();
			var today = new Date();
    		var monthDigit = today.getMonth() + 1;
    			if (monthDigit <= 9) {
        			monthDigit = '0' + monthDigit;
    			}
   
            if (state === "SUCCESS") {
                var LogisticsCase = response.getReturnValue().cse;
                var LogisticsCountrySetting = response.getReturnValue().CounSet;
				console.log('>>LogisticsCase>>',JSON.stringify(LogisticsCase));
                component.set("v.Name", LogisticsCase.CaseNumber);
                component.set("v.Style",LogisticsCase.Style__r.Name +' '+ (LogisticsCase.StyleNumber__c != null ? '('+LogisticsCase.StyleNumber__c+')' : ''));
                component.set("v.Size", LogisticsCase.Size__c);
                component.set("v.ColourName", LogisticsCase.Colour_Name__r.Name);
                component.set("v.MIDCode", LogisticsCase.MID_code__r.Name);
                component.set("v.CutNumber", LogisticsCase.Cut_Number__c);
                component.set("v.YearofManufacture", LogisticsCase.Manufacture_Year__c);
                component.set("v.GenerationCheckbox", LogisticsCase.Generation_Re_commerce__c);
                component.set("v.Country", LogisticsCountrySetting.ShippingIndicator);
                component.set("v.Missing", LogisticsCase.Items_Missing_On_Arrival__c);
                component.set('v.printDate', today.getFullYear() + "-" + monthDigit + "-" + today.getDate());
            }
            else {
                console.log("Failed retrieving InspectionResults" + state);
            }
        });

        // Send action off to be executed
        $A.enqueueAction(action);
    }
})