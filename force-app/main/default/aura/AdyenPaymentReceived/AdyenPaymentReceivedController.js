({
    "SubmitPayment" : function(cmp) {
        // create a one-time use instance of the serverEcho action
        // in the server-side controller
        
        console.log("In client Get params");
        var searchString = window.location.search;
        console.log("searchString");
        console.log(searchString);
        var paramsString = searchString.replace('?','');
        console.log("paramsString");
        console.log(paramsString);
        var params = paramsString.split("&");
        console.log("params");
        console.log(params);
        var paramObject = {};
        console.log("In client Get params:getting params in an object");
        for (var i=0;i<params.length;i++) {
            var val = params[i].split("=");
            console.log(val[0]);
            paramObject[val[0]]=decodeURIComponent(val[1]);
        }
        console.log(JSON.stringify(paramObject));
        cmp.set("v.parameters",paramObject);
        
        console.log("setting parameters");
        
        console.log("calling server for echo");
        var action = cmp.get("c.getHPPReceivedPaymentVerification");
        
        var ParamString = window.location.href
        
        action.setParams({ URL : JSON.stringify(cmp.get("v.parameters")) });
        
        // Create a callback that is executed after 
        // the server-side action returns
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                // Alert the user with the value returned 
                // from the server
                var parsed = JSON.parse(response.getReturnValue());
                console.log("From server: " + response.getReturnValue());
                cmp.set("v.PaymentMessage", parsed.PaymentConfirmationStatus);
                cmp.set("v.caseNumber",parsed.caseNumber);
                
                // You would typically fire a event here to trigger 
                // client-side notification that the server-side 
                // action is complete
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                        errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
        });
        
        // optionally set storable, abortable, background flag here
        
        // A client-side action could cause multiple events, 
        // which could trigger other events and 
        // other server-side action calls.
        // $A.enqueueAction adds the server-side action to the queue.
        $A.enqueueAction(action);
    },
    "getParameters":  function (cmp) {
        console.log("In client Get params");
        var searchString = window.location.search;
        console.log("searchString");
        console.log(searchString);
        var paramsString = searchString.replace('?','');
        console.log("paramsString");
        console.log(paramsString);
        var params = paramsString.split("&");
        console.log("params");
        console.log(params);
        var paramObject = {};
        console.log("In client Get params:getting params in an object");
        for (var i=0;i<params.length;i++) {
            var val = params[i].split("=");
            console.log(val[0]);
            paramObject[val[0]]=val[1];
        }
        console.log(JSON.stringify(paramObject));
        cmp.set("v.parameters",paramObject);
    }
 
 })