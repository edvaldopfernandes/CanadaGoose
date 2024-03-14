global class CustomerImportScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        Database.executeBatch(new BulkCustomerImporter(), 1);
    }
}