/**
 * @file function/index.js
 * @fileoverview Higher-order utilities and function wrappers.
 * Contains functions that operate on or return other functions, enabling composition,
 * currying, memoization, and other functional programming patterns.
 * Ideal for enhancing modularity and reusability in JavaScript applications.
 * 
 * @module function
 */
import * as rgx from '../regex/index';

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

/*
 * Compare two objects by reducing an array of keys in obj1, having the
 * keys in obj2 as the intial value of the result. Key points:
 *
 * - All keys of obj2 are initially in the result.
 *
 * - If the loop finds a key (from obj1, remember) not in obj2, it adds
 *   it to the result.
 *
 * - If the loop finds a key that are both in obj1 and obj2, it compares
 *   the value. If it's the same value, the key is removed from the result.
 */
function diff(obj1, obj2) {
    const diff = Object.keys(obj1).reduce((result, key) => {
        if (!obj2.hasOwnProperty(key)) {
            result.push(key);
        } else if (isEqual(obj1[key], obj2[key])) {
            const resultKeyIndex = result.indexOf(key);
            result.splice(resultKeyIndex, 1);
        }
        return result;
    }, Object.keys(obj2));

    return diff;
}

/**
 * Applies two alternative functions and returns the first truthy result.
 *
 * @param {Function} fn1 - First function to try.
 * @param {Function} fn2 - Fallback function.
 * @param {*} val - The value to process.
 * @returns {*} - First non-falsy result.
 */
const eitherFn = R.curry((fn1, fn2, val) => fn1(val) || fn2(val));

/**
 * Applies two functions to the same input and joins their result with a third function.
 * Great for combining parallel operations.
 *
 * @param {Function} fnJoin - Function to merge the results.
 * @param {Function} fn1 - First function to apply.
 * @param {Function} fn2 - Second function to apply.
 * @returns {Function}
 */
const fork = (fnJoin, fn1, fn2) => val => fnJoin(fn1(val), fn2(val));

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
 * Checks if 'expr' is a function.
 * @param {any} expr 
 * @returns {boolean} 
 */
const isFunction = expr => {
  return typeof expr === 'function';
}

/**
 * Executes a sequence of functions using the same input.
 * Primarily used for side effects.
 *
 * @param {...Function} funcs - The functions to run.
 * @returns {Function}
 */
const pipeEach = function () {
    const funcs = Array.prototype.slice.call(arguments);
    return function (val) {
        funcs.forEach(function (fn) {
            fn(val)
        });
    }
}

/**
 * Tuple type constructor for immutable fixed-size records with runtime type checks.
 *
 * @param {...Function} typeInfo - List of type-checking functions.
 * @returns {Function} - A constructor for that Tuple type.
 */
const tuple = function (...typeInfo) {
    const T = function (...values) {
        if (values.some(val => val === null || val === undefined)) {
            throw new ReferenceError('Tuples may not contain null or undefined values.');
        }

        if (values.length !== typeInfo.length) {
            throw new TypeError('Tuple arity does not match type definition.');
        }

        values.forEach((val, index) => {
            this[`_${index + 1}`] = checkType(typeInfo[index])(val);
        });

        Object.freeze(this);
    };

    /**
     * Returns the values stored in the tuple.
     *
     * @returns {Array<*>}
     */
    T.prototype.values = function () {
        return Object.values(this);
    };

    return T;
};

export {
  debounce,
  eitherFn,
  fork,
  getFunctionName,
  getParameterNames,
  isFunction,
  pipeEach,
  tuple
};