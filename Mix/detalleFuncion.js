// Estos métodos básicamente parsean la función para obtener los datos (utilizan function.toString para hacerlo). Incluye algo de soporte de ECMAScript 2015.

var funcion = (function () {
    'use strict';

    var stripComments = /((\/\/.*$)|(\/\*[\s\S]*?\*\/))/mg,
        argumentNames = /([^\s,]+)/g,
        funcion = {};

    /**
     * Checks if 'expr' is a function 
     * @param {} expr 
     * @returns {} 
     */
    function isFunction(expr) {
        return typeof expr === 'function';
    }

    /**
     * Gets the function parameter names as an Array.
     * 
     * usage example: getParameterNames(function (a,b,c){}); // ['a','b','c']
     * @param {} func the function. 
     * @returns {} An ordered array of string with the parameters names, or an empty array if the function has no parameters.
     */
    function getParameterNames(func) {
        var fnStr = func.toString().replace(stripComments, '');
        var result = fnStr.slice(fnStr.indexOf('(') + 1, fnStr.indexOf(')')).match(argumentNames);
        if (result === null)
            result = [];
        return result;
    }

    /**
     * Gets the function name.
     * 
     * @param {} func the function. 
     * @returns {} the name of the function, empty string if is an anonymous function. 
     */
    function getFunctionName(func) {
        if (!isFunction(func)) throw new TypeError('"func" must be a function.');
        // ECMAScript 2015
        if (func.name) {
            return func.name;
        }
        // old fashion way
        var fnStr = func.toString().substr('function '.length),
            result = fnStr.substr(0, fnStr.indexOf('('));
        return result;
    }

    // Module Exports
    funcion.isFunction = isFunction;
    funcion.getFunctionName = getFunctionName;
    funcion.getParameterNames = getParameterNames;
    return funcion;
}());

module.exports.funcion = funcion
// Retorna el nombre de la funcion:
// console.log(funcion.getFunctionName(function myFunction(a, b, c){}))// que retorna "myFunction" o una cadena vacía si es una función anónima.

// Retorna el nombre de los parámetros:

// console.log(funcion.getParameterNames(function myFunction(a, b, c){}))// que retorna "[a, b, c]"
