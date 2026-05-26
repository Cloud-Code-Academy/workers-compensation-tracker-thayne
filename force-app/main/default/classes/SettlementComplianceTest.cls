/**
 * =========================================================
 * SETTLEMENT COMPLIANCE TEST CLASS
 * =========================================================
 *
 * Unit test class for validating settlement compliance
 * rules enforced during claim lifecycle processing.
 *
 * This class verifies that claims cannot transition
 * to Settled status unless a valid settlement amount
 * is provided.
 *
 * ---------------------------------------------------------
 * BUSINESS PURPOSE
 * ---------------------------------------------------------
 *
 * Settlement amounts represent the financial resolution
 * of an insurance claim.
 *
 * Invalid settlement values may cause:
 *
 * - inaccurate financial reporting
 * - audit inconsistencies
 * - compliance violations
 * - incorrect payout calculations
 * - unreliable analytics
 *
 * These validation rules ensure that claims marked
 * as Settled always contain meaningful payout data.
 *
 * ---------------------------------------------------------
 * ACCEPTANCE CRITERIA
 * ---------------------------------------------------------
 *
 * A claim CANNOT move to:
 *
 *     Status__c = 'Settled'
 *
 * when:
 *
 *     Settlement_Amount__c = null
 *
 * OR
 *
 *     Settlement_Amount__c = 0
 *
 * Additional validation may also prevent:
 *
 *     Settlement_Amount__c < 0
 *
 * A claim CAN move to Settled when:
 *
 *     Settlement_Amount__c > 0
 *
 * ---------------------------------------------------------
 * TEST COVERAGE AREAS
 * ---------------------------------------------------------
 *
 * This class validates:
 *
 * ✔ Null settlement amount validation
 * ✔ Zero settlement amount validation
 * ✔ Positive settlement amount success
 * ✔ Negative settlement amount edge cases
 * ✔ Bulk settlement validation behavior
 * ✔ Validation exception handling
 * ✔ Partial-save bulk processing
 *
 * ---------------------------------------------------------
 * NULL SETTLEMENT VALIDATION TESTING
 * ---------------------------------------------------------
 *
 * Claims should fail validation when:
 *
 * - Status__c = 'Settled'
 * - Settlement_Amount__c = null
 *
 * These tests confirm:
 *
 * - DML operations fail correctly
 * - validation messages appear properly
 * - settlement requirements are enforced
 *
 * ---------------------------------------------------------
 * ZERO SETTLEMENT VALIDATION TESTING
 * ---------------------------------------------------------
 *
 * Claims should fail validation when:
 *
 * - Status__c = 'Settled'
 * - Settlement_Amount__c = 0
 *
 * These tests validate:
 *
 * - zero-dollar settlements are rejected
 * - business-rule enforcement works correctly
 *
 * ---------------------------------------------------------
 * POSITIVE SETTLEMENT TESTING
 * ---------------------------------------------------------
 *
 * Claims with valid payout amounts should:
 *
 * - update successfully
 * - transition to Settled status
 * - retain settlement values correctly
 *
 * These tests validate successful lifecycle behavior.
 *
 * ---------------------------------------------------------
 * NEGATIVE VALUE EDGE CASE TESTING
 * ---------------------------------------------------------
 *
 * Negative settlement amounts represent invalid
 * financial data.
 *
 * These tests validate:
 *
 * - defensive validation logic
 * - improper financial values are blocked
 * - exception handling works correctly
 *
 * ---------------------------------------------------------
 * BULKIFICATION VALIDATION
 * ---------------------------------------------------------
 *
 * Bulk tests ensure automation:
 *
 * - validates multiple records independently
 * - supports partial-save processing
 * - handles mixed-validity datasets
 * - remains governor-limit safe
 *
 * Database.update(records, false) is used
 * to confirm partial-success behavior.
 *
 * ---------------------------------------------------------
 * ERROR HANDLING VALIDATION
 * ---------------------------------------------------------
 *
 * Exception testing confirms:
 *
 * - DmlException is thrown correctly
 * - validation messages are meaningful
 * - trigger addError() logic executes properly
 *
 * ---------------------------------------------------------
 * TESTING STRATEGY
 * ---------------------------------------------------------
 *
 * This class follows Apex testing best practices:
 *
 * - isolated test methods
 * - reusable TestDataFactory helpers
 * - positive and negative testing
 * - edge-case validation
 * - bulk-processing validation
 * - exception verification
 *
 * ---------------------------------------------------------
 * DEPENDENCIES
 * ---------------------------------------------------------
 *
 * This class depends on:
 *
 * - Claim__c object
 * - settlement compliance validation logic
 * - claim lifecycle automation
 * - TestDataFactory helper methods
 *
 * ---------------------------------------------------------
 * EXPECTED AUTOMATION BEHAVIOR
 * ---------------------------------------------------------
 *
 * The tested automation is expected to:
 *
 * - block settled claims with null payouts
 * - block settled claims with zero payouts
 * - optionally block negative payouts
 * - allow valid positive payouts
 * - support bulk operations safely
 * - provide meaningful validation messages
 * - maintain financial data integrity
 *
 * ---------------------------------------------------------
 * NOTES
 * ---------------------------------------------------------
 *
 * - This class uses @IsTest and does not count
 *   against Apex organization storage limits.
 *
 * - Tests execute in isolated transactions and do not
 *   access production organization data.
 *
 * - Assertions validate both technical correctness
 *   and business-rule enforcement.
 *
 * =========================================================
 */
