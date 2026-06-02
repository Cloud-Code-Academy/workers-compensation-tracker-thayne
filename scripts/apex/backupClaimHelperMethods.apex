// public with sharing class ClaimHelper {


// //Context: On afterInsert / afterUpdate of Claim records,
// // Validates that Incident Date field is not in future.
// // Validates that Incident Date field is not set to AFTER the Date Filed field.
// // This is because a claim cannot be reported before it has happened.
// //Considers for where an incident shares the same date as the date filed.

// //////////Setting threshold/////////
//     //Note: updates the 'Is high value' checkbox when a claim has a settlement value of $15000 or greater.
//     private static final Integer highValueSettlement = 1500;

// ///////////////////////////////////////////////////////////HELPER METHOD///////////////////////////////////////////////////////////////////////////////
// // Context: Validates date of incident and date filed on claim.
// // Used by claimStatusAutomation method but is also referenced in before insert. To ensure that we are validating the fields 
// // before inserting, preventing bad data at entry point. 

//     public static void claimDatesValidation (List<Claim__c> claimsList){
//         Integer i = 0;

//         System.debug(':::::::::claimsDatavalidation claimsList  3:::::::: ');
//         for (Claim__c c : claimsList) {
            
//             // System.debug(c.Name);            
//             // System.debug(c.Incident_Date__c);
//             // System.debug(c.Date_Filed__c);
//             // System.debug(c.Insurance_Provider__c);

//             //error if the Incident date and date filed fields are not populated.
//             if (c.Incident_Date__c == null && c.Date_Filed__c == null) {
//                 c.addError('Please add in the Incident Date and Date filed field for this claim.' + c.Name);
//                 // System.debug('Error if the Incident date and date filed fields are not populated::: ' + c.Name );
//                 i++;
//                 continue;
//             }

//             //error if the Insurance Provider has not been populated.
//             if (c.Insurance_Provider__c == null) {
//                 c.addError('Insurance_Provider__c', 'Please add in the Insurance Provider for this claim.' + c.Name);
//                 // System.debug('Error if the Insurance Provider has not been populated.::: ' + c.Name);
//                 i++;
//                 continue;
//             }

//             //error if the incident (date) has happened after the reported (filed) date. You can't file an incident that hasn't happened yet.
//             // no null check on incident date/date filed as first if statement validates for that.
//             if ((c.Incident_Date__c > c.Date_Filed__c)) {
//                 c.addError('Incident_Date__c', 'An incident cannot be reported before the incident has happened. Please update the "Incident Date" field to be before the "Date Filed" field.' + c.Name);
//                 // System.debug('Error if the incident (date) has happened after the reported (filed) date.' + c.Name);
//                 i++;
//                 continue;
//             }

//             //error for if incident (i.e when accident has occurred) is dated in the future (after today).
//             //i.e you can't say that an incident has happened in the future (after today).
//             //i.e While I know that the incident date is technically enough, it feels safer to add in date filed as an additional check. Even if the previous if check does consider for it.

//             if (c.Incident_Date__c > System.today() || c.Date_Filed__c > System.today()) {
//                 c.addError('Incident_Date__c', 'The incident date or the date filed is set to be after today. This incident and reported date could not have happened after today. Please the fields to the correct dates.' + c.Name);
//                 // System.debug('Error for if incident (i.e when accident has occurred) or filed date is dated in the future (after today)'+ c.Name);
//                 i++;
//                 continue;
//             } 
//             i++;
//         }
//         System.debug('END VALIDATION METHOD');
//     }



// //Context: On after Insert/Update of Claim records, calculates the number of days between Incident Date and TODAY(), OR
// // IF status is inserted/updated with 'Settled' or 'Denied', calculate number of days between Date Filed and TODAY().
// // I have also added 'Closed' even if not listed in capstone document. 'Closed' would mean that the claim has been 'closed', so there is no need to track the days it is 'open' at that point.

//     //This method is the main method that handles main business logic. Other methods in this class will call on this after processing the list of records initially.
    
// public static void claimDurationTracking(List<Claim__c> claimsList){

