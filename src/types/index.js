/**
 * @fileoverview Type definitions and structural contracts for application components.
 * This file provides reusable types and interfaces to ensure consistency and type safety.
 * Ideal for projects using TypeScript or JSDoc with JavaScript for better developer tooling.
 * 
 * @module types
 */


/**
 * Check if a number is odd.
 * @param {number} val - The value to check.
 * @returns {boolean} - True if the value is an odd number, false otherwise.
 */
const isOdd = (val) => (Number.isInteger(val) ? val % 2 !== 0 : false);

// Exports
module.exports = {
    isOdd
};
  