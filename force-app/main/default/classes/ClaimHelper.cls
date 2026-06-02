//HIGH LEVEL CLASS EXPLANATION:
    // beforeInsert passes in records that are to be immediately passed to the validation method for processing.
    // beforeUpdate passes in records to updatedClaimsDurationTracking. This method aims filter down records that can be processed by the primary method claimDurationTracking

//The flow of this is 
    // beforeInsert >  claimDurationTracking > claimDatesValidation > claimDurationTracking
    // beforeUpdate > updatedClaimsDurationTracking > claimsDurationTracking > claimDatesValidation > claimDurationTracking

//WHERE the claimDurationTracking method will always assume to receive ready/qualified list of claims to process before updates.
    //BECAUSE claims are filtered (qualified/disqualified) through a combination of updatedClaimsDurationTracking AND/OR claimsDateValidation, depending on context. 
        //WHERE updatedClaimsDurationTracking disqualifies/filters out updated claims based on Settled or Denied conditions, AND
        //WHERE claimDatesValidation handles the base level validation rules that applies to both before insert/update context (i.e all claims have to go through it)




//METHODS: This class has two main methods and two helpers///
        //1. claimDurationTracking handles most of the main requirements in capstone and processes both new and updated claims.
        
        //2. updatedClaimsDurationTracking 'processes' updated claims and filters out for the claims relevant to the solution.
            //any filtered out claims are considered disqualified and are then checked to see if required fields are null. They are updated if null.
            //this is the only method that 'disqualifies' records that will be eventually processed for additional checks.
            // claims that are 'qualified' will be passed into the claimDurationTracking method.
    
        //3. claimDatesValidation (helper method) is used by both main methods to separately handle ALL BASE validation checks before final processing per requirements.
            //Claims on beforeInsert/beforeUpdate will be passed into this method by the claimsDurationTracking as a way to validate claims per requirements. Any that fails validation will be removed from the claimsList so that it will not be updated.
            

        //4. highValueSettlement (helper method) is used to check if the record is a high value settlement.

//Definitions:
        //Qualified = claims that meets the requirements and can be processed by the solution.
        //Disqualified = claims that fails to meet the requirements. These are either settled or denied claims being updated to a different status OR that have had no status updates.
            //A feature is added in to check these disqualified records in case they need an update to specific fields.

//Hard rules:
        //My rule here is that settled/denied records cannot be updated to any other Status value to protect record integrity.
            // I would like to potentially add in an override option to allow for updates on such records post capstone.
        
        //Any inserted records MUST have the date fields (filed/incident) populated on insert/update.


//ADD ON FEATURE NOT IN CAPSTONE:
    //An additional value was added to Status called 'Closed'.
            // This value represents a case that was automatically closed after a certain number of days is met.
                //In hindsight, I would have had created a scheduled job to run everyday to update the days open field.

    //Disqualified feature:
            // This feature is embedded in the methods to process any disqualified claims that may have a specific set of fields null (days open/settlment date/is high value)
            // This is more to cover off the original inserts for this capstone assignment, before the mentioned fields were created.

    //Date fields
            // Introduced new date fields (Denied Date, Closed Date)

//FUTURE FEATURES:
    //Build scheduled flow that will update the days open field on any claims where status != Settled/Denied in increments of 1 per day.
    //Scheduled flow will check if days_open__c field is >= totalDaysToCloseClaim. If true, updates the Closed Date to today and Status = closed.

    

