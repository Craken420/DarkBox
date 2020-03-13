const R = require('ramda')
const { fnNums } = require('./fnNums')

module.exports.fnObj = (function () {
    const _objToTxtVBeta = entryObj => {

        const objToTxt = R.pipe(
            R.toPairs,
            R.map(R.join('\n')),
            R.join('\n')
        )    

        const multiObjsToTxt = val => {
    
            if ( isObj(val) ) {
        
                if ( hasArray(val) ) {
                    val = R.map(arrayToText, val)
                }
        
                if ( hasntObj(val) ) {
                    val = objToTxt(val)
                } else {
                    val = deepObjToTxt(val)
                }
        
            } else if ( isArray(val) ) {
                val = arrayToText(val)
            } else {
                val = val
            }
            return val
        }

        const arrayToText = val => {
            if ( isArray(val) ) {
                if ( hasntArray(val) && hasntObj(val) ) {
                    val = val.join('\n')
                } else if ( hasObj(val) ) {
                    val = deepObjToTxt(val)
                } else if ( hasArray(val) ) {
                    val = R.map(arrayToText, val)
                } else {
                    val = val
                }
            } else if ( hasObj(val) ) {
                val = deepObjToTxt(val)
            } else {
                val = val
            }
        
            return val
        }    
        //----------------------------------------------------
        const deepObjToTxt = entryObj => {
            let obj = R.clone(entryObj)
        
            if ( hasObj(obj) ) {
                obj = R.map(multiObjsToTxt, obj)
            }
        
            if ( hasArray(obj) ) {
                obj = R.map(arrayToText, obj)
            }
        
            if ( hasObj(obj) && hasArray(val) ) {
                deepObjToTxt(obj)
            } else {
                return objToTxt(obj)
            }
        }

        return {
            objToTxt,
            multiObjsToTxt,
            arrayToText,
            deepObjToTxt
        }
    }

    const _isObj = R.pipe(
        R.clone,
        Object.getPrototypeOf,
        R.equals({})
    )

    const _isArray = R.pipe(
        Object.getPrototypeOf,
        R.equals([])
    )

    const _hasObj = objEntry => {
        let obj = R.clone(objEntry)
        for (key in obj ) {
            if (isObj(obj[key])) {
                return true
            }
        }
        return false
    }

    const _hasArray = objEntry => {
        let obj = R.clone(objEntry)
        for (key in obj ) {
            if (isArray(obj[key])) {
                return true
            }
        }
        return false
    }
    
    const _hasntObj = R.complement(hasObj)
    const _hasntArray = R.complement(hasArray)
    const _isntObj = R.complement(isObj)
    const _isntArray = R.complement(isArray)

    const _toQuote = pVal => ( pVal == null ) 
                                ? 'Object:null'
                                : ( R.is(Object, pVal) )
                                    ? R.map(toQuote, pVal)
                                    : ( typeof(pVal) == 'string' )
                                        ? ( !R.test(/\"/g, pVal) ) 
                                            ? '\"' + pVal + '\"' 
                                            : pVal 
                                        : pVal
                                        
    const _objToTxt = obj => {
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

    const _inObjPairs = entryObj => {
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

    const _objToSqlInserLine = obj => (function (obj) {
        
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

    function objToTxt          (obj) { return _objToTxt(obj)            }
    function objToSqlInserLine (obj) { return _objToSqlInserLine(obj)   }
    function objToTxtVBeta     (val) { return _objToTxtVBeta(val)       }
    function isObj             (val) { return _isObj(val)               }
    function hasObj            (val) { return _hasObj(val)              }
    function hasArray          (val) { return _hasArray(val)            }
    function hasntObj          (val) { return _hasntObj(val)            }
    function hasntArray        (val) { return _hasntArray(val)          }
    function isntObj           (val) { return _isntObj(val)             }
    function isntArray         (val) { return _isntArray(val)           }
    function isArray           (val) { return _isArray(val)             }
    function inObjPairs        (val) { return _inObjPairs(val)          }
    function toQuote           (val) { return _toQuote(val)             }

    return {
        objToTxt,
        isObj,
        hasObj,
        hasArray,
        isntObj,
        isntArray,
        hasntObj,
        hasntArray,
        isArray,
        objToTxtVBeta,
        objToSqlInserLine,
        inObjPairs,
        toQuote
    }
})();
