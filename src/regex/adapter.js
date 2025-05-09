/**
 * @file regex/adapter.js
 * @fileoverview Utility functions to adapt or convert strings to regular expressions,
 * or to structured formats for use with pattern-based operations.
 *
 * This module is useful for transforming inputs (such as raw strings or simple configs)
 * into formats that are safe and optimized for pattern matching using RegExp.
 * 
 * @module regex.adapter
 */

/**
 * Converts INI-style text to object-like format.
 * Replaces '=' with ':', handles brackets, slashes, and removes unwanted characters.
 *
 * @param {string} txt - The input text in INI format.
 * @returns {string} The converted text in object-like format.
 *
 * @example
 * // returns 'config.ini:Database\nhost: localhost\nport: 3306'
 * toObject('[config.ini/Database]\nhost=localhost\nport=3306');
 */
function toObject(txt) {
    txt = txt.replace(/=/g, ':')
        .replace(/\[.*?(?=\/)|\]/g, '')
        .replace(/(?<=\/\w+)\./g, ':')
        .replace(/\//, '')
        .replace(/[^\w:,\.]/gm, "")
        .replace(/,/g, ', ');
    return txt;
}

/**
 * Escapes special characters in a string for use in regular expressions.
 * Replaces characters like `\`, `[`, `]`, `(`, `)`, `{`, `}`, `+`, `*`, `$`, `.` and others.
 *
 * @param {string} txt - The string to escape for regex.
 * @returns {string} The escaped string, ready for use in regular expressions.
 *
 * @example
 * // returns '\\[MySection\\]'
 * toRegExp('[MySection]');
 */
function toRegExp(txt) {
    txt = txt.replace(/\\/g, '\\\\')
        .replace(/\[/g, '\\[').replace(/\]/g, '\\]')
        .replace(/\(/g, '\\(').replace(/\)/g, '\\)')
        .replace(/\{/g, '\\{').replace(/\}/g, '\\}')
        .replace(/\(\?/g, '\\(\\?')
        .replace(/\+/g, '\\+')
        .replace(/\n/g, '\\n')
        .replace(/\s/g, '\\s')
        .replace(/\*/g, '\\*')
        .replace(/\$/g, '\\$')
        .replace(/\./g, '\\.');
    return txt;
}

export {
    toObject,
    toRegExp
};