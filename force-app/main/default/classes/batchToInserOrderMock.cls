public class batchToInserOrderMock implements HttpCalloutMock {

    public HttpResponse respond(HttpRequest req) {
        string body ='{ "segment_id": 513,  "customer_id": "003DR00000nUg8zYAC", "customer_master": {'
        				+ '"customer_master_id": 1200056, "customer_name": "Sh Yz", "customer_first_name": "Sh", '
        				+ '"customer_last_name": "Yz", "email": "testsharif2@abc.com", "phone_no": "6478888889", '
        				+ '"customer_locale_id": "en_CA" }, "customer_orders": [{ "order_id": 1531174, "order_no": "DVCA_A00178451", '
        				+ '"payment_status": "Paid", "order_total": 1581.25,"sales_company": "CG_Canada", '
        				+ '"address": { "address1": "R-121 Ilsley Ave", "address2": "", "city": "Dartmouth", "state_code": "NS", "country_code": "CA", "postal_code": "B3B 1S4" '
        				+ '}, "customer_order_lines": [{ "order_line_id": 1, "order_id": 1531174, "order_no": "DVCA_A00178451", "product_id": 801688939992, '
            			+ ' "product_name": "Chilliwack Bomber Heritage", "quantity": 1.0,"size": "S","color_name": "Stormy Sky",  '
            			+ '"base_price": 1375.00, "item_id": "7999L", "item_text": "Chilliwack Bomber", "price": 1375.00, "price_after_order_discount": 1375.00,'
            			+ '"tax": 206.25, "tax_basis": 0.0, "tax_class_id": "TPP", "tax_rate": 0.00, "parent_order_id": "" }], '
						+ '"invoice": [{ "invoice_id": "16637758033161498032", "invoice_status": "Closed", "invoice_total": 2912.95,"order_line_id": 1}],'
						+ '"created_by": "Customer"  }] }';
		HttpResponse resCustomerAuth = new HttpResponse();
        resCustomerAuth.setHeader('Content-Type', 'application/json');
        resCustomerAuth.setHeader('authorization', B2CConstant.AUTHTEST_AUTHTOKEN);
        resCustomerAuth.setBody(body);
        resCustomerAuth.setStatus('OK');
        resCustomerAuth.setStatusCode(200);
        return resCustomerAuth;
    }
}