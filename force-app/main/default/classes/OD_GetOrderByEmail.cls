/**
* ============================================
* Name: OD_GetOrderByEmail
* Description: Code to parse and save order data
 
* Author :- Venkat Kalyan
* Date   :- 26-02-2023
* Test Class :- 
* =======================================================
* */
public class OD_GetOrderByEmail {

	public Integer segment_id;
	public String customer_id;
	public Customer_master customer_master;
	public List<Customer_orders> customer_orders;

	public class Invoice {
		public String invoice_id;
		public String invoice_status;
		public Double invoice_total;
		public Integer order_line_id;
	}

	public class Address {
		public String address1;
		public String address2;
		public String city;
		public String state_code;
		public String country_code;
		public String postal_code;
	}

	public class Customer_master {
		public Integer customer_master_id;
		public String customer_name;
		public String customer_first_name;
		public String customer_last_name;
		public String email;
		public String phone_no;
		public String customer_locale_id;
	}

	public class Customer_orders {
		public Integer order_id;
		public String order_no;
		public String payment_status;
		public Double order_total;
		public String sales_company;
		public Address address;
		public List<Customer_order_lines> customer_order_lines;
		public List<Invoice> invoice;
        public string created_by;
	}

	public class Customer_order_lines {
		public Integer order_line_id;
		public Integer order_id;
		public String order_no;
		public Long product_id;
		public String product_name;
		public Double quantity;
		public String size;
		public String color_name;
		public Double base_price;
		public String item_id;
		public String item_text;
		public Double price;
		public Double price_after_order_discount;
		public Double tax;
		public Double tax_basis;
		public String tax_class_id;
		public Double tax_rate;
		public String parent_order_id;
	}

	
	public static OD_GetOrderByEmail parse(String json) {
		return (OD_GetOrderByEmail) System.JSON.deserialize(json, OD_GetOrderByEmail.class);
	}
}