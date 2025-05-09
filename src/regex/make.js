/**
 * @file regex/make.js
 * @fileoverview This module provides a set of functions to generate regular expressions dynamically,
 * with a focus on parsing and manipulating INI configuration files and SQL statements.
 *
 * Each function returns a RegExp instance tailored to match specific structures,
 * such as full INI sections, section headers, key-value pairs, or SQL conditions involving NULL.
 *
 * Dependencies:
 * - Relies on `regex.adapter` for escaping and adapting strings to safe regex patterns.
 * 
 * @module regex.make
 */

import adapt from './adapter.js';

/**
 * Matches an INI section and its content when the section header includes a filename as prefix.
 * Example:
 *   INI:
 *     [config.ini/Database]
 *     host=localhost
 *
 *   iniFileSectionByBaseFile('config.ini') will match:
 *     [config.ini/Database]
 *     host=localhost
 *
 * @param {string} nameFile - The prefix (usually a filename) before the slash.
 * @returns {RegExp}
 */
const iniFileSectionByBaseFile = nameFile =>
    new RegExp(
        `^\\[${adapt.toRegExp(nameFile)}\\/.*?\\]((\\n|\\r)(?!^\\[.+?\\]).*?$)+`,
        `gm`
);

/**
 * Matches a section in an INI file by name using adaptation.
 * Example:
 *   Input INI content:
 *     [MySection]
 *     key=value
 *
 *   matchFullSection('MySection') will match:
 *     [MySection]
 *     key=value
 *
 * @param {string} nameSect - The name of the section.
 * @returns {RegExp}
 */
const matchFullSection = (nameSect) =>
    new RegExp(
      `\\[\\b${adapt.toRegExp(nameSect)}\\b\\]((\\n|\\r)(?!^\\[.+?\\]).*?$)+`,
      'gm'
    );
 
/**
 * Matches an INI section and its full content by name, without applying any adaptation to the name.
 *
 * Example:
 *   INI:
 *     [MySection]
 *     key1=value1
 *     key2=value2
 *
 *   matchFullSectionRaw('MySection') will match:
 *     [MySection]
 *     key1=value1
 *     key2=value2
 *
 * @param {string} nameSect - The section name to match literally.
 * @returns {RegExp}
 */
const matchFullSectionRaw = nameSect =>
    new RegExp(`\\[\\b${nameSect}\\b\\]((\\n|\\r)(?!^\\[.+?\\]).*?$)+`, `gm`);

/**
 * Extracts the value of a specific field in a section.
 * Example:
 *   INI content:
 *     myField=someValue
 *
 *   matchKeyValue('myField') will match "someValue"
 *
 * @param {string} field
 * @returns {RegExp}
 */
const matchKeyValue = (field) =>
    new RegExp(`(?<=^${adapt.toRegExp(field)}=).*?(?=(\\r|\\n|$))`, 'gm');

/**
 * Matches all sections that are not the given one.
 * Example:
 *   If nameSect is "Config", this will match:
 *     [OtherSection/Sub]
 *     key=val
 *
 *   But it will skip:
 *     [Config/Sub]
 *     key=val
 *
 * @param {string} nameSect
 * @returns {RegExp}
 */
const matchOtherSections = (nameSect) =>
    new RegExp(
      `\\[(?!(\\b${adapt.toRegExp(nameSect)}\\b)).*?\\/.*?\\]((\\n|\\r)(?!^\\[.+?\\]).*?$)+`,
      'gim'
    );

/**
 * Checks if a section exists in the INI file based on joined section name parts.
 * Useful when section names are built dynamically.
 *
 * Example:
 *   nameSect = ['User', 'Config']
 *   Matches:
 *     [UserConfig]
 *
 * @param {string[]} nameSect - Array of strings to join as a single section name.
 * @returns {RegExp}
 */
const matchSectionHeader = nameSect =>
    new RegExp(`^\\[${adapt.toRegExp(nameSect.join(''))}\\]`, `gm`);

/**
 * Matches an INI section header exactly by name.
 *
 * Example:
 *   INI:
 *     [MySection]
 *
 *   iniFileNameSectionNoRgx('MySection') will match:
 *     [MySection]
 *
 * @param {string} nameSect - The section name.
 * @returns {RegExp}
 */
const matchSectionHeaderRaw = nameSect =>
    new RegExp(`^\\[\\b${nameSect}\\b\\]`, `gm`);

/**
 * Matches content that appears specifically at the end of a named INI section.
 * Useful when parsing or injecting data after a section ends.
 *
 * Example:
 *   INI:
 *     [FinalBlock]
 *     foo=bar
 *
 *   sectionAtEnd('FinalBlock') will match content right after:
 *     [FinalBlock]
 *     foo=bar
 *
 * @param {string} nameSect - The name of the section.
 * @returns {RegExp}
 */
const sectionAtEnd = nameSect =>
    new RegExp(`(?<=\\[${nameSect}\\](\\r\\n(?!^\\[.+?\\]).*?$)+)`, `m`);

/**
 * Matches SQL conditions that compare something to NULL.
 * Example:
 *   SQL:
 *     user.status = NULL
 *
 *   sqlCompareWithNull('status') will match:
 *     status = NULL
 *
 * @param {string} cond
 * @returns {RegExp}
 */
const sqlCompareWithNull = (cond) =>
    new RegExp(
      `\\b${cond}\\b[\\s\\n]*?[\\w.\\(\\)_@-]*?[\\s\\n]*?(=|<>|>|<|>=|<=|!=|!<|!>)[\\s\\n]*?\\bNULL\\b`,
      'gi'
    );

/**
 * Matches the comparison operator used in a NULL comparison for a specific condition.
 *
 * Example:
 *   SQL:
 *     user.status = NULL
 *
 *   sqlSymbolCmprNullIn('status') will match:
 *     =
 *
 * @param {string} cond - The condition/field name to match.
 * @returns {RegExp}
 */
const sqlCompareSymbolWithNull = cond => new RegExp(
    `(?<=\\b${cond}\\b[\\s\\n]*?[\\w.\\(\\)_@-]*?[\\s\\n]*?)(=|<>|>|<|>=|<=|!=|!<|!>)[\\s\\n]*?\\bNULL\\b`,
    `gi`
);

export {
    iniFileSectionByBaseFile,
    matchFullSection,
    matchFullSectionRaw,
    matchKeyValue,
    matchOtherSections,
    matchSectionHeader,
    matchSectionHeaderRaw,
    sectionAtEnd,
    sqlCompareWithNull,
    sqlCompareSymbolWithNull
}