//     System.debug(':::::::::ClaimsList BEFORE 1 claimDataValidation');
//     System.debug('START claimDatesValidation 2');
//             claimDatesValidation(claimsList);
//     System.debug('END claimDatesValidation 4');

//         System.debug('START claimsDurationTracking 5');
//         Integer i = 0; 

//         if (claimsList.isEmpty()) {
//             // System.debug('5.1 LIST IS EMPTY');
//             // System.debug(claimsList);
//             return; //////////////////
//         }

//         if (!claimsList.isEmpty()) {
//            System.debug('START 5. 1 FOR LOOP STARTS'); 

//         //TR -- INSERT TRY CATCH
//         for (Claim__c c : claimsList) {
//                 // String dateToday = '2026-05-18'; //must be updated to TODAY's date whenever I test
//                 // Date dateValueOfToday = date.valueOf(dateToday);
//                 // Date previousDay = dateValueOfToday - 1;

//                 System.debug('5.1 LOOP DAYS ELSE CHECK::: ' + c.Name);
//                 System.debug('5.1 LOOP DAYS ELSE CHECK 2::: ' + c.Status__c);     
//                 System.debug('5.1 LOOP DAYS ELSE CHECK 3::: ' + c.Date_Filed__c);  
//                 System.debug('5.1 LOOP DAYS ELSE CHECK 3::: ' + c.Incident_Date__c); 

//             // for when updated to Settled or Denied.
//             if (c.Status__c == 'Settled' || c.Status__c == 'Denied' && c.Date_Filed__c != null || c.Incident_Date__c != null) {
//                // c.Days_Open__c = (c.Date_Filed__c).daysBetween(dateValueOfToday);
//                 c.Days_Open__c = (c.Date_Filed__c).daysBetween(Date.today()); 
//                 System.debug('Date filed SETTLED/DENIED difference:: ' + c.Days_Open__c);
//             } 

//             //for inserts / updates and status not FROM settled/denied
//             if (c.Status__c != 'Settled' || c.Status__c != 'Denied' && c.Date_Filed__c != null || c.Incident_Date__c != null) {
//                 //c.Days_Open__c = (c.Incident_Date__c).daysBetween(dateValueOfToday);
//                  c.Days_Open__c = (c.Incident_Date__c).daysBetween(Date.today());
//                 System.debug('Date filed NOT SETTLED/DENIED difference:: ' + c.Days_Open__c);
//             }

//             //if settlement amount has exceeded the threshold, set to true.
//             if (c.Settlement_Amount__c >= highValueSettlement ) {
//                 c.Is_High_Value = true; 
//             } else {
//                 c.Is_High_Value = false;
//             }

//             i++;
//             System.debug('TOTAL LOOP IN MAIN:: ' + i);
//                }
//         }
//         System.debug('END claimsDurationTracking 6');
//     }

//     //handles beforeUpdate and processes it before passing to claimDurationTracking()
//     // acts as a means to process records that qualifies to be processed in the above method.
//     // method will check if there was any actual updates between status field in old/new.
//     public static void updatedClaimsDurationTracking (List<Claim__c> oldClaimsList, List<Claim__c> newClaimsList){
//         System.debug('START updatedClaimsDurationTracking');

//         Integer i = 0; 
//         Map<Id, Claim__c> oldClaimsMap = new Map<Id, Claim__c> (oldClaimsList);
//         System.debug('Old Claims Map :' + oldClaimsMap);
//         List<Claim__c> claimsList = new List<Claim__c>();
        
//         for (Claim__c c : newClaimsList) {
//             Claim__c oldClaim = oldClaimsMap.get(c.Id);
//             System.debug('updatedClaimsDurationTracking current claim status: ' + oldClaim.Status__c + ' ,' + i);
//             System.debug('updatedClaimsDurationTracking current claim status: ' + c.Status__c);


//             //if no change to status, skip to next iteration as we only want to check for difference in Status.
//             //NOTE: This is a check that determines if the current record is qualified for the rest of the loop.

