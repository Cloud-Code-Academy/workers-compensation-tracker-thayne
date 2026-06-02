/*
* Description:  Capstone
* Author: Thayne Rodrigo
* Date: 15/05/2026
*
*
*/

trigger ClaimTrigger on Claim__c (before insert, before update) {
new ClaimHandler().run();

}