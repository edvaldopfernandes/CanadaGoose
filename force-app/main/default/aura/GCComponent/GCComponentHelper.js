({
	
    UpdateFields : function(component) {
		 //Set Currency on the basis of Case Region & Language on the basis of account language
        console.log('case' + component.get("v.CaseId"));
        var cid = component.get("v.CaseId");
        var action = component.get("c.SetFields");
        action.setParams({ "cid" : cid });
        action.setCallback(this, function(response) {
            console.log('success');
            this.GetAmount(component);
        });
        $A.enqueueAction(action);
	},
    
    GetAmount : function(component) {
		 //Set Currency on the basis of Case Region
        console.log('case' + component.get("v.CaseId"));
        var cid = component.get("v.CaseId");
        var action = component.get("c.GetRefund");
        action.setParams({ "cid" : cid });
        action.setCallback(this, function(response) {
            console.log('success');
            component.set("v.arr", response.getReturnValue());
            var arr = component.get("v.arr");
            
            component.set("v.curr", arr[1]);
            if(component.get("v.curr") == 'CAD' || component.get("v.curr") == 'USD') {
                component.set("v.sign",'$ ');
                component.set("v.isNorthAmerica",true)
            }
            else {
                component.set("v.sign",'€ ');
            }
            var sign = component.get("v.sign");
            component.set("v.gca", arr[1] + sign + arr[0]);
            component.set("v.gct", arr[1] + sign + arr[3]);
            component.set("v.gcamt", arr[1] + sign + arr[4]);
            component.set("v.lang", arr[2]);
            console.log(component.get("v.gca"));
            console.log(component.get("v.curr"));
            console.log(component.get("v.lang"));
            console.log(component.get("v.sign"));
        });
        $A.enqueueAction(action);
	},
    
})