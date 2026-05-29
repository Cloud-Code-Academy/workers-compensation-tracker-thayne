public with sharing class ClaimHelper extends TriggerHandler{
    //instantiate private variable references to trigger records
    private List<Claim__c> newRecords;
    private Map<Id, Claim__c> oldRecordsMap;

    public ClaimHelper(){
        //introduce private variabes to the constructor
        this.newRecords = (List<Claim__c>) Trigger.new;
        this.oldRecordsMap = (Trigger.oldMap != null) ? (Map<Id,Claim__c>) Trigger.oldMap : null;
    }
    
    public override void beforeInsert() {
        this.executeBeforeLogic();
        
    }
    public override void beforeUpdate() {
        this.executeBeforeLogic();
    }    

    private void executeBeforeLogic(){
        for (Claim__c claim : newRecords){
            //SCRUM-7: Intake Validation moved into framework
            if(claim.Incident_Date__c != null && claim.Incident_Date__c > Date.today()){
                claim.Incident_Date__c.addError('Incident Date cannot be in the future.');
            }
            //SCRUM-12: Settlement Compliance
            If(claim.Status__c == 'Settled'){
                if (claim.Settlement_Amount__c == null || claim.Settlement_Amount__c <= 0){
                claim.Settlement_Amount__c.addError('A claim cannot be marked Settled with a $0 or blank payout.');
                }
            }
            else if(claim.Status__c == 'Denied'){
                claim.Settlement_Amount__c = 0;
            }
            //High value automation rule
            if(claim.Settlement_Amount__c > 15000 && claim.Status__c != 'Denied'){
                claim.High_Value_Claim__c = true;
            } else {
                claim.High_Value_Claim__c = false;
            }
        }        
    }

	public static void validateIncidentDate(List<Claim__c> claims) {
        // for (Claim__c claim : claims) {

        //     if (claim.Incident_Date__c != null && claim.Incident_Date__c > Date.today()) {
        //         claim.Incident_Date__c.addError('Incident Date cannot be in the future.');
        //     }

        // }
    }
}