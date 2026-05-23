trigger ClaimTrigger on Claim__c (before insert, before update) {
	ClaimTriggerHandler.validateIncidentDate(Trigger.new);
}