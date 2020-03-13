const R = require('ramda')

module.exports.fnNums = (function () {

    const _isOdd = val => ( Number.isInteger(val) ) // value should be integer
                            ? (val % 2 !== 0 ) ? true : false : false   // value should not be even


    function isOdd (val) { return _isOdd(val)    }

    return {
        isOdd
    }
})();
