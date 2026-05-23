/**
 * Unit tests for ClaimTriggerHandler.validateIncidentDate().
 *
 * Validates:
 * - Claims cannot be saved with future Incident_Date__c values
 * - Valid incident dates are accepted
 * - Bulk validation works correctly
 */
@isTest
private class IntakeValidationTest {

    /*
     * =========================================================
     * FUTURE DATE VALIDATION TESTS
     * =========================================================
     */

    /**
     * Verifies validation prevents inserting
     * claims with future incident dates.
     */
    @isTest
    static void testFutureIncidentDateFailsValidation() {

        Claim__c claim =
            TestDataFactory.createOpenClaim();

        claim.Incident_Date__c =
            Date.today().addDays(5);

        Test.startTest();

        try {

            insert claim;

            System.assert(
                false,
                'Expected validation error for future incident date'
            );

        } catch (DmlException e) {

            System.assert(
                e.getMessage().contains(
                    'Incident Date cannot be in the future'
                ),
                'Validation message should match trigger error'
            );
        }

        Test.stopTest();
    }

    /*
     * =========================================================
     * VALID DATE TESTS
     * =========================================================
     */

    /**
     * Verifies claims save successfully
     * when incident date is today.
     */
    @isTest
    static void testTodayIncidentDateSucceeds() {

        Claim__c claim =
            TestDataFactory.createOpenClaim();

        claim.Incident_Date__c =
            Date.today();

        Test.startTest();
        insert claim;
        Test.stopTest();

        Claim__c insertedClaim = [
            SELECT Incident_Date__c
            FROM Claim__c
            WHERE Id = :claim.Id
        ];

        System.assertEquals(
            Date.today(),
            insertedClaim.Incident_Date__c,
            'Today should be accepted as valid incident date'
        );
    }

    /**
     * Verifies claims save successfully
     * when incident date is in the past.
     */
    @isTest
    static void testPastIncidentDateSucceeds() {

        Claim__c claim =
            TestDataFactory.createOpenClaim();

        claim.Incident_Date__c =
            Date.today().addDays(-10);

        Test.startTest();
        insert claim;
        Test.stopTest();

        Claim__c insertedClaim = [
            SELECT Incident_Date__c
            FROM Claim__c
            WHERE Id = :claim.Id
        ];

        System.assertEquals(
            Date.today().addDays(-10),
            insertedClaim.Incident_Date__c,
            'Past dates should be accepted'
        );
    }

    /*
     * =========================================================
     * NULL DATE TESTS
     * =========================================================
     */

    /**
     * Verifies null incident dates
     * do not trigger validation logic.
     */
    @isTest
    static void testNullIncidentDateSucceeds() {

        Claim__c claim =
            TestDataFactory.createOpenClaim();

        claim.Incident_Date__c = null;

        Test.startTest();
        insert claim;
        Test.stopTest();

        Claim__c insertedClaim = [
            SELECT Incident_Date__c
            FROM Claim__c
            WHERE Id = :claim.Id
        ];

        System.assertEquals(
            null,
            insertedClaim.Incident_Date__c,
            'Null incident dates should be allowed by handler'
        );
    }

    /*
     * =========================================================
     * BULK VALIDATION TESTS
     * =========================================================
     */

    /**
     * Verifies bulk inserts correctly validate
     * future incident dates while allowing valid records.
     */
    @isTest
    static void testBulkIncidentDateValidation() {

        List<Claim__c> claims =
            new List<Claim__c>();

        Claim__c validClaim =
            TestDataFactory.createOpenClaim();

        validClaim.Incident_Date__c =
            Date.today();

        claims.add(validClaim);

        Claim__c invalidClaim =
            TestDataFactory.createOpenClaim();

        invalidClaim.Incident_Date__c =
            Date.today().addDays(3);

        claims.add(invalidClaim);

        Test.startTest();

        Database.SaveResult[] results =
            Database.insert(claims, false);

        Test.stopTest();

        System.assertEquals(
            true,
            results[0].isSuccess(),
            'Valid claim should insert successfully'
        );

        System.assertEquals(
            false,
            results[1].isSuccess(),
            'Future incident date should fail validation'
        );

        System.assert(
            results[1].getErrors()[0]
                .getMessage()
                .contains('Incident Date cannot be in the future'),
            'Bulk validation should return correct error message'
        );
    }

    /*
     * =========================================================
     * UPDATE VALIDATION TESTS
     * =========================================================
     */

    /**
     * Verifies updates cannot change
     * incident dates into the future.
     */
    @isTest
    static void testUpdateFutureIncidentDateFails() {

        Claim__c claim =
            TestDataFactory.createOpenClaim();

        claim.Incident_Date__c =
            Date.today();

        insert claim;

        claim.Incident_Date__c =
            Date.today().addDays(7);

        Test.startTest();

        try {

            update claim;

            System.assert(
                false,
                'Expected validation failure during update'
            );

        } catch (DmlException e) {

            System.assert(
                e.getMessage().contains(
                    'Incident Date cannot be in the future'
                ),
                'Update validation should enforce future-date restriction'
            );
        }

        Test.stopTest();
    }
}