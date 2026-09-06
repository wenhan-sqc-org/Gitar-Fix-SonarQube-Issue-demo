package com.example.demo;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;

import org.junit.jupiter.api.Test;

class InventoryTest {

    @Test
    void unknownCodeHasNoStock() {
        assertEquals(0, new Inventory().unitsOnHand("SKU-1"));
    }

    @Test
    void receivedUnitsAccumulate() {
        Inventory inventory = new Inventory();

        inventory.receive("SKU-1", 4);
        inventory.receive("SKU-1", 6);
        inventory.receive("SKU-2", 1);

        assertEquals(10, inventory.unitsOnHand("SKU-1"));
        assertEquals(1, inventory.unitsOnHand("SKU-2"));
    }

    @Test
    void nonPositiveReceiptIsRejected() {
        Inventory inventory = new Inventory();

        assertThrows(IllegalArgumentException.class, () -> inventory.receive("SKU-1", 0));
    }
}
