({
    handleAcceptCharges : function (component, event, helper) {
        // First disable the button
        event.getSource().set("v.disabled", true);
        
        // Build action for accepting charges
        var action = component.get("c.acceptCharges");
        action.setParams({
            "caseId" : component.get("v.recordId")
        });
        
        // Add callback behavior for when response is received
        action.setCallback(this, function(response) {
            // Call back is Received 
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                
                if (result == '') {
                    component.set("v.uiMessage", $A.get("$Label.c.Warranty_AcceptCharges_Message_SuccessDescription"));
                    component.set("v.uiMessageTitle", $A.get("$Label.c.Warranty_AcceptCharges_Message_SuccessHeader"));
                    component.set("v.severity", "confirm");
                }
                else {
                    component.set("v.uiMessage", result);
                    component.set("v.uiMessageTitle", $A.get("$Label.c.Warranty_AcceptCharges_Message_ErrorHeader"));
                    component.set("v.severity", "error");
                }
            }
            else {
                console.log("Failed with state: " + state);
                component.set("v.uiMessage", $A.get("$Label.c.Warranty_AcceptCharges_Message_ErrorServer"));
                component.set("v.uiMessageTitle", $A.get("$Label.c.Warranty_AcceptCharges_Message_ErrorHeader"));
                component.set("v.severity", "error");
            }
        });
        
        // Send action off to be executed
        $A.enqueueAction(action);
    }
})