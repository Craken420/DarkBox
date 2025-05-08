/**
 * @fileoverview Data encoding and decoding utilities.
 * Supports transformations such as Base64, UTF-8, hexadecimal, and other formats.
 * 
 * @module encoding
 */

/**
 * Encodes a string into its HTML entity representation.
 * Example: "ABC" → "&#65;&#66;&#67;"
 * 
 * @param {string} str - The input string to encode.
 * @returns {string} The encoded HTML entity string.
 */
const encodeEntity = (str) => {
    const result = [];
    for (let i = str.length - 1; i >= 0; i--) {
      result.unshift(`&#${str.charCodeAt(i)};`);
    }
    return result.join('');
}

/**
 * Decodes a string containing HTML numeric entities into plain text.
 * Example: "&#65;&#66;&#67;" → "ABC"
 * 
 * @param {string} str - The encoded entity string to decode.
 * @returns {string} The decoded plain text string.
 */
const decodeEntity = (str) => {
    return str.replace(/&#(\d+);/g, (_, code) => String.fromCharCode(code));
}

/**
 * Detects the character encoding of a file.
 *
 * @param {string} filePath - Path to the file.
 * @returns {string} - Detected encoding.
 */
const detectFileEncoding = (filePath) => chardet.detectFileSync(filePath);

/**
 * Reads a file and returns its content using the detected encoding.
 *
 * @param {string} filePath - Path to the file.
 * @returns {string} - Decoded text content.
 */
const readFileWithDetectedEncoding = (filePath) => {
    const encoding = detectFileEncoding(filePath);
    return iconv.decode(fs.readFileSync(filePath), encoding);
}

/**
 * Reads a file and returns its content using a specified encoding.
 *
 * @param {string} filePath - Path to the file.
 * @param {string} targetEncoding - Target encoding (e.g., 'utf-8', 'latin1').
 * @returns {string} - Decoded content.
 */
const readFileWithEncoding = (filePath, targetEncoding) => iconv.decode(fs.readFileSync(filePath), targetEncoding);

/**
 * Encodes a string to Base64.
 * @param {string} str - The input string to encode.
 * @returns {string} The Base64 encoded string.
 */
const base64Encode = (str) => {
    if (typeof str !== 'string') {
      throw new TypeError('Expected a string');
    }
    return Buffer.from(str, 'utf-8').toString('base64');
}
  
  /**
   * Decodes a Base64 encoded string.
   * @param {string} b64 - The Base64 string to decode.
   * @returns {string} The decoded string.
   */
const base64Decode = (b64) => {
    if (typeof b64 !== 'string') {
      throw new TypeError('Expected a Base64 string');
    }
    return Buffer.from(b64, 'base64').toString('utf-8');
}

module.exports = {
    encodeEntity,
    decodeEntity,
    detectFileEncoding,
    readFileWithDetectedEncoding,
    readFileWithEncoding,
    base64Encode,
    base64Decode
};