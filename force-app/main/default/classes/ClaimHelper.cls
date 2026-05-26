public with sharing class ClaimHelper extends TriggerHandler{
    
    public override void beforeInsert() {
        ClaimTriggerHandler.validateIncidentDate(Trigger.new);
        
    }
    public override void afterInsert() {
        
    }
    public override void beforeUpdate() {
        ClaimTriggerHandler.validateIncidentDate(Trigger.new);
    }    



	public static void validateIncidentDate(List<Claim__c> claims) {
        for (Claim__c claim : claims) {

            if (claim.Incident_Date__c != null && claim.Incident_Date__c > Date.today()) {
                claim.Incident_Date__c.addError('Incident Date cannot be in the future.');
            }

        }
    }
}