({
    // Load expenses from Salesforce
    doInit: function(component) {
        // Determine user's language to render language specific values
        component.set("v.UserLanguage", $A.get("$Locale.language"));

        //if payment is pending request the inspection results
        //and if the status of case is past inspection
        var action = component.get("c.getTaxedInspectionResults"); 
        action.setParams({
            "caseId":component.get("v.recordId")
        }); 
 
        // Add callback behavior for when response is received      
        action.setCallback(this, function(response) {
            // Call back is Received 
            var state = response.getState();
            if (state === "SUCCESS") {
                var taxedInspectionResults = response.getReturnValue();
console.log(taxedInspectionResults);
                if(taxedInspectionResults.PaymentMethod !== "None")
                {
                    component.set("v.ShowPrices",true);
                }
				
                if (taxedInspectionResults != null ) {
                    var inspectionResults = taxedInspectionResults.InspectionResults;
                    var paidInspectionResults = taxedInspectionResults.PaidInspectionResults;

              
                    component.set("v.paidInspectionResults", paidInspectionResults);
                    console.log(paidInspectionResults);

                    if(paidInspectionResults.length != 0)
                    {
                        component.set("v.ShowPaidInspectionResults","True");
                        component.set("v.CurrencyCode", paidInspectionResults[0].Currency__c);

                        component.set("v.SubtotalInvoiced", taxedInspectionResults.InvoicedSubtotal);
                        component.set("v.TaxInvoiced", taxedInspectionResults.InvoicedTax);
                        component.set("v.TotalInvoiced", taxedInspectionResults.InvoicedTotal);

                        component.set("v.ShowSubtotalInvoiced", true);
                        
                    }
                    if (inspectionResults != null && inspectionResults.length > 0) {
                        component.set("v.InspectionResults", inspectionResults);
                        component.set("v.SubtotalResult", taxedInspectionResults.Subtotal);
                        component.set("v.TaxResult", taxedInspectionResults.Tax);
                        component.set("v.TotalResult", taxedInspectionResults.Total);
                        component.set("v.CurrencyCode", inspectionResults[0].Currency__c)
                        component.set("v.CaseStatus", inspectionResults[0].Case__r.Status)
                        component.set("v.CasePaymentPending", inspectionResults[0].Case__r.Payment_Pending__c)
                        
                        if(taxedInspectionResults.Tax != null)
                            component.set("v.ShowSubtotalResults", true);
                        
                        var Status = component.get("v.CaseStatus");
                        
                        if(component.get("v.CasePaymentPending") !=0
                           && Status != null
                           && Status != "New/Validate"
                           && Status != "New_Validate"
                           && Status != "Waiting On Product"
                           && Status != "Cleaning"
                           && Status != "Inspecting"
                           && Status != "Pending Customer Feedback"
                          )
                        {
                            component.set("v.ShowInspectionResults","True");  
                        }
                    }
                }
            }
            else {
                console.log("Failed retrieving InspectionResults with state: " + state);
            }
        });
        // Send action off to be executed
        $A.enqueueAction(action);
    }
})