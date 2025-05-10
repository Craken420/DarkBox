/**
 * @file array/index.js
 * @fileoverview Utility functions for working with arrays.
 * Includes tools for comparing, filtering, finding differences, and analyzing array contents.
 * 
 * @module arrays
 */

import * as R from 'ramda';

/**
 * Splits an array into chunks of a given size.
 * @param {Array} array - The array to split.
 * @param {number} size - The maximum size of each chunk.
 * @returns {Array[]} An array of chunks (sub-arrays).
 */
const chunk = (array, size) => {
  if (size <= 0) {
    throw new Error('Size must be a positive number.');
  }
  const chunks = [];
  for (let i = 0; i < array.length; i += size) {
    chunks.push(array.slice(i, i + size));
  }
  return chunks;
}

/**
 * Returns the symmetric difference between two arrays.
 * Example: diff(['a', 'b'], ['a', 'b', 'c']) => ['c']
 * 
 * @param {Array} arr1 
 * @param {Array} arr2 
 * @returns {Array}
 */
const diff = (arr1, arr2) => {
    const a = {};
    const diff = [];
  
    for (let i = 0; i < arr1.length; i++) {
      a[arr1[i]] = true;
    }
  
    for (let i = 0; i < arr2.length; i++) {
      if (a[arr2[i]]) {
        delete a[arr2[i]];
      } else {
        a[arr2[i]] = true;
      }
    }
  
    for (let k in a) {
      diff.push(k);
    }
  
    return diff;
}

/**
 * Checks if the provided value is an array.
 *
 * @param {*} val - The value to check.
 * @returns {boolean}
 */
const isArray = R.pipe(
    Object.getPrototypeOf,
    R.equals([])
);

/**
 * Remove all falsy values from an array.
 * @param {Array} arr - The input array to filter.
 * @returns {Array} - New array with falsy values removed.
 */
const removeAllFalsy = (arr) => arr.filter(Boolean);

/**
 * Returns a new array containing only the unique values from the input array.
 * @param {Array} array - The array to filter for unique values.
 * @returns {Array} A new array with duplicates removed.
 */
const unique = (array) => Array.from(new Set(array));

export {
  chunk,
  diff,
  isArray,
  removeAllFalsy,
  unique,
};