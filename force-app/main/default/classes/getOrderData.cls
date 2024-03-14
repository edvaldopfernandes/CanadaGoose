public class getOrderData {
		@AuraEnabled(cacheable = true) public static List<Order> getOrderDetails(String recordId) {
        	return [SELECT Id, First_Name__c, Last_Name__c, Phone_Number__c, Email__c, Order_Id__c, 
                    	Order_Created_By__c, Sales_Company__c, Order_No__c, Address_1__c , Address_2__c,
                    	City__c, Country_Code__c, State_Code__c, Postal_Code__c, Status, CreatedDate,
                    	Order_Total__c, TotalAmount, Payment_Status__c, StatusCode, OOBO_Order__c, 
                    	CSR_Email__c FROM Order 
                    WHERE AccountId = :recordId];
    	}

    	//Order_Line_Item__c
   		@AuraEnabled(cacheable = true)
    	public static List<Order_Line_Item__c> getOrderLineItemDetails(String recordId) {
            return [SELECT Id, Base_Price__c, Color_Name__c, CreatedDate, ext_order_id__c,
                    	Item_Id__c, Name, Order__c, Order_No__c, Price__c, Product_Id__c, 
                    	Product_Name__c, Quantity__c, Size__c, Tax__c 
                    FROM Order_Line_Item__c WHERE Order__r.Id = :recordId];
    	}
}