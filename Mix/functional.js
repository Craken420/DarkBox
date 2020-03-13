const R = require('ramda')

module.exports.pfn = (function () {

    const _seq = function () {
        const funcs = Array.prototype.slice.call(arguments);
        return function (val) {
            funcs.forEach(function (fn) {
                fn(val)
            });
        }
    }

    const _fork = function (fnJoin, fn1, fn2) {
        return function(val) {
            return fnJoin(fn1(val), fn2(val));
        }
    }

    const _alt = R.curry((fn1, fn2, val)  => fn1(val) || fn2(val));

    const _deepFreeze = obj => {
        if (isObject(obj) && !Object.isFrozen(obj)) {
            Object.keys(obj).forEach(name => _deepFreeze(obj[name]));
            Object.freeze(obj);
        }
        return obj;
    }

    const _Tuple = function () {
        const typeInfo = Array.prototype.slice.call(arguments, 0);
        const _T = function () {
            const values = Array.prototype.slice.call(arguments, 0);

            if (values.some((val) => val === null || val === undefined)) {
                throw new ReferenceError('Tuples may not have any null values');
            }

            if (values.length !== typeInfo.length) {
                throw new TypeError('Tuple arity does not match its prototype');
            }

            values.map(function (val, index) {
                this['_' + (index + 1)] = checkType(typeInfo[index])(val);
            }, this);

            Object.freeze(this);
        };

        _T.prototype.values = function () {
            return Object.keys(this).map(function (k) {
                return this[k];
            })
        }
        return _T;
    }

    function seq () { return _seq() }
    function fork (fnJoin, fn1, fn2) { return _fork(fnJoin)(fn1)(fn2) }
    function alt (fn1, fn2, val) { return _alt(fn1)(fn2)(val) }
    function Tuple () { return _Tuple() }
    function deepFreeze (obj) { return _deepFreeze(obj)}

    return {
        seq,
        fork,
        alt,
        Tuple,
        deepFreeze
    }
})();