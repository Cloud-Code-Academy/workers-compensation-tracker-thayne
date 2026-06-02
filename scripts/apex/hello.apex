// Use .apex files to store anony00000 Code by selecting the
//     apex text and running the command:
//     SFDX: Execute Anonymous Apex with Currently Selected Text
// You can also execute the entire file by running the command:
//     SFDX: Execute Anonymous Apex with Editor Contents


List<String> claimStatus = new List<String>();
claimStatus.add('Settled');
claimStatus.add('Denied');
claimStatus.add('Closed');

List<Claim__c> c = [SELECT Id, Date_Filed__c, Incident_Date__c FROM Claim__c WHERE Status__c IN :claimStatus];

Map<Id, Claim__c> oldClaimsMap = new Map<Id, Claim__c> (c);
        
System.debug('Old Claims Map :' + oldClaimsMap);
/*
//FOR CLAIM DURATION TRACKING
System.debug('Date Filed :' + c.Date_Filed__c);
System.debug('Incident Date :' + c.Incident_Date__c);

String dateToday = '2022-09-10';
Date dateValueOfToday = date.valueOf(dateToday);
System.debug('todays date:' + dateValueOfToday);

Integer dateFiled1 = (c.Date_Filed__c).daysBetween(dateValueOfToday);
System.debug('DateFiled:' + dateFiled1);
Integer IncidentDate1 = (c.Incident_Date__c).daysBetween(dateValueOfToday);
System.debug('IncidentDate1:' + IncidentDate1);
*/ 
System.debug('END');


//TR - NOTE: To test EmployeeRiskFlagging AFTER UPDATE, AFTER INSERT, AFTER 
// No dml. Just calling directly on method to cover
// 'Aisha Thompson : a00g800000k7h8OAAQ' | a02g8000003tmKXAAY | $14,900 , 3 claims | claim with $0 settlement. a02g8000003tmL8AAI
// 'Carmen Rivera : a00g800000k7h8GAAQ' | a02g8000003tmKHAAY | $15,300, 2 claims


// Set<Id> employeeClaimId = new Set<Id>();
// employeeClaimId.add('a02g8000003tmL8AAI');

// List <Employee_Claim__c> employeeClaims = [SELECT Id, Employee__c, Claim__c FROM Employee_Claim__c WHERE Id IN :employeeClaimId];
// System.debug('Script employeeClaims queried:: ' + employeeClaims);

// //delete employeeClaims;
// System.debug('SCRIPT END');
