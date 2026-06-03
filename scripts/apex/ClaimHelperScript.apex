//1. Test for Claim Duration Tracking method where
// a) the Claim is inserted/updated AND not settled or denied so the days open is updated to Incident_Date__c - Today();
// b) the Claim IS CHANGED to settled or denied so the days open is updated to Date_Filed - Today();

// open claims
Set<Id> claimIds = new Set<Id>();
claimIds.add('a01g800000FC829AAD');
claimIds.add('a01g800000FC82DAAT');
claimIds.add('a01g800000FC82JAAT');

List<Claim__c> claims = [SELECT Id, Date_Filed__c, Incident_Date__c FROM Claim__c WHERE Id IN :claimIds];
List<Claim__c> newClaims = new List<Claim__c>();


for (Claim__c c : claims) {
    Claim__c insertClaim = new Claim__c();

    insertClaim.Name = 'Testing Claim Duration Tracking ' + i; 
    insertClaim.Date_Filed__c = Date.valueOf('2026-05-17'); 
    insertClaim.Incident_Date__c = Date.valueOf('2026-05-10');
    insertClaim.Insurance_Provider__c = '001g800000FBTvlAAH'; 

    String dateToday = '2026-05-18'; //UPDATE TO TODAYS DATE
    Date dateValueOfToday = date.valueOf(dateToday);
    Integer dateFiled1 = (c.Date_Filed__c).daysBetween(dateValueOfToday);
    Integer IncidentDate = (c.Incident_Date__c).daysBetween(dateValueOfToday);

    // System.debug('todays date:' + dateValueOfToday);
    // System.debug('Date Filed :' + c.Date_Filed__c);
    // System.debug('Incident Date :' + c.Incident_Date__c);
    // System.debug('DateFiled DAYS BETWEEN:' + dateFiled1);
    // System.debug('IncidentDate DAYS BETWEEN:' + IncidentDate);
    
    i++;
    newClaims.add(insertClaim);
}

