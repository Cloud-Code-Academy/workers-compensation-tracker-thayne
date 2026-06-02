public with sharing class ClaimHandler extends TriggerHandler {


    //
    public override void beforeInsert() {
        
        ClaimHelper.claimDurationTracking(Trigger.new, null);
    }


    public override void beforeUpdate() {
        ClaimHelper.updatedClaimsDurationTracking(Trigger.old, Trigger.new);
    }


}
