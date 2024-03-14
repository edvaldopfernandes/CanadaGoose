global class BulkCustomerImportClearScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        Database.executeBatch(new BulkCustomerImportClear());
    }
}