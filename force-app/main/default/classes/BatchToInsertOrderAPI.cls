/**
* ============================================
* Name: BatchToInsertOrderAPI
* Description: Batch to pull the BatchToInsertOrderAPI
 
* Author :- Venkat Kalyan
* Date   :- 26-02-2023
* Test Class :- BatchToInsertOrderAPITest 
* =======================================================
* */

public class BatchToInsertOrderAPI implements Database.Batchable<Sobject>, Database.AllowsCallouts,
											  Database.RaisesPlatformEvents, Database.stateful {
  
   public string recordId;
   OD_GetOrderByEmail order;
   public BatchToInsertOrderAPI(id recordId){
       if(recordId != null){ this.recordId = recordId; } 
    }
   public Database.querylocator start (Database.BatchableContext BC){
      return Database.getQueryLocator([SELECT Id, PersonEmail FROM Account  WHERE id= :this.recordId LIMIT 1]);
   }
    
   public void execute(Database.BatchableContext BC, List<account> listOfAccount){
       for(account acc : listOfAccount ) {
            OD_GetOrderByEmail order;     
            order = performHttpRequest(acc.PersonEmail);
            populateData(order, acc);
       }
   }
    
    
    public void finish(Database.BatchableContext BC){}
    public static OD_GetOrderByEmail performHttpRequest(string email){
        OD_GetOrderByEmail order = new OD_GetOrderByEmail();
        if(email != null){
           
            Http h = new Http();
            HttpRequest req = new HttpRequest();
            req.setEndpoint('callout:AzureCredsForOrderAPI/api/v2/orders/GetCustomerAndOrderByEmailId/'+ email);
            req.setHeader('Content-Type', 'application/json');
            req.setTimeout(120000);
            req.setMethod('GET');
            HttpResponse response = h.send(req);
            if(response.getStatusCode() == 200){
                System.debug('response>>>>'+response);
                String body = response.getBody();
                Map<String,Object> data = (Map<String,Object>)JSON.deserializeUntyped(body);
                order = OD_GetOrderByEmail.parse(body);
                System.debug('>>>Order'+ order);
            } }
        return order;
    }
     
   public static void updateCountOfOrders(string csrId){
    
       list<order> listOfOrders = new List<order>();
       listOfOrders =[SELECT id FROM Order WHERE CSRCreatedTheOrder__c =:csrId];
       if(listOfOrders != null && listOfOrders.size() > 0){
           User usr = new User(Id = csrID, Count_Of_Orders_Created_By_CSR__c = listOfOrders.size());
           update usr;
       }
   }
   
    public static void populateData( OD_GetOrderByEmail order, account acc) {
        System.debug('>>>order'+order);
        User csrUser = new User();
        if(order != null){
            List<order> listOfSfOrder = new List<order>();
            set<String> setOfOrders = new set<String>();
            Map<String,Id> MapOfOrderIdSFid = new Map<String, Id>();
            list<OrderInvoice__c> listOfFinalInvoice = new list<OrderInvoice__c>();
            list<Order_Line_Item__c> listOfFinalItems = new list<Order_Line_Item__c>();
            
            List<OrderInvoice__c> listOfInvoices = new List<OrderInvoice__c>();
            List<Order_Line_Item__c> listOfOrderLineItems = new List<Order_Line_Item__c>();
            set<string> setOfStyleCode = new set<string>();
            //Added to check the CSR who placed the order-- start//
            set<string> setOfEmails = new set<string>();
            if(order.Customer_orders != null){
                for(OD_GetOrderByEmail.Customer_orders CusOrder : order.Customer_orders){ if(CusOrder.created_by != null){ setOfEmails.add(CusOrder.created_by); }
                }
            }
            
            if(setOfEmails != null && setOfEmails.size() >0){
                for(user usr : [SELECT id FROM User WHERE Email =:setOfEmails LIMIT 1]){ csrUser = usr; }
            }
            
            if(order.Customer_orders != null){
                for(OD_GetOrderByEmail.Customer_orders CusOrder : order.Customer_orders){
                    order sfOrder = new Order();
                    string emailtext = CusOrder.created_by;
                    if(emailtext.contains('@')){ sfOrder.CSR_Email__c = CusOrder.created_by; }
                    else{ sfOrder.Order_Created_By__c =CusOrder.created_by; }
                    sfOrder.AccountId = acc.id;
                    if( csrUser.Id != NULL){
                        sfOrder.CSRCreatedTheOrder__c = csrUser.id;
                        sfOrder.OOBO_Order__c = true;
                        sfOrder.Order_Created_By__c = 'OOBO';
                    }
                    else{ sfOrder.Order_Created_By__c = 'Customer'; }
                   //Added to check the CSR who placed the order--- end// 
                    sfOrder.EffectiveDate = Date.today();
                    sfOrder.Status = 'Draft';  
                    sfOrder.customer_master_id__c = String.ValueOf(order.customer_master.customer_master_id);
                    sfOrder.customer_name__c = order.customer_master.customer_name;
                    sfOrder.First_Name__c = order.customer_master.customer_first_name;
                    sfOrder.Last_Name__c = order.customer_master.customer_last_name;
                    sfOrder.Email__c =   order.customer_master.email;
                    sfOrder.Phone_Number__c = order.customer_master.phone_no;
                    sfOrder.customer_locale_id__c = order.customer_master.customer_locale_id;
                    sfOrder.Order_Id__c = String.ValueOf(CusOrder.order_id);
                    sfOrder.Order_No__c =   CusOrder.order_no;
                    sfOrder.Payment_Status__c = CusOrder.payment_status;
                    sfOrder.Order_Total__c =   CusOrder.order_total;
                    sfOrder.Sales_Company__c = CusOrder.sales_company;
                    sfOrder.Address_1__c = CusOrder.address.address1;
                    sfOrder.Address_2__c = CusOrder.address.address2;
                    sfOrder.City__c = CusOrder.address.city;
                    sfOrder.State_Code__c = CusOrder.address.state_code;
                    sfOrder.Country_Code__c = CusOrder.address.country_code;
                    sfOrder.Postal_Code__c = CusOrder.address.postal_code;
                    //sfOrder.Parent_Order_Number__c = orderline.parent_order_id;
                    System.debug('>>>>>CusOrder.customer_order_lines>>'+ CusOrder.customer_order_lines);
                    
                   for(OD_GetOrderByEmail.Customer_order_lines orderline : CusOrder.customer_order_lines){
                       
                       System.debug('Inside CusOrder.customer_order_lines loop >>'+ orderline);
                       Order_Line_Item__c item = new Order_Line_Item__c();
                       item.Name = String.ValueOf(orderline.order_line_id);
                       item.Base_Price__c = orderline.base_price;
                       item.Color_Name__c = orderline.color_name;
                       item.ext_order_id__c = String.ValueOf(orderline.order_id);
                       item.Item_Id__c = String.ValueOf(orderline.order_line_id)+ orderline.item_id + String.ValueOf(orderline.order_id);
                       item.Item_Id2__c = orderline.item_id;
                       item.Order_No__c = orderline.order_no;
                       item.Price__c = orderline.price;
                       item.Price_After_Order_Discount__c = orderline.price_after_order_discount;
                       item.Product_Name__c = orderline.product_name;
                       item.Product_Id__c = String.ValueOf(orderline.product_id);
                       item.Quantity__c = String.ValueOf(orderline.quantity);
                       item.Size__c = orderline.size;
                       item.Tax__c = orderline.tax;
					   sfOrder.Parent_Order_Number__c = orderline.parent_order_id;//added to get parent order ID for return Orders
                       item.Parent_Order_Number__c = orderline.parent_order_id;//added to get parent order ID for return Orde
                       setOfStyleCode.add(item.Item_Id2__c);
                       listOfOrderLineItems.add(item);
                   }
                   System.debug('>>>>>listOfOrderLineItems>>'+listOfOrderLineItems);
                   System.debug('>>>>>CusOrder.invoice>>'+CusOrder.invoice);
                   for(OD_GetOrderByEmail.Invoice inv : CusOrder.invoice){
                       System.debug('>>>>>Inside CusOrder.invoice>>'+inv);
                       OrderInvoice__c sfinvoice = new OrderInvoice__c();
                       sfinvoice.Invoice_Id__c = inv.invoice_id;
                       sfinvoice.Ext_Order_Id__c = String.ValueOf(CusOrder.order_id);
                       sfinvoice.Invoice_Status__c = inv.invoice_status;
                       sfinvoice.Invoice_Total__c =  inv.invoice_total;
                       listOfInvoices.add(sfinvoice);
                   }
                   listOfSfOrder.add(sfOrder);
                   setOfOrders.add(sfOrder.Order_Id__c);
               }
           } 
			Schema.SObjectField field = Schema.Order.Fields.Order_Id__c;
            System.debug('>>>>>listOfSfOrder upsert>>'+listOfSfOrder);
           if(listOfSfOrder != null && listOfSfOrder.size() > 0){
            Database.UpsertResult [] cr = Database.Upsert(listOfSfOrder,field, false); 
               System.debug('>>>>>>>results'+cr);
           }
           for(Order od :[SELECT Id,Order_Id__c FROM order WHERE Order_Id__c IN :setOfOrders]){
               if(!MapOfOrderIdSFid.containsKey(od.Order_Id__c)){
                   MapOfOrderIdSFid.put(od.Order_Id__c, od.id);
               }
           }
            Map <String, Style__c> mapofStyles = new map <String, Style__c>();
             System.debug('<<<setOfStyleCode>>>>>'+setOfStyleCode);
           for(Style__c  style : [SELECT id, Name, Style_Photo__c, Parent_Style__c  FROM Style__c WHERE Name IN : setOfStyleCode]) {
               if(!mapofStyles.containsKey(style.Name)){
                   mapofStyles.put(style.Name ,style);
               }  
           }
           System.debug('>>>>>listOfInvoices>>'+listOfInvoices); 
		  for(OrderInvoice__c odInv : listOfInvoices){
              if(MapOfOrderIdSFid.containsKey(odInv.ext_order_id__c) &&
                 MapOfOrderIdSFid.get(odInv.ext_order_id__c) != null){
                     System.debug('>>>>>odInv>>'+odInv); 
                     odInv.Order_Id__c = MapOfOrderIdSFid.get(odInv.ext_order_id__c);
                     listOfFinalInvoice.add(odInv);
                 }
          }
          Schema.SObjectField fieldInvoice = Schema.OrderInvoice__c.Fields.Invoice_Id__c  ;
          System.debug('>>>>>listOfFinalInvoice>>'+listOfFinalInvoice);  
          if(listOfFinalInvoice != Null && listOfFinalInvoice.size() > 0){
              Database.Upsert(listOfFinalInvoice, fieldInvoice, false);   
          }
          System.debug('>>>>>listOfOrderLineItems>>'+listOfOrderLineItems); 
          for (Order_Line_Item__c item : listOfOrderLineItems) {
              System.debug('<<<mapofStyles>>>>>'+mapofStyles);
               if(mapofStyles.containsKey(item.Item_Id2__c) &&
                   mapofStyles.get(item.Item_Id2__c) != null){
                       System.debug('<<<style>>>>>'+mapofStyles.get(item.Item_Id2__c));
                       Style__c style = new Style__c ();
                       style = mapofStyles.get(item.Item_Id2__c);
                       item.Style__c  = style.id;
                       item.Style_Image__c = style.Style_Photo__c;
               }
              if(MapOfOrderIdSFid.containsKey(item.ext_order_id__c) &&
                   MapOfOrderIdSFid.get(item.ext_order_id__c) != null){
                        System.debug('>>>>>item>>'+item); 
                       item.Order__c =  MapOfOrderIdSFid.get(item.ext_order_id__c);
                       listOfFinalItems.add(item);
               }
          }
          Schema.SObjectField fieldItem = Schema.Order_Line_Item__c.Fields.Item_Id__c ;
          System.debug('>>>>>listOfFinalItems>>'+listOfFinalItems); 
          if(listOfFinalItems != null && listOfFinalItems.size() >0){
              Database.upsert(listOfFinalItems, fieldItem, false);
          }
          //Added to check the CSR who placed the order--- Update count of order on CSR level// 
          if(csrUser.id != null){
            	updateCountOfOrders(csrUser.id);
          }
       }
   }
}