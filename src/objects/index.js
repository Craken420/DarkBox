/**
 * @fileoverview Utility functions for working with JavaScript objects.
 * Provides tools for inspecting, transforming, and deeply comparing plain or nested objects.
 * 
 * @module objects
 */

/**
 * Check if a value is an object.
 * @param {any} val - The value to check.
 * @returns {boolean} - True if the value is an object, false otherwise.
 */
const isObj = (val) => Object.prototype.toString.call(val) === '[object Object]';

// Exports
module.exports = {
    isObj
};
  