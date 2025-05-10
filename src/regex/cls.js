
/**
 * @file regex/cls.js
 * @fileoverview This module contains utility functions for manipulating and cleaning text,
 * particularly for processing file paths, SQL scripts, RDP configuration files, and general text.
 *
 * @module regex.cls
 */

import * as R from 'ramda';
import * as patt from './patterns.js';
import * as add from './add.js';

const iniFile = {
    /**
     * Removes inline comments from INI-style RDP configuration files.
     * @param {string} txt - The text containing comments.
     * @returns {string} The text without comments.
     */
    removeComments: R.replace(patt.iniFile.comments, ''),

    /**
     * Removes comparison lines that are found outside the expected header section.
     * @param {string} nameFileInHead - The expected header name.
     * @param {string} txt - The text to search in.
     * @returns {string} The modified text with out-of-header comparisons removed.
     */
    removeComparisonsOutsideHeader: (nameFileInHead, txt) => {
        if (make.cmpOutSide(nameFileInHead).test(txt)) {
        return txt.replace(make.cmpOutSide(nameFileInHead), '');
        }
        return txt;
    },

    /**
     * Removes all content outside a defined header section.
     * @param {string} nameFileInHead - The expected header name.
     * @param {string} txt - The full configuration text.
     * @returns {string} Cleaned text with content outside the header removed.
     */
    removeContentOutsideHeader: (nameFileInHead, txt) => {
        if (make.outSide(nameFileInHead).test(txt)) {
        return txt.replace(make.outSide(nameFileInHead), '');
        }
        return txt;
    },

    /**
     * Removes keys from INI files that are not under any section header.
     * @param {string} txt - The text containing orphaned keys.
     * @returns {string} The text with those keys removed.
     */
    removeHeaderlessComparisons: txt => txt.replace(patt.iniFile.keysWithoutHeader, '')
}

const path = {
    /**
     * Removes the path from the beginning of the string up to (and including) the file extension.
     * @param {string} txt - A string containing a file path.
     * @returns {string} The cleaned string with path and extension removed.
     */
    removePathUntilExtension: txt => txt.replace(patt.pathUntilExt, ''),

    /**
     * Removes the root path portion from a full file path.
     * @param {string} txt - The full file path.
     * @returns {string} The file path with the root portion removed.
     */
    removeRootFromPath: txt => txt.replace(patt.file.pathRoot, '')
}

const sql = {
    /**
     * Removes ANSI control settings from SQL scripts.
     * @param {string} txt - SQL script.
     * @returns {string} Script without ANSI settings.
     */
    removeAnsiControlChars: R.replace(patt.sql.ANSISettings, ''),

    /**
     * Removes SQL single-line comments (e.g., `-- comment`) from the script.
     * @param {string} txt - SQL script with line comments.
     * @returns {string} Script without single-line comments.
     */
    removeLineComments: R.replace(patt.sql.lineComments, ''),

    /**
     * Recursively removes multi-line SQL comments (/ * ... * /) from the script.
     * Handles nested or repeated blocks.
     * @param {string} txt - SQL script with multiline comments.
     * @returns {string} Script with all multiline comments removed.
     */
    removeMultilineCommentsRecursively: function clsMultiLineComments(txt) {
        txt = txt.replace(patt.sql.mltilineComments, '');
        if (patt.sql.mltilineComments.test(txt)) {
        return clsMultiLineComments(txt);
        }
        return txt;
    },

    /**
     * Removes SQL `WITH (NOLOCK)` clauses from queries.
     * @param {string} txt - SQL query.
     * @returns {string} Query without NOLOCK clauses.
     */
    removeWithNoClauses: R.replace(patt.sql.detectNoLockHints, ' ')
}


const txt = {
    /**
     * Normalizes multiple spaces to a single space on each line.
     * @param {string} input - Multi-line string.
     * @returns {string} Normalized string with single spaces.
     */
    normalizeSpacesInLines: R.pipe(
        R.split(/\r\n|\r|\n/g),
        R.map(R.replace(/\s+/g, ' ')),
        R.join('\n')
    ),

    /**
     * Removes all ampersands (&) from a string.
     * @param {string} input - String with ampersands.
     * @returns {string} String without ampersands.
     */
    removeAmpersands: R.replace(/&/g, ''),

    /**
     * Removes all empty lines from a multi-line string.
     * @param {string} input - Multi-line string with potential empty lines.
     * @returns {string} String with empty lines removed.
     */
    removeEmptyLines: R.pipe(
        R.split(/\r\n|\r|\n/g),
        R.filter(Boolean),
        R.join('\n')
    ),

    /**
     * Removes all tab characters from a string.
     * @param {string} input - String with tabs.
     * @returns {string} String without tabs.
     */
    removeTabs: R.replace(/\t+/g, ''),

    /**
     * Trims whitespace at the start and end of each line in a multi-line string.
     * @param {string} input - Multi-line string.
     * @returns {string} Normalized string.
     */
    trimEachLine: R.pipe(
        R.split(/\r\n|\r/g),
        R.map(R.trim),
        R.join('\n')
    )
}

const rdp = {
    /**
     * Cleans and normalizes RDP text using a functional pipeline.
     * Removes ANSI settings, NOLOCK hints, comments, tabs, and extra spacing.
     * Converts the result to lowercase.
     * @param {string} txt - Raw RDP configuration text.
     * @returns {string} Cleaned and normalized text.
     */
    cleanText: R.pipe(
        sql.removeAnsiControlChars,
        sql.removeWithNoClauses,
        sql.removeMultilineCommentsRecursively,
        sql.removeLineComments,
        txt.removeTabs,
        txt.trimEachLine,
        txt.normalizeSpacesInLines,
        txt.removeEmptyLines,
        add.cmpEnterInHead,
        R.toLower
    ),

    /**
     * Removes any text after a defined abbreviation suffix in an object line.
     * @param {string} txt - The object text with abbreviation suffix.
     * @returns {string} The cleaned object text.
     */
    removeAfterAbbreviationInObj: txt => txt.replace(patt.rdp.postAbbreviationSuffix, ''),

    /**
     * Removes -specific comparisons that appear outside any header.
     * @param {string} txt - Text containing  INI configuration.
     * @returns {string} Cleaned text.
     */
    removeHeaderlessComparisons: txt => txt.replace(patt.iniFile.keysWithoutHeader, '')
}

export {
    iniFile,
    path,
    rdp,
    sql,
    txt
}