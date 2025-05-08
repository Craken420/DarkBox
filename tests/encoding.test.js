import { describe, it, expect } from 'vitest'; // o de 'jest'
import { encodeEntity, decodeEntity } from '../src/encoding/index.js';

describe('Encoding Utilities', () => {

  describe('Encode entity Utilities', () => {
    it('should encode string into HTML entities', () => {
      const input = "Hello";
      const expected = "&#72;&#101;&#108;&#108;&#111;";
      expect(encodeEntity(input)).toBe(expected);
    });
  });

  describe('Encode entity Utilities', () => {
    it('should decode HTML entities into string', () => {
      const input = "&#72;&#101;&#108;&#108;&#111;";
      const expected = "Hello";
      expect(decodeEntity(input)).toBe(expected);
    });
  });

  describe('Encode entity Utilities', () => {
    it('should handle empty strings correctly', () => {
      expect(encodeEntity("")).toBe("");
      expect(decodeEntity("")).toBe("");
    });
  });

  describe('Encode entity Utilities', () => {
    it('should handle special characters', () => {
      const input = "¡Hi!";
      const encoded = encodeEntity(input);
      const decoded = decodeEntity(encoded);
      expect(decoded).toBe(input);
    });
  });

  describe('Encode entity Utilities', () => {
    it('base64Encode and base64Decode should be inverses', () => {
      const text = 'Test123';
      const encoded = encoding.base64Encode(text);
      expect(encoding.base64Decode(encoded)).toBe(text);
    });
  });

  describe('Encode entity Utilities', () => {
    it('base64Encode should correctly encode a string', () => {
      expect(encoding.base64Encode('Hello')).toBe(Buffer.from('Hello').toString('base64'));
    });
  });
});
