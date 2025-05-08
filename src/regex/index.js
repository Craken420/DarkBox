/**
 * @fileoverview Regular expression utilities and patterns.
 * Provides reusable regex snippets and helper functions for matching,
 * validating, and extracting patterns from strings.
 * Useful for parsing, input validation, and text processing tasks.
 * 
 * @module regex
 */

module.exports = {
    // Regular expression to remove comments (single-line and multi-line) from a function
    stripComments: /((\/\/.*$)|(\/\*[\s\S]*?\*\/))/mg,
    
    // Regular expression to get the parameter names
    argumentNames: /([^\s,]+)/g,

    //Regular expression matching one or more non-alphanumeric characters.
    wordSplit: /[^a-zA-Z0-9]+/
};
