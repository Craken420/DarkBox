/**
 * @file objects/index.js
 * @fileoverview Utility functions for working with JavaScript objects.
 * Provides tools for inspecting, transforming, and deeply comparing plain or nested objects.
 * 
 * @module objects
 */

/**
 * Recursively freezes an object and all of its nested structures.
 * This is useful for immutability enforcement.
 *
 * @param {*} obj - The object to deep freeze.
 * @returns {*} - The deeply frozen object.
 */
const deepFreeze = obj => {
    if (isObject(obj) && !Object.isFrozen(obj)) {
        Object.keys(obj).forEach(name => deepFreeze(obj[name]));
        Object.freeze(obj);
    }
    return obj;
};

/** Returns true if the object does NOT contain any array. */
const hasntArray = R.complement(hasArray);

/**
 * Checks whether an object contains at least one nested object.
 *
 * @param {Object} objEntry - The object to inspect.
 * @returns {boolean}
 */
const hasObj = objEntry => {
    let obj = R.clone(objEntry);
    for (const key in obj) {
        if (isObj(obj[key])) return true;
    }
    return false;
};

/** Returns true if the object does NOT contain any nested object. */
const hasntObj = R.complement(hasObj);

/**
 * Converts a flat array into an object using alternating key/value pairs.
 * If input is already an object, it's returned as-is.
 *
 * @param {Array|Object} entryObj - Array or object to convert.
 * @returns {Object}
 */
const inObjPairs = entryObj => {
    const twoInPairs = val => {
        if ( isArray(val) && hasntArray(val) ) {
            let endObj = {}
            let arx = R.clone(val)
            for (let i = 0; i <=  R.length(arx); i++) {
                if ( !fnNums.isOdd(i) ) 
                    if ( arx[i+1] != undefined  ) {
                        if ( R.is(Object, arx[i]) ) {
                            endObj = R.assoc( i, arx[i], endObj)
                            endObj = R.assoc( i + 1, arx[i+1], endObj)
                        } else if ( typeof(arx[i]) == 'string' )
                            endObj = R.assoc( R.replace(/\"/g, '', arx[i]), arx[i+1], endObj)
                        else
                            endObj = R.assoc( arx[i], arx[i+1], endObj)
                        

                    } else if ( arx[i] != undefined )
                        if ( isObj(arx[i]) )
                            endObj = R.assoc( i,arx[i], endObj)
                        else if ( typeof(arx[i]) == 'string' )
                            endObj = R.assoc( R.replace(/\"/g, '', arx[i]), '\"\"', endObj)
                        else
                            endObj = R.assoc( arx[i], '\"\"', endObj)
            }
            return endObj
        } else 
            return val
    } 

    const isEmpty = val => ( R.isEmpty(val) ) ? {} : val
    const whenHasArray = val => ( hasArray(val) ) ? R.map(opp, val) : val
    const opp = R.pipe( R.clone, isEmpty, whenHasArray, twoInPairs )

    return opp(entryObj)
}

/**
 * Determines whether the provided value is a plain object (not an array or function).
 *
 * @param {*} val - The value to check.
 * @returns {boolean}
 */
const isObj = R.pipe(
    R.clone,
    Object.getPrototypeOf,
    R.equals({})
);

/** Returns true if the value is NOT an array. */
const isntArray = R.complement(isArray);

/** Returns true if the value is NOT a plain object. */
const isntObj = R.complement(isObj);

/**
 * Converts a flat object or array into a SQL `INSERT INTO` line.
 * Useful for quick prototyping or static inserts.
 *
 * @param {Object|Array} obj - The data to convert.
 * @returns {string|null} SQL insert line or null if unsupported structure.
 */
const objToSqlInserLine = obj => (function (obj) {
    
    const getHead = R.pipe(
        R.keys,
        R.uniq,
        R.join(', '),
        R.replace(/^/g, 'INSERT INTO TblName ('),
        R.replace(/$/g, ') VALUES (')
    )

    const getBody = R.pipe(
        R.map(x => {
            let newval = '' 

            if ( typeof(x) == 'object' ) 
                if (x == null) 
                    newval = 'null'
                else
                    newval = '\'' + R.replace( /\n/g, ', ', objToTxt(x) ) + '\''
            else if ( typeof(x) == 'string' )
                newval =  '\'' + x + '\''
            else newval = x

            return newval
        }),
        R.valuesIn,R.join(', '),
        R.replace(/$/g, ');')
    )

    const toLine = obj => getHead(obj) + getBody(obj);

    const get = obj => {
        if ( typeof(obj) == 'object' && !R.isEmpty(obj) && !R.isNil(obj) )
            if ( isArray(obj) && ( hasArray(obj) || hasObj(obj) ) )
                return R.uniq( R.map(get, obj ) )
            else if ( isObj(obj) )
                return toLine(obj)
            else if ( isArray(obj) && ( hasntArray(obj) || hasntObj(obj) ) ) 
                return toLine( inObjPairs(obj) )
            else return null
        else return null
    }

    return get(obj)
})(obj);

/**
 * Converts a flat object into a single-line string in the format:
 * key1:value1, key2:value2...
 *
 * @param {Object} obj - The object to convert.
 * @returns {string}
 */
const objToTxt = obj => {
    const isEmpty = val => ( R.isEmpty(val) ) ? '\"\"' : val
    const someWithArraysToObjPair = val => ( hasArray(val) || isArray(val) ) 
                                            ? inObjPairs(val) : val
    const hasObjAgain = obj => ( hasObj(obj) ) ? toQuoteBeforOpp(obj) : obj
    const objToTxt = R.pipe( toQuote, R.toPairs, R.map( R.join(':') ), R.join(', ') ) 
    const objHasntObjsToTxt = obj => ( isObj(obj) && hasntObj(obj) ) ? objToTxt(obj) : obj
    const opp = R.pipe(isEmpty, someWithArraysToObjPair, hasObjAgain, objHasntObjsToTxt )
    const toQuoteBeforOpp = R.pipe( R.map(toQuote), R.map(opp) )
    const editResult = val => ( typeof(val) == 'string' ) ? R.replace(/\"Object:null\"/g, 'null', val): val
    return editResult( opp(obj) )
}

/**
 * Quotes string values and recursively processes nested structures.
 * Useful for preparing data for display or serialization.
 *
 * @param {*} pVal - The value to quote.
 * @returns {*} - Quoted strings or processed objects/arrays.
 */
const toQuote = pVal =>
    pVal == null
        ? 'Object:null'
        : R.is(Object, pVal)
        ? R.map(toQuote, pVal)
        : typeof pVal === 'string'
        ? !R.test(/\"/g, pVal)
            ? `"${pVal}"`
            : pVal
        : pVal;

export {
    deepFreeze,
    hasntArray,
    hasObj,
    hasntObj,
    inObjPairs,
    isObj,
    isntArray,
    isntObj,
    objToSqlInserLine,
    objToTxt,
    toQuote
};