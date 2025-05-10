// __tests__/encoding.test.js

import { describe, it, expect, vi } from 'vitest';
import path from 'path';
import * as fs from 'fs';
import * as fnEncoding from '../src/encoding/index.js';

// Setup archivo temporal para pruebas de archivo
const TEST_FILE = path.join(process.cwd(), 'tests/__tests__', 'encoding-test.txt');
const sampleText = '¡Hola mundo!';
const sampleBase64 = Buffer.from(sampleText, 'utf-8').toString('base64');
const sampleEntities = '&#161;&#72;&#111;&#108;&#97;&#32;&#109;&#117;&#110;&#100;&#111;&#33;';

describe('Encoding Utilities', () => {
  describe('base64Encode', () => {
    it('should encode a string to Base64', () => {
      const result = fnEncoding.base64Encode(sampleText);
      expect(result).toBe(sampleBase64);
    });

    it('should throw if input is not a string', () => {
      expect(() => fnEncoding.base64Encode(123)).toThrow(TypeError);
    });
  });

  describe('base64Decode', () => {
    it('should decode a Base64 string', () => {
      const result = fnEncoding.base64Decode(sampleBase64);
      expect(result).toBe(sampleText);
    });

    it('should throw if input is not a string', () => {
      expect(() => fnEncoding.base64Decode(null)).toThrow(TypeError);
    });
  });

  describe('encodeEntity', () => {
    it('should encode a string into HTML numeric entities', () => {
      const result = fnEncoding.encodeEntity(sampleText);
      expect(result).toBe(sampleEntities);
    });
  });

  describe('decodeEntity', () => {
    it('should decode HTML numeric entities into a plain string', () => {
      const result = fnEncoding.decodeEntity(sampleEntities);
      expect(result).toBe(sampleText);
    });
  });

  describe('detectFileEncoding', () => {
    it('should detect encoding of a file', async () => {
      fs.writeFileSync(TEST_FILE, sampleText, 'utf-8');
      const encoding = fnEncoding.detectFileEncoding(TEST_FILE);
      expect(typeof encoding).toBe('string');
    });
  });

  describe('readFileWithEncoding', () => {
    it('should read file using specified encoding', () => {
      fs.writeFileSync(TEST_FILE, sampleText, 'utf-8');
      const result = fnEncoding.readFileWithEncoding(TEST_FILE, 'utf-8');
      expect(result).toBe(sampleText);
    });
  });

  describe('readFileWithDetectedEncoding', () => {
    it('should read file using detected encoding', () => {
      fs.writeFileSync(TEST_FILE, sampleText, 'utf-8');
      const result = fnEncoding.readFileWithDetectedEncoding(TEST_FILE);
      expect(result).toBe(sampleText);
    });
  });

  afterAll(() => {
    try {
      fs.unlinkSync(TEST_FILE);
    } catch (err) {}
  });
});
