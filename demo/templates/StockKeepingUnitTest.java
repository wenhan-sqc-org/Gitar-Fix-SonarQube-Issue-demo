package com.example.demo;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotEquals;

import org.junit.jupiter.api.Test;

/**
 * These tests pass BEFORE and AFTER Gitar's fix.
 *
 * <p>That is deliberate: the fix only adds {@code hashCode()}, so no observable
 * behaviour changes and the "Build and Test" check stays green throughout. The
 * pull request is therefore blocked purely by the SonarQube quality gate.
 *
 * <p>Note the hashCode test only asserts stability across calls on one instance
 * — true with the inherited identity hash as well. Asserting that two *equal*
 * instances share a hash would fail before the fix and would make the pre-fix
 * failure ambiguous.
 */
class StockKeepingUnitTest {

    @Test
    void exposesTheValuesItWasBuiltWith() {
        StockKeepingUnit sku = new StockKeepingUnit("SKU-1", "BER-01");

        assertEquals("SKU-1", sku.code());
        assertEquals("BER-01", sku.warehouse());
        assertEquals("BER-01/SKU-1", sku.lookupKey());
    }

    @Test
    void equalsComparesCodeAndWarehouse() {
        StockKeepingUnit sku = new StockKeepingUnit("SKU-1", "BER-01");
        StockKeepingUnit sameValues = new StockKeepingUnit("SKU-1", "BER-01");
        StockKeepingUnit otherCode = new StockKeepingUnit("SKU-2", "BER-01");
        StockKeepingUnit otherWarehouse = new StockKeepingUnit("SKU-1", "HAM-02");
        Object notAnSku = "SKU-1";

        assertEquals(sku, sku);
        assertEquals(sku, sameValues);
        assertEquals(sameValues, sku);
        assertNotEquals(sku, otherCode);
        assertNotEquals(sku, otherWarehouse);
        assertNotEquals(sku, notAnSku);
    }

    @Test
    void hashCodeIsStableAcrossCalls() {
        StockKeepingUnit sku = new StockKeepingUnit("SKU-1", "BER-01");

        int firstCall = sku.hashCode();
        int secondCall = sku.hashCode();

        assertEquals(firstCall, secondCall);
    }
}
