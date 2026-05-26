trigger ClaimTrigger on Claim__c (before insert, after insert, before update, after update, before delete, after delete, after undelete) {

	// Create an instance of the handler class to manage the logic
    ClaimHelper claimHelper = new ClaimHelper();
    claimHelper.run();
	
}