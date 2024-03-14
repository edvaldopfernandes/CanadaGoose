({
    // Load inspections from salesforce
    doInit: function(component) {
        //if payment is pending request the inspection results
        //and if the status of case is past inspection
        var action = component.get("c.getPaidInspectionResults");

        action.setParams({
            "caseId":component.get("v.caseId")
        }); 
        // Add callback behavior for when response is received      
        action.setCallback(this, function(response) {
            // Call back is Received 
            var state = response.getState();
            
            var Insps = response.getReturnValue() ;
            component.set("v.paidInspectionResults", Insps);
            
            if (Insps != null && Insps.length > 0) {
                component.set("v.caseNumber", Insps[0].Case__r.CaseNumber);
            }
        });
        
        // Send action off to be executed
        $A.enqueueAction(action);
    }
})