@IsTest
private class SettlementComplianceTest {

    /*
     * =========================================================
     * NULL SETTLEMENT AMOUNT TESTS
     * =========================================================
     */

    /**
     * Verifies validation prevents claims
     * from being settled with null settlement amount.
     */
    @IsTest
    static void testSettledStatusFailsWithNullSettlementAmount() {

        Claim__c claim =
            TestDataFactory.createOpenClaim();

        insert claim;

        claim.Status__c = 'Settled';
        claim.Settlement_Amount__c = null;

        Test.startTest();

        try {

            update claim;

            System.assert(
                false,
                'Expected validation error for null settlement amount'
            );

        } catch (DmlException e) {

            System.assert(
                e.getMessage().contains('Settlement'),
                'Validation message should reference settlement amount'
            );
        }

        Test.stopTest();
    }

    /*
     * =========================================================
     * ZERO SETTLEMENT AMOUNT TESTS
     * =========================================================
     */

    /**
     * Verifies validation prevents claims
     * from being settled with zero settlement amount.
     */
    @IsTest
    static void testSettledStatusFailsWithZeroSettlementAmount() {

        Claim__c claim =
            TestDataFactory.createOpenClaim();

        insert claim;

        claim.Status__c = 'Settled';
        claim.Settlement_Amount__c = 0;

        Test.startTest();

        try {

            update claim;

            System.assert(
                false,
                'Expected validation error for zero settlement amount'
            );

        } catch (DmlException e) {

            System.assert(
                e.getMessage().contains('Settlement'),
                'Validation message should reference settlement amount'
            );
        }

        Test.stopTest();
    }

    /*
     * =========================================================
     * POSITIVE SETTLEMENT TESTS
     * =========================================================
     */

    /**
     * Verifies valid settlement amount
     * allows claim to be settled successfully.
     */
    @IsTest
    static void testSettledStatusSucceedsWithValidSettlementAmount() {

        Claim__c claim =
            TestDataFactory.createOpenClaim();

        insert claim;

        claim.Status__c = 'Settled';
        claim.Settlement_Amount__c = 5000;

        Test.startTest();
        update claim;
        Test.stopTest();

        Claim__c updatedClaim = [
            SELECT
                Status__c,
                Settlement_Amount__c
            FROM Claim__c
            WHERE Id = :claim.Id
        ];

        System.assertEquals(
            'Settled',
            updatedClaim.Status__c,
            'Claim should successfully move to Settled status'
        );

        System.assertEquals(
            5000,
            updatedClaim.Settlement_Amount__c,
            'Settlement amount should save correctly'
        );
    }

    /*
     * =========================================================
     * NEGATIVE VALUE EDGE CASE TESTS
     * =========================================================
     */

    /**
     * Verifies negative settlement amounts
     * are blocked if validation rules exist.
     */
    @IsTest
    static void testSettledStatusFailsWithNegativeSettlementAmount() {

        Claim__c claim =
            TestDataFactory.createOpenClaim();

        insert claim;

        claim.Status__c = 'Settled';
        claim.Settlement_Amount__c = -100;

        Test.startTest();

        try {

            update claim;

            System.assert(
                false,
                'Expected validation error for negative settlement amount'
            );

        } catch (DmlException e) {

            System.assert(
                true,
                'Negative settlement validation triggered successfully'
            );
        }

        Test.stopTest();
    }

    /*
     * =========================================================
     * BULK VALIDATION TESTS
     * =========================================================
     */

    /**
     * Verifies bulk updates enforce
     * settlement validation consistently.
     */
    @IsTest
    static void testBulkSettlementComplianceValidation() {

        List<Claim__c> claims =
            TestDataFactory.createBulkClaims(3, 1000);

        insert claims;

        claims[0].Status__c = 'Settled';
        claims[0].Settlement_Amount__c = null;

        claims[1].Status__c = 'Settled';
        claims[1].Settlement_Amount__c = 0;

        claims[2].Status__c = 'Settled';
        claims[2].Settlement_Amount__c = 5000;

        Test.startTest();

        Database.SaveResult[] results =
            Database.update(claims, false);

        Test.stopTest();

        System.assertEquals(
            false,
            results[0].isSuccess(),
            'Null settlement amount should fail validation'
        );

        System.assertEquals(
            false,
            results[1].isSuccess(),
            'Zero settlement amount should fail validation'
        );

        System.assertEquals(
            true,
            results[2].isSuccess(),
            'Valid settlement amount should succeed'
        );
    }
}
