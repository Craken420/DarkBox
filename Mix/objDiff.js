var isEqual = require('lodash.isequal');

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
function getObjectDiff(obj1, obj2) {
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

// Here's an example output:

// Test
let obj1 = {
    a: 1,
    b: 2,
    c: { foo: 1, bar: 2},
    d: { baz: 1, bat: 2 }
}

let obj2 = {
    b: 2, 
    c: { foo: 1, bar: 'monkey'}, 
    d: { baz: 1, bat: 2 },
    e: 1
}
console.log(getObjectDiff(obj1, obj2))
// ["c", "e", "a"]