public with sharing class ClaimHelper {     
    
    private static final Integer highValueSettlement = 1500;

    //this is a variable to use when I build out a scheduled flow
    private static final Integer totalDaysToCloseClaim = 100;


    public static void claimDurationTracking(List<Claim__c> claimsList, List<Claim__c> disqualifiedClaims){


        if (claimsList.isEmpty() && disqualifiedClaims.isEmpty()) {
            System.debug ('no claims to process');
        } 

        //See METHODS (3) for explanation.
        claimDatesValidation(claimsList);

        if (!claimsList.isEmpty()) {
            for (Claim__c c : claimsList) {

                // IF claim IS Settled or Denied, set the 'days open' field.
                    //We check if the days open field is null, because if we are inserting new records we want to ensure the days open field, where populated, are not overriden.
                    //This also covers updates, where records are updated to settled/denied.
                    
                if (c.Status__c == 'Settled' || c.Status__c == 'Denied' && c.Days_Open__c == null) {
                        c.Days_Open__c = (c.Date_Filed__c).daysBetween(Date.today());
                }
                
                //IF status IS NOT settled/denied, set the 'days open' field 
                    // No days open null check like above as I want the field updated whenever the claim is updated to be as accurate as possible.

                if (c.Status__c != 'Settled' || c.Status__c != 'Denied') {
                        c.Days_Open__c = (c.Incident_Date__c).daysBetween(Date.today());
                }

                // IF status is Settled, set the Settlement Date to today.
                        // The settlement date should only ever be populated once and that is when the Status is settled on insert or on update.
                        // This means that the settlement date does not need a check.
                        
                if (c.Status__c == 'Settled') {
                    c.Settlement_Date__c = System.today();
                }

                //When status is Denied
                    // The settlement date should only ever be populated once and that is when the Status is settled on insert or on update.
                    // This means that the settlement date does not need a check.
                    // validation for incident date > date filed is already handled by validationMethod.
                if (c.Status__c == 'Denied') {
                    c.Settlement_Amount__c = 0;
                    c.deniedDate__c = System.today();
                }
                
                //I want the high value checkbox to always be updated in this method without checks because it will cover both insert and update scenarios.
                setHighValue(c);
            }
        }

        if (!disqualifiedClaims.isEmpty()) {
            for (Claim__c c : disqualifiedClaims) {
                
                //assumes that settlement amount field validation is checked (settlement amount > 0)
                //handled by validation method
                
                if (c.Status__c == 'Settled' && c.Settlement_Date__c == null) {
                    c.Settlement_Date__c = System.today();
                }

                //updates Closed date field 
                if (c.Status__c == 'Denied' && c.Settlement_Amount__c != null) {
                    c.Settlement_Amount__c = 0;
                }

                if (c.Status__c != 'Settled' || c.Status__c != 'Denied') {
                    c.Days_Open__c = (c.Incident_Date__c).daysBetween(Date.today());
                }

                setHighValue(c);
            }
        }       

        System.debug('END claimsDurationTracking 6');     
    }



/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
public static void updatedClaimsDurationTracking (List<Claim__c> oldClaimsList, List<Claim__c> newClaimsList){
    // handles beforeUpdate and processes it before passing to claimDurationTracking()
    // acts as a means to process records that qualifies to be processed in the above method.
    // method will check if there was any actual updates between status field and settlement amount field in old/new list.
    // after qualifying or disqualifying records, the method calls on the main method to do final processing before update.

        System.debug('START updatedClaimsDurationTracking');

        //Map - to retrieve old claim values.
            //Map2 - to collect claims that do not qualify.
            //List - to collect claims that meets criteria to be passed into main method.
        Map<Id, Claim__c> oldClaimsMap = new Map<Id, Claim__c> (oldClaimsList);
        List<Claim__c> disqualifiedClaims = new List<Claim__c>();
        List<Claim__c> claimsList = new List<Claim__c>();
        

        for (Claim__c c : newClaimsList) {
            Claim__c oldClaim = oldClaimsMap.get(c.Id);
            Integer i = 0; 
            
            //i.e - throw an error if the user attempted to change a record that was already settled/denied.
                // this means that the new status value is either settled, denied, or any other values available.
                // this means that the settlement amount hasn't changed (as it can't be changed)
                // this means that only records that are properly updated to settled/denied or to other statuses will be processed.
            if (((oldClaim.Status__c == 'Settled' || oldClaim.Status__c == 'Denied') && oldClaim.Status__c != c.Status__c)) {
                c.addError('Status__c', 'A Settled or Denied claim cannot be reopened. Please create a new claim.');
                disqualifiedClaims.add(c);
                claimsList.remove(0);
                i++;
                continue;
            }

            if ((c.Status__c == 'Settled' || c.Status__c == 'Denied') && oldClaim.Settlement_Amount__c != c.Settlement_Amount__c || oldClaim.Injury_Type__c != c.Injury_Type__c || oldClaim.Insurance_Provider__c != c.Insurance_Provider__c) {
                c.addError('A Settled or Denied claim cannot have any fields updated. Please create a new claim.');
                disqualifiedClaims.add(c);
                claimsList.remove(0);
                i++;
                continue;               
            }

            //as first if statement checks if status was updated FROM settled/denied and continues the loop if true, this IF statement does not need a check with old value.
            if (c.Status__c == 'Settled' && (c.Settlement_Amount__c <= 0 || c.Settlement_Amount__c == null)) {
                c.addError('Settlement_Amount__c', 'Claim cannot be marked as settled without a $0 payout. Please add in the payout in the Settlement Amount field.');
                disqualifiedClaims.add(c);
                claimsList.remove(0);
                i++;
                continue;
            }              
            
            claimsList.add(c);
            i++;
            }




    if (!claimsList.IsEmpty()) {
        claimDurationTracking(claimsList, disqualifiedClaims);
    } else {
        System.debug('No claims can be updated');
    }
    
}

//////////////////////////////////////HELPER METHODS/////////////////////////////////////////////////////////////////////

    //Context: Used to set High_Value__c checkbox based on settlement amount.
        //ASSUMPTION: Settlement Amount can be updated when the record was not already Settled/Denied.
            //This method assumes that the current record was not updated from a Settled or Denied claim.
            // This assumption is checked for and covered by the method that called it.

    public static void setHighValue (Claim__c claim) {
        
        if (claim.Settlement_Amount__c < highValueSettlement || claim.Settlement_Amount__c == null) {
            claim.Is_High_Value__c = false;
        
        } else if (claim.Settlement_Amount__c >= highValueSettlement) {
            claim.Is_High_Value__c = true;
        }
    }


//ASSUMPTION: These following fields are populated on insert (Date Filed, Incident Date). date filed represents when the claim was created && incident date represents when the incident occurred.
// Context: Validates date of incident and date filed on claim records for different scenarios.
// Context: Additional validations specific to this solution are placed in here to validate/check any claims passed to the helper method.
    //Applied to before insert context to ensure that we are validating the fields before creation, preventing bad data at entry point. 
    // Applied to after update context to ensure that all relevant fields are populated throughout the claims stage.


    public static void claimDatesValidation (List<Claim__c> claimsList){
        if (!claimsList.isEmpty()) {
            for (Claim__c c : claimsList) {
                Integer i = 0;

                //error if the Incident date and date filed fields are not populated.
                if (c.Incident_Date__c == null && c.Date_Filed__c == null) {
                    c.addError('Please add in the Incident Date and Date filed field for this claim.' + c.Name);
                    claimsList.remove(0);
                    i++;
                continue;
            }

                //error if the Insurance Provider has not been populated.
                if (c.Insurance_Provider__c == null) {
                    c.addError('Insurance_Provider__c', 'Please add in the Insurance Provider for this claim.' + c.Name);
                    claimsList.remove(0);
                    i++;
                continue;
            }

                //error if the incident (date) has happened after the reported (filed) date as you can't file an incident that hasn't happened yet.
                // no null check on incident date/date filed as first IF statement validates for that.
                if ((c.Incident_Date__c > c.Date_Filed__c)) {
                    c.addError('Incident_Date__c', 'An incident cannot be reported before the incident has happened. Please update the "Incident Date" field to be before the "Date Filed" field.' + c.Name);
                    claimsList.remove(0);
                    i++;
                continue;
            }

                //error for if incident (i.e when accident has occurred) is dated in the future (after today).
                //i.e you can't say that an incident has happened in the future (after today).
                //i.e While I know that the incident date is technically enough, it feels safer to add in date filed as an additional check. Even if the previous if check does consider for it.
                if (c.Incident_Date__c > System.today() || c.Date_Filed__c > System.today()) {
                    c.addError('Incident_Date__c', 'The incident date or the date filed is set to be after today. This incident and reported date could not have happened after today. Please the fields to the correct dates.' + c.Name);
                    claimsList.remove(0);
                    i++;
                continue;       
            } 
 
            
        }
    }
        System.debug('END VALIDATION METHOD');
    }
}