// both happy and not happy path testing || POTENTIALLY USED FOR TEST CLASS + UPDATES
// TR UNIT TESTING MATERIALS FOR claimDatesValidation method
for (Integer i = 6; i < 10; i++) {
    i = 5;

    // error if the Incident date and date filed fields are not populated.
    if (i == 0) {
    Claim__c insertClaim1 = new Claim__c();
    insertClaim1.Name = 'Testing Claim Duration Tracking OPEN STATUS' + i; 
    insertClaim1.Incident_Date__c = null;
    insertClaim1.Date_Filed__c = null;
    insertClaim1.Insurance_Provider__c = '001g800000FBTvlAAH'; 
    insertClaim1.Status__c = 'Open';
    // System.debug('Incident Date :' + insertClaim1.Incident_Date__c + i);
    // System.debug('Date Filed :' + insertClaim1.Date_Filed__c + i);
    // System.debug('Incident Date :' + insertClaim1.Status__c);
    newClaims.add(insertClaim1);
    i++;
    }

    //error if the Insurance Provider has not been populated.   
    if (i == 1) {
        Claim__c insertClaim2 = new Claim__c();
        insertClaim2.Name = 'Testing Claim Duration Tracking IN REVIEW STATUS' + i; 
        insertClaim2.Incident_Date__c = Date.valueOf('2026-05-14'); //-2
        insertClaim2.Date_Filed__c = Date.valueOf('2026-05-15'); //-1
        insertClaim2.Insurance_Provider__c = null; 
        insertClaim2.Status__c = 'Open';
        // System.debug('Incident Date :' + insertClaim2.Incident_Date__c + i);
        // System.debug('Date Filed :' + insertClaim2.Date_Filed__c + i);
        newClaims.add(insertClaim2);
        i++;
    }

    //error if the incident (date) has happened after the reported (filed) date. You can't file an incident that hasn't happened yet.
    if (i == 2) {
        Claim__c insertClaim3 = new Claim__c();
        insertClaim3.Name = 'Testing Claim Duration Tracking SETTLED STATUS' + i; 
        insertClaim3.Incident_Date__c = Date.valueOf('2026-05-17'); // +2 days after date filed
        insertClaim3.Date_Filed__c = Date.valueOf('2026-05-15'); // -2 days before incident date
        insertClaim3.Insurance_Provider__c = '001g800000FBTvlAAH'; 
        insertClaim3.Status__c = 'Open';
        // System.debug('Incident Date :' + insertClaim3.Incident_Date__c + i);
        // System.debug('Date Filed :' + insertClaim3.Date_Filed__c + i);
        newClaims.add(insertClaim3);
        i++;
    }

    //error for if incident (i.e when accident has occurred) is dated in the future (after today). (Incident Date check)
    if (i == 3) {
        Claim__c insertClaim4 = new Claim__c();
        insertClaim4.Name = 'Testing Claim Duration Tracking (Incident Date check) DENIED STATUS' + i; 
        insertClaim4.Incident_Date__c = Date.valueOf('2026-05-30'); //is set greater than today (current date)
        insertClaim4.Date_Filed__c = Date.valueOf('2026-05-31'); 
        insertClaim4.Insurance_Provider__c = '001g800000FBTvlAAH'; 
        insertClaim4.Status__c = 'Open';
        // System.debug('Incident Date :' + insertClaim4.Incident_Date__c + i);
        // System.debug('Date Filed :' + insertClaim4.Date_Filed__c + i);
        newClaims.add(insertClaim4);
        i++;
    }

    //error for if incident (i.e when accident has occurred) is dated in the future (after today). (Date filed check)
        if (i == 4) {
        Claim__c insertClaim5 = new Claim__c();
        insertClaim5.Name = 'Testing Claim Duration Tracking (Date filed check) ' + i; 
        insertClaim5.Incident_Date__c = Date.valueOf('2026-05-17'); //day before today (last test)
        insertClaim5.Date_Filed__c = Date.valueOf('2026-05-31');  // set to way past current date (my today testing this)
        insertClaim5.Insurance_Provider__c = '001g800000FBTvlAAH'; 
        insertClaim5.Status__c = 'Open';
        // System.debug('Incident Date :' + insertClaim5.Incident_Date__c + i);
        // System.debug('Date Filed :' + insertClaim5.Date_Filed__c + i);
        newClaims.add(insertClaim5);
        i++;
    }

    // no error, calibrated for always testing against the current day (today)
    if (i == 5) {
    Claim__c insertClaim6 = new Claim__c();
    String dateToday = '2026-05-18'; //must be updated to TODAY's date whenever I test
    Date dateValueOfToday = date.valueOf(dateToday);
    Date previousDay = dateValueOfToday - 1;

    // System.debug('todays date:' + dateValueOfToday + i);
    // System.debug('yesterdays date:' + previousDay + i);
    
        insertClaim6.Name = 'Testing Claim Duration Tracking NO ERROR' + i;     
        insertClaim6.Date_Filed__c = Date.valueOf(dateValueOfToday); //-2 days  
        insertClaim6.Incident_Date__c = Date.valueOf('2026-05-15'); //- 1 day
        insertClaim6.Status__c = 'Open';
        insertClaim6.Insurance_Provider__c = '001g800000FBTvlAAH'; 
        // System.debug('Incident Date :' + insertClaim6.Incident_Date__c + i);
        // System.debug('Date Filed :' + insertClaim6.Date_Filed__c + i);
        newClaims.add(insertClaim6);
        i++;
    }

}
System.debug('script for loop END');

insert newClaims;
// expecting for days open to be updated to incident date - today (187/190 | 126/130 | 29/31);
System.debug('INSERTED new claims');

// setting from open to denied
// expecting for no validation error
// expecting to go through before update > updatedClaimsDurationTracking > ClaimsDurationTracking > validation > claimsDurationTracking..
Integer i = 0;
for (Claim__c c : newClaims) {
    System.debug('update to denied/in review:::' + i);
    c.Status__c = 'Denied';
    if (i == 1) {
        c.Status__c = 'In Review';
    }
    i++;
}
    update newClaims;
    System.debug('UPDATED new claims :' + newClaims);

    
    delete newClaims;
    System.debug('DELETED test transaction');
