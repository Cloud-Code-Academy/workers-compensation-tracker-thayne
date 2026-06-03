
// * Description:  Called from EmployeeClaimTrigger | Extends TriggerHandler class | 
// * Author: Thayne Rodrigo
// * Date: 12/05/2026



public with sharing class EmployeeClaimHandler extends TriggerHandler {

    //Only passing new list for updated values to calculate totals.
    public override void afterInsert() {
    EmployeeClaimHelper.EmployeeRiskFlagging(Trigger.new);
    }

    //Only passing new list for updated values to calculate totals.
    // TR - Do I want to add an extra check in helper to compare old and new totals?... Seems very extra, as there's no harm in running this at any scenario?
    public override void afterUpdate() {
    EmployeeClaimHelper.EmployeeRiskFlagging(Trigger.new);
    }

    //Passing in old list (of deleted records) 
    // Requires a query of database to get 'current' employee claims (that does not include the deleted records after delete.)
    public override void afterDelete() {
    EmployeeClaimHelper.EmployeeRiskFlaggingAfterDelete(Trigger.old);
    }

    // Passing in new values of restored employeeclaim records. 
    public override void afterUndelete() {
    EmployeeClaimHelper.EmployeeRiskFlagging(Trigger.new);
    }

    
}