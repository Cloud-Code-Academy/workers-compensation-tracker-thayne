
/*
* Description: Capstone
* Author: Thayne Rodrigo
* Date: 12/05/2026
*
* 
*/

trigger EmployeeClaimTrigger on Employee_Claim__c (after insert, after update, after delete, after undelete) {
    
new EmployeeClaimHandler().run();

}