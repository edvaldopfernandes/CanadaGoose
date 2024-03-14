public class OrderTriggerHandler {
  
    public static void OnAfterUpdate(List<Order> lstNewOrder, Map<Id, Order> mapOldOrder) {
       getAccountLinkedToOrders(lstNewOrder, mapOldOrder , true); // calling the funationality to update the OrderCount on Account
    }
    public static void OnAfterInsert(List<Order> lstNewOrder) {
       getAccountLinkedToOrders(lstNewOrder, null , false); // calling the funationality to update the OrderCount on Account
    }
    
    /***  method to get the linked accounts from the inserted or updated Order  */
    public static void getAccountLinkedToOrders(List<Order> lstNewOrder, Map<Id, Order> mapOldOrder , boolean isUpdate){
        order oldOrder = new order();
        set<Id> setOfAccountIds = new set<id>();
        
         for(order orderVar : lstNewOrder){
             if(mapOldOrder!= Null && mapOldOrder.size() >0 ){
                 oldOrder = mapOldOrder.get(orderVar.Id);
             }
             if(!isUpdate && orderVar.AccountId != NULL || (isUpdate && oldOrder != null && oldOrder.AccountId != orderVar.AccountId) ){
                 setOfAccountIds.add(oldOrder.AccountId);
                 setOfAccountIds.add(orderVar.AccountId);
             } 
         }
        if(setOfAccountIds != null && setOfAccountIds.size() >0 ){
            UpdateCountOfOrderOnAccount(setOfAccountIds);
        }
         
    }
   
    /*** future method to update the count of cases linked to account  */
    //@Future 
	public static void UpdateCountOfOrderOnAccount(set<Id> setOfAccountIds) {
        List<Account> listOfAccounts = new List<Account>();	
        for(Account accVar : [SELECT id, Number_Of_Orders__c,Total_Order_Total_for_Account__c, (SELECT Id, Order_Total__c FROM Orders) 
                              							FROM Account WHERE Id IN:setOfAccountIds]){
             
             accVar.Number_Of_Orders__c = accVar.orders.size();
             accVar.Total_Order_Total_for_Account__c = 0;
             listOfAccounts.add(accVar);
             for(order OrderVar : accVar.Orders ){
                 OrderVar.Order_Total__c =  OrderVar.Order_Total__c == null ? 0 : OrderVar.Order_Total__c;
                 accVar.Total_Order_Total_for_Account__c =  accVar.Total_Order_Total_for_Account__c + OrderVar.Order_Total__c;
             }
        }
         if(listOfAccounts != null && listOfAccounts.size() >0){
             Database.update(listOfAccounts, false);
         }
     }
}