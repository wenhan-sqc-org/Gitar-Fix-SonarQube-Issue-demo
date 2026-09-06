package com.example.demo;

import java.util.Objects;

/**
 * Immutable identifier for a stocked article in a given warehouse.
 */
public final class StockKeepingUnit {

    private final String code;
    private final String warehouse;

    public StockKeepingUnit(String code, String warehouse) {
        this.code = code;
        this.warehouse = warehouse;
    }

    public String code() {
        return code;
    }

    public String warehouse() {
        return warehouse;
    }

    @Override
    public boolean equals(Object other) {
        if (this == other) {
            return true;
        }
        if (!(other instanceof StockKeepingUnit that)) {
            return false;
        }
        return Objects.equals(code, that.code)
                && Objects.equals(warehouse, that.warehouse);
    }

    @Override
    public int hashCode() {
        return Objects.hash(code, warehouse);
    }
}
