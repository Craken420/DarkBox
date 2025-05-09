/**
 * @file regex/match.js
 * @fileoverview This module provides reusable functions for searching and extracting specific information 
 * from INI configuration files or similar structures using regular expressions.
 * 
 * The functions allow detection of sections, keys, values, headers, and abbreviations
 * within a text, making it easier to analyze and process structured configurations.
 * 
 * Currying is used with Ramda to enable functional composition and code reuse.
 * 
 * Dependencies:
 * - ./patterns: contains regular expressions categorized by file type.
 * - make: helper module that generates dynamic regular expressions based on parameters.
 * - ramda: functional programming library.
 * 
 * @module regex.match
 */
import * as R from 'ramda';;
import patt from './patterns.js';

/**
 * Searches for and returns a full INI section by exact name.
 *
 * @param {string} nameComp - The exact name of the section to search for.
 * @param {string} txt - The content of the INI file.
 * @returns {string[]|false} - Matches for the section or `false` if not found.
 */
const findSectionByName = R.curry((nameComp, txt) =>
    (make.sectionByName(nameComp).test(txt))
        ? txt.match(make.sectionByName(nameComp))
        : false
);

/**
 * Searches for an INI section whose header name includes a file name as prefix.
 *
 * @param {string} nameComp - The base file name (without brackets).
 * @param {string} txt - The content of the INI file.
 * @returns {string[]|false} - Matches found or `false` if none.
 */
const findSectionByFileName = R.curry((nameComp, txt) => {
    if (make.sectionByNameFile(nameComp).test(txt)) {
        return txt.match(make.sectionByNameFile(nameComp));
    } else {
        return false;
    }
});

/**
 * Matches abbreviations surrounded by underscores.
 *
 * @param {string} txt - The text to analyze.
 * @returns {string[]|false} - Abbreviations found or `false`.
 */
const matchAbbreviationBetweenLowScripts = txt =>
    (patt.rdp.abbrBetweenUnderscores.test(txt))
        ? txt.match(patt.rdp.abbrBetweenUnderscores)
        : false;

/**
 * Matches all INI sections that do not contain comments.
 *
 * @param {string} txt - INI content to analyze.
 * @returns {string[]|false} - Sections found or `false`.
 */
const matchAllSections = txt =>
    (patt.iniFile.sectionWithoutComments.test(txt))
        ? txt.match(patt.iniFile.sectionWithoutComments)
        : false;

/**
 * Matches prefixes that appear before an abbreviation.
 *
 * @param {string} txt - The text to analyze.
 * @returns {string[]|false} - Prefixes found or `false`.
 */
const matchBeforeAbbreviation = txt => {
    if (patt.rdp.prefixBeforeAbbreviation.test(txt)) {
        return txt.match(patt.rdp.prefixBeforeAbbreviation);
    } else {
        return false;
    }
};

/**
 * Matches expressions that include the word "Wizard" within a specific situation.
 *
 * @param {string} txt - The text to analyze.
 * @returns {string[]} - Matches found.
 */
const matchElseWizardSituation = R.match(patt.rdp.expressionWithWizardInSituation);

/**
 * Matches full key-value pairs like `key=value`.
 *
 * @param {string} txt - INI content.
 * @returns {string[]|false} - Key-value matches or `false`.
 */
const matchFullKey = txt =>
    (patt.iniFile.fullKeyValue.test(txt))
        ? txt.match(patt.iniFile.fullKeyValue)
        : false;

/**
 * Extracts the value associated with a specific key.
 *
 * @param {string} field - The name of the key to search.
 * @param {string} txt - The content of the INI file.
 * @returns {string|undefined} - The value found or `undefined`.
 */
const matchKeyContent = R.curry((field, txt) => {
    if (make.keyContnt(field).test(txt)) {
        return txt.match(make.keyContnt(field)).join('');
    }
});

/**
 * Extracts all keys within the INI content.
 *
 * @param {string} txt - INI content.
 * @returns {string[]|false} - Key names or `false`.
 */
const matchKeyName = txt =>
    (patt.iniFile.keyName.test(txt))
        ? txt.match(patt.iniFile.keyName)
        : false;

/**
 * Matches section headers (e.g. [Section]), ensuring they are at the beginning of the line.
 *
 * @param {string} txt - Text to search in.
 * @returns {string[]|false} - Headers found or `false`.
 */
const matchSectionHeader = txt =>
    (patt.rdp.sectionHeader.test(txt.replace(/^/, '\n')))
        ? txt.replace(/^/, '\n').match(patt.rdp.sectionHeader)
        : false;

/**
 * Extracts the file name from an INI section header (e.g. [file.ini/Section]).
 *
 * @param {string} txt - The file content.
 * @returns {string[]|false} - File name found or `false`.
 */
const matchSectionNameFile = txt =>
    patt.iniFile.fileNameFromSectionHeader.test(txt) && txt.match(patt.iniFile.fileNameFromSectionHeader);

/**
 * Finds sections that do not match a specific name.
 *
 * @param {string} nameComp - Section name to exclude.
 * @param {string} txt - INI content.
 * @returns {string[]|false} - Non-matching sections or `false`.
 */
const matchSectionOutside = R.curry((nameComp, txt) => {
    if (make.sectionOutSide(nameComp).test(txt)) {
        return txt.match(make.sectionOutSide(nameComp));
    } else {
        return false;
    }
});

export {
    findSectionByName,
    findSectionByFileName,
    matchAbbreviationBetweenLowScripts,
    matchAllSections,
    matchBeforeAbbreviation,
    matchElseWizardSituation,
    matchFullKey,
    matchKeyContent,
    matchKeyName,
    matchSectionHeader,
    matchSectionNameFile,
    matchSectionOutside
};
