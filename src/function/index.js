/**
 * @fileoverview Higher-order utilities and function wrappers.
 * Contains functions that operate on or return other functions, enabling composition,
 * currying, memoization, and other functional programming patterns.
 * Ideal for enhancing modularity and reusability in JavaScript applications.
 * 
 * @module function
 */

import * as rgx from '../regex/index';

/**
 * Checks if 'expr' is a function.
 * @param {any} expr 
 * @returns {boolean} 
 */
const isFunction = expr => {
  return typeof expr === 'function';
}

/**
 * Gets the function parameter names as an Array.
 * Usage example: getParameterNames(function (a,b,c){}); // ['a','b','c']
 * @param {Function} func The function whose parameters to extract.
 * @returns {Array} An ordered array of string with the parameters names, or an empty array if the function has no parameters.
 */
const getParameterNames = func => {
  const fnStr = func.toString().replace(rgx.stripComments, '');
  const result = fnStr.slice(fnStr.indexOf('(') + 1, fnStr.indexOf(')')).match(rgx.argumentNames);
  return result === null ? [] : result;
}

/**
 * Gets the function name.
 * @param {Function} func The function whose name to retrieve.
 * @returns {string} The name of the function, or an empty string if it is an anonymous function.
 */
const getFunctionName = func => {
  if (!isFunction(func)) throw new TypeError('"func" must be a function.');

  // ECMAScript 2015
  if (func.name) {
    return func.name;
  }

  // Old-fashioned way
  const fnStr = func.toString().substr('function '.length);
  const result = fnStr.substr(0, fnStr.indexOf('('));
  return result;
}

/**
 * Creates a debounced function that delays invoking the original function until after wait milliseconds.
 * @param {Function} fn - The original function to debounce.
 * @param {number} wait - The delay in milliseconds.
 * @returns {Function} A new debounced function.
 */
const debounce = (fn, wait) => {
  if (typeof fn !== 'function' || typeof wait !== 'number') {
    throw new TypeError('Invalid arguments for debounce');
  }
  let timeoutId;
  return function(...args) {
    clearTimeout(timeoutId);
    timeoutId = setTimeout(() => fn.apply(this, args), wait);
  };
}

// Exports
module.exports = {
  isFunction,
  getFunctionName,
  getParameterNames,
  debounce
};
