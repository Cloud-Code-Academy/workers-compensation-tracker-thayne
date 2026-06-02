// FOR UPDATED CLAIMS CHECKING STATUS
// FOR OPEN TO IN REVIEW STATUS UPDATE (CLEAN NO ERROR)
for (Integer i = 6; i < 9; i++) {
    
    if (i == 6) {
    Claim__c insertClaim7 = new Claim__c();
    String dateToday = '2026-05-18'; //must be updated to TODAY's date whenever I test
    Date dateValueOfToday = date.valueOf(dateToday);
    Date previousDay = dateValueOfToday - 1;

    // System.debug('todays date:' + dateValueOfToday + i);
    // System.debug('yesterdays date:' + previousDay + i);
    
        insertClaim7.Name = 'Testing Claim Duration Tracking STATUS' + i;     
        insertClaim7.Date_Filed__c = Date.valueOf(dateValueOfToday); //-2 days  
        insertClaim7.Incident_Date__c = Date.valueOf('2026-05-16'); //- 1 day
        insertClaim7.Status__c = 'Open';
        insertClaim7.Insurance_Provider__c = '001g800000FBTvlAAH'; 
        // System.debug('Incident Date :' + insertClaim6.Incident_Date__c + i);
        // System.debug('Date Filed :' + insertClaim6.Date_Filed__c + i);
        newClaims.add(insertClaim7);
        i++;
    }

// FOR In review TO SETTLED STATUS UPDATE (CLEAN NO ERROR)
    //CONTROL - CAN BE COMMENTED
    if (i == 7){
        i++;
    }
    
    if (i == 7) {
    Claim__c insertClaim8 = new Claim__c();
    String dateToday = '2026-05-18'; //must be updated to TODAY's date whenever I test
    Date dateValueOfToday = date.valueOf(dateToday);
    Date previousDay = dateValueOfToday - 1;

    // System.debug('todays date:' + dateValueOfToday + i);
    // System.debug('yesterdays date:' + previousDay + i);
    
        insertClaim8.Name = 'Testing Claim Duration Tracking STATUS' + i;     
        insertClaim8.Date_Filed__c = Date.valueOf(dateValueOfToday); //-2 days  
        insertClaim8.Incident_Date__c = Date.valueOf('2026-05-17'); //- 1 day
        insertClaim8.Status__c = 'Settled';
        insertClaim8.Insurance_Provider__c = '001g800000FBTvlAAH'; 
        // System.debug('Incident Date :' + insertClaim6.Incident_Date__c + i);
        // System.debug('Date Filed :' + insertClaim6.Date_Filed__c + i);
        newClaims.add(insertClaim8);
        i++;
    }

// FOR SETTLED TO Closed STATUS UPDATE (CLEAN NO ERROR) EXPECTING ERROR
    if (i == 8){
        i++;
    }
    if (i == 8) {
    Claim__c insertClaim9 = new Claim__c();
    String dateToday = '2026-05-18'; //must be updated to TODAY's date whenever I test
    Date dateValueOfToday = date.valueOf(dateToday);
    Date previousDay = dateValueOfToday - 1;

    // System.debug('todays date:' + dateValueOfToday + i);
    // System.debug('yesterdays date:' + previousDay + i);
    
        insertClaim9.Name = 'Testing Claim Duration Tracking ERROR' + i;     
        insertClaim9.Date_Filed__c = Date.valueOf(dateValueOfToday); //-2 days  
        insertClaim9.Incident_Date__c = Date.valueOf('2026-05-16'); //- 1 day
        insertClaim9.Status__c = 'Denied';
        insertClaim9.Insurance_Provider__c = '001g800000FBTvlAAH'; 
        // System.debug('Incident Date :' + insertClaim6.Incident_Date__c + i);
        // System.debug('Date Filed :' + insertClaim6.Date_Filed__c + i);
        newClaims.add(insertClaim9);
        i++;
        
    }

    // FOR Denied TO Closed STATUS UPDATE (CLEAN NO ERROR) EXPECTING ERROR
    if (i == 9) {
    Claim__c insertClaim10 = new Claim__c();
    String dateToday = '2026-05-18'; //must be updated to TODAY's date whenever I test
    Date dateValueOfToday = date.valueOf(dateToday);
    Date previousDay = dateValueOfToday - 1;

    // System.debug('todays date:' + dateValueOfToday + i);
    // System.debug('yesterdays date:' + previousDay + i);
    
        insertClaim10.Name = 'Testing Claim Duration Tracking ERROR' + i;     
        insertClaim10.Date_Filed__c = Date.valueOf(dateValueOfToday); //-2 days  
        insertClaim10.Incident_Date__c = Date.valueOf('2026-05-15'); //- 1 day
        insertClaim10.Status__c = 'Open';
        insertClaim10.Insurance_Provider__c = '001g800000FBTvlAAH'; 
        // System.debug('Incident Date :' + insertClaim6.Incident_Date__c + i);
        // System.debug('Date Filed :' + insertClaim6.Date_Filed__c + i);
        newClaims.add(insertClaim10);
        i++;
    }
}


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
