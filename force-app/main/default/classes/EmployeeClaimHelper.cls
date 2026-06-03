public with sharing class EmployeeClaimHelper {

    //setting final values to calculate overall risk levels
    ///Note: Make sure to update ClaimHelper if thresholds requirements are updated by business///

    private static final Integer highRiskTotalClaims = 15;
    private static final Integer highRiskTotalSettlements = 30000;
    private static final Integer mediumRiskTotalClaims = 10;
    private static final Integer mediumRiskTotalSettlements = 15000;
    private static final Integer lowRiskTotalClaims = 0;
    private static final Integer lowRiskTotalSettlements = 0;
    
    //class to allow storing aggregatedata values per provider.
    private class AggregateData {
        public Integer totalClaims = 0;
        public Decimal totalSettlement = 0;
    }

    //AFTER DELETE
    // receives list of old values from trigger context and use old list to get current claims in system (as records in old list are now in bin)
    // pass to method EmployeeRiskFlagging(employeeClaims, oldEmployeeClaims)
            //query for current claims in system using employeeId. This is the only way to get current claims per Employee (by using the employee lookups). 

    public static void EmployeeRiskFlaggingAfterDelete(List <Employee_Claim__c> oldEmployeeClaims){

        Set<Id> employeeIds = generateEmployeeIdsSet(oldEmployeeClaims);
        List<Employee_Claim__c> currentClaims = [SELECT Id, Employee__c, Claim__c FROM Employee_Claim__c WHERE Employee__c IN: employeeIds];

        EmployeeRiskFlagging(currentClaims);
    }

    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //after insert, after update, after undelete calls directly.
    // after delete will call this method through <EmployeeRiskFlaggingAfterDelete> method.
    // NOTE  - Insurance Provider is set to required. It can never be null on a Claim record.

   
        //BLOCK A
        //created a map that maps the employee to the total values per insurance provider.
            //created for loop to loop through each employee claim passed to the method. This is to populate the map and update the aggregate values.
            //FOR every employee claim, the loop will populate the map where needed to map each employee to groups of providers (that they have claims agianst) and the total values.

        //BLOCK B
        //set values for map and aggregation.   
            //Define employeeId for map population or nested map retrieval.
            //Define insuranceProvider for map population or agg retrieval.
            //Define settlementAmount to add to total settlementAmount against the provider in nested map.

        //BLOCK C
            //Begin populating primary Map (employeeTotalsMap)
            //IF the map does not contain the current employeeClaim's employeeId, add in employeeId to key and nested map, else continue.
            //This is to introduce any new employees not in the map. If skipped, it means the employee has already been added in and a new agg.total is being added against a provider in the nested map.

        //BLOCK D
            //Initialize nested map.
            //Returns snested map as value. 
            //i.e insuranceProviderMap = new Map<String, AggregateData>();
            //
            //
            //If the nested map does not contain the Insurance Provider(String), add in insuranceProvider to the nested Map as key and instantiate a new AggregateData value.
            // else, instantiate the aggregateData and add/update the aggregate values.
            // the values continue to be updated per insurance provider per loop.
            
        //BLOCK E
        //After loop, create list of employees to update risk fields on.
        //Calculate risk level by looping through each employeeId in the map's key values.
    
        //BLOCK F
            //Initialize nested map by retrieving value from parent map using current employeeId.
            // call method to calculate risk level
            // populate total claims with AggregateData grouped by provider.
            // populate total Settlement amount with AggregateData grouped by provider.
            // call method to calculate risk level summary
            //add employee to list for update.

public static void EmployeeRiskFlagging(List <Employee_Claim__c> employeeClaims){    

    Set<Id> employeeIds = generateEmployeeIdsSet(employeeClaims);
    List <Employee_Claim__c> allEmployeeClaims = [SELECT Id, Employee__c, Claim__c, Claim__r.Insurance_Provider__r.Name, Claim__r.Settlement_Amount__c, Claim__r.Status__c FROM Employee_Claim__c WHERE Employee__c IN :employeeIds];
    System.debug('EmployeeClaimsList::: ' + allEmployeeClaims);


        Map<Id, Map<String, AggregateData>> employeeTotalsMap = new Map<Id, Map<String, AggregateData>>();                //BLOCK A
        for (Employee_Claim__c ec : allEmployeeClaims) {

            Id employeeId = ec.Employee__c;                                                                               //BLOCK B
            String insuranceProvider = ec.Claim__r.Insurance_Provider__r.Name;
            Decimal settlementAmount = 0; 

            // This is a check to ensure that the settlementAmount returns a 0 if not null, to allow for aggregation.
            if (ec.Claim__r.Settlement_Amount__c != null && ec.Claim__r.Status__c == 'Settled') {
                settlementAmount = ec.Claim__r.Settlement_Amount__c;
            }

            //puts in the employeeId into the map if it's not already in there.
            if (!employeeTotalsMap.containsKey(employeeId)) {                                                              //BLOCK C
                employeeTotalsMap.put(employeeId, new Map<String, AggregateData>());
            }
                                                                                                                            
        Map<String,AggregateData> insuranceProviderMap = employeeTotalsMap.get(employeeId);                                //BLOCK D
        
            if (insuranceProvider == null) {
                continue;
            }

            if (!insuranceProviderMap.containsKey(insuranceProvider) && insuranceProvider != null) {
                insuranceProviderMap.put(insuranceProvider, new AggregateData());
            }

            AggregateData agg = insuranceProviderMap.get(insuranceProvider);
            agg.totalClaims++;
            agg.totalSettlement += settlementAmount;

            System.debug('employeeclaimMapLooop1:::' + employeeId);
            System.debug('employeeclaimMapLooop1:::' + insuranceProvider);
            System.debug('employeeclaimMapLooop1:::' + settlementAmount);

        }
                                                      
        List <Employee__c> employeeUpdate = [SELECT Id, Risk_Level__c, Risk_Level_Summary__c, Total_Claims__c, Total_Settlement_Amount__c       //BLOCK E
        FROM Employee__c WHERE Id IN :employeeTotalsMap.keySet()];

            System.debug('employeeUpdateList:::' + employeeUpdate);


        for (Employee__c emp : employeeUpdate) {
                                                                                                                            
                Map<String,AggregateData> insuranceProviderMap = employeeTotalsMap.get(emp.Id);                                                 //BLOCK F

                for (String insuranceProvider : insuranceProviderMap.keySet()) {
                    AggregateData agg = insuranceProviderMap.get(insuranceProvider);

                    System.debug('Insurance Provider and Employee :::' + insuranceProvider + ', ' + emp);

                    emp.Risk_Level__c = riskLevelCalculation(agg);
                    emp.Total_Claims__c = agg.totalClaims;
                    emp.Total_Settlement_Amount__c = agg.totalSettlement;

                    emp.Risk_Level_Summary__c = riskLevelSummarygeneration(insuranceProvider, agg);
                    System.debug('Risk Level Summary loop:::' + emp.Risk_Level_Summary__c);
                    
                }
            }
                 System.debug('END:: ' + employeeUpdate);
        update employeeUpdate;
        }

    
////////////////////////////////////HELPER METHODS///////////////////////////////////////////

//Context - creates set of EmployeeIds from list.

Public static Set<Id> generateEmployeeIdsSet (List<Employee_Claim__c> employeeClaims){
    
    Set<Id> employeeIds = new Set<Id>();
    for (Employee_Claim__c empClaim : employeeClaims) {
        if (!employeeIds.contains(empClaim.Employee__c)) {
            employeeIds.add(empClaim.Employee__c);
        }
    }

System.debug('HELPER 1: ' + employeeIds);
    return employeeIds;
}


//Context - calculates risk level
    Public static String riskLevelCalculation (AggregateData agg){
        String riskLevel;
        
        //if total claims are greater than OR equals to defined highrisk values, set to high risk.
        if (agg.totalClaims >= highRiskTotalClaims || agg.totalSettlement >= highRiskTotalSettlements ) {
            riskLevel = 'High Risk';
        }

        // if total claims falls within range of either defined mediumRisk values, set to medium risk
        if ( (agg.totalClaims >= mediumRiskTotalClaims && agg.totalClaims < highRiskTotalClaims) || (agg.totalSettlement >= mediumRiskTotalSettlements && agg.totalSettlement < highRiskTotalSettlements)) {
            riskLevel = 'Medium Risk';
        }

        // if total claims falls below defined medium risk values, set to standard risk.
        if ((agg.totalClaims >= lowRiskTotalClaims && agg.totalClaims < mediumRiskTotalClaims) || (agg.totalSettlement >= lowRiskTotalSettlements && agg.totalSettlement < mediumRiskTotalSettlements)) {
            riskLevel = 'Standard Risk';
        }

System.debug('HELPER 2: ' + riskLevel);
        return riskLevel;
    }

//Context - generates riskLevelSummary value for employee record.
    Public static String riskLevelSummarygeneration (String insuranceProvider, AggregateData agg){
        String risklevelSummary ='';
        risklevelSummary +=
        'Insurance Provider: ' + insuranceProvider + '\n' +
        'Total Claims: ' + agg.totalClaims + '\n' +
        'Total Settlement: $' + agg.totalSettlement + '\n\n';

System.debug('HELPER 3: ' + risklevelSummary);
        return risklevelSummary;
    }
    
}

