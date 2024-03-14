({
    doInit : function(component, event, helper) {
        var action = component.get("c.getContactCurrencyCode");

        // Dynamically loaded labels - DO NOT DELETE COMMENTED CODE
        // $Label.c.Warranty_Cleaning_Price_CAD
        // $Label.c.Warranty_Cleaning_Price_USD
        // $Label.c.Warranty_Cleaning_Price_GBP
        // $Label.c.Warranty_Cleaning_Price_EUR
        // $Label.c.Warranty_Cleaning_Price_SEK
        // $Label.c.Warranty_Cleaning_Price_CNY

        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.CustomMessage", $A.get("$Label.c.Warranty_Cleaning_Price_" + response.getReturnValue()));
            }
        });
        $A.enqueueAction(action);
    }
})