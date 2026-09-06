package com.example.demo;

import java.util.LinkedHashMap;
import java.util.Map;

/**
 * Tracks how many units of each article code are currently on hand.
 *
 * <p>This class is the pre-existing, Sonar-clean baseline of the demo. The
 * intentional issue is introduced in a separate class on the demo branch so
 * that every flawed line is "new code" for SonarQube pull request analysis.
 */
public final class Inventory {

    private final Map<String, Integer> unitsOnHand = new LinkedHashMap<>();

    /**
     * Adds stock for the given article code.
     *
     * @param code  article code
     * @param units number of units received, must be positive
     */
    public void receive(String code, int units) {
        if (units <= 0) {
            throw new IllegalArgumentException("units must be positive, was " + units);
        }
        unitsOnHand.merge(code, units, Integer::sum);
    }

    /**
     * @return the units on hand for the given code, or {@code 0} if unknown
     */
    public int unitsOnHand(String code) {
        return unitsOnHand.getOrDefault(code, 0);
    }
}
