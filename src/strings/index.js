/**
 * @fileoverview Text comparison utilities for detecting word-level similarities and differences.
 * Ideal for linguistic analysis, version tracking, or text validation in JavaScript applications.
 * 
 * @module string
 */


/**
 * Recursively compares two strings at the word level, returning matches and unique segments.
 *
 * @param {string} text1 - The first string to compare.
 * @param {string} text2 - The second string to compare.
 * @returns {{
*   differences1: string[],
*   differences2: string[],
*   coincidences: string[]
* }} An object containing:
* - `differences1`: Words or phrases unique to `text1`.
* - `differences2`: Words or phrases unique to `text2`.
* - `coincidences`: Matching fragments found in both strings.
*/
const compareTextByPhraseSimilarity = (text1, text2) => {
 text1 = text1.trim();
 text2 = text2.trim();

 if (text1 && text2) {
   const words1 = text1.split(/\s+/);
   const words2 = text2.split(/\s+/);

   for (let i = Math.min(words1.length, words2.length); i > 0; i--) {
     for (let j = 0; j <= words1.length - i; j++) {
       const pattern = words1.slice(j, j + i).join(' ');
       const coincidenceIndex = text2.indexOf(pattern);

       if (coincidenceIndex >= 0) {
         const before = checkDifferences(
           words1.slice(0, j).join(' '),
           text2.slice(0, coincidenceIndex).trim()
         );

         const after = checkDifferences(
           words1.slice(j + i).join(' '),
           text2.slice(coincidenceIndex + pattern.length).trim()
         );

         return {
           differences1: before.differences1.concat(after.differences1),
           differences2: before.differences2.concat(after.differences2),
           coincidences: before.coincidences.concat([pattern], after.coincidences),
         };
       }
     }
   }
 }

 return {
   differences1: text1 ? [text1] : [],
   differences2: text2 ? [text2] : [],
   coincidences: [],
 };
};

/**
* Finds word groups of a specific length in `text1` that are not found in `text2`.
*
* @param {string} text1 - The base text to extract patterns from.
* @param {string} text2 - The reference text to search for matches.
* @param {number} length - The number of consecutive words to compare per group.
* @returns {string[]} An array of word fragments from `text1` not found in `text2`.
*/
const checkDifferencesByLength = (text1, text2, length) => {
 const words1 = text1.trim().split(/\s+/);
 if (words1.length < length) return [];

 const differences = [];

 for (let i = 0; i + length <= words1.length; i++) {
   const fragment = words1.slice(i, i + length).join(' ');
   if (!text2.includes(fragment)) {
     differences.push(fragment);
   }
 }

 return differences;
};

/**
 * Capitalizes the first character of a string.
 * @param {string} str - The string to capitalize.
 * @returns {string} A new string with the first letter capitalized.
 */
const capitalize = (str) => {
  if (typeof str !== 'string') {
    throw new TypeError('Expected a string');
  }
  return str.charAt(0).toUpperCase() + str.slice(1);
}

/**
 * Converts a string to kebab-case (lowercase words separated by hyphens).
 * @param {string} str - The string to convert.
 * @returns {string} The kebab-cased string.
 */
const kebabCase = (str) => {
  return str
    .split(WORD_SPLIT_REGEX)
    .filter(Boolean)
    .map(word => word.toLowerCase())
    .join('-');
}

/**
 * Converts a string to camelCase.
 * @param {string} str - The string to convert.
 * @returns {string} The camelCased string.
 */
const camelCase = (str) => {
  return str
    .split(WORD_SPLIT_REGEX)
    .filter(Boolean)
    .map((word, index) =>
      index === 0
        ? word.toLowerCase()
        : word.charAt(0).toUpperCase() + word.slice(1).toLowerCase()
    )
    .join('');
}

const getTrailingStringDifference = (shorter, longer) => {
  const extractNonMatchingSuffix = function(base, extended) {
    const baseChars = base.split('');
    const extendedChars = extended.split('');
    let index = 0;

    baseChars.forEach((char) => {
      if (extendedChars[index] === char) {
        extendedChars.splice(index, 1);
      } else {
        index += 1;
      }
    });

    if (index > 0) {
      extendedChars.splice(index, extendedChars.length);
    }

    return extendedChars.join('');
  };

  return shorter.length < longer.length
    ? extractNonMatchingSuffix(shorter, longer)
    : extractNonMatchingSuffix(longer, shorter);
}

module.exports = {
  compareTextByPhraseSimilarity,
  checkDifferencesByLength,
  capitalize,
  kebabCase,
  camelCase,
  getTrailingStringDifference
};
