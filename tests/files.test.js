import { describe, it, expect } from 'vitest'; // O usa 'jest' si lo prefieres
import { promises as fs } from 'fs';
import path from 'path';

import { readFile, writeFile } from '../src/fs/index.js'; // Ajusta el path según tu estructura

const TEST_FILE = path.join(process.cwd(), '__tests__', 'test-file.txt');

describe('File System Utilities', () => {
  const sampleText = 'Hola mundo desde el test!';

  describe('writeFile', () => {
    it('should write data to a file', async () => {
      await writeFile(TEST_FILE, sampleText);
      const writtenContent = await fs.readFile(TEST_FILE, 'utf-8');
      expect(writtenContent).toBe(sampleText);
    });
  });

  describe('readFile', () => {
    it('should read data from a file', async () => {
      await fs.writeFile(TEST_FILE, sampleText, 'utf-8'); // Setup
      const content = await readFile(TEST_FILE);
      expect(content).toBe(sampleText);
    });
  });

  afterAll(async () => {
    // Cleanup test file after all tests
    try {
      await fs.unlink(TEST_FILE);
    } catch (err) {
      // Si ya fue eliminado o no existe, no pasa nada
    }
  });
});