//             // ASSUMPTION: FIRST IF STATEMENT means that all IF statements in this block assumes that there IS a difference between old status and new status (i.e it has been updated)
//             if (oldClaim.Status__c == c.Status__c) {
//                 System.debug('updatedClaimsDurationTracking first if statement SKIP'  + ' ,' + i);
//                 continue;
//             }


//             //TR - added this in; seems like a realistic scenario.
//             //if the original value was 'Settled' or 'Denied' and the updated value is not, throw an error.
//             //i.e - throw an error if the user attempted to change a record that was already settled/denied.
//                 //ELSE IF the original value does not match the new value and wasn't Settled/Denied, add to list to be processed in main method.
//                 // this means that the new status value is either settled, denied, or any other values available.


//                 //NEED TO CHECK HOW TO ALLOW LOOP TO CONTINUE AFTER ERROR
//             if ((oldClaim.Status__c == 'Settled' || oldClaim.Status__c == 'Denied')
//             ) {c.addError('Status__c', 'A Settled or Denied claim cannot be reopened. Please create a new claim.' + c.Name);
//                System.debug('updatedClaimsDurationTracking second if statement' + ' ,' + i);
//                continue;
//             }

// ///////////////////////////Claim Status Automation//////////////////////////////////////////////////////////////////////
            
//         /////////The above IF statement protects/allows for the below IF statements ///////////

//         //ASSUMPTIONS: Settlement dates are only ever populated once, when a claim is set to 'Settled' or 'Denied'. 
//         //This is because we have a guard in earlier IF status to not allow for claims to be reopened.
//         //THUS there is no null checks for the date field.

//         //When status is changed to Settled, set the Settlement DAte to today IF BLANK
//             //AND validate that settlment amount > 0;
//             //set error to 'Claim cannot be marked as settled without a $0 payout. Please add in the payout in the Settlement Amount field.'
//             if (c.Status__c == 'Settled') {
//                 c.Settlement_Date__c = System.today();
            
//                 if (c.Settlement_Amount__c <= 0) {
//                 c.addError('Settlement_Amount__c', 'Claim cannot be marked as settled without a $0 payout. Please add in the payout in the Settlement Amount field.');
//                 }
//             }

//         //When status is changed to Denied, set the Settlement amount = 0;
//             //Validate incident date is not in the future and is not after the date filed 'a claim cannot be reported before it has happened'.
//             //validation is already handled by validationMethod (fourth IF statement).
//             // if the checkbox is true and the threshold has been exceeded, set the checkbox to false.
//             if (c.Status__c == 'Denied') {
//                 c.Settlement_Amount__c = 0;

//             if (c.Settlement_Amount__c >= highValueSettlement && c.Is_High_Value__c = true) {
//                 Is_High_Value__c = false;
//             }
//         }
        
//         System.debug('Added updated record to claims list ' + ' ,' + c.Name + ', ' + i);                
//         claimsList.add(c);
//         i++;
//         }
//         System.debug('END UPDATED LOOP');
//         if (!claimsList.isEmpty()) {
//             System.debug('CALLING claimDurationTracking method');
//             claimDurationTracking(claimsList);
//         }
//         System.debug('END updatedClaimsDurationTracking');
//     }

//     //////////////////////////////////////HELPER METHODS////////////////////////////////////////////////////////

//     //Context: Used to set High_Value__c checkbox based on settlement amount.
//         //ASSUMPTION: Settlement Amount can be updated by the users UNLESS the oldValue was Settled or Denied.
//             //This method assumes that the current record was not updated from a Settled or Denied claim.
//             // This assumption is checked for and covered by the method that called it.

//     public static Claim__c setHighValue (Claim__c claim){
//                 if (c.Settlement_Amount__c == null) {
//                     c.Settlement_Amount__c = 0;
//                     Is_High_Value__c = false;
//                 } else if (c.Settlement_Amount__c < highValueSettlement) {
//                     Is_High_Value__c = false;
//                 } else {
//                     //now assumes if settlement amount is greater than or equals to threshold and settlement amount is not null
//                     Is_High_Value__c = true;
//                 }
//         }

// }
