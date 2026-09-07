package com.example.demo;

import java.util.Objects;

/**
 * Immutable identifier for a stocked article in a given warehouse.
 *
 * <p>The {@code warehouse/code} lookup key is computed once in the constructor
 * because callers use it as a map key on every read.
 *
 * <p>Demo note: this type is deliberately a class and not a
 * {@code record StockKeepingUnit(String code, String warehouse)}. A record may
 * not declare instance fields beyond its components, so {@code lookupKey} is
 * what keeps SonarQube's java:S6206 ("this class declaration could be a
 * record") from firing. That matters: a record generates {@code hashCode()}
 * automatically, so the java:S1206 issue this demo relies on could not exist,
 * and a fixer could silently resolve it by converting the class to a record.
 * See DEMO.md.
 */
public final class StockKeepingUnit {

    private final String code;
    private final String warehouse;
    private final String lookupKey;

    public StockKeepingUnit(String code, String warehouse) {
        this.code = code;
        this.warehouse = warehouse;
        this.lookupKey = warehouse + "/" + code;
    }

    public String code() {
        return code;
    }

    public String warehouse() {
        return warehouse;
    }

    /**
     * @return the stable {@code warehouse/code} key used for map lookups
     */
    public String lookupKey() {
        return lookupKey;
